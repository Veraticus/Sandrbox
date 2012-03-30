require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Sandrbox" do

  it 'performs arbitrary correct irb commands' do
    Sandrbox.perform(['a = 1 + 1', 'a + a', 'a * a']).output.should == [2, 4, 4]
  end
  
  it 'returns syntax errors immediately' do
    Sandrbox.perform(['a = 1 + 1', 'b', 'a * a']).output.should == [2, "NameError: undefined local variable or method `b' for main:Object", 4]
  end
  
  it 'allows constants to be used after uninitializing them' do
    Sandrbox.perform(['a = 1 + 1'])
    lambda {Object.const_get(:File)}.should_not raise_error
  end
  
  it 'allows methods to be called after removing them' do
    Sandrbox.perform(['a = 1 + 1'])
    Kernel.methods.should include(:exit)
  end
  
  it 'only waits half a second for each command' do
    Sandrbox.perform(['sleep 5']).output.should == ["Timeout::Error: execution expired"]
  end
  
  it 'does multiline class definitions correctly' do
    Sandrbox.perform(['class Foo', 'def test', '"hi"', 'end', 'end', 'Foo.new.test']).output.should == [nil, "hi"]
  end
  
  it 'removes previous class definitions and methods between calls' do
    Sandrbox.perform(['class Foo', 'def test', '"hi"', 'end', 'end'])
    Sandrbox.perform(['Foo.new.test']).output.should == ["NameError: uninitialized constant Foo"]
  end
  
  context 'unsafe commands' do
    it 'does not exit' do
      Sandrbox.perform(['exit']).output.should == ["NameError: undefined local variable or method `exit' for main:Object"]
    end
    
    it 'does not exit for kernel' do
      Sandrbox.perform(['Kernel.exit']).output.should == ["NameError: undefined local variable or method `exit' for Kernel:Module"]
    end
    
    it 'does not exec' do
      Sandrbox.perform(['exec("ps")']).output.should == ["NameError: undefined local variable or method `exec' for main:Object"]
    end
    
    it 'does not exec for kernel' do
      Sandrbox.perform(['Kernel.exec("ps")']).output.should == ["NameError: undefined local variable or method `exec' for Kernel:Module"]
    end
    
    it 'does not `' do
      Sandrbox.perform(['`ls`']).output.should == ["NameError: undefined local variable or method ``' for main:Object"]
    end
    
    it 'does not implement File' do
      Sandrbox.perform(['File']).output.should == ["NameError: uninitialized constant File"]
    end
    
    it 'does not implement Dir' do
      Sandrbox.perform(['Dir']).output.should == ["NameError: uninitialized constant Dir"]
    end
    
    it 'does not implement IO' do
      Sandrbox.perform(['IO']).output.should == ["NameError: uninitialized constant IO"]
    end
    
    it 'does not implement Open3' do
      Sandrbox.perform(['Open3']).output.should == ["NameError: uninitialized constant Open3"]
    end
    
    it 'does not implement Open3 even after requiring it' do
      Sandrbox.perform(['require "open3"', 'Open3']).output.should == ["NameError: undefined local variable or method `require' for main:Object", "NameError: uninitialized constant Open3"]
    end
    
    it 'does not allow you to manually call protected Sandrbox methods' do
      Sandrbox.perform(['Sandrbox Sandrbox.inspect']).output.should == ["NameError: uninitialized constant Sandrbox"]
    end
    
    it 'does not allow you to manually call children of removed classes' do
      Sandrbox.perform(['Sandrbox Sandrbox::Config.inspect']).output.should == ["NameError: uninitialized constant Sandrbox"]
    end
  end
end
