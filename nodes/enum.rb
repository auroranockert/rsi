module RSI
  class EnumValue
    include SAXMachine

    attribute :name
    attribute :value

    def to_code
      "#{self.name} = #{self.value}"
    end
  end

  class Enum
    include SAXMachine

    attribute :name
    attribute :representation

    elements :value, as: 'values', class: RSI::EnumValue

    def representation
      @representation || 'i32'
    end

    def to_code(indent)
      a = RSI.indent("#[repr(#{self.representation})]", indent)
      b = RSI.indent("pub enum #{self.name} {", indent)
      c = RSI.indent(self.values.map(&:to_code).join(",\n"), indent + 1)
      d = RSI.indent("}", indent)

      a + b + c + d
    end
  end
end