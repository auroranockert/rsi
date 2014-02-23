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

    def print_code(indent)
      self.crate.print("pub mod #{self.name} {", indent)
      self.crate.print('use std;', indent + 1)
      self.crate.print()

      self.crate.print_list([self.enums, self.structs, self.implementations, self.modules]) do |c|
        self.crate.print_list(c) do |m|
          m.print_code(indent + 1)
        end
      end

      self.crate.print('}', indent)
    end
  end
end