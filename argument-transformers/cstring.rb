module RSI::ArgumentTransformer
  class CString
    attr_reader :argument

    def initialize(argument)
      @argument = argument
    end

    def to_rust_argument
      case self.argument.pass_by
      when 'ref'
        "#{self.argument.name}: &#{self.argument.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_argument
      case self.argument.pass_by
      when 'ref'
        "#{self.argument.name}: std::c_str::CString"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      "#{self.argument.name}.to_c_str()"
    end

    def uses(indent)
      RSI.indent("use std::c_str::ToCStr;", indent)
    end

    def to_preparation_code(indent)
      case self.argument.pass_by
      when 'ref'
        nil
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end
  end
end