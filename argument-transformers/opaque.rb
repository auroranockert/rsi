module RSI::ArgumentTransformer
  class Opaque < RSI::ArgumentTransformer::Transformer
    def to_rust_argument
      case self.argument.pass_by
      when 'self'
        "&self"
      when 'mut-self'
        "&mut self"
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
      when 'self', 'ref'
        "#{self.argument.name}: *std::libc::c_void"
      when 'mut-self', 'mut-ref'
        "#{self.argument.name}: *mut std::libc::c_void"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      case self.argument.pass_by
      when 'self', 'ref'
        "#{self.argument.value}.opaque as *std::libc::c_void"
      when 'mut-self', 'mut-ref'
        "#{self.argument.value}.opaque"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end
  end
end