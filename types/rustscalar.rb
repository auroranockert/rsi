module RSI::Type
  class RustScalar < RSI::Type::Type
    def self.register_types(context)
      {
        'bool' => 'bool',
        'string' => 'str'
      }.map do |k, v|
        context.register_type("rust:#{k}", RustScalar.new(v))
      end
    end

    def initialize(ty)
      @path = ty
    end
    
    def inspect
      "Rust { rust: #{@path} }"
    end
  end
end