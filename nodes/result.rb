module RSI
  class Result
    include SAXMachine

    attribute :name
    attribute :type
    attribute :implements

    attribute :pass_by

    attribute :value
    attribute :transformer

    ancestor :fn

    def crate
      self.fn.crate
    end

    def pass_by
      @pass_by || 'value'
    end

    def type
      self.crate.type_from_string(@type) if @type
    end

    def c_type
      if self.implements
        '*mut std::libc::c_void'
      else
        self.type
      end
    end

    def transformer
      self.crate.result_transformer_from_name(@transformer, self)
    end

    def method_missing(message, *args)
      self.transformer.public_send(message, *args)
    end
  end
end