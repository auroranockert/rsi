module RSI::Type
  class VecLength < RSI::Type::Type
    def self.register_types(context)
      context.register_type("rsi:vec-length", VecLength)
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

    def arg_as_native_prototype
      nil
    end

    def as_foreign_argument_prototype(arg)
      self.element.as_foreign_argument_prototype(arg)
    end

    def as_foreign_argument(arg)
      "#{arg.name}.len() as #{self.element.as_foreign_argument_prototype(arg)}"
    end

    def as_foreign_result_prototype(relative)
      self.element.as_foreign_result_prototype(relative)
    end

    def inspect
      "VecLength { element: #{self.element.inspect} }"
    end
  end
end