module YardStruct
  class StructHandler < YARD::Handlers::Ruby::Legacy::Base
    include SharedMethods
    
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
    
    def process
      # matches normal classes
      if match = normal_class?
        classname, klass_string = match[1], match[2]
        # is it a struct/ostruct subclass
        if superclass = struct_subclass?(klass_string)
          # get the class
          klass = create_class(classname, superclass)

          # Get the members
          params = extract_parameters klass_string
          
          create_attributes(klass, params)
        end # end if struct subclass
      end # end if normal class declaration
    end # end process
    
  end
end