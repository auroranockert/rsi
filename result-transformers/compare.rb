module RSI::ResultTransformer
  class Compare < RSI::ResultTransformer::Transformer
    def to_rust_result
      "foreign_result != #{@result.value}"
    end

    def to_rust_result_type
      "bool"
    end

    def to_c_result_type
      "i32"
    end
  end
end