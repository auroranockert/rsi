module RSI
  class Module
    include SAXMachine

    attribute :name
    attribute :file
    attribute :extern

    elements :use, as: 'uses', class: RSI::Use
    elements :enum, as: 'enums', class: RSI::Enum
    elements :module, as: 'modules', class: RSI::Module
    elements :struct, as: 'structs', class: RSI::Struct
    elements :gobject, as: 'gobjects', class: RSI::GObject
    elements :implementation, as: 'implementations', class: RSI::Implementation

    ancestor :module

    def crate
      self.module.crate
    end

    def extern
      @extern || 'false'
    end

    def extern?
      self.extern == 'true'
    end

    def print_code(indent)
      if self.extern?
        self.crate.print("extern mod #{self.name};")
      else
        self.crate.print("pub mod #{self.name} {", indent)
        self.crate.print('use std;', indent + 1)
        self.uses.each { |u| u.print_code(indent + 1) }
        self.crate.print()

        self.crate.print_list([self.enums, self.structs, self.gobjects, self.implementations, self.modules]) do |c|
          self.crate.print_list(c) do |m|
            m.print_code(indent + 1)
          end
        end

        self.crate.print('}', indent)
      end
    end
  end
end