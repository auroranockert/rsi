module RSI::ArgumentTransformer
  class Zero
    attr_reader :argument

    def initialize(argument)
      @argument = argument
    end

    def to_rust_argument
      nil
    end

    def to_c_argument
      case @argument.pass_by
      when 'mut-ref'
        "#{self.argument.name}: *mut #{self.argument.type}"
      else
        raise "This pass-by doesn't make sense #{@argument.pass_by}"
      end
    end

    def to_c_call_argument
      "&mut #{self.argument.name}"
    end

    def uses(indent)
      nil
    end

    def to_preparation_code(indent)
      RSI.indent("let mut #{self.argument.name}:#{self.argument.type} = std::unstable::intrinsics::init();", indent)
    end
  end
end