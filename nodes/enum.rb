module RSI
  class EnumValue < RSI::Node
    attr_reader :name

    def prepare
      @name, @value = @node['name'], @node['value']
    end

    def value
      if @value
        Integer(@value)
      elsif p = self.previous_sibling
        p.value + 1
      else
        0
      end
    end
  end

  class Enum < RSI::Node
    attr_reader :name, :representation, :wrap

    def prepare
      @name, @representation, @wrap = @node['name'], @node['representation'] || 'i32', @node['wrap'] == 'true'

      self.create_children(value: RSI::EnumValue)

      self.context.register_type(self.qualified_name, RSI::Type::Enum.new(self.fully_qualified_name))
    end

    def qualified_name
      "#{self.path}::#{self.name}"
    end

    def wrap?
      self.wrap == true
    end

    def fully_qualified_name
      if self.wrap?
        "#{self.path}::#{self.name.underscore}::#{self.name}"
      else
        "#{self.path}::#{self.name}"
      end
    end

    def values
      self.children.select { |x| RSI::EnumValue === x }
    end

    def to_code(indent = 0)
      if self.wrap
        self.render('enum-wrap', indent)
      else
        self.render('enum', indent)
      end
    end

    def inspect
      "Enum { name: #{self.name}, representation: #{self.representation} }"
    end
  end
end