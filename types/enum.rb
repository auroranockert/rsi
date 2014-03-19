module RSI::Type
  class Enum < RSI::Type::Type
    def initialize(path)
      @path = path
    end

    attr_reader :path

    def inspect
      "Type::Enum { path: #{self.path} }"
    end
  end
end