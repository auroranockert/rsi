module RSI::ResultTransformer
  class Foreign < RSI::ResultTransformer::Transformer
    def to_rust_result
      case @result.pass_by
      when 'owned'
        "std::cast::transmute(foreign_result)"
      else
        "foreign_result"
      end
    end

    def to_rust_result_type
      case @result.pass_by
      when 'owned'
        "~#{self.result.type}"
      else
        "#{self.result.type}"
      end
    end

    def to_c_result_type
      case @result.pass_by
      when 'owned'
        "*#{self.result.type}"
      else
        "#{self.result.type}"
      end
    end
  end
end