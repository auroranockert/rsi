module RSI::Type
  class Vec < RSI::Type::Type
    def self.register_types(context)
      context.register_type("rsi:vec", Vec)
    end

    def out_uses
      ['std::num::Zero', 'std::vec::MutableVector']
    end

    def path
      self.element.path
    end

    def element
      @element ||= self.parent.context.lookup_type(self.parent.node['element'], self.parent)
    end

    def out_prelude
      self.parent.render('function/prelude/vec-out')
    end
    
    def out_as_foreign_argument
      "#{self.parent.name}.as_mut_ptr()"
    end

    def pass_by_ref?
      true
    end

    def as_native_argument_prototype
      "[#{self.lookup_relative(self.parent.path)}]"
    end

    def as_native_result_prototype
      "~[#{self.lookup_relative(self.parent.path)}]"
    end

    def as_native_result
      "#{self.parent.name}"
    end

    def as_foreign_argument_prototype
      if self.parent.immutable?
        "*#{self.element.lookup_relative(self.parent.path)}"
      else
        "*mut #{self.element.lookup_relative(self.parent.path)}"
      end
    end

    def as_foreign_argument
      if self.parent.immutable?
        "#{self.parent.name}.as_ptr()"
      else
        "#{self.parent.name}.as_mut_ptr()"
      end
    end

    def as_foreign_result_prototype(relative)
      self.element.as_foreign_result_prototype(relative)
    end

    def inspect
      "VecLength { element: #{self.element.inspect} }"
    end
  end
end