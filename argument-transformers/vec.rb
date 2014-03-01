module RSI::ArgumentTransformer
  class Vec < RSI::ArgumentTransformer::Transformer
    def to_rust_type
      case self.argument.pass_by
      when 'ref'
        "&#{self.argument.type}"
      when 'mut-ref'
        "&mut #{self.argument.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_type
      case self.argument.pass_by
      when 'ref'
        "*#{self.argument.type.type}"
      when 'mut-ref'
        "*mut #{self.argument.type.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      case self.argument.pass_by
      when 'ref'
        "#{self.argument.value}.as_ptr()"
      when 'mut-ref'
        "#{self.argument.value}.as_mut_ptr()"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end
  end
end