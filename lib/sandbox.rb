require 'irb'

module Sandbox
  module Workspace; end
  
  @@bad_methods = [
    [:Object, :exit],
    [:Kernel, :exit],
    [:Object, :exit!],
    [:Kernel, :exit!],
    [:Object, :at_exit],
    [:Kernel, :at_exit],
    [:Object, :exec],
    [:Kernel, :exec],
    [:Object, :system],
    [:Kernel, :system],
    [:Object, :remove_method],
    [:Kernel, :remove_method],
    [:Object, :undef_method],
    [:Kernel, :undef_method],
    [:Object, :require],
    [:Kernel, :require],
    [:Object, :require_relative],
    [:Kernel, :require_relative],
    [:Object, "`".to_sym],
    [:Kernel, "`".to_sym],
    [:Class, "`".to_sym]
  ]
  
  @@bad_constants = [:Open3, :File, :Dir, :IO, :Sandbox]
  
  @@unbound_methods = []
  @@unbound_constants = []
  
  def self.unbound_methods
    @@unbound_methods
  end
  
  def self.unbound_constants
    @@unbound_constants
  end
  
  def self.perform(array)
    returning_array = []
    @@binding = TOPLEVEL_BINDING
    Thread.new do
      $SAFE = 2
      array.each_with_index do |line, line_no|
        @@bad_methods.each {|meth| self.remove_method(meth.first, meth.last)}
        @@bad_constants.each {|const| self.remove_constant(const)}
        begin
          returning_array << eval(line, @@binding, "sandbox", line_no)
        rescue Exception => e
          returning_array << "#{e.class}: #{e.to_s}"
        end
        self.restore_constants
        self.restore_methods
      end
    end.join
    returning_array
  end
  
  private
  
  def self.remove_method(klass, method)
    const = Object.const_get(klass.to_s)
    if const.methods.include?(method)
      @@unbound_methods << [const, const.method(method).unbind]
      metaclass = class << const; self; end
      
      metaclass.send(:define_method, method) do |*args|
        raise NameError, "undefined local variable or method `#{method}' for #{klass}:#{const.class}"
      end
      
      const.send(:define_method, method) do |*args|
        raise NameError, "undefined local variable or method `#{method}' for #{klass}:#{const.class}"
      end
    end
  end
  
  def self.remove_constant(constant)
    @@unbound_constants << Object.send(:remove_const, constant) if Object.const_defined?(constant)
  end
  
  def self.restore_constants
    @@unbound_constants.each {|const| Object.const_set(const.to_s.to_sym, const) unless Object.const_defined?(const.to_s.to_sym)}
  end
  
  def self.restore_methods
    @@unbound_methods.each do |unbound|
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
  
end