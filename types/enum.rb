module RSI::Type
  class Enum
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def to_s
      @name
    end
  end
end