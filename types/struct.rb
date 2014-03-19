module RSI::Type
  class Struct < RSI::Type::Type
    def initialize(path, opaque)
      @path, @opaque = path, opaque
    end

    attr_reader :path

    def name
      @path
    end

    def opaque?
      @opaque
    end

    def pass_by_ref?
      true
    end

    def as_foreign_argument_prototype(arg)
      if self.opaque?
        '*mut std::libc::c_void'
      else
        super
      end
    end

    def as_foreign_argument(arg)
      if self.opaque?
        "#{arg.name}.opaque"
      else
        super
      end
    end

    def as_foreign_result_prototype(relative)
      if self.opaque?
        "std::libc::c_void"
      else
        super
      end
    end

    def as_native_result(name, relative)
      if self.opaque?
        "#{self.lookup_relative(relative)} { opaque: #{name} as *mut std::libc::c_void }"
      else
        super
      end
    end

    def inspect
      "Type::Struct { path: #{self.path}, opaque: #{self.opaque?} }"
    end
  end
end