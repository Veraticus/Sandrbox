require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Sandbox::Response" do
  it 'initializes values correctly' do
    @response = Sandbox::Response.new([])
    
    @response.class_count.should == 0
    @response.module_count.should == 0
    @response.def_count.should == 0
    @response.end_count.should == 0
    @response.do_count.should == 0
    @response.left_curly_count.should == 0
    @response.right_curly_count.should == 0
    @response.compressed_array.should == []
  end
  
  it 'expands semicolons into new lines' do
    Sandbox::Response.new(['class Test; def foo; "hi"; end; end']).expanded_array == ['class Test', 'def foo', '"hi"', 'end', 'end']
  end
  
  it 'detects class correctly' do
    Sandbox::Response.new(['class Test < ActiveRecord::Base']).class_count.should == 1
  end
  
  it 'detects module correctly' do
    Sandbox::Response.new(['  module Enumerable']).module_count.should == 1
  end
  
  it 'detects def correctly' do
    Sandbox::Response.new(['def method(test)']).def_count.should == 1
  end
  
  it 'detects end correctly' do
    Sandbox::Response.new(['   end']).end_count.should == 1
  end
  
  it 'detects do correctly' do
    Sandbox::Response.new(['test.each do |foo, wee|']).do_count.should == 1
  end
  
  it 'detects left curly correctly' do
    Sandbox::Response.new(['test.each { |foo| ']).left_curly_count.should == 1
  end
  
  it 'detects right curly correctly' do
    Sandbox::Response.new([' } ']).right_curly_count.should == 1
  end
  
  it 'detects left bracket correctly' do
    Sandbox::Response.new(['[ "test", ']).left_bracket_count.should == 1
  end
  
  it 'detects right curly correctly' do
    Sandbox::Response.new(['] ']).right_bracket_count.should == 1
  end
  
  it 'compresses multiline statements into one line' do
    Sandbox::Response.new(['class Test', 'def foo', '"hi"', 'end', 'end']).compressed_array.should == ['class Test;def foo;"hi";end;end;']
  end
  
  it 'ignores comments in parsing' do
    response = Sandbox::Response.new([]).uncomment('def method(test) # end class module').should == 'def method(test)'
  end
  
  it 'correctly determines a line is complete for def, class, module, do and end' do
    Sandbox::Response.new(['class Test; def foo; "hi"; end; end']).should be_complete
    Sandbox::Response.new(['class Test', 'def foo', '"hi"', 'end', 'end']).should be_complete
    Sandbox::Response.new(['module Wee', '[1, 2, 3].each do |num|', '"#{num}"', 'end', 'end']).should be_complete
  end
  
  it 'correctly determines a line is incomplete for def, class, module, do and end' do
    Sandbox::Response.new(['class Test; def foo; "hi"; end']).should_not be_complete
    Sandbox::Response.new(['class Test', 'def foo', '"hi"', 'end']).should_not be_complete
    Sandbox::Response.new(['module Wee', '[1, 2, 3].each do |num|', '"#{num}"']).should_not be_complete
  end
  
  it 'correctly determines indent level' do
    Sandbox::Response.new(['class Test; def foo; "hi"; end']).indent_level.should == 1
    Sandbox::Response.new(['class Test', 'def foo', '"hi"', 'end']).indent_level.should == 1
    Sandbox::Response.new(['module Wee', '[1, 2, 3].each do |num|', '"#{num}"']).indent_level.should == 2
    Sandbox::Response.new(['[1, 2, 3].each { |num|', '']).indent_level.should == 1
    Sandbox::Response.new(['module Test', 'class Weeha', 'def Foo', '[ "test", ']).indent_level.should == 4
  end
  
  it 'correctly determines indent character' do
    Sandbox::Response.new(['class Test; def foo; "hi"; end']).indent_character.should == 'class'
    Sandbox::Response.new(['class Test', 'def foo', '"hi"', 'end']).indent_character.should == 'class'
    Sandbox::Response.new(['module Wee', '[1, 2, 3].each do |num|', '"#{num}"']).indent_character.should == 'do'
    Sandbox::Response.new(['[1, 2, 3].each { |num|', '']).indent_character.should == '{'
    Sandbox::Response.new(['module Test', 'class Weeha', 'def Foo', '[ "test", ']).indent_character.should == '['
  end
  
  it 'does not make an indent character if indents are on the same line' do
    Sandbox::Response.new(['[1, 2, 3]']).indent_character.should == nil
    Sandbox::Response.new(['{:test => "foo"}']).indent_character.should == nil
  end
  
  it 'does make an indent character if indents are on the same line but are unmatched' do
    Sandbox::Response.new(['{:test => "foo"}, {:test => "wee"']).indent_character.should == '{'
  end
  
  it 'does not return a negative indent level' do
    Sandbox::Response.new(['end', 'end', 'end']).indent_level.should == 0
  end
end