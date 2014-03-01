module RSI::ArgumentTransformer
  class Opaque < RSI::ArgumentTransformer::Transformer
    def to_rust_call_argument
      "#{self.argument.type} { opaque: #{self.argument.name} }"
    end
    
    def to_c_type
      case self.argument.pass_by
      when 'self', 'ref'
        "*std::libc::c_void"
      when 'mut-self', 'mut-ref'
        "*mut std::libc::c_void"
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