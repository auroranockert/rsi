module RSI
  class Dependency < RSI::Node
    attr_reader :name, :type

    def prepare
      @name, @type = @node['name'], @node['type']
    end

    def to_code
      case self.type
      when 'c'
        self.render('dependency-c')
      else
        raise "Invalid dependency type #{self.type.inspect}"
      end
    end

    def inspect
      "Dependency { name: #{self.name}, type: #{self.type} }"
    end
  end
end