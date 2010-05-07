module YardStruct
  module SharedMethods
    include YARD::CodeObjects
    
    ##
    # Extracts the user's defined @member tag for a given class and its member. Returns
    # nil if the user did not define a @member tag for this struct entry.
    #
    # @param [ClassObject] klass the class whose tags we're searching
    # @param [String] member the name of the struct member we need
    # @return [YARD::Tags::Tag, nil] the tag matching the request, or nil if not found
    def member_tag_for_member(klass, member)
      klass.tags(:member).find {|tag| tag.name == member}
    end
    
    ##
    # Gets the return type for the member in a nicely formatted string. Used
    # to be injected into auto-generated docstrings.
    #
    # @param [ClassObject] klass the class whose tags we're searching
    # @param [String] member the name of the struct member whose return type we need
    # @return [String] the user-declared type of the struct member, or [Object] if
    #   the user did not define a type for this member.
    def return_type_for_member(klass, member)
      member_tag = member_tag_for_member(klass, member)
      return_type = member_tag ? "[#{member_tag.types.join(', ')}]" : "[Object]"
    end
    
    ##
    # Creates the auto-generated docstring for the getter method of a struct's
    # member. This is used so the generated documentation will look just like that
    # of an attribute defined using attr_accessor.
    #
    # @param [ClassObject] klass the class whose members we're working with
    # @param [String] member the name of the member we're generating documentation for
    # @return [String] a docstring to be attached to the getter method for this member
    def getter_docstring(klass, member)
      member_tag = member_tag_for_member(klass, member)
      getter_doc_text = member_tag ? member_tag.text : "Returns the value of attribute #{member}"
      getter_doc_text += "\n@return #{return_type_for_member(klass, member)} the current value of #{member}"
    end
    
    ##
    # Creates the auto-generated docstring for the setter method of a struct's
    # member. This is used so the generated documentation will look just like that
    # of an attribute defined using attr_accessor.
    #
    # @param [ClassObject] klass the class whose members we're working with
    # @param [String] member the name of the member we're generating documentation for
    # @return [String] a docstring to be attached to the setter method for this member
    def setter_docstring(klass, member)
      member_tag = member_tag_for_member(klass, member)
      return_type = return_type_for_member(klass, member)
      setter_doc_text = member_tag ? member_tag.text : "Sets the attribute #{member}"
      setter_doc_text += "\n@param #{return_type} value the value to set the attribute #{member} to."
      setter_doc_text += "\n@return #{return_type} the newly set value"
    end
    
    ##
    # Creates and registers a class object with the given name and superclass name.
    # Returns it for further use.
    #
    # @param [String] classname the name of the class
    # @param [String] superclass the name of the superclass
    # @return [ClassObject] the class object for further processing/method attaching
    def create_class(classname, superclass)
      register ClassObject.new(namespace, classname) do |o|
        o.superclass = superclass if superclass
        o.superclass.type = :class if o.superclass.is_a?(Proxy)
      end
    end
    
    ##
    # Creates the setter (writer) method and attaches it to the class as an attribute.
    # Also sets up the docstring to prettify the documentation output.
    #
    # @param [ClassObject] klass the class to attach the method to
    # @param [String] member the name of the member we're generating a method for
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
    
    ##
    # Creates the getter (reader) method and attaches it to the class as an attribute.
    # Also sets up the docstring to prettify the documentation output.
    #
    # @param [ClassObject] klass the class to attach the method to
    # @param [String] member the name of the member we're generating a method for
    def create_reader(klass, member)
      # Do the getter
      new_meth = register MethodObject.new(klass, member, :instance) do |o|
        o.signature ||= "def #{member}"
        o.source ||= "#{o.signature}\n  @#{member}\nend"
      end
      new_meth.docstring.replace getter_docstring(klass, member)
      klass.attributes[:instance][member][:read] = new_meth
    end
    
    ##
    # Creates the given member methods and attaches them to the given ClassObject.
    #
    # @param [ClassObject] klass the class to generate attributes for
    # @param [Array<String>] members a list of member names
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