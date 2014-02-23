module RSI::ArgumentTransformer
  class Zero < RSI::ArgumentTransformer::Transformer
    def to_c_argument
      "#{self.argument.name}: *mut #{self.argument.type}"
    end

    def to_c_call_argument
      "&mut #{self.argument.name}"
    end

    def to_preparation_code(indent)
      self.crate.print("let mut #{self.argument.name}:#{self.argument.type} = std::unstable::intrinsics::init();", indent)
    end
  end
end