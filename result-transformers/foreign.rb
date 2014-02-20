module RSI
  class ForeignTransformer
    attr_reader :result

    def initialize(result)
      @result = result
    end

    def needs_foreign_result
      true
    end

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

    def to_postparation_code(indent)
      nil
    end
  end
end