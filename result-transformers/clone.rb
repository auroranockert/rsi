module RSI::ResultTransformer
  class Clone < RSI::ResultTransformer::Transformer
    def to_rust_result
      "foreign_result.clone()"
    end
  end
end