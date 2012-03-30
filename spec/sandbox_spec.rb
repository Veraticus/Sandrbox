require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Sandbox" do

  it 'performs arbitrary correct irb commands' do
    Sandbox.perform(['a = 1 + 1', 'a + a', 'a * a']).should == [2, 4, 4]
  end
  
  it 'returns syntax errors immediately' do
    Sandbox.perform(['a = 1 + 1', 'b', 'a * a']).should == [2, "NameError: undefined local variable or method `b' for main:Object", 4]
  end
  
  it 'allows constants to be used after uninitializing them' do
    Sandbox.perform(['a = 1 + 1'])
    lambda {Object.const_get(:File)}.should_not raise_error(NameError)
  end
  
  it 'allows methods to be called after removing them' do
    Sandbox.perform(['a = 1 + 1'])
    Kernel.methods.should include(:exit)
  end
  
  context 'unsafe commands' do
    it 'does not exit' do
      Sandbox.perform(['exit']).should == ["NameError: undefined local variable or method `exit'"]
    end
    
    it 'does not exit for kernel' do
      Sandbox.perform(['Kernel.exit']).should == ["NameError: undefined local variable or method `exit'"]
    end
    
    it 'does not exec' do
      Sandbox.perform(['exec("ps")']).should == ["NameError: undefined local variable or method `exec'"]
    end
    
    it 'does not exec for kernel' do
      Sandbox.perform(['Kernel.exec("ps")']).should == ["NameError: undefined local variable or method `exec'"]
    end
    
    it 'does not `' do
      Sandbox.perform(['`ls`']).should == ["NameError: undefined local variable or method `ls' for main:Object"]
    end
    
    it 'does not implement File' do
      Sandbox.perform(['File']).should == ["NameError: uninitialized constant File"]
    end
    
    it 'does not implement Dir' do
      Sandbox.perform(['Dir']).should == ["NameError: uninitialized constant Dir"]
    end
    
    it 'does not implement IO' do
      Sandbox.perform(['IO']).should == ["NameError: uninitialized constant IO"]
    end
    
    it 'does not implement Open3' do
      Sandbox.perform(['Open3']).should == ["NameError: uninitialized constant Open3"]
    end
    
    it 'does not implement Open3 even after requiring it' do
      Sandbox.perform(['require "open3"', 'Open3']).should == [false, "NameError: uninitialized constant Open3"]
    end
    
    it 'does not allow you to manually call protected Sandbox methods' do
      raise Sandbox.perform(['Sandbox.class_variable_get("@@unbound_constants".to_sym).first']).inspect
    end
  end
end
