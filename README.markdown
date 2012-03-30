# Sandrbox

Sandrbox allows you to execute arbitrary Ruby code while being assured it won't destroy your life (or your server). It's intended to be small, fast, and secure. I built it to replace TryRuby's really slow Ruby sandrbox, since I wanted something faster.

Note that while I made a concentrated effort to make this secure, it's still possible it's not. I wouldn't run this code outside of a secure prison of some sort, and definitely not anything connected to a database whose data you care about. (I intend to run this on Heroku.)

## Set It Up

I automatically remove all the bad methods and classes I can think of. But maybe you need more:

```ruby
Sandrbox.configure do |config|
  config.bad_classes << [:Rails]
  config.bad_classes << [:ActiveRecord]
end
```

## How To Use It

```ruby
require 'sandrbox'

Sandrbox.perform(['a = 1']).output # => [1]
Sandrbox.perform(['a = 1', 'a = a + a', 'a ** a']).output # => [1, 2, 4]
Sandrbox.perform(['a = 1', 'a = a + a', 'a ** b']).output # => [1, 2, "NameError: undefined local variable or method `b' for main:Object"] 

Sandrbox.perform(['`rm -rf /`']).output # => ["NameError: undefined local variable or method ``' for Kernel:Module"]
Sandrbox.perform(['exec("rm -rf /")']).output # => ["NameError: undefined local variable or method `exec' for main:Object"] 
Sandrbox.perform(['Kernel.exec("rm -rf /")']).output # => ["NameError: undefined local variable or method `exec' for Kernel:Module"]

Sandrbox.perform(['require "open3"']).output # => ["NameError: undefined local variable or method `require' for main:Object"]

Sandrbox.perform(['class Foo', 'def test', '"hi"', 'end', 'end']).output # => [nil]
Sandrbox.perform(['class Foo', 'def test', '"hi"', 'end', 'end', 'Foo.new.test']).output # => [nil, "hi"]
Sandrbox.perform(['Foo.new.test']).output # => ["NameError: uninitialized constant Foo"] Each perform is independent of previous performs

Sandrbox.perform(['class Foo']).output # => []
Sandrbox.perform(['class Foo']).complete? # => false
Sandrbox.perform(['class Foo']).indent_level # => 1
Sandrbox.perform(['class Foo']).indent_character # => class
```

## Copyright

Copyright (c) 2012 Josh Symonds. See LICENSE.txt for further details.
