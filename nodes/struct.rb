module RSI
  class StructField
    include SAXMachine

    attribute :name
    attribute :type

    ancestor :struct

    def crate
      self.struct.module.crate
    end

    def type
      self.crate.type_from_string(@type) if @type
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

    ancestor :module

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