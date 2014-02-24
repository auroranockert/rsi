module RSI::Type
  class Vec
    def initialize(type)
      @type = type
    end

    attr_reader :type

    def to_s
      "[#{@type}]"
    end
  end
end