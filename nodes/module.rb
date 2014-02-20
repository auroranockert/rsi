module RSI
  class Module
    include XML::Mapping

    root_element_name :module

    text_node :name, '@name'

    array_node :uses, 'use', default_value: []
    array_node :enums, 'enum', class: RSI::Enum, default_value: []
    array_node :modules, 'module', class: RSI::Module, default_value: []
    array_node :opaques, 'opaque', default_value: []
    array_node :structs, 'struct', class: RSI::Struct, default_value: []
    array_node :implementations, 'implementation', class: RSI::Implementation, default_value: []
  
    def to_code(indent)
      uses = '' # self.uses.map { |c| c.to_code(1) }.join('')
      enums = self.enums.map { |c| c.to_code(indent + 1) }.join("\n")
      structs = self.structs.map { |c| c.to_code(indent + 1) }.join("\n")
      implementations = self.implementations.map { |c| c.to_code(indent + 1) }.join("\n")
      modules = self.modules.map { |c| c.to_code(indent + 1) }.join("\n")

      contents = []

      contents.push(uses) if uses != ''
      contents.push(enums) if enums != ''
      contents.push(structs) if structs != ''
      contents.push(implementations) if implementations != ''
      contents.push(modules) if modules != ''

      RSI.indent("pub mod #{self.name} {", indent) + RSI.indent('use std;', indent + 1) + "\n" + contents.join("\n") + RSI.indent("}", indent)
    end
  end
end