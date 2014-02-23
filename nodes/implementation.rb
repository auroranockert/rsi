module RSI
  class Argument
    include SAXMachine

    attribute :name
    attribute :type

    attribute :pass_by

    attribute :value
    attribute :transformer

    ancestor :function

    def implementation
      self.function.implementation
    end

    def crate
      self.function.crate
    end

    def pass_by
      @pass_by || 'value'
    end

    def type
      case self.pass_by
      when 'self', 'mut-self'
        self.implementation.for
      else
        self.crate.type_from_string(@type) if @type
      end
    end

    def transformer
      self.crate.argument_transformer_from_name(@transformer, self)
    end

    def method_missing(message, *args)
      self.transformer.public_send(message, *args)
    end
  end

  class Result
    include SAXMachine

    attribute :name
    attribute :type

    attribute :pass_by

    attribute :value
    attribute :transformer

    ancestor :function

    def crate
      self.function.crate
    end

    def pass_by
      @pass_by || 'value'
    end

    def type
      self.crate.type_from_string(@type) if @type
    end

    def transformer
      self.crate.result_transformer_from_name(@transformer, self)
    end

    def method_missing(message, *args)
      self.transformer.public_send(message, *args)
    end
  end

  class Function
    include SAXMachine

    attribute :name
    attribute :extern
    attribute :foreign

    attribute :value
    attribute :transformer

    elements :argument, as: 'arguments', class: RSI::Argument
    elements :result, as: 'results', class: RSI::Result

    ancestor :implementation

    def crate
      self.implementation.crate
    end

    def extern
      @extern != 'false'
    end

    def foreign
      @foreign || "#{self.implementation.prefix}#{self.name}"
    end

    def print_code(indent)
      prototype_args = self.arguments.map { |a| a.to_rust_argument }.select { |a| a }.join(', ')
      prototype_result = case self.results.length
      when 0
        ''
      when 1
        " -> #{self.results[0].to_rust_result_type}"
      else
        " -> (#{self.results.map { |r| r.to_rust_result_type }.join(', ')})"
      end

      self.crate.print("#{self.implementation.trait ? '' : 'pub '}fn #{self.name}(#{prototype_args})#{prototype_result} {", indent)
      self.crate.print('unsafe {', indent + 1)

      self.arguments.map { |a| a.uses(indent + 2) }
      self.arguments.map { |a| a.to_preparation_code(indent + 2) }

      e = "#{self.foreign}(#{self.arguments.map { |a| a.to_c_call_argument }.select { |a| a }.join(', ')});"
      self.crate.print((self.results.any? { |r| r.needs_foreign_result } ? 'let foreign_result = ' : '') + e, indent + 2)

      self.results.map { |r| r.to_postparation_code(indent + 2) }

      case self.results.length
      when 0
      when 1
        self.crate.print("return #{self.results[0].to_rust_result};", indent + 2)
      else
        self.crate.print("return (#{self.results.map(&:to_rust_result).join(', ')});", indent + 2)
      end

      self.crate.print("}", indent + 1)
      self.crate.print("}", indent)
    end

    def print_extern(indent)
      if self.extern
        prototype_args = self.arguments.map(&:to_c_argument).select { |a| a }.join(', ')
        prototype_result = if r = self.results.find { |r| r.needs_foreign_result }
          " -> #{r.to_c_result_type}"
        end

        self.crate.print("fn #{self.foreign}(#{prototype_args})#{prototype_result};", indent)
      end
    end
  end

  class Implementation
    include SAXMachine

    attribute :for
    attribute :trait
    attribute :prefix

    elements :method, as: 'functions', class: RSI::Function

    ancestor :module

    def crate
      self.module.crate
    end

    def for
      RSI::Type::Struct.new(@for)
    end

    def print_code(indent)
      self.crate.print(self.trait ? "impl #{self.trait} for #{self.for} {" : "impl #{self.for} {", indent)
      self.crate.print_list(functions) { |m| m.print_code(indent + 1) }
      self.crate.print("}", indent)
      self.crate.print('')
      self.crate.print("extern {", indent)
      functions.each { |m| m.print_extern(indent + 1) }
      self.crate.print("}", indent)
    end
  end
end