module RSI
  class Argument
    include XML::Mapping

    root_element_name :argument

    text_node :name, '@name', optional: true
    text_node :ty, '@type', optional: true

    text_node :pass_by, '@pass_by', default_value: 'value'

    text_node :trans, '@transformer', optional: true

    def type
      @type ||= RSI.type_from_string(self.ty)
    end

    def transformer
      @transformer ||= RSI.argument_transformer_from_name(self.trans || 'identity', self)
    end

    def to_rust_argument
      self.transformer.to_rust_argument
    end

    def to_c_argument
      self.transformer.to_c_argument
    end

    def to_c_call_argument
      self.transformer.to_c_call_argument
    end

    def uses(indent)
      self.transformer.uses(indent)
    end

    def to_preparation_code(indent)
      self.transformer.to_preparation_code(indent)
    end
  end

  class Result
    include XML::Mapping

    root_element_name :result

    text_node :name, '@name', optional: true
    text_node :ty, '@type', optional: true

    text_node :pass_by, '@pass_by', default_value: 'value'

    text_node :trans, '@transformer', optional: true

    def type
      @type ||= RSI.type_from_string(self.ty)
    end

    def transformer
      @transformer ||= RSI.result_transformer_from_name(self.trans || 'foreign', self)
    end

    def to_rust_result
      self.transformer.to_rust_result
    end

    def to_rust_result_type
      self.transformer.to_rust_result_type
    end

    def to_c_result
      self.transformer.to_c_result
    end

    def to_c_result_type
      self.transformer.to_c_result_type
    end

    def needs_foreign_result
      self.transformer.needs_foreign_result
    end
    
    def to_postparation_code(indent)
      self.transformer.to_postparation_code(indent)
    end
  end

  class Method
    include XML::Mapping

    root_element_name :method

    text_node :name, '@name'
    text_node :foreign, '@foreign'
    boolean_node :extern, '@extern', 'true', 'false', default_value: true

    array_node :arguments, 'argument', class: RSI::Argument, default_value: []
    array_node :results, 'result', class: RSI::Result, default_value: []

    def to_code(trait, indent)
      prototype_args = self.arguments.map(&:to_rust_argument).select { |a| a }.join(', ')
      prototype_result = case self.results.length
      when 0
        ''
      when 1
        " -> #{self.results[0].to_rust_result_type}"
      else
        " -> (#{self.results.map(&:to_rust_result_type).join(', ')})"
      end

      a = RSI.indent("#{trait ? '' : 'pub '}fn #{self.name}(#{prototype_args})#{prototype_result} {", indent)
      b = RSI.indent('unsafe {', indent + 1)

      c = self.arguments.map { |a| a.uses(indent + 2) }.select { |a| a }.join('')
      d = self.arguments.map { |a| a.to_preparation_code(indent + 2) }.select { |a| a }.join('')

      e = "#{self.foreign}(#{self.arguments.map(&:to_c_call_argument).select { |a| a }.join(', ')});"
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
    include XML::Mapping

    root_element_name :implementation

    text_node :for, '@for'
    text_node :trait, '@trait', default_value: nil

    array_node :methods, 'method', class: RSI::Method, default_value: []

    def for_type
      @type ||= RSI::StructType.new(self.for)
    end

    def to_code(indent)
      a = RSI.indent(self.trait ? "impl #{self.trait} for #{self.for} {" : "impl #{self.for} {", indent)
      b = self.methods.map { |m| m.to_code(self.trait, indent + 1) }.join("\n")
      c = RSI.indent("}", indent)
      d = "\n"
      e = RSI.indent("extern {", indent)
      f = self.methods.map { |m| m.to_extern(indent + 1) }.select { |m| m }.join('')
      g = RSI.indent("}", indent)

      a + b + c + d + e + f + g
    end
  end
end