module RSI::ArgumentTransformer
  class GObject < RSI::ArgumentTransformer::Transformer
    def to_rust_call_argument
      case self.argument.pass_by
      when 'self', 'ref'
        "&#{self.argument.name}_r"
      when 'mut-self', 'mut-ref'
        "&mut #{self.argument.name}_r"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_type
      case self.argument.pass_by
      when 'self', 'ref'
        '*std::libc::c_void'
      when 'mut-self', 'mut-ref'
        '*mut std::libc::c_void'
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      case self.argument.pass_by
      when 'mut-self'
        "#{self.argument.value}.#{self.argument.fn.gobject.as_name}()"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_preparation_code(indent)
      self.crate.print("let mut #{self.argument.name}_r = #{self.argument.type} { opaque: #{self.argument.value} };", indent)
    end

    def to_c_postparation_code(indent)
      self.crate.print("std::cast::forget(#{self.argument.name}_r);", indent)
    end
  end
end