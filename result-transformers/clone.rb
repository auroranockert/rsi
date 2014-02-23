module RSI::ResultTransformer
  class Clone < RSI::ResultTransformer::Transformer
    def to_rust_result
      "foreign_result.clone()"
    end

    def to_rust_result_type
      "#{self.result.type}"
    end

    def to_c_result_type
      "#{self.result.type}"
    end
  end
end