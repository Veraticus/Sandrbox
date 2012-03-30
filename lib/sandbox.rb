require 'irb'
#require 'fakefs'

module Sandbox
  module Workspace; end
  
  @@methods = [
    [:Object, :exit],
    [:Kernel, :exit],
    [:Object, :exit!],
    [:Kernel, :exit!],
    [:Object, :at_exit],
    [:Kernel, :at_exit],
    [:Object, :exec],
    [:Kernel, :exec],
    [:Object, :undef_method],
    [:Kernel, :undef_method],
    [:Object, :remove_method],
    [:Kernel, :remove_method]
  ]
  
  @@constants = [:Open3, :File, :Dir, :IO]
  
  @@unbound_methods = []
  @@unbound_constants = []
  
  def self.perform(array)
    returning_array = []
    @@binding = TOPLEVEL_BINDING
    Thread.new do
      $SAFE = 2
      array.each_with_index do |line, line_no|
        @@methods.each {|meth| self.remove_method(meth.first, meth.last)}
        @@constants.each {|const| self.remove_constant(const)}
        begin
          returning_array << eval(self.sanitize(line), @@binding, "sandbox", line_no)
        rescue Exception => e
          returning_array << "#{e.class}: #{e.to_s}"
        end
        self.restore_constants
        self.restore_methods
      end
    end.join
    returning_array
  end
  
  def self.sanitize(line)
    line.gsub('`','')
  end
  
  private
  
  def self.remove_method(klass, method)
    const = Object.const_get(klass.to_s)
    if const.methods.include?(method)
      @@unbound_methods << const.method(method)
      eval("class <<#{klass}; def #{method}(*args); raise NameError, \"undefined local variable or method `#{method}'\"; end; end; #{klass}.send(:define_method, :#{method}) {|*args| raise NameError, \"undefined local variable or method `#{method}'\"}", @@binding, "inner_irb", 0) 
    end
  end
  
  def self.remove_constant(constant)
    @@unbound_constants << Object.send(:remove_const, constant) if Object.const_defined?(constant)
  end
  
  def self.restore_constants
    @@unbound_constants.each {|const| Object.const_set(const.to_s.to_sym, const) unless Object.const_defined?(const.to_s.to_sym)}
  end
  
  def self.restore_methods
    @@unbound_methods.each {|meth| meth.class.send(:define_method, meth.name) {|*args| meth.call(*args)}}
  end
  
end