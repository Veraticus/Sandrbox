require 'sandrbox/options/option'

module Sandrbox
  
  module Config
    extend self
    extend Options

    option :bad_methods, :default => [
      [:Object, :abort],
      [:Kernel, :abort],
      [:Object, :autoload],
      [:Kernel, :autoload],
      [:Object, :autoload?],
      [:Kernel, :autoload?],
      [:Object, :callcc],
      [:Kernel, :callcc],
      [:Object, :exit],
      [:Kernel, :exit],
      [:Object, :exit!],
      [:Kernel, :exit!],
      [:Object, :at_exit],
      [:Kernel, :at_exit],
      [:Object, :exec],
      [:Kernel, :exec],
      [:Object, :fork],
      [:Kernel, :fork],
      [:Object, :load],
      [:Kernel, :load],
      [:Object, :open],
      [:Kernel, :open],
      [:Object, :set_trace_func],
      [:Kernel, :set_trace_func],
      [:Object, :spawn],
      [:Kernel, :spawn],
      [:Object, :syscall],
      [:Kernel, :syscall],
      [:Object, :system],
      [:Kernel, :system],
      [:Object, :test],
      [:Kernel, :test],
      [:Object, :remove_method],
      [:Kernel, :remove_method],
      [:Object, :require],
      [:Kernel, :require],
      [:Object, :require_relative],
      [:Kernel, :require_relative],
      [:Object, :undef_method],
      [:Kernel, :undef_method],
      [:Object, "`".to_sym],
      [:Kernel, "`".to_sym],
      [:Class, "`".to_sym]
    ]
    option :bad_constants, :default => [:Continuation, :Open3, :File, :Dir, :IO, :Sandrbox, :Process, :Thread, :Fiber, :Gem, :Net, :ThreadGroup, :SystemExit, :SignalException, :Interrupt, :FileTest, :Signal]
    
  end
end