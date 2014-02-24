module RSI
  class Method < RSI::Fn
    include SAXMachine

    ancestor :gobject

    def arguments
      unless @argz
        @argz = [RSI::Argument.new.tap do |a|
          a.fn = self
          a.pass_by = 'mut-self'
          a.transformer = 'opaque'
        end] + super
      end

      @argz
    end
  end

  class Constructor < RSI::Fn
    ancestor :gobject

    def results
      @results || [RSI::Result.new.tap do |r|
        r.fn = self
        r.type = "{#{self.gobject.type_name}}"
      end]
    end
  end

  class GObject
    include SAXMachine


    attribute :name
    attribute :prefix

    elements :fn, as: 'fns', class: RSI::Method
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

    def print_code(indent)
      self.crate.print("pub struct #{self.name}Ref {", indent)
      self.crate.print("opaque: *mut std::libc::c_void", indent + 1)
      self.crate.print("}", indent)
      self.crate.print
      self.crate.print("trait #{self.name} {", indent)
      self.crate.print("fn #{self.as_name}(&self) -> *std::libc::c_void;", indent + 1)
      self.crate.print
      self.crate.print_list(self.constructors + self.fns) { |f| f.print_code(indent + 1) }
      self.crate.print("}", indent)
      self.crate.print
      self.crate.print("impl #{self.name} for #{self.name}Ref {", indent)
      self.crate.print("fn #{self.as_name}(&self) -> *std::libc::c_void {", indent + 1)
      self.crate.print("return self.opaque;", indent + 2)
      self.crate.print("}", indent + 1)
      self.crate.print("}", indent)
      self.crate.print('')
      self.crate.print("extern {", indent)
      self.constructors.each { |c| c.print_extern(indent + 1) }
      self.fns.each { |f| f.print_extern(indent + 1) }
      self.crate.print("}", indent)
    end
  end
end