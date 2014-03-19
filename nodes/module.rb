module RSI
  class Module < RSI::Context
    def initialize(context, parent, node)
      @document, @dirname = *context.find_rsi(node['file'], parent.dirname)

      @context, @parent, @node = context, parent, @document.at_xpath('/mod')

      self.prepare
    end
    
    def dirname
      @dirname
    end

    def find_rsi(*args)
      self.context.find_rsi(*args)
    end

    def path
      "#{self.parent.name}::#{self.name}"
    end

    def types
      self.context.types
    end

    def extern
      @extern || 'false'
    end

    def extern?
      self.extern == 'true'
    end

    def to_code
      output, directory = self.render('mod'), "#{self.context.output}/#{self.name}"

      # FileUtils.mkdir_p(directory)
      # File.open("#{directory}/mod.rs", 'w+') do |f|
      #   f.write(output.each_line.map { |x| x.chomp }.join("\n"))
      # end
      #
      # "pub mod #{self.name};"
      
      output
    end
  end
end