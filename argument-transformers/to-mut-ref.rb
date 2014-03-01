module RSI::ArgumentTransformer
  class ToMutRef < RSI::ArgumentTransformer::Transformer
    def to_rust_argument
      "#{self.argument.name}_r: #{self.to_rust_type}"
    end

    def to_c_type
      "&mut #{self.argument.c_type}"
    end

    def to_c_call_argument
      "&mut #{self.argument.value}"
    end

    def to_preparation_code(indent)
      self.crate.print("let mut #{self.argument.name} = #{self.argument.name}_r;", indent)
    end
  end
end