module RSI::Type
  class Struct < RSI::Type::Type
    def prepare(path, opaque)
      @path, @opaque = path, opaque
    end

    def name
      @path
    end

    def opaque?
      @opaque
    end

    def pass_by_ref?
      true
    end

    def as_foreign_argument_prototype
      if self.opaque?
        '*mut std::libc::c_void'
      else
        super
      end
    end

    def as_foreign_argument
      if self.opaque?
        "#{self.parent.name}.opaque"
      else
        super
      end
    end

    def as_foreign_result_prototype
      if self.opaque?
        "std::libc::c_void"
      else
        super
      end
    end

    def as_native_result
      if self.opaque?
        "#{self.lookup_relative(self.parent.path)} { opaque: #{self.parent.name} as *mut std::libc::c_void }"
      else
        super
      end
    end

    def inspect
      "Type::Struct { path: #{self.path}, opaque: #{self.opaque?} }"
    end
  end
end