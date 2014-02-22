module RSI
  class EnumValue
    include SAXMachine

    attribute :name
    attribute :value

    ancestor :enum

    def value
      @value ||= self.enum.next_value
    end

    def to_code
      value = self.value

      self.enum.last_value = value.to_i

      "#{self.name} = #{self.value}"
    end
  end

  class Enum
    include SAXMachine

    attribute :name
    attribute :representation

    elements :value, as: 'values', class: RSI::EnumValue

    def last_value
      @last_value ||= -1
    end

    def last_value=(value)
      @last_value = value
    end

    def next_value
      self.last_value + 1
    end

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