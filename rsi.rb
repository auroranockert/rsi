require 'pp'
require 'erb'
require 'nokogiri'
require 'fileutils'

Root = File.dirname(File.absolute_path(__FILE__))

module RSI
  class Node
    attr_reader :context, :parent, :node
    attr_accessor :children, :next_sibling, :previous_sibling

    def initialize(context, parent, node, *args)
      @context, @parent, @node, @children = context, parent, node, []

      self.prepare(*args)
    end

    def prepare
    end

    def path
      self.parent.path
    end

    def dirname
      self.parent.dirname
    end

    def create_children(mapping)
      children = self.node.children.map do |c|
        if c.element?
          klass = mapping[c.name.intern]

          raise "Found unexpected element #{c.name.intern.inspect} in #{self.node.css_path} (supported are #{mapping})" unless klass

          klass.new(self.context, self, c)
        end
      end.compact

      children.each.with_index do |c, i|
        c.next_sibling = children[i + 1] if i < children.length
        c.previous_sibling = children[i - 1] if i > 0
      end

      @children = children
    end

    def render(filename, indent = 0)
      t = ERB.new(File.read("#{Root}/templates/#{filename}.rs.erb"), nil, ">-")
      t.filename = "#{Root}/templates/#{filename}.rs.erb"
      t.result(binding).indent(indent)
    end
  end

  module Type
    class Type
      attr_reader :path

      def uses
        []
      end

      def as_struct_field(relative)
        self.lookup_relative(relative)
      end

      def as_native_result_prototype(relative)
        self.lookup_relative(relative)
      end

      def as_native_result(name, relative)
        "#{name}"
      end

      def as_native_argument_prototype(relative)
        self.lookup_relative(relative)
      end

      def as_foreign_argument_prototype(arg)
        t = self.lookup_relative(arg.path)

        if self.pass_by_ref?
          if arg.immutable?
            "*#{t}"
          else
            "*mut #{t}"
          end
        else
          t
        end
      end

      def as_foreign_argument(arg)
        arg.name
      end

      def as_foreign_out_argument(name)
        "#{name}"
      end

      def as_foreign_result_prototype(relative)
        self.lookup_relative(relative)
      end

      def pass_by_ref?
        false
      end

      def lookup_relative(relative)
        s, r = self.path.split('::'), relative.split('::')

        name = s.pop

        if s == r
          name
        elsif s[0] == r[0]
          result = if s.length > r.length
            s.zip(r)
          else
            r.zip(s).map { |a, b| [b, a] }
          end.drop_while { |a, b| a == b }

          prefix = result.map { |a, b| 'super' if b }.compact
          suffix = result.map { |a, b| a if a }.compact

          (prefix + suffix + [name]).join('::')
        else
          self.path
        end
      end
    end
  end

  class Context < RSI::Node
    attr_reader :types, :name, :output

    def initialize(rsi, output, load_paths = [FileUtils.pwd])
      @load_paths, @output, @types = load_paths, output, {}

      @document, @dirname = *self.find_rsi(rsi)
      @context, @node = self, @document.at_xpath('/rsi')

      RSI::Type::CScalar.register_types(self)
      RSI::Type::CString.register_types(self)
      RSI::Type::RustScalar.register_types(self)

      RSI::Type::Vec.register_types(self)
      RSI::Type::VecLength.register_types(self)

      self.prepare
    end

    def dirname
      @dirname
    end

    def prepare
      raise "Could not find root in RSI" unless @node

      @name = @node['name']

      self.create_children(dependency: RSI::Dependency, type: RSI::Ty, enum: RSI::Enum, struct: RSI::Struct, mod: RSI::Module)
    end

    def find_rsi(name, relative = nil)
      relative ||= @load_paths.find do |path|
        File.exists? "#{path}/#{name}"
      end

      if relative
        filename = "#{relative}/#{name}"

        return Nokogiri::XML(File.read(filename)), File.dirname(filename)
      else
        raise "Unknown RSI #{name}, could not find in #{@load_paths.inspect}"
      end
    end

    def path
      self.name
    end

    def modules
      self.children.select { |c| RSI::Module === c }
    end

    def register_type(name, type)
      self.types[name] = type
    end

    def lookup_type(name, parent)
      case t = self.types[name]
      when Class
        t.new(parent)
      else
        t
      end
    end

    def to_code
      output = self.render('rsi')
      File.open("#{@output}/#{self.name}.rs", 'w+') do |f|
        f.write(output)
      end
    end
  end
end

class Object
  def try(method, *a, &b)
    public_send(method, *a, &b) if self.respond_to?(method)
  end

  def try_or(method, *a)
    if self.respond_to? method
      public_send(method, *a)
    else
      yield
    end
  end
end

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def indent(indent)
    self.gsub(/^/, "  " * indent)
  end
end

Dir.glob("#{Root}/types/**/*.rb").map { |f| require f }
Dir.glob("#{Root}/nodes/{module,dependency,enum,struct,function,type}.rb").map { |f| require f }

# $enable_tracing = false
# $trace_out = open('trace.txt', 'w')
#
# set_trace_func proc { |event, file, line, id, binding, classname|
#   if $enable_tracing && event == 'call'
#     $trace_out.puts "#{file}:#{line} #{classname}##{id}"
#   end
# }
#
# $enable_tracing = true

context = RSI::Context.new(ARGV[0], ARGV[1])
context.to_code