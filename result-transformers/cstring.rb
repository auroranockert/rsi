module RSI
  class CStringTransformer
    attr_reader :result

    def initialize(result)
      @result = result
    end

    def needs_foreign_result
      true
    end

    def to_rust_result
      "std::c_str::CString::new(foreign_result, false)"
    end

    def to_rust_result_type
      "#{self.result.type}"
    end

    def to_c_result_type
      "*i8"
    end

    def to_postparation_code(indent)
      nil
    end
  end
end