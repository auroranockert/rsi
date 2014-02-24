module RSI
  class Function < RSI::Fn
    include SAXMachine

    ancestor :implementation
  end

  class Implementation
    include SAXMachine

    attribute :for
    attribute :trait
    attribute :prefix

    elements :fn, as: 'functions', class: RSI::Function

    ancestor :module

    def crate
      self.module.crate
    end

    def for
      RSI::Type::Struct.new(@for)
    end

    def print_code(indent)
      self.crate.print(self.trait ? "impl #{self.trait} for #{self.for} {" : "impl #{self.for} {", indent)
      self.crate.print_list(functions) { |m| m.print_code(indent + 1) }
      self.crate.print("}", indent)
      self.crate.print('')
      self.crate.print("extern {", indent)
      self.functions.each { |m| m.print_extern(indent + 1) }
      self.crate.print("}", indent)
    end
  end
end