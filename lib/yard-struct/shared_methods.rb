module YardStruct
  module SharedMethods
    include YARD::CodeObjects
    
    def member_tag_for_member(klass, member)
      klass.tags(:member).find {|tag| tag.name == member}
    end
    
    def return_type_for_member(klass, member)
      member_tag = member_tag_for_member(klass, member)
      return_type = member_tag ? "[#{member_tag.types.join(', ')}]" : "[Object]"
    end
    
    def raw_return_types_for_member(klass, member)
      member_tag = member_tag_for_member(klass, member)
      return_type = member_tag ? member_tag.types : nil
    end
    
    def getter_docstring(klass, member)
      member_tag = member_tag_for_member(klass, member)
      getter_doc_text = member_tag ? member_tag.text : "Returns the value of attribute #{member}"
      getter_doc_text += "\n@return #{return_type_for_member(klass, member)} the current value of #{member}"
    end
    
    def setter_docstring(klass, member)
      member_tag = member_tag_for_member(klass, member)
      return_type = return_type_for_member(klass, member)
      setter_doc_text = member_tag ? member_tag.text : "Sets the attribute #{member}"
      setter_doc_text += "\n@param #{return_type} value the value to set the attribute #{member} to."
      setter_doc_text += "\n@return #{return_type} the newly set value"
    end
    
    def create_class(classname, superclass)
      register ClassObject.new(namespace, classname) do |o|
        o.superclass = superclass if superclass
        o.superclass.type = :class if o.superclass.is_a?(Proxy)
      end
    end
    
    def create_writer(klass, member)
      # We want to convert these members into attributes just like
      # as if they were declared using attr_accessor.
      new_meth = register MethodObject.new(klass, "#{member}=", :instance) do |o|
        o.parameters = [['value', nil]]
        o.signature ||= "def #{member}=(value)"
        o.source ||= "#{o.signature}\n  @#{member} = value\nend"
      end
      new_meth.docstring.replace setter_docstring(klass, member)
      klass.attributes[:instance][member][:write] = new_meth
    end
    
    def create_reader(klass, member)
      # Do the getter
      new_meth = register MethodObject.new(klass, member, :instance) do |o|
        o.signature ||= "def #{member}"
        o.source ||= "#{o.signature}\n  @#{member}\nend"
      end
      new_meth.docstring.replace getter_docstring(klass, member)
      klass.attributes[:instance][member][:read] = new_meth
    end
    
    def create_attributes(klass, members)
      # For each parameter, add reader and writers
      members.each do |member|
        # Ripped off from YARD's attribute handling source
        klass.attributes[:instance][member] = SymbolHash[:read => nil, :write => nil]
        
        create_writer klass, member
        create_reader klass, member
      end
    end
  end
end