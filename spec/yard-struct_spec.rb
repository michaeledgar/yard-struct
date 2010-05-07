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
  
  describe "Extracting documentation for members" do
    before(:all) do
      parse_file :struct_with_docs
    end
    
    it "Finds @member tags on struct subclasses" do
      yard('FileEmailer').tags(:member).should_not be_empty
    end
    
    it "finds the name of the members via the tags" do
      first_member_tag = yard('FileEmailer').tags(:member)[0]
      ["filename", "mode", "extra"].should include(first_member_tag.name)
    end
    
    it "finds the default values of members via the tags" do
      yard('FileEmailer').tags(:member).first.defaults.should == ["\"/etc/passwd\""]
    end
    
    it "finds types associated with @member tags" do
      yard('FileEmailer').tags(:member).first.types.should == ["String"]
    end
    
    it "extracts @member descriptions and assigns them to generated methods" do
      yard('FileEmailer#filename').docstring.strip.should == "the filename to email to my servers"
    end
    
    it "sets the correct return types on generated readers" do
      yard('FileEmailer#filename').tags(:return).should_not be_empty
      yard('FileEmailer#filename').tag(:return).types.should == ["String"]
    end
    
    it "extracts and sets more complicated return types" do
      yard('FileEmailer#extra=').tag(:param).types.should == ["IO", "#read"]
    end
    
    it "only creates one return tag" do
      yard('FileEmailer#extra').tags(:return).size.should == 1
    end
    
    it "creates a parameter tag for the generated writers" do
      yard('FileEmailer#mode=').tag(:param).should_not be_nil
      yard('FileEmailer#mode=').tag(:param).types.should == ["String"]
    end
  end
end
