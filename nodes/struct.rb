module RSI
  class StructField
    include SAXMachine

    attribute :name
    attribute :type

    ancestor :struct

    def crate
      self.struct.crate
    end

    def type
      self.crate.type_from_string(@type) if @type
    end

    def last?
      self.struct.fields.last == self
    end

    def print_code(indent)
      self.crate.print("#{self.name}: #{self.type}#{self.last? ? '' : ','}", indent)
    end
  end

  class Struct
    include SAXMachine

    attribute :name
    attribute :opaque

    elements :field, as: 'fields', class: RSI::StructField

    ancestor :module
    
    def crate
      self.module.crate
    end

    def print_code(indent)
      self.crate.print("pub struct #{self.name} {", indent)
      if self.opaque
        self.crate.print("opaque: *mut std::libc::c_void", indent + 1)
      else
        self.fields.each { |f| f.print_code(indent + 1) }
      end
      self.crate.print("}", indent)
    end
  end
end