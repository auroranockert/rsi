module RSI::ArgumentTransformer
  class Transformer
    attr_reader :crate, :argument

    def initialize(crate, argument)
      @crate, @argument = crate, argument
    end

    def to_rust_argument
      nil
    end

    def to_c_argument
      nil
    end

    def to_c_call_argument
      nil
    end

    def uses(indent)
      nil
    end

    def to_preparation_code(indent)
      nil
    end

    def to_postparation_code(indent)
      nil
    end
  end
end