module RSI
  class Argument
    include SAXMachine

    attribute :name

    attribute :as
    attribute :type
    attribute :implements

    attribute :pass_by

    attribute :value
    attribute :transformer

    ancestor :fn

    def crate
      self.fn.crate
    end

    def name
      case self.pass_by
      when 'self', 'mut-self'
        @name || 'self_value'
      else
        @name
      end
    end

    def pass_by
      @pass_by || 'value'
    end

    def generic?
      @implements
    end
    
    def constant?
      @value
    end
    
    def to_generic
      if self.generic?
        "#{self.type}: #{self.implements.join(' + ')}"
      end
    end
    
    def implements
      if @implements
        @implements.split(',').map { |i| i.strip }
      end
    end

    def type
      case self.pass_by
      when 'self', 'mut-self'
        self.fn.for
      else
        if self.as
          self.as
        else
          if @type
            if self.generic?
              @type
            else
              self.crate.type_from_string(@type)
            end
          else
            raise "No type set… #{self.inspect}"
          end
        end
      end
    end

    def c_type
      if self.generic?
        '*mut std::libc::c_void'
      else
        self.type
      end
    end
    
    def value
      case self.pass_by
      when 'self', 'mut-self'
        'self'
      else
        if @value
          self.as ? "(#{@value} as #{self.as})" : "#{@value}"
        else
          self.as ? "(#{self.name} as #{self.as})" : "#{self.name}"
        end
      end
    end

    def transformer
      self.crate.argument_transformer_from_name(@transformer, self)
    end

    def method_missing(message, *args)
      self.transformer.public_send(message, *args)
    end
  end
end