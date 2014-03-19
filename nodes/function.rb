module RSI
  class FunctionParameter < RSI::Node
    attr_accessor :name, :type, :type_name, :immutable

    def prepare(name = nil, type = nil)
      @name = name || @node.try(:[], 'name')
      @type, @type_name = type, @node.try(:[], 'type')
      @immutable = (@node.try(:[], 'immutable') == 'true')
      @pass_by = @node.try(:[], 'pass-by')
    end

    def type
      if @type
        @type
      elsif self.type_name
        self.context.lookup_type(self.type_name, self)
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

    def to_native_result_prototype
      self.type.try_or("#{self.prefix}_as_native_result_prototype") do
        self.try(:as_native_result_prototype)
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
    def prepare
      super('self')
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
    def prepare(name = nil)
      super(name || 'foreign_result')
    end

    def prefix
      'result'
    end

    def foreign_result
      self.name
    end

    def as_native_result_prototype
      self.render('function/native-prototype-result/result')
    end

    def as_native_result
      self.render('function/native-result/result')
    end

    def inspect
      "FunctionResult { type: #{self.type.inspect} }"
    end
  end

  class FunctionOut < FunctionParameter
    def prepare(name = nil)
      super(name)
    end

    def prefix
      'out'
    end

    def as_foreign_prototype
      self.render('function/foreign-prototype/out')
    end

    def as_foreign_argument
      self.render('function/foreign-call/out')
    end

    def as_native_result_prototype
      self.render('function/native-prototype-result/result')
    end

    def as_native_result
      self.render('function/native-result/out')
    end

    def default_prelude
      self.render('function/prelude/out')
    end

    def inspect
      "FunctionOut { name: #{self.name.inspect}, type: #{self.type.inspect} }"
    end
  end

  class FunctionInOut < FunctionParameter
    def prefix
      'inout'
    end

    def as_foreign_prototype
      self.render('function/foreign-prototype/out')
    end

    def as_foreign_argument
      self.render('function/foreign-call/out')
    end

    def as_native_prototype
      self.render('function/native-prototype/argument')
    end

    def as_native_result_prototype
      self.render('function/native-prototype-result/result')
    end

    def as_native_result
      self.render('function/native-result/out')
    end

    def default_prelude
      self.render('function/prelude/inout')
    end

    def inspect
      "FunctionInOut { name: #{self.name.inspect}, type: #{self.type.inspect} }"
    end
  end

  class FunctionConstant < FunctionParameter
    def prefix
      'constant'
    end

    def value
      self.node['value']
    end

    def as_foreign_prototype
      self.render('function/foreign-prototype/argument')
    end

    def as_foreign_argument
      self.render('function/foreign-call/constant')
    end

    def inspect
      "FunctionConstant { name: #{self.name.inspect}, value: #{self.value.inspect} }"
    end
  end

  class Function < RSI::Node
    attr_reader :name, :foreign

    def prepare
      @name, @foreign, @extern = @node['name'], @node['foreign'] || (@parent.prefix + @node['name']), (@node['extern'] != 'false')

      self.create_children(arg: RSI::FunctionArgument, self: RSI::FunctionSelf, result: RSI::FunctionResult, out: RSI::FunctionOut, inout: RSI::FunctionInOut, constant: RSI::FunctionConstant)

      case self.node.name
      when 'constructor'
        p = FunctionResult.new(self.context, self, nil, nil).tap do |r|
          r.type_name = self.parent.qualified_name
        end

        self.children.unshift(p)
      when 'method'
        p = FunctionSelf.new(self.context, self, nil).tap do |s|
          s.type_name = self.parent.qualified_name
          s.immutable = (@node['immutable'] == 'true')
        end

        self.children.unshift(p)
      end
    end

    def extern?
      @extern
    end

    def to_code
      self.render('function/function', 1)
    end

    def to_extern
      self.render('function/extern', 1) if self.extern?
    end

    def inspect
      "Function { name: #{self.name}, children: #{self.children} }"
    end
  end
end