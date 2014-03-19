module RSI::Type
  class Custom < RSI::Type::Type
    attr_reader :definition

    def prepare(definition)
      @definition = definition
    end

    def out
      @out ||= self.definition.context.lookup_type(self.definition.out, self.parent)
    end

    def path
      self.out.path
    end

    def as_struct_field
      self.out.as_struct_field
    end

    def as_native_result_prototype
      self.out.as_native_result_prototype
    end

    def as_native_argument_prototype
      self.out.as_native_argument_prototype
    end

    def as_foreign_argument
      "#{self.parent.name}"
    end

    def inspect
      "Type::Custom { definition: #{self.definition.name.inspect} }"
    end
  end
end