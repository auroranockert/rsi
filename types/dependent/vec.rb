module RSI::Type
  class Vec < RSI::Type::Type
    def self.register_types(context)
      context.register_type("rsi:vec", Vec)
    end

    attr_reader :parent

    def initialize(parent)
      @parent = parent
    end

    def out_uses
      ['std::num::Zero', 'std::vec::MutableVector']
    end

    def path
      self.element.path
    end

    def element
      @element ||= @parent.context.lookup_type(@parent.node['element'], @parent)
    end

    def out_prelude
      @parent.render('function/prelude/vec-out')
    end
    
    def out_as_foreign_argument
      "#{@parent.name}.as_mut_ptr()"
    end

    def pass_by_ref?
      true
    end

    def as_native_argument_prototype(relative)
      "[#{self.lookup_relative(relative)}]"
    end

    def as_native_result_prototype(relative)
      "~[#{self.lookup_relative(relative)}]"
    end

    def as_native_result(name, relative)
      "#{name}"
    end

    def as_foreign_argument_prototype(arg)
      if arg.immutable?
        "*#{self.element.lookup_relative(arg.path)}"
      else
        "*mut #{self.element.lookup_relative(arg.path)}"
      end
    end

    def as_foreign_argument(arg)
      if arg.immutable?
        "#{arg.name}.as_ptr()"
      else
        "#{arg.name}.as_mut_ptr()"
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