module RSI::Type
  class Vec < RSI::Type::Type
    def self.register_types(context)
      context.register_type("rsi:vec", Vec)
    end

    attr_reader :parent

    def initialize(parent)
      @parent = parent
    end

    def path
      self.element.path
    end

    def element
      @element ||= @parent.context.lookup_type(@parent.node['element'], @parent)
    end

    def pass_by_ref?
      true
    end

    def as_native_argument_prototype(relative)
      "[#{self.lookup_relative(relative)}]"
    end

    def as_foreign_argument_prototype(arg)
      if arg.immutable?
        "*#{self.element.lookup_relative(arg.path)}"
      else
        "*mut #{self.element.lookup_relative(arg.path)}"
      end
    end

    def as_foreign_argument(arg)
      "#{arg.name}.as_ptr()"
    end

    def as_foreign_result_prototype(relative)
      self.element.as_foreign_result_prototype(relative)
    end

    def inspect
      "VecLength { element: #{self.element.inspect} }"
    end
  end
end