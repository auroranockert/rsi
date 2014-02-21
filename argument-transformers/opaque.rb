module RSI::ArgumentTransformer
  class Opaque
    attr_reader :argument

    def initialize(argument)
      @argument = argument
    end

    def to_rust_argument
      case self.argument.pass_by
      when 'self'
        "&self"
      when 'mut-self'
        "&mut self"
      when 'ref'
        "#{self.argument.name}: &#{self.argument.type}"
      when 'mut-ref'
        "#{self.argument.name}: &mut #{self.argument.type}"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_argument
      case self.argument.pass_by
      when 'self'
        'self_value: *std::libc::c_void'
      when 'mut-self'
        'self_value: *mut std::libc::c_void'
      when 'ref'
        "#{self.argument.name}: *std::libc::c_void"
      when 'mut-ref'
        "#{self.argument.name}: *mut std::libc::c_void"
      else
        raise "Unknown pass_by #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      case self.argument.pass_by
      when 'self', 'mut-self'
        'self.opaque'
      else
        "#{self.argument.name}.opaque"
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