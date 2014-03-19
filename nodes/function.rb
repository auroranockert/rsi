module RSI
  class FunctionParameter < RSI::Node
    attr_accessor :name, :type, :immutable

    def prepare(name = nil, type = nil)
      @name = name || @node.try(:[], 'name')
      @type, @type_name = type, @node.try(:[], 'type')
      @immutable = (@node.try(:[], 'immutable') == 'true')
      @pass_by = @node.try(:[], 'pass-by')
    end

    def type
      if @type
        @type
      elsif @type_name
        if t = self.context.lookup_type(@type_name, self)
          t
        else
          raise "Could not resolve type #{@type_name} for argument #{self.name} of #{self.parent.name}"
        end
      else
        raise "Could not resolve type for argument #{self.name} of #{self.parent.name}"
      end
    end

    def immutable?
      @immutable
    end

    def to_native_prototype
      self.type.try_or("#{self.prefix}_as_native_prototype") do
        self.try(:as_native_prototype)
      end
    end

    def to_native_result
      self.type.try_or("#{self.prefix}_as_native_result") do
        self.try(:as_native_result)
      end
    end

    def to_foreign_prototype
      self.type.try_or("#{self.prefix}_as_foreign_prototype") do
        self.try(:as_foreign_prototype)
      end
    end

    def to_foreign_argument
      self.type.try_or("#{self.prefix}_as_foreign_argument") do
        self.try(:as_foreign_argument)
      end
    end

    def to_foreign_result
      self.type.try_or("#{self.prefix}_as_foreign_result") do
        self.try(:as_foreign_result)
      end
    end

    def uses
      self.type.try_or("#{self.prefix}_uses") do
        self.type.try(:uses)
      end
    end

    def prelude
      self.type.try_or("#{self.prefix}_prelude") do
        self.type.try_or(:prelude) do
          self.try(:default_prelude)
        end
      end
    end

    def postlude
      self.type.try_or("#{self.prefix}_postlude") do
        self.type.try_or(:postlude) do
          self.try(:default_postlude)
        end
      end
    end
  end

  class FunctionArgument < FunctionParameter
    def prefix
      'arg'
    end

    def as_native_prototype
      self.render('function/native-prototype/argument')
    end

    def to_foreign_prototype
      self.render('function/foreign-prototype/argument')
    end

    def to_foreign_argument
      self.render('function/foreign-call/argument')
    end

    def inspect
      "FunctionArgument { name: #{self.name.inspect}, type: #{self.type.inspect} }"
    end
  end

  class FunctionSelf < FunctionParameter
    def prepare(type = nil)
      super('self', type)
    end

    def prefix
      'self'
    end

    def as_native_prototype
      self.render('function/native-prototype/self')
    end

    def as_foreign_prototype
      self.render('function/foreign-prototype/self')
    end

    def as_foreign_argument
      self.render('function/foreign-call/argument')
    end

    def inspect
      "FunctionSelf { type: #{self.type.inspect} }"
    end
  end

  class FunctionResult < FunctionParameter
    def prepare(name = nil, type = nil)
      super(name || 'foreign_result', type)
    end

    def prefix
      'result'
    end

    def foreign_result
      self.name
    end

    def as_native_result
      self.render('function/native-result/result')
    end

    def inspect
      "FunctionResult { type: #{self.type.inspect} }"
    end
  end

  class FunctionOut < FunctionParameter
    def prepare(name = nil, type = nil)
      super(name, type)
    end

    def prefix
      'out'
    end

    def to_foreign_prototype
      self.render('function/foreign-prototype/out')
    end

    def to_foreign_argument
      if self.type.respond_to? :out_as_foreign_argument
        self.type.out_as_foreign_argument
      else
        self.render('function/foreign-call/out')
      end
    end

    def to_native_result
      self.render('function/native-result/out')
    end

    def default_prelude
      self.render('function/prelude/out')
    end

    def inspect
      "FunctionOut { name: #{self.name.inspect}, type: #{self.type.inspect} }"
    end
  end

  class Function < RSI::Node
    attr_reader :name, :arguments, :results, :foreign

    def prepare
      @name, @foreign, @extern = @node['name'], @node['foreign'] || (@parent.prefix + @node['name']), (@node['extern'] != 'false')

      self.create_children(arg: RSI::FunctionArgument, self: RSI::FunctionSelf, result: RSI::FunctionResult, out: RSI::FunctionOut)

      case self.function_type
      when :constructor
        r = FunctionResult.new(self.context, self, nil, nil, self.context.lookup_type(parent.qualified_name, self))

        self.children.unshift(r)
      when :method
        s = FunctionSelf.new(self.context, self, nil, self.context.lookup_type(parent.qualified_name, self))
        s.immutable = (@node['immutable'] == 'true')

        self.children.unshift(s)
      end

      @arguments = self.children.select do |x|
        case x
        when RSI::FunctionArgument, RSI::FunctionSelf
          true
        end
      end

      @results = self.children.select do |x|
        case x
        when RSI::FunctionResult, RSI::FunctionOut
          true
        end
      end
    end

    def extern?
      @extern
    end

    def function_type
      case self.node.name
      when 'method'
        :method
      when 'constructor'
        :constructor
      when 'fn'
        :function
      else
        raise "Unknown function type #{self.node.name.inspect}"
      end
    end

    def immutable_self?
      @immutable_self || false
    end

    def method?
      self.function_type == :method
    end

    def constructor?
      self.function_type == :constructor
    end

    def to_code
      self.render('function/function', 1)
    end

    def to_extern
      self.render('function/extern', 1) if self.extern?
    end

    def inspect
      "Function { name: #{self.name}, type: #{self.function_type}, arguments: #{self.arguments}, results: #{self.results} }"
    end
  end
end