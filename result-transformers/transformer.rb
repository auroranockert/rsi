module RSI::ResultTransformer
  class RSI::ResultTransformer::Transformer
    attr_reader :crate, :result

    def initialize(crate, result)
      @crate, @result = crate, result
    end

    def to_rust_result
      nil
    end

    def to_rust_result_type
      case self.result.pass_by
      when 'owned'
        "~#{self.result.rust_type}"
      else
        "#{self.result.rust_type}"
      end
    end

    def to_c_result_type
      case @result.pass_by
      when 'owned'
        "*#{self.result.c_type}"
      else
        "#{self.result.c_type}"
      end
    end

    def needs_foreign_result
      true
    end

    def uses(indent)
      nil
    end

    def to_preparation_code(indent)
      nil
    end

    def to_postparation_code(indent)
      nil
    end

    def to_c_preparation_code(indent)
      nil
    end

    def to_c_postparation_code(indent)
      nil
    end
  end
end
