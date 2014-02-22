module RSI
  class StructField
    include SAXMachine

    attribute :name
    attribute :type

    def type= value
      @type = Context.type_from_string(value)
    end

    def to_code
      "#{self.name}: #{self.type}"
    end
  end

  class Struct
    include SAXMachine

    attribute :name
    attribute :opaque

    elements :field, as: 'fields', class: RSI::StructField

    def to_code(indent)
      if self.opaque
        a = RSI.indent("pub struct #{self.name} {", indent)
        b = RSI.indent("opaque: *mut std::libc::c_void", indent + 1)
        c = RSI.indent("}", indent)

        a + b + c
      else
        a = RSI.indent("pub struct #{self.name} {", indent)
        b = RSI.indent(self.fields.map(&:to_code).join(",\n"), indent + 1)
        c = RSI.indent("}", indent)

        a + b + c
      end
    end
  end
end