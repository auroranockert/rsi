module RSI
  class Fn
    include SAXMachine

    attribute :name
    attribute :extern
    attribute :foreign

    attribute :value
    attribute :transformer

    elements :argument, as: 'arguments', class: RSI::Argument
    elements :result, as: 'results', class: RSI::Result

    ancestor :ancestor

    def for
      self.ancestor.for
    end
    
    def trait
      self.ancestor.trait
    end

    def crate
      self.ancestor.crate
    end

    def extern
      @extern != 'false'
    end

    def foreign
      @foreign || "#{self.ancestor.prefix}#{self.name}"
    end

    def print_code(indent)
      prototype_generics = self.arguments.map { |a| a.to_generic }.select { |a| a }.join(', ')
      prototype_args = self.arguments.map { |a| a.to_rust_argument }.select { |a| a }.join(', ')
      prototype_result = case self.results.length
      when 0
        ''
      when 1
        " -> #{self.results[0].to_rust_result_type}"
      else
        " -> (#{self.results.map { |r| r.to_rust_result_type }.join(', ')})"
      end

      self.crate.print("#{self.trait ? '' : 'pub '}fn #{self.name}#{prototype_generics != '' ? "<#{prototype_generics}>" : ''}(#{prototype_args})#{prototype_result} {", indent)
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
end