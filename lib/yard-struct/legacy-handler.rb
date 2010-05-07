module YardStruct
  class StructHandler < YARD::Handlers::Ruby::Legacy::Base
    handles TkCLASS
    
    CLASS_REGEX = /^class\s+(#{NAMESPACEMATCH})\s*(?:<\s*(.+)|\Z)/m

    def process
      # matches normal classes
      if match = statement.tokens.to_s.match(CLASS_REGEX)
        classname, klass_string = match[1], match[2]
        # is it a struct/ostruct subclass
        if klass_string =~ /\A(Struct|OStruct)\.new\((.*?)\)/
          superclass = $1
          params = $2.split(",").map {|x| x.strip[1..-1] }
          # get the class
          klass = register ClassObject.new(namespace, classname) do |o|
            o.superclass = superclass if superclass
            o.superclass.type = :class if o.superclass.is_a?(Proxy)
          end
          
          # For each parameter, add reader and writers
          params.each do |member|
            # make reader...
            obj = register MethodObject.new(klass, member, :instance) do |o| 
              o.visibility = :public
              o.signature = "def #{member}"
              o.explicit = false
              o.parameters = []
              o.source = statement
            end
            # make writer...
            obj = register MethodObject.new(klass, "#{member}=", :instance) do |o|
              o.visibility = :public
              o.signature = "def #{member}="
              o.explicit = false
              o.parameters = [['value', nil]]
              o.source = statement
            end
          end
          
        end # end if struct subclass
      end # end if normal class declaration
    end # end process
    
  end
end