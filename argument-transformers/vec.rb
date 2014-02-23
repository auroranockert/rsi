module RSI::ArgumentTransformer
  class Vec < RSI::ArgumentTransformer::Transformer
    def to_rust_argument
      case self.argument.pass_by
      when 'ref'
        "#{self.argument.name}: &#{self.argument.type}"
      when 'mut-ref'
        "#{self.argument.name}: &mut #{self.argument.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_argument
      case self.argument.pass_by
      when 'ref'
        "#{self.argument.name}: *#{self.argument.type.type}"
      when 'mut-ref'
        "#{self.argument.name}: *mut #{self.argument.type.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      case self.argument.pass_by
      when 'ref'
        "#{self.argument.name}.as_ptr()"
      when 'mut-ref'
        "#{self.argument.name}.as_mut_ptr()"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end
  end
end