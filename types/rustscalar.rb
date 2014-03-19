module RSI::Type
  class RustScalar < RSI::Type::Type
    def self.register_types(context)
      {
        'bool' => 'bool',
        'string' => 'str'
      }.map do |k, v|
        context.register_type("rust:#{k}", RustScalar, v)
      end
    end

    def prepare(ty)
      self.path = ty
    end
    
    def inspect
      "Rust { rust: #{self.path} }"
    end
  end
end