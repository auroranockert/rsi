module RSI
  class EnumValue
    include XML::Mapping

    root_element_name :value

    text_node :name, '@name'
    text_node :value, '@value'

    def to_code
      "#{self.name} = #{self.value}"
    end
  end

  class Enum
    include XML::Mapping

    root_element_name :enum

    text_node :name, '@name'
    text_node :representation, '@representation', default_value: 'u32'
    array_node :values, 'value', class: RSI::EnumValue, default_value: []

    def to_code(indent)
      a = RSI.indent("#[repr(#{self.representation})]", indent)
      b = RSI.indent("pub enum #{self.name} {", indent)
      c = RSI.indent(self.values.map(&:to_code).join(",\n"), indent + 1)
      d = RSI.indent("}", indent)

      a + b + c + d
    end
  end
end