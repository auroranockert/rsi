module RSI::Type
  class CString < RSI::Type::Type
    def self.register_types(context)
      context.register_type("c:string", CString)
    end

    def path
      'str'
    end

    def uses
      ['std::c_str::ToCStr']
    end

    def pass_by_ref?
      true
    end

    def as_foreign_argument_prototype
      '*i8'
    end

    def as_foreign_argument
      "#{super}.to_c_str().unwrap()" # TODO: Error check?
    end

    def inspect
      "CString { }"
    end
  end
end