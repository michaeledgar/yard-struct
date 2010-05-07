module YardStruct
  class StructHandler < YARD::Handlers::Ruby::Legacy::Base
    handles TkCLASS
    
    CLASS_REGEX = /^class\s+(#{NAMESPACEMATCH})\s*(?:<\s*(.+)|\Z)/m

    def normal_class?
      statement.tokens.to_s.match(CLASS_REGEX)
    end

    def struct_subclass?(superstring)
      superstring && (superstring.match(/\A(Struct|OStruct)\.new\((.*?)\)/) ? $1 : nil)
    end
    
    def extract_parameters(superstring)
      paramstring = superstring.match(/\A(Struct|OStruct)\.new\((.*?)\)/)[2]
      paramstring.split(",").map {|x| x.strip[1..-1] } # the 1..-1 chops the leading :
    end
    
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
    
    def process
      # matches normal classes
      if match = normal_class?
        classname, klass_string = match[1], match[2]
        # is it a struct/ostruct subclass
        if superclass = struct_subclass?(klass_string)
          params = extract_parameters klass_string
          # get the class
          klass = register ClassObject.new(namespace, classname) do |o|
            o.superclass = superclass if superclass
            o.superclass.type = :class if o.superclass.is_a?(Proxy)
          end
          
          # For each parameter, add reader and writers
          params.each do |member|
            # Ripped off from YARD's attribute handling source
            klass.attributes[:instance][member] = SymbolHash[:read => nil, :write => nil]
            
            # We want to convert these members into attributes just like
            # as if they were declared using attr_accessor.
            new_meth = register MethodObject.new(klass, "#{member}=", :instance) do |o|
              o.parameters = [['value', nil]]
              o.signature ||= "def #{member}=(value)"
              o.source ||= "#{o.signature}\n  @#{member} = value\nend"
            end
            new_meth.docstring.replace setter_docstring(klass, member)
            
            klass.attributes[:instance][member][:write] = new_meth
            
            # Do the getter
            new_meth = register MethodObject.new(klass, member, :instance) do |o|
              o.signature ||= "def #{member}"
              o.source ||= "#{o.signature}\n  @#{member}\nend"
            end
            new_meth.docstring.replace getter_docstring(klass, member)
            
            klass.attributes[:instance][member][:read] = new_meth
            
          end
          
        end # end if struct subclass
      end # end if normal class declaration
    end # end process
    
  end
end