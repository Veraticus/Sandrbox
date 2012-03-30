require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Sandbox" do

  it 'performs arbitrary correct irb commands' do
    Sandbox.perform(['a = 1 + 1', 'a + a', 'a * a']).output.should == [2, 4, 4]
  end
  
  it 'returns syntax errors immediately' do
    Sandbox.perform(['a = 1 + 1', 'b', 'a * a']).output.should == [2, "NameError: undefined local variable or method `b' for main:Object", 4]
  end
  
  it 'allows constants to be used after uninitializing them' do
    Sandbox.perform(['a = 1 + 1'])
    lambda {Object.const_get(:File)}.should_not raise_error
  end
  
  it 'allows methods to be called after removing them' do
    Sandbox.perform(['a = 1 + 1'])
    Kernel.methods.should include(:exit)
  end
  
  it 'only waits half a second for each command' do
    Sandbox.perform(['sleep 5']).output.should == ["Timeout::Error: execution expired"]
  end
  
  it 'does multiline class definitions correctly' do
    Sandbox.perform(['class Foo', 'def test', '"hi"', 'end', 'end', 'Foo.new.test']).output.should == [nil, "hi"]
  end
  
  context 'unsafe commands' do
    it 'does not exit' do
      Sandbox.perform(['exit']).output.should == ["NameError: undefined local variable or method `exit' for main:Object"]
    end
    
    it 'does not exit for kernel' do
      Sandbox.perform(['Kernel.exit']).output.should == ["NameError: undefined local variable or method `exit' for Kernel:Module"]
    end
    
    it 'does not exec' do
      Sandbox.perform(['exec("ps")']).output.should == ["NameError: undefined local variable or method `exec' for main:Object"]
    end
    
    it 'does not exec for kernel' do
      Sandbox.perform(['Kernel.exec("ps")']).output.should == ["NameError: undefined local variable or method `exec' for Kernel:Module"]
    end
    
    it 'does not `' do
      Sandbox.perform(['`ls`']).output.should == ["NameError: undefined local variable or method ``' for main:Object"]
    end
    
    it 'does not implement File' do
      Sandbox.perform(['File']).output.should == ["NameError: uninitialized constant File"]
    end
    
    it 'does not implement Dir' do
      Sandbox.perform(['Dir']).output.should == ["NameError: uninitialized constant Dir"]
    end
    
    it 'does not implement IO' do
      Sandbox.perform(['IO']).output.should == ["NameError: uninitialized constant IO"]
    end
    
    it 'does not implement Open3' do
      Sandbox.perform(['Open3']).output.should == ["NameError: uninitialized constant Open3"]
    end
    
    it 'does not implement Open3 even after requiring it' do
      Sandbox.perform(['require "open3"', 'Open3']).output.should == ["NameError: undefined local variable or method `require' for main:Object", "NameError: uninitialized constant Open3"]
    end
    
    it 'does not allow you to manually call protected Sandbox methods' do
      Sandbox.perform(['raise Sandbox.inspect']).output.should == ["NameError: uninitialized constant Sandbox"]
    end
    
    it 'does not allow you to manually call children of removed classes' do
      Sandbox.perform(['raise Sandbox::Config.inspect']).output.should == ["NameError: uninitialized constant Sandbox"]
    end
  end
end
