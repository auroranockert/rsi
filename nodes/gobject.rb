module RSI
  class Method < RSI::Fn
    ancestor :gobject

    def arguments
      unless @argz
        @argz = [RSI::Argument.new.tap do |a|
          a.fn = self
          a.pass_by = 'mut-self'
          a.transformer = 'gobject'
        end] + super
      end

      @argz
    end
  end

  class Interface
    include SAXMachine

    attribute :name

    ancestor :gobject

    def crate
      self.gobject.crate
    end

    def as_name
      'as_' + self.name.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
    end

    def print_code(indent)
      self.crate.print("impl #{self.name} for #{self.gobject.name}Ref {", indent)
      self.crate.print("fn #{self.as_name}(&self) -> *mut std::libc::c_void {", indent + 1)
      self.crate.print("return self.opaque;", indent + 2)
      self.crate.print("}", indent + 1)
      self.crate.print("}", indent)
    end
  end

  class Constructor < RSI::Fn
    ancestor :gobject

    def crate
      self.gobject.crate
    end

    def trait
      nil
    end

    def results
      @results || [RSI::Result.new.tap do |r|
        r.fn = self
        r.type = "{#{self.gobject.type_name}}"
      end]
    end
  end

  class Signal < RSI::Fn
    include SAXMachine

    ancestor :gobject

    def name
      @name.tr('-', '_')
    end

    def crate
      self.gobject.crate
    end

    def as_name
      'as_' + self.gobject.name.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
    end

    def print_code(indent)
      prototype_generics = self.arguments.map { |a| a.to_generic }.select { |a| a }.join(', ')
      prototype_args = self.arguments.map { |a| a.to_rust_type }.select { |a| a }.join(', ')
      prototype_result = case self.results.length
      when 0
        ''
      when 1
        " -> #{self.results[0].to_rust_result_type}"
      else
        " -> (#{self.results.map { |r| r.to_rust_result_type }.join(', ')})"
      end

      self.crate.print("#{self.trait ? '' : 'pub '}fn on_#{self.name}#{prototype_generics != '' ? "<#{prototype_generics}>" : ''}(&mut self, handler: &|#{prototype_args}|#{prototype_result}) -> u64 {", indent)
      self.crate.print('unsafe {', indent + 1)
      self.crate.print("return rsi_connect_on_#{self.name}(self.#{self.as_name}(), \"#{self.name}\".to_c_str().unwrap(), handler_for_on_#{self.name}, std::cast::transmute::<&|#{prototype_args}|#{prototype_result}, *mut std::libc::c_void>(handler), std::ptr::null(), 0);", indent + 2)
      self.crate.print("}", indent + 1)
      self.crate.print("}", indent)
    end

    def print_handler(indent)
      prototype_args = (self.arguments.map { |a| a.to_c_argument } + ["handler: *mut std::libc::c_void"]).select { |a| a }.join(', ')
      prototype_result = case self.results.length
      when 0
        ''
      when 1
        " -> #{self.results[0].to_c_result_type}"
      else
        " -> (#{self.results.map { |r| r.to_c_result_type }.join(', ')})"
      end

      handler_args = self.arguments.map { |a| a.to_rust_argument }.select { |a| a }.join(', ')
      handler_result = case self.results.length
      when 0
        ''
      when 1
        " -> #{self.results[0].to_rust_result_type}"
      else
        " -> (#{self.results.map { |r| r.to_rust_result_type }.join(', ')})"
      end

      self.crate.print("extern \"C\" fn handler_for_on_#{self.name}(#{prototype_args})#{prototype_result} {", indent)
      self.crate.print('unsafe {', indent + 1)

      (self.arguments + self.results).map { |a| a.uses(indent + 2) }
      (self.arguments + self.results).map { |a| a.to_c_preparation_code(indent + 2) }

      self.crate.print("let handler = std::cast::transmute::<*mut std::libc::c_void, &|#{handler_args}|#{handler_result}>(handler);", indent + 2);

      e = "(*handler)(#{self.arguments.map { |a| a.to_rust_call_argument }.select { |a| a }.join(', ')});"
      self.crate.print((self.results.any? { |r| r.needs_foreign_result } ? 'let foreign_result = ' : '') + e, indent + 2)

      (self.arguments + self.results).map { |r| r.to_c_postparation_code(indent + 2) }

      case self.results.length
      when 0
      when 1
        self.crate.print("return #{self.results[0].to_c_result};", indent + 2)
      else
        self.crate.print("return (#{self.results.map { |r| r.to_c_result }.join(', ')});", indent + 2)
      end

      self.crate.print("}", indent + 1)
      self.crate.print("}", indent)
      
    end

    def print_extern(indent)
      prototype_args = self.arguments.map { |a| a.to_c_type }.select { |a| a }.join(', ')
      prototype_result = if r = self.results.find { |r| r.needs_foreign_result }
        " -> #{r.to_c_result_type}"
      end

      self.crate.print('#[link_name = "g_signal_connect_data"]', indent)
      self.crate.print("fn rsi_connect_on_#{self.name}(instance: *mut std::libc::c_void, detailed_signal: *std::libc::c_char, c_handler: extern \"C\" fn(#{prototype_args}, *mut std::libc::c_void)#{prototype_result}, data: *mut std::libc::c_void, destroy_data: *std::libc::c_void, connect_flags: i32) -> u64;", indent)
    end
  end

  class GObject
    include SAXMachine

    attribute :name
    attribute :prefix


    elements :fn, as: 'fns', class: RSI::Method
    elements :signal, as: 'signals', class: RSI::Signal
    elements :interface, as: 'interfaces', class: RSI::Interface
    elements :constructor, as: 'constructors', class: RSI::Constructor

    ancestor :module

    def crate
      self.module.crate
    end

    def trait
      self.name
    end

    def as_name
      'as_' + self.name.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
    end

    def type_name
      "#{self.name}Ref"
    end

    def interfaces
      unless @ifs
        @ifs = [RSI::Interface.new.tap do |i|
          i.name = self.name
          i.gobject = self
        end] + (@interfaces || [])
      end

      @ifs
    end

    def print_code(indent)
      self.crate.print("pub struct #{self.name}Ref {", indent)
      self.crate.print("opaque: *mut std::libc::c_void", indent + 1)
      self.crate.print("}", indent)
      self.crate.print
      if self.constructors.length > 0
        self.crate.print("impl #{self.name}Ref {", indent)
        self.crate.print_list(self.constructors) { |f| f.print_code(indent + 1) }
        self.crate.print("}", indent)
        self.crate.print
      end
      self.crate.print("pub trait #{self.name} {", indent)
      self.crate.print("fn #{self.as_name}(&self) -> *mut std::libc::c_void;", indent + 1)
      self.crate.print
      self.crate.print_list(self.fns + self.signals) { |f| f.print_code(indent + 1) }
      self.crate.print("}", indent)
      self.crate.print
      self.crate.print_list(self.interfaces) { |i| i.print_code(indent) }
      if self.signals.length > 0
        self.crate.print
        self.crate.print_list(self.signals) { |s| s.print_handler(indent) }
      end
      self.crate.print
      self.crate.print("extern {", indent)
      self.constructors.each { |c| c.print_extern(indent + 1) }
      self.signals.each { |s| s.print_extern(indent + 1) }
      self.fns.each { |f| f.print_extern(indent + 1) }
      self.crate.print("}", indent)
    end
  end
end