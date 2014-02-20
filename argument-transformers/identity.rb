module RSI::ArgumentTransformer
  class Identity
    attr_reader :argument

    def initialize(argument)
      @argument = argument
    end

    def to_rust_argument
      case self.argument.pass_by
      when 'value'
        "#{self.argument.name}: #{self.argument.type}"
      when 'ref'
        "#{self.argument.name}: &#{self.argument.type}"
      when 'mut-ref'
        "#{self.argument.name}: &mut #{self.argument.type}"
      when 'self'
        '&self'
      when 'mut-self'
        '&mut self'
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_argument
      case self.argument.pass_by
      when 'value'
        "#{self.argument.name}: #{self.argument.type}"
      when 'ref'
        "#{self.argument.name}: &#{self.argument.type}"
      when 'mut-ref'
        "#{self.argument.name}: &mut #{self.argument.type}"
      when 'self'
        "self_value: *#{self.argument.type}"
      when 'mut-self'
        "self_value: *mut #{self.argument.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      case self.argument.pass_by
      when 'self', 'mut-self'
        'self'
      else
        "#{self.argument.name}"
      end
    end

    def uses(indent)
      nil
    end

    def to_preparation_code(indent)
      nil
    end
  end
end