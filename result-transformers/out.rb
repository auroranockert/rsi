module RSI
  class OutTransformer
    attr_reader :result

    def initialize(result)
      @result = result
    end

    def needs_foreign_result
      false
    end

    def to_rust_result
      self.result.name
    end

    def to_rust_result_type
      "#{self.result.type}"
    end

    def to_postparation_code(indent)
      nil
    end
  end
end