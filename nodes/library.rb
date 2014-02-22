module RSI
  class Library
    include SAXMachine

    attribute :name

    def to_code(indent)
      a = RSI.indent("#[link(name = \"#{self.name}\")]", indent)
      b = RSI.indent("extern {}", indent)

      a + b
    end
  end
end