module RSI::ArgumentTransformer
  class VecZero < RSI::ArgumentTransformer::Transformer
    def to_c_type
      case @argument.pass_by
      when 'mut-ref'
        "*mut #{self.argument.type.type}"
      else
        raise "This pass-by doesn't make sense #{self.argument.pass_by}"
      end
    end

    def to_c_call_argument
      "#{self.argument.name}.as_mut_ptr()"
    end

    def uses(indent)
      self.crate.print('use std::num::Zero;', indent)
      self.crate.print("use std::vec::MutableVector;", indent)
    end

    def to_preparation_code(indent)
      self.crate.print("let #{self.argument.name}_len = #{self.argument.value} as uint;", indent)
      self.crate.print("let mut #{self.argument.name}:~#{self.argument.type} = std::vec::from_elem(#{self.argument.name}_len, Zero::zero());", indent)
    end
  end
end