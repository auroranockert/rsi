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
    when /([\w:{}\[\]]+)\?\z/
      RSI::OptionType.new(RSI.type_from_string($1))
    when 'i8', 'char'
      RSI::IntType.new(true, 8)
    when 'i16', 'short'
      RSI::IntType.new(true, 16)
    when 'i32', 'int'
      RSI::IntType.new(true, 32)
    when 'i64', 'long'
      RSI::IntType.new(true, 64)
    when 'u8', 'unsigned char'
      RSI::IntType.new(true, 8)
    when 'u16', 'unsigned short'
      RSI::IntType.new(true, 16)
    when 'u32', 'unsigned int'
      RSI::IntType.new(true, 32)
    when 'u64', 'unsigned long'
      RSI::IntType.new(true, 64)
    when 'f32', 'single', 'float'
      RSI::FloatType.new(32)
    when 'f64', 'double'
      RSI::FloatType.new(64)
    when 'string'
      RSI::String.new
    when /\A{([\w:]+)}\z/
      RSI::StructType.new($1)
    when /\A\[([\w:]+)\]\z/
      RSI::EnumType.new($1)
    when /\Avec ([\w:{}\[\]]+)\z/
      RSI::VecType.new(RSI.type_from_string($1))
    else
      raise "Unknown type… #{type.inspect}"
    end
  end

  def self.argument_transformer_from_name(transformer, arg)
    case transformer
    when 'identity'
      RSI::ArgumentTransformer::Identity.new(arg)
    when 'zero'
      RSI::ArgumentTransformer::Zero.new(arg)
    when 'opaque'
      RSI::ArgumentTransformer::Opaque.new(arg)
    when 'to-mut-ref'
      RSI::ArgumentTransformer::ToMutRef.new(arg)
    when 'from-mut-ref'
      RSI::ArgumentTransformer::FromMutRef.new(arg)
    when 'cstring'
      RSI::ArgumentTransformer::CString.new(arg)
    when 'vec'
      RSI::ArgumentTransformer::Vec.new(arg)
    when 'vec-zero'
      RSI::ArgumentTransformer::VecZero.new(arg)
    when 'vec-length'
      RSI::ArgumentTransformer::VecLength.new(arg)
    else
      raise "Unknown transformer… #{transformer}"
    end
  end

  def self.result_transformer_from_name(transformer, arg)
    case transformer
    when 'out'
      RSI::OutTransformer.new(arg)
    when 'clone'
      RSI::CloneTransformer.new(arg)
    when 'compare'
      RSI::CompareTransformer.new(arg)
    when 'cstring'
      RSI::CStringTransformer.new(arg)
    when 'foreign'
      RSI::ForeignTransformer.new(arg)
    else
      raise "Unknown transformer… #{transformer}"
    end
  end

  class OptionType
    def initialize(type)
      @type = type
    end

    attr_reader :type

    def to_s
      "Option<#{@type}>"
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

  class VecType
    def initialize(type)
      @type = type
    end

    attr_reader :type

    def to_s
      "[#{@type}]"
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

  class String
    def to_s
      'str'
    end
  end
  
  class CString
    def to_s
      'std::c_str::CString'
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
require 'argument-transformers/opaque'
require 'argument-transformers/cstring'
require 'argument-transformers/identity'
require 'argument-transformers/to-mut-ref'
require 'argument-transformers/vec'
require 'argument-transformers/vec-zero'
require 'argument-transformers/vec-length'

require 'result-transformers/out'
require 'result-transformers/clone'
require 'result-transformers/compare'
require 'result-transformers/cstring'
require 'result-transformers/foreign'

require 'nodes/enum'
require 'nodes/struct'
require 'nodes/implementation'
require 'nodes/module'
require 'nodes/library'

require 'nodes/crate'

Root = File.dirname(ARGV[0])

puts RSI::Crate.load_from_file(ARGV[0]).to_code