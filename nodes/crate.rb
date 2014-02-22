module RSI
  class Crate
    include SAXMachine

    attribute :name
    
    elements :enum, as: 'enums', class: RSI::Enum
    elements :module, as: 'modules', class: RSI::Module
    elements :struct, as: 'structs', class: RSI::Struct
    elements :library, as: 'libraries', class: RSI::Library
    elements :implementation, as: 'implementations', class: RSI::Implementation

    attr_accessor :root, :filename, :machine
    
    def self.get_xml(root, file)
      f = Nokogiri::XML(File.read("#{root}/#{file}.xml"))

      f.xpath('//module[@file]').each do |m|
        m.replace(get_xml(root, m['file']).root)
      end

      f
    end
    
    def self.from_rsi(filename, machine)
      root = File.dirname(filename)

      self.parse(self.get_xml(root, File.basename(filename)).to_s).tap do |c|
        c.root = root
        c.machine = machine
        c.filename = filename
      end
    end

    def crate
      self
    end

    def type_from_string(string)
      @machine.type_from_string(string)
    end

    def to_code
      [self.libraries, self.enums, self.structs, self.implementations, self.modules].map do |c|
        c.map { |m| m.to_code(0) }.join("\n")
      end.select { |c| c != '' }.join("\n")
    end
  end
end