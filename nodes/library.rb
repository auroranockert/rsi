module RSI
  class Library
    include XML::Mapping

    root_element_name :library

    text_node :name, '@name'

    def to_code(indent)
      a = RSI.indent("#[link(name = \"#{self.name}\")]", indent)
      b = RSI.indent("extern {}", indent)

      a + b
    end
  end
end