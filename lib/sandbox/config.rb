require 'sandbox/options/option'

module Sandbox
  
  module Config
    extend self
    extend Options

    option :bad_methods, :default => [
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
    option :bad_constants, :default => [:Open3, :File, :Dir, :IO, :Sandbox, :Process, :Thread, :Fiber]
    
  end
end