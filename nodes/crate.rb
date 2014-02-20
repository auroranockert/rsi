module RSI
  class Crate
    include XML::Mapping

    root_element_name :crate

    text_node :name, '@name'

    array_node :uses, 'use', default_value: []
    array_node :enums, 'enum', class: RSI::Enum, default_value: []
    array_node :modules, 'module', class: RSI::Module, default_value: []
    array_node :opaques, 'opaque', default_value: []
    array_node :structs, 'struct', class: RSI::Struct, default_value: []
    array_node :libraries, 'library', class: RSI::Library, default_value: []
    array_node :implementations, 'implementation', class: RSI::Implementation, default_value: []

    def to_code
      uses = '' # self.uses.map { |c| c.to_code(1) }.join('')
      libs = self.libraries.map { |c| c.to_code(0) }.join("\n")
      enums = self.enums.map { |c| c.to_code(0) }.join("\n")
      structs = self.structs.map { |c| c.to_code(0) }.join("\n")
      implementations = self.implementations.map { |c| c.to_code(0) }.join("\n")
      modules = self.modules.map { |c| c.to_code(0) }.join("\n")

      contents = []

      contents.push(uses) if uses != ''
      contents.push(libs) if libs != ''
      contents.push(enums) if enums != ''
      contents.push(structs) if structs != ''
      contents.push(implementations) if implementations != ''
      contents.push(modules) if modules != ''

      RSI.indent('use std;', 0) + "\n" + contents.join("\n")
    end
  end
end