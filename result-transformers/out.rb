module RSI::ResultTransformer
  class Out < RSI::ResultTransformer::Transformer
    def needs_foreign_result
      false
    end

    def to_rust_result
      self.result.name
    end
  end
end