require 'nokogiri'
require 'sax-machine'

module RSI
  class Machine # TODO: Implement non-amd64 support maybe?
    def type_from_string(type)
      case type
      when 'i8', 'char'
        RSI::Type::Integer.new(true, 8)
      when 'i16', 'short'
        RSI::Type::Integer.new(true, 16)
      when 'i32', 'int'
        RSI::Type::Integer.new(true, 32)
      when 'i64', 'long'
        RSI::Type::Integer.new(true, 64)
      when 'u8', 'unsigned char'
        RSI::Type::Integer.new(true, 8)
      when 'u16', 'unsigned short'
        RSI::Type::Integer.new(true, 16)
      when 'u32', 'unsigned int'
        RSI::Type::Integer.new(true, 32)
      when 'u64', 'unsigned long'
        RSI::Type::Integer.new(true, 64)
      when 'f32', 'single', 'float'
        RSI::Type::Float.new(32)
      when 'f64', 'double'
        RSI::Type::Float.new(64)
      when 'string'
        RSI::Type::String.new
      when /\A{([\w:]+)}\z/
        RSI::Type::Struct.new($1)
      when /\A\[([\w:]+)\]\z/
        RSI::Type::Enum.new($1)
      when /\Avec ([\w:{}\[\]]+)\z/
        RSI::Type::Vec.new(self.type_from_string($1))
      else
        raise "Unknown type… #{type.inspect}"
      end
    end
  end
end

$:.unshift(File.dirname(__FILE__))

require 'types/enum'
require 'types/numeric'
require 'types/string'
require 'types/struct'
require 'types/vec'

require 'argument-transformers/transformer'
require 'argument-transformers/zero'
require 'argument-transformers/opaque'
require 'argument-transformers/cstring'
require 'argument-transformers/identity'
require 'argument-transformers/to-mut-ref'
require 'argument-transformers/vec'
require 'argument-transformers/vec-zero'
require 'argument-transformers/vec-length'

require 'result-transformers/transformer'
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

RSI::Crate.from_rsi(ARGV[0], RSI::Machine.new, File.new(ARGV[1], 'w+')).print_code