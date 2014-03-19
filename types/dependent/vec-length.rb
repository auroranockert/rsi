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

    def as_foreign_argument_prototype
      self.element.as_foreign_argument_prototype
    end

    def as_foreign_argument
      "#{self.parent.name}.len() as #{self.element.as_foreign_argument_prototype}"
    end

    def as_foreign_result_prototype
      self.element.as_foreign_result_prototype
    end

    def inspect
      "VecLength { element: #{self.element.inspect} }"
    end
  end
end