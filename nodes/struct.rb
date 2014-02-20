module RSI
  class StructField
    include XML::Mapping

    root_element_name :field

    text_node :name, '@name'
    text_node :ty, '@type'

    def type
      @type ||= RSI.type_from_string(self.ty)
    end

    def to_code
      "#{self.name}: #{self.type}"
    end
  end

  class Struct
    include XML::Mapping

    root_element_name :struct

    text_node :name, '@name'
    array_node :fields, 'field', class: RSI::StructField, default_value: []

    def to_code(indent)
      a = RSI.indent("pub struct #{self.name} {", indent)
      b = RSI.indent(self.fields.map(&:to_code).join(",\n"), indent + 1)
      c = RSI.indent("}", indent)

      a + b + c
    end
  end
end