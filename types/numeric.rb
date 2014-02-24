module RSI::Type
  class Integer
    def initialize(signed, bits)
      @signed, @bits = signed, bits
    end

    attr_reader :signed, :bits

    def to_s
      case self.bits
      when 64
        self.signed ? 'i64' : 'u64'
      when 32
        self.signed ? 'i32' : 'u32'
      when 16
        self.signed ? 'i16' : 'u16'
      when 8
        self.signed ? 'i8' : 'u8'
      else
        raise "Unknown bit-length for integer #{self.bits}"
      end
    end
  end

  class Float
    def initialize(bits)
      @bits = bits
    end

    attr_reader :bits

    def to_s
      case self.bits
      when 64
        'f64'
      when 32
        'f32'
      else
        raise "Unknown bit-length for float #{self.bits}"
      end
    end
  end
end