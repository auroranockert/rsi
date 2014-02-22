module RSI
  class Module
    include SAXMachine

    attribute :name
    attribute :file

    elements :enum, as: 'enums', class: RSI::Enum
    elements :module, as: 'modules', class: RSI::Module
    elements :struct, as: 'structs', class: RSI::Struct
    elements :implementation, as: 'implementations', class: RSI::Implementation

    ancestor :module

    def crate
      self.module.crate
    end

    def to_code(indent)
      a = RSI.indent("pub mod #{self.name} {", indent) + RSI.indent('use std;', indent + 1) + "\n"

      b = [self.enums, self.structs, self.implementations, self.modules].map do |c|
        c.map { |m| m.to_code(indent + 1) }.join("\n")
      end.select { |c| c != '' }.join("\n")

      c = RSI.indent("}", indent)

      a + b + c
    end
  end
end