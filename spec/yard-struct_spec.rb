require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'examples/example_helper'
require 'yard-struct'

describe "YardStruct" do
  include Helpers::Examples
  
  describe "Extracting readers and writers" do
    before(:all) do
      parse_file :simple_struct
    end
    
    it "should register an instance reader for each struct member" do
      yard('SimpleStruct#foo').should be_instance_of(CodeObjects::MethodObject)
      yard('SimpleStruct#bar').should be_instance_of(CodeObjects::MethodObject)
      yard('SimpleStruct#baz').should be_instance_of(CodeObjects::MethodObject)
    end
    
    it "should register instance writers for each struct member" do
      yard('SimpleStruct#foo=').should be_instance_of(CodeObjects::MethodObject)
      yard('SimpleStruct#bar=').should be_instance_of(CodeObjects::MethodObject)
      yard('SimpleStruct#baz=').should be_instance_of(CodeObjects::MethodObject)
    end
    
    it "should create readable attributes to represent each struct member" do
      yard('SimpleStruct').attributes[:instance][:foo][:read].should be_instance_of(CodeObjects::MethodObject)
      yard('SimpleStruct').attributes[:instance][:bar][:read].should be_instance_of(CodeObjects::MethodObject)
      yard('SimpleStruct').attributes[:instance][:baz][:read].should be_instance_of(CodeObjects::MethodObject)
    end
    
    it "should create writeable attributes to represent each struct member" do
      yard('SimpleStruct').attributes[:instance][:foo][:write].should be_instance_of(CodeObjects::MethodObject)
      yard('SimpleStruct').attributes[:instance][:bar][:write].should be_instance_of(CodeObjects::MethodObject)
      yard('SimpleStruct').attributes[:instance][:baz][:write].should be_instance_of(CodeObjects::MethodObject)
    end
  end
end
