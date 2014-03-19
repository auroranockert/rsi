module RSI
  class Implementation < RSI::Node
    attr_reader :trait

    def prepare(trait = nil)
      @trait = trait || @node['trait']

      self.create_children(fn: RSI::Function, method: RSI::Function, constructor: RSI::Function)
    end

    def functions
      self.children.select { |x| RSI::Function === x }
    end

    def qualified_name
      self.parent.qualified_name
    end

    def to_code(indent = 0)
      self.render('implementation', indent)
    end
  end

  class StructField < RSI::Node
    attr_reader :name

    def prepare(name = nil, type = nil)
      @name = name || @node.try(:[], 'name')
      @type, @type_name = type, @node.try(:[], 'type')
    end

    def type
      if @type
        @type
      elsif @type_name
        if t = self.context.lookup_type(@type_name, self)
          t
        else
          raise "Could not resolve type #{@type_name} for field #{self.name} of #{self.parent.name}"
        end
      else
        raise "Could not resolve type for field #{self.name} of #{self.parent.name}"
      end
    end
  end

  class Struct < RSI::Node
    attr_reader :name, :prefix

    def prepare
      @name, @opaque, @prefix = @node['name'], @node['opaque'] == 'true', @node['prefix']

      self.context.register_type(self.qualified_name, RSI::Type::Struct, self.qualified_name, self.opaque?)

      self.create_children(field: RSI::StructField, fn: RSI::Function, method: RSI::Function, constructor: RSI::Function, implementation: RSI::Implementation)
    end

    def qualified_name
      "#{self.path}::#{self.name}"
    end

    def opaque?
      @opaque
    end

    def fields
      self.children.select { |x| RSI::StructField === x }
    end

    def functions
      self.children.select { |x| RSI::Function === x }
    end

    def implementations
      self.children.select { |x| RSI::Implementation === x }
    end

    def to_code(indent = 0)
      self.render('struct', indent)
    end

    def inspect
      "Struct { name: #{self.name}, opaque: #{self.opaque?} }"
    end
  end
end