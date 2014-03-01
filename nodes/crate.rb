module RSI
  class Crate
    include SAXMachine

    attribute :name

    elements :fn, as: 'fns', class: RSI::Fn
    elements :enum, as: 'enums', class: RSI::Enum
    elements :module, as: 'modules', class: RSI::Module
    elements :struct, as: 'structs', class: RSI::Struct
    elements :gobject, as: 'gobjects', class: RSI::GObject
    elements :library, as: 'libraries', class: RSI::Library
    elements :implementation, as: 'implementations', class: RSI::Implementation

    attr_accessor :root, :output, :filename, :machine

    def self.get_xml(root, file)
      f = Nokogiri::XML(File.read("#{root}/#{file}.xml"))

      f.xpath('//module[@file]').each do |m|
        m.replace(get_xml(root, m['file']).root)
      end

      f
    end

    def self.from_rsi(filename, machine, output)
      root = File.dirname(filename)
      xml_string = self.get_xml(root, File.basename(filename)).to_s

      self.parse(xml_string).tap do |c|
        c.root = root
        c.output = output
        c.machine = machine
        c.filename = filename
      end
    end

    def crate
      self
    end

    def print(string = '', indent = 0)
      unless string == ''
        @output.puts("#{'  ' * indent}#{string}")

        return true
      else
        @output.write("\n")

        return false
      end
    end

    def print_list(list, &block)
      anything_printed = false

      list.each do |e|
        if yield e
          anything_printed = true
          self.print
        end
      end

      @output.seek(-1, IO::SEEK_CUR) if anything_printed

      return anything_printed
    end

    def type_from_string(string)
      @machine.type_from_string(string)
    end

    def argument_transformer_from_name(transformer, arg)
      klass = {
        'zero' => RSI::ArgumentTransformer::Zero,
        'opaque' =>  RSI::ArgumentTransformer::Opaque,
        'cstring' => RSI::ArgumentTransformer::CString,
        'identity' => RSI::ArgumentTransformer::Transformer,
        'to-mut-ref' => RSI::ArgumentTransformer::ToMutRef,
        'gobject' => RSI::ArgumentTransformer::GObject,
        'vec' => RSI::ArgumentTransformer::Vec,
        'vec-zero' => RSI::ArgumentTransformer::VecZero,
        'vec-length' => RSI::ArgumentTransformer::VecLength
      }[transformer || 'identity']

      if klass
        klass.new(self, arg)
      else
        raise "Unknown argument transformer… #{transformer.inspect}"
      end
    end

    def result_transformer_from_name(transformer, arg)
      klass = {
        'out' => RSI::ResultTransformer::Out,
        'clone' => RSI::ResultTransformer::Clone,
        'compare' => RSI::ResultTransformer::Compare,
        'cstring' => RSI::ResultTransformer::CString,
        'foreign' => RSI::ResultTransformer::Foreign
      }[transformer || 'foreign']

      if klass
        klass.new(self, arg)
      else
        raise "Unknown result transformer… #{transformer.inspect}"
      end
    end

    def print_code
      self.print_list([self.modules.select { |m| m.extern? }, self.libraries, self.enums, self.structs, self.fns, self.gobjects, self.implementations, self.modules.reject { |m| m.extern? }]) do |c|
        self.print_list(c) do |m|
          m.print_code(0)
        end
      end

      if self.fns.length > 0
        self.print
        self.print('extern {', 0)
        self.fns.each { |f| f.print_extern(1) }
        self.print('}', 0)
      else
        @output.truncate(@output.pos)
      end
    end
  end
end