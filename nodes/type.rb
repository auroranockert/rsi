module RSI
  class Ty < RSI::Node
    attr_reader :name, :in, :out, :template

    def prepare
      @name, @in, @out, @template = @node['name'], @node['in'], @node['out'], @node['template']

      self.context.register_type(@name, RSI::Type::Custom, self)
    end

    def to_code
    end

    def inspect
      "Type { name: #{self.name.inspect}, in: #{self.in.inspect}, out: #{self.out.inspect}, template: #{self.out.inspect} }"
    end
  end
end