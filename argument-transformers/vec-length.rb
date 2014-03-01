module RSI::ArgumentTransformer
  class VecLength < RSI::ArgumentTransformer::Transformer
    def to_rust_argument
      nil
    end
    
    def to_c_argument
      "#{self.argument.name}_length: #{self.to_c_type}"
    end

    def to_c_type
      case self.argument.pass_by
      when 'value'
        "#{self.argument.c_type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      "#{self.argument.value}.len() as #{self.argument.type}"
    end
  end
end