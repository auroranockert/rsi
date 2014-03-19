module RSI::Type
  class CScalar < RSI::Type::Type
    def self.register_types(context)
      {
        'i8' => 'i8',
        'i16' => 'i16',
        'i32' => 'i32',
        'i64' => 'i64',
        'u8' => 'u8',
        'u16' => 'u16',
        'u32' => 'u32',
        'u64' => 'u64',
        'f32' => 'f32',
        'f64' => 'f64',
        'char' => 'std::libc::c_char',
        'short' => 'std::libc::c_short',
        'int' => 'std::libc::c_int',
        'long' => 'std::libc::c_long',
        'longlong' => 'std::libc::c_longlong',
        'uchar' => 'std::libc::c_uchar',
        'ushort' => 'std::libc::c_ushort',
        'uint' => 'std::libc::c_uint',
        'ulong' => 'std::libc::c_ulong',
        'ulonglong' => 'std::libc::c_ulonglong',
        'size_t' => 'std::libc::size_t'
      }.map do |k, v|
        context.register_type("c:#{k}", CScalar.new(v))
      end
    end

    def initialize(ty)
      @path = ty
    end

    def inspect
      "CScalar { rust: #{@path} }"
    end
  end
end