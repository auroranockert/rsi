module RSI
  class Argument
    include SAXMachine

    attribute :name
    attribute :type

    attribute :pass_by

    attribute :value
    attribute :transformer

    ancestor :function

    def crate
      self.function.implementation.module.crate
    end

    def pass_by
      @pass_by || 'value'
    end

    def type
      self.crate.type_from_string(@type) if @type
    end

    def transformer
      @transformer ||= RSI.argument_transformer_from_name('identity', self)
    end

    def transformer= value
      @transformer = RSI.argument_transformer_from_name(value, self)
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
      self.function.implementation.module.crate
    end

    def pass_by
      @pass_by || 'value'
    end

    def type
      self.crate.type_from_string(@type) if @type
    end

    def transformer
      @transformer ||= RSI.result_transformer_from_name('foreign', self)
    end

    def transformer= value
      @transformer = RSI.result_transformer_from_name(value, self)
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

    def extern
      @extern != 'false'
    end

    def to_code(trait, indent)
      prototype_args = self.arguments.map { |a| a.to_rust_argument }.select { |a| a }.join(', ')
      prototype_result = case self.results.length
      when 0
        ''
      when 1
        " -> #{self.results[0].to_rust_result_type}"
      else
        " -> (#{self.results.map { |r| r.to_rust_result_type }.join(', ')})"
      end

      a = RSI.indent("#{trait ? '' : 'pub '}fn #{self.name}(#{prototype_args})#{prototype_result} {", indent)
      b = RSI.indent('unsafe {', indent + 1)

      c = self.arguments.map { |a| a.uses(indent + 2) }.select { |a| a }.join('')
      d = self.arguments.map { |a| a.to_preparation_code(indent + 2) }.select { |a| a }.join('')

      e = "#{self.foreign}(#{self.arguments.map { |a| a.to_c_call_argument }.select { |a| a }.join(', ')});"
      e = RSI.indent((self.results.any? { |r| r.needs_foreign_result } ? 'let foreign_result = ' : '') + e, indent + 2)

      f = self.results.map { |r| r.to_postparation_code(indent + 2) }.select { |r| r }.join('')

      g = case self.results.length
      when 0
        ''
      when 1
        RSI.indent("return #{self.results[0].to_rust_result};", indent + 2)
      else
        RSI.indent("return (#{self.results.map(&:to_rust_result).join(', ')});", indent + 2)
      end
      
      h = RSI.indent("}", indent + 1)
      i = RSI.indent("}", indent)

      a + b + c + d + e + f + g + h + i
    end

    def to_extern(indent)
      if self.extern
        prototype_args = self.arguments.map(&:to_c_argument).select { |a| a }.join(', ')
        prototype_result = if r = self.results.find { |r| r.needs_foreign_result }
          " -> #{r.to_c_result_type}"
        end

        a = RSI.indent("fn #{self.foreign}(#{prototype_args})#{prototype_result};", indent)
      end
    end
  end

  class Implementation
    include SAXMachine

    attribute :for
    attribute :trait

    elements :method, as: 'functions', class: RSI::Function

    ancestor :module

    def for_type
      @type ||= RSI::StructType.new(self.for)
    end

    def to_code(indent)
      a = RSI.indent(self.trait ? "impl #{self.trait} for #{self.for} {" : "impl #{self.for} {", indent)
      b = self.functions.map { |m| m.to_code(self.trait, indent + 1) }.join("\n")
      c = RSI.indent("}", indent)
      d = "\n"
      e = RSI.indent("extern {", indent)
      f = self.functions.map { |m| m.to_extern(indent + 1) }.select { |m| m }.join('')
      g = RSI.indent("}", indent)

      a + b + c + d + e + f + g
    end
  end
end