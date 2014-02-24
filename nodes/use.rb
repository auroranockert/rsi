module RSI
  class Use
    include SAXMachine

    attribute :name

    ancestor :module

    def crate
      self.module.crate
    end

    def print_code(indent)
      self.crate.print("use #{self.name};", indent)
    end
  end
end