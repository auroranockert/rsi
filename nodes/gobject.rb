module RSI
  class Method < RSI::Fn
    ancestor :gobject

    def arguments
      unless @argz
        @argz = [RSI::Argument.new.tap do |a|
          a.fn = self
          a.pass_by = 'mut-self'
          a.transformer = 'gobject-self'
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

  class GObject
    include SAXMachine


    attribute :name
    attribute :prefix


    elements :fn, as: 'fns', class: RSI::Method
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
      self.crate.print_list(self.fns) { |f| f.print_code(indent + 1) }
      self.crate.print("}", indent)
      self.crate.print
      self.crate.print_list(self.interfaces) { |i| i.print_code(indent) }
      self.crate.print
      self.crate.print("extern {", indent)
      self.constructors.each { |c| c.print_extern(indent + 1) }
      self.fns.each { |f| f.print_extern(indent + 1) }
      self.crate.print("}", indent)
    end
  end
end