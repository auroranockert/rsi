module RSI::ArgumentTransformer
  class VecZero
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
        "#{self.argument.name}: *mut #{self.argument.type.type}"
      else
        raise "This pass-by doesn't make sense #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      "#{self.argument.name}.as_mut_ptr()"
    end

    def uses(indent)
      a = RSI.indent('use std::num::Zero;', indent)
      b = RSI.indent("use std::vec::MutableVector;", indent)

      a + b
    end

    def to_preparation_code(indent)
      a = RSI.indent("let #{self.argument.name}_len = #{self.argument.value} as uint;", indent)
      b = RSI.indent("let mut #{self.argument.name}:~#{self.argument.type} = std::vec::from_elem(#{self.argument.name}_len, Zero::zero());", indent)

      a + b
    end
  end
end