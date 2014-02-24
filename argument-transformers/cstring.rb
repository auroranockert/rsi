module RSI::ArgumentTransformer
  class CString < RSI::ArgumentTransformer::Transformer
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
      "#{self.argument.value}.to_c_str()"
    end

    def uses(indent)
      self.crate.print("use std::c_str::ToCStr;", indent)
    end
  end
end