module RSI::ArgumentTransformer
  class GObjectSelf < RSI::ArgumentTransformer::Transformer
    def to_rust_argument
      case self.argument.pass_by
      when 'mut-self'
        "&mut self"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_argument
      case self.argument.pass_by
      when 'mut-self'
        "#{self.argument.name}: *mut std::libc::c_void"
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
  end
end