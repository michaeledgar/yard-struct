module YardStruct
  ##
  # This handler is used by the Ruby 1.9+ parser engine. Uses AST nodes.
  #
  # All the interesting logic is actually all in SharedMethods. This class
  # specifically defines the parsing logic to get the data ready for the
  # Shared Methods.
  class ModernStructHandler < YARD::Handlers::Ruby::Base
    include SharedMethods
    
    namespace_only
    handles :class
    
    ##
    # Called to process all class definitions. We'll ignore anything but subclasses
    # of Struct.new()
    def process
      classname = statement[0].source
      superclass = parse_superclass(statement[1])
      # did we get a superclass worth parsing?
      if superclass
        # get the class
        klass = create_class(classname, superclass)
        # get the members
        members = extract_parameters(statement[1])
        # create all the members
        create_attributes(klass, members)
      end
    end
    
    ##
    # Extrat the parameters from the Struct.new AST node, returning them as a list
    # of strings
    #
    # @param [MethodCallNode] superclass the AST node for the Struct.new call
    # @return [Array<String>] the member names to generate methods for
    def extract_parameters(superclass)
      members = superclass.parameters.dup[0..-2] # drop the "false" at the end
      members.map {|x| x.source.strip[1..-1]}
    end
    
    ##
    # Extracts the superclass name from the class definition, returning `nil` if
    # we get something other than a Struct/OStruct subclass.
    #
    # @param [AstNode] superclass some AST node representing a superclass definition
    # @return [String, nil] either a name to use as a superclass, or nil if we are
    #   not interested in this class definition
    def parse_superclass(superclass)
      return nil unless superclass
      return nil unless superclass.type == :call || superclass.type == :command_call
      
      cname = superclass.namespace.source
      if cname =~ /^O?Struct$/ && superclass.method_name(true) == :new
        return cname
      end
      nil
    end
  end
end