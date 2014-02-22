module RSI
  class Crate
    include SAXMachine

    attribute :name
    
    elements :enum, as: 'enums', class: RSI::Enum
    elements :module, as: 'modules', class: RSI::Module
    elements :struct, as: 'structs', class: RSI::Struct
    elements :library, as: 'libraries', class: RSI::Library
    elements :implementation, as: 'implementations', class: RSI::Implementation

    def to_code
      [self.libraries, self.enums, self.structs, self.implementations, self.modules].map do |c|
        c.map { |m| m.to_code(0) }.join("\n")
      end.select { |c| c != '' }.join("\n")
    end
  end
end