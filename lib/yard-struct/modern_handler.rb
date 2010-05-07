module YardStruct
  class ModernStructHandler < YARD::Handlers::Ruby::Base
    include SharedMethods
    
    namespace_only
    handles :class
    
    def process
      classname = statement[0].source
      superclass = parse_superclass(statement[1])
      # did we get a superclass worth parsing?
      if superclass
        # get the class
        klass = create_class(classname, superclass)
        # get the members
        members = extract_parameters(statement[1])

        create_attributes(klass, members)
      end
    end
    
    def extract_parameters(superclass)
      members = superclass.parameters.dup[0..-2] # drop the "false" at the end
      members.map {|x| x.source.strip[1..-1]}
    end
    
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