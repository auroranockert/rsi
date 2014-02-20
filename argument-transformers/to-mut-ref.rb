module RSI
  class ToMutRefTransformer
    attr_reader :argument

    def initialize(argument)
      @argument = argument
    end

    def to_rust_argument
      case self.argument.pass_by
      when 'value'
        "#{self.argument.name}_r: #{self.argument.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_argument
      "#{self.argument.name}: &mut #{self.argument.type}"
    end

    def to_c_call_argument
      "&mut #{self.argument.name}"
    end

    def to_preparation_code(indent)
      case self.argument.pass_by
      when 'value'
        RSI.indent("let mut #{self.argument.name} = #{self.argument.name}_r;", indent)
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end
  end
end