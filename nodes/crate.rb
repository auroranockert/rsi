module RSI
  class Crate
    include XML::Mapping

    text_node :name, '@name'

    array_node :enums, 'enum', class: RSI::Enum, default_value: []
    array_node :modules, 'module', class: RSI::Module, default_value: []
    array_node :structs, 'struct', class: RSI::Struct, default_value: []
    array_node :libraries, 'library', class: RSI::Library, default_value: []
    array_node :implementations, 'implementation', class: RSI::Implementation, default_value: []

    def to_code
      [self.libraries, self.enums, self.structs, self.implementations, self.modules].map do |c|
        c.map { |m| m.to_code(0) }.join("\n")
      end.select { |c| c != '' }.join("\n")
    end
  end
end