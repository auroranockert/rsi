module RSI::ResultTransformer
  class RSI::ResultTransformer::Transformer
    attr_reader :crate, :result

    def initialize(crate, result)
      @crate, @result = crate, result
    end

    def to_rust_result
      nil
    end

    def to_rust_result_type
      nil
    end

    def to_c_result_type
      nil
    end

    def needs_foreign_result
      true
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
