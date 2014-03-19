module RSI::Type
  class Enum < RSI::Type::Type
    def prepare(path)
      @path = path
    end

    def inspect
      "Type::Enum { path: #{self.path} }"
    end
  end
end