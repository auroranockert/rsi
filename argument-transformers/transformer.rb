module RSI::ArgumentTransformer
  class Transformer
    attr_reader :crate, :argument

    def initialize(crate, argument)
      @crate, @argument = crate, argument
    end

    def to_rust_argument
      unless self.argument.constant?
        case self.argument.pass_by
        when 'value', 'ref', 'mut-ref'
          "#{self.argument.name}: #{self.to_rust_type}"
        when 'self'
          '&self'
        when 'mut-self'
          '&mut self'
        else
          raise "Unknown pass_by #{self.argument.pass_by}"
        end
      end
    end

    def to_rust_type
      case self.argument.pass_by
      when 'value'
        "#{self.argument.type}"
      when 'ref'
        "&#{self.argument.type}"
      when 'mut-ref'
        "&mut #{self.argument.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_rust_call_argument
      case self.argument.pass_by
      when 'ref'
        "std::cast::transmute(#{self.argument.value})"
      when 'mut-ref'
        "std::cast::transmute(#{self.argument.value})"
      else
        "#{self.argument.value}"
      end
    end

    def to_c_argument
      "#{self.argument.name}: #{self.to_c_type}"
    end

    def to_c_type
      if self.argument.generic?
        "#{self.argument.c_type}"
      else
        case self.argument.pass_by
        when 'value'
          "#{self.argument.c_type}"
        when 'self', 'ref'
          "*#{self.argument.c_type}"
        when 'mut-self', 'mut-ref'
          "*mut #{self.argument.c_type}"
        else
          raise "Unknown pass_by #{self.argument.pass_by}"
        end
      end
    end

    def to_c_call_argument
      "#{self.argument.value}"
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