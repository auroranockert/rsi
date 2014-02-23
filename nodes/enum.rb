module RSI
  class EnumValue
    include SAXMachine

    attribute :name
    attribute :value

    ancestor :enum

    def crate
      self.enum.crate
    end

    def value
      @value ||= self.enum.next_value
    end

    def last?
      self.enum.values.last == self
    end

    def print_code(indent)
      value = self.value

      self.enum.last_value = value.to_i

      self.crate.print("#{self.name} = #{self.value}#{self.last? ? '' : ','}", indent)
    end
  end

  class Enum
    include SAXMachine

    attribute :name
    attribute :representation

    elements :value, as: 'values', class: RSI::EnumValue

    ancestor :module

    def crate
      self.module.crate
    end

    def last_value
      @last_value ||= -1
    end

    def last_value=(value)
      @last_value = value
    end

    def next_value
      self.last_value + 1
    end

    def representation
      @representation || 'i32'
    end

    def print_code(indent)
      self.crate.print("#[repr(#{self.representation})]", indent)
      self.crate.print("pub enum #{self.name} {", indent)
      self.values.each { |v| v.print_code(indent + 1) }
      self.crate.print("}", indent)
    end
  end
end