module RSI::Type
  class Custom < RSI::Type::Type
    attr_reader :parent

    def initialize(parent)
      @parent = parent
    end

    def out
      @out ||= @parent.context.lookup_type(@parent.out, @parent)
    end

    def path
      self.out.path
    end

    def as_struct_field(relative)
      self.out.as_struct_field(relative)
    end

    def as_native_result_prototype(relative)
      self.out.as_native_result_prototype(relative)
    end

    def as_native_argument_prototype(relative)
      self.out.as_native_argument_prototype(relative)
    end

    def as_foreign_argument(arg)
      "#{arg.name}"
    end

    def inspect
      "Type::Custom { parent: #{self.parent.name.inspect} }"
    end
  end
end