# yard-struct

Plugin for YARD which generates documentation for Struct members.

## Why?

Without yard-struct, there's a big difference between these as YARD can see
them:

    class A < Struct.new(:foo, :bar)
      def to_s
        foo + bar
      end
    end

    class B
      attr_accessor :foo, :bar
      def to_s
        foo + bar
      end
    end

`yard-struct` makes it so that when YARD examines the first, it creates attributes
for the auto-generated accessors `:foo` and `:bar`.

## There's more

This plugin also adds a new tag, `@member`. This lets you document the Struct members
with types. Use it as such:

    ##
    # Whizbang class does lots of stuff.
    #
    # @member [IO, #read] input the input file to whizbang
    # @member [Proc, #call] frob the proc to frobinate the input
    class Whizbang < Struct.new(:input, :frob)
    end
    
The generated types will be shown prominently in the generated documentation.

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Michael Edgar. See LICENSE for details.
