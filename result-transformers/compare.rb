module RSI
  class CompareTransformer
    attr_reader :result

    def initialize(result)
      @result = result
    end

    def needs_foreign_result
      true
    end

    def to_rust_result
      "foreign_result != #{@result.value}"
    end

    def to_rust_result_type
      "bool"
    end

    def to_c_result_type
      "i32"
    end

    def to_postparation_code(indent)
      nil
    end
  end
end