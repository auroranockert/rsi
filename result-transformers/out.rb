module RSI::ResultTransformer
  class Out < RSI::ResultTransformer::Transformer
    def needs_foreign_result
      false
    end

    def to_rust_result
      self.result.name
    end

    def to_rust_result_type
      case self.result.pass_by
      when 'owned'
        "~#{self.result.type}"
      else
        "#{self.result.type}"
      end
    end
  end
end