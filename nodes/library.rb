module RSI
  class Library
    include SAXMachine

    attribute :name

    ancestor :crate

    def print_code(indent)
      self.crate.print("#[link(name = \"#{self.name}\")]", indent)
      self.crate.print("extern {}", indent)
    end
  end
end