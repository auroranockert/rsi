module RSI::ArgumentTransformer
  class CString < RSI::ArgumentTransformer::Transformer
    def to_rust_type
      case self.argument.pass_by
      when 'ref'
        "&#{self.argument.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_type
      case self.argument.pass_by
      when 'ref'
        "*std::libc::c_char"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      "#{self.argument.value}.to_c_str().unwrap()"
    end

    def uses(indent)
      self.crate.print("use std::c_str::ToCStr;", indent)
    end
  end
end