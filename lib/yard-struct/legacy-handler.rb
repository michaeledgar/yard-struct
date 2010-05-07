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
            klass.attributes[:instance][member] = SymbolHash[:read => nil, :write => nil]
            {:read => member, :write => "#{member}="}.each do |type, meth|
              klass.attributes[:instance][member][type] = MethodObject.new(klass, meth, scope) do |o|
                if type == :write
                  o.parameters = [['value', nil]]
                  src = "def #{meth}=(value)"
                  full_src = "#{src}\n  @#{member} = value\nend"
                  doc = "Sets the attribute #{member}\n@param value the value to set the attribute #{member} to."
                else
                  src = "def #{meth}"
                  full_src = "#{src}\n  @#{member}\nend"
                  doc = "Returns the value of attribute #{member}"
                end
                o.source ||= full_src
                o.signature ||= src
                o.docstring = statement.comments.to_s.empty? ? doc : statement.comments
              end

              # Register the objects explicitly
              register klass.attributes[:instance][member][type]
            end
          end
          
        end # end if struct subclass
      end # end if normal class declaration
    end # end process
    
  end
end