require 'xml/mapping'

module RSI
  def self.fail! message
    $stderr.puts message
    exit(1)
  end

  def self.indent(string, n)
    "  " * n + string.gsub("\n", "\n" + "  " * n) + "\n"
  end

  def self.type_from_string(type)
    case type
    when 'f32', 'single', 'float'
      RSI::FloatType.new(32)
    when 'f64', 'double'
      RSI::FloatType.new(64)
    when /\A{([\w]+)}\z/
      RSI::StructType.new($1)
    when /\A\[([\w]+)\]\z/
      RSI::EnumType.new($1)
    else
      raise "Unknown type… #{type}"
    end
  end

  def self.argument_transformer_from_name(transformer, arg)
    case transformer
    when 'identity'
      RSI::IdentityTransformer.new(arg)
    when 'zero'
      RSI::ZeroTransformer.new(arg)
    when 'to-mut-ref'
      RSI::ToMutRefTransformer.new(arg)
    when 'from-mut-ref'
      RSI::FromMutRefTransformer.new(arg)
    else
      raise "Unknown transformer… #{transformer}"
    end
  end

  def self.result_transformer_from_name(transformer, arg)
    case transformer
    when 'foreign'
      RSI::ForeignTransformer.new(arg)
    when 'out'
      RSI::OutTransformer.new(arg)
    else
      raise "Unknown transformer… #{transformer}"
    end
  end

  class StructType
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def to_s
      @name
    end
  end

  class EnumType
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def to_s
      @name
    end
  end

  class IntType
    def initialize(signed, bits)
      @signed, @bits = signed, bits
    end

    attr_reader :signed, :bits

    def to_s
      case self.bits
      when 64
        self.signed ? 'i64' : 'u64'
      when 32
        self.signed ? 'i32' : 'u32'
      when 16
        self.signed ? 'i16' : 'u16'
      when 8
        self.signed ? 'i8' : 'u8'
      else
        raise "Unknown bit-length for integer #{self.bits}"
      end
    end
  end

  class FloatType
    def initialize(bits)
      @bits = bits
    end

    attr_reader :bits

    def to_s
      case self.bits
      when 64
        'f64'
      when 32
        'f32'
      else
        raise "Unknown bit-length for float #{self.bits}"
      end
    end
  end
end

$:.unshift(File.dirname(__FILE__))

require 'argument-transformers/zero'
require 'argument-transformers/identity'
require 'argument-transformers/to-mut-ref'

require 'result-transformers/out'
require 'result-transformers/foreign'

require 'nodes/enum'
require 'nodes/struct'
require 'nodes/implementation'
require 'nodes/module'
require 'nodes/library'

require 'nodes/crate'

puts RSI::Crate.load_from_file(ARGV[0]).to_code