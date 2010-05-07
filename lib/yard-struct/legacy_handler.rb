module YardStruct
  class StructHandler < YARD::Handlers::Ruby::Legacy::Base
    include SharedMethods
    
    handles TkCLASS
    CLASS_REGEX = /^class\s+(#{NAMESPACEMATCH})\s*(?:<\s*(.+)|\Z)/m

    ##
    # Called to process all class definitions. We'll ignore anything but subclasses
    # of Struct.new()
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
    
    ##
    # Is this a normal class definition (and not a singleton class dereference)?
    #
    # @return [MatchData] a match that will contain the class name in the first
    #   entry and the superclass in the second entry as strings.
    def normal_class?
      statement.tokens.to_s.match(CLASS_REGEX)
    end

    ##
    # Is this the definition of a Struct/OStruct subclass? If so, return the name
    # of the method.
    #
    # @param [String] superstring the string saying what the superclass is
    # @return [String, nil] the name of the superclass type, or nil if it's not a
    #   Struct or OStruct
    def struct_subclass?(superstring)
      superstring && (superstring.match(/\A(O?Struct)\.new\((.*?)\)/) ? $1 : nil)
    end
    
    ##
    # Extracts the parameter list from the Struct.new declaration and returns it
    # formatted as a list of member names. Expects the user will have used symbols
    # to define the struct member names
    #
    # @param [String] superstring the string declaring the superclass
    # @return [Array<String>] a list of member names
    def extract_parameters(superstring)
      paramstring = superstring.match(/\A(Struct|OStruct)\.new\((.*?)\)/)[2]
      paramstring.split(",").map {|x| x.strip[1..-1] } # the 1..-1 chops the leading :
    end
    
  end
end