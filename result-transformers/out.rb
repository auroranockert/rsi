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
      case self.result.pass_by
      when 'owned'
        "~#{self.result.type}"
      else
        "#{self.result.type}"
      end
    end

    def to_postparation_code(indent)
      nil
    end
  end
end