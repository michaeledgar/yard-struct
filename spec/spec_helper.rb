$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'yard-struct'
require 'spec'
require 'spec/autorun'
require 'yard'

Spec::Runner.configure do |config|
  
end

include YARD