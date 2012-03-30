# Sandbox

Sandbox allows you to execute arbitrary Ruby code while being assured it won't destroy your life (or your server). It's intended to be small, fast, and secure. I built it to replace TryRuby's really slow Ruby sandbox, since I wanted something faster.

## How To Use It

```ruby
require 'sandbox'

Sandbox.perform(['a = 1']) # => [1]
Sandbox.perform(['a = 1', 'a = a + a', 'a ** a']) # => [1, 2, 4]
Sandbox.perform(['a = 1', 'a = a + a', 'a ** b']) # => [1, 2, "NameError: undefined local variable or method `b' for main:Object"] 

Sandbox.perform(['`rm -rf /`']) # => ["NameError: undefined local variable or method ``' for Kernel:Module"]
Sandbox.perform(['exec("rm -rf /")']) # => ["NameError: undefined local variable or method `exec' for main:Object"] 
Sandbox.perform(['Kernel.exec("rm -rf /")']) # => ["NameError: undefined local variable or method `exec' for Kernel:Module"]

Sandbox.perform(['require "open3"']) # => ["NameError: undefined local variable or method `require' for main:Object"]

```

## Copyright

Copyright (c) 2012 Josh Symonds. See LICENSE.txt for further details.
