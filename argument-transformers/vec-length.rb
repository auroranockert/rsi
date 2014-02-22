module RSI::ArgumentTransformer
  class VecLength
    attr_reader :argument

    def initialize(argument)
      @argument = argument
    end

    def to_rust_argument
      nil
    end

    def to_c_argument
      case self.argument.pass_by
      when 'value'
        "#{self.argument.name}_length: #{self.argument.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      "#{self.argument.name}.len() as #{self.argument.type}"
    end

    def uses(indent)
      nil
    end

    def to_preparation_code(indent)
      nil
    end
  end
end