module RSI
  class Module
    include XML::Mapping

    text_node :name, '@name', optional: true
    text_node :file, '@file', optional: true

    array_node :enums, 'enum', class: RSI::Enum, default_value: []
    array_node :modules, 'module', class: RSI::Module, default_value: []
    array_node :opaques, 'opaque', default_value: []
    array_node :structs, 'struct', class: RSI::Struct, default_value: []
    array_node :implementations, 'implementation', class: RSI::Implementation, default_value: []

    def to_code(indent)
      if self.file
        RSI::Module.load_from_file("#{Context.root}/#{self.file}.xml").to_code(indent)
      else
        a = RSI.indent("pub mod #{self.name} {", indent) + RSI.indent('use std;', indent + 1) + "\n"

        b = [self.enums, self.structs, self.implementations, self.modules].map do |c|
          c.map { |m| m.to_code(indent + 1) }.join("\n")
        end.select { |c| c != '' }.join("\n")

        c = RSI.indent("}", indent)

        a + b + c
      end
    end
  end
end