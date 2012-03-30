module Sandrbox
  class Value
    attr_accessor :line, :line_no, :result, :time, :unbound_methods, :unbound_constants, :error
    
    def initialize(line, line_no)
      self.unbound_methods = []
      self.unbound_constants = []
      self.line = line
      self.line_no = line_no
      evaluate
    end
    
    def evaluate
      t = Thread.new do
        $SAFE = 2
        begin
          Timeout::timeout(0.5) do
            Sandrbox.config.bad_methods.each {|meth| remove_method(meth.first, meth.last)}
            Sandrbox.config.bad_constants.each {|const| remove_constant(const)}
            self.result = eval(line, TOPLEVEL_BINDING, "sandrbox", line_no)
          end
        rescue Exception => e
          self.result = "#{e.class}: #{e.to_s}"
          self.error = true
        ensure
          restore_constants
          restore_methods
        end
      end
      
      timeout = t.join(3)
      if timeout.nil?
        self.result = "SandrboxError: execution expired" 
        self.error = true
      end

      self
    end
    
    def to_s
      self.result
    end
    
    private
      
    def remove_method(klass, method)
      const = Object.const_get(klass.to_s)
      if const.methods.include?(method) || const.instance_methods.include?(method)
        self.unbound_methods << [const, const.method(method).unbind]
        metaclass = class << const; self; end

        message = if const == Object
          "undefined local variable or method `#{method}' for main:Object"
        else
          "undefined local variable or method `#{method}' for #{klass}:#{const.class}"
        end

        metaclass.send(:define_method, method) do |*args|
          raise NameError, message
        end

        const.send(:define_method, method) do |*args|
          raise NameError, message
        end
      end
    end
    
    def restore_methods
      self.unbound_methods.each do |unbound|
        klass = unbound.first
        method = unbound.last

        metaclass = class << klass; self; end

        metaclass.send(:define_method, method.name) do |*args|
          method.bind(klass).call(*args)
        end

        klass.send(:define_method, method.name) do |*args|
          method.bind(klass).call(*args)
        end
      end
    end

    def remove_constant(constant)
      self.unbound_constants << Object.send(:remove_const, constant) if Object.const_defined?(constant)
    end

    def restore_constants
      self.unbound_constants.each {|const| Object.const_set(const.to_s.to_sym, const) unless Object.const_defined?(const.to_s.to_sym)}
    end
        
  end
end