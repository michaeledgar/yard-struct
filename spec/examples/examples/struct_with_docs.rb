
##
# This class has some interesting members.
#
# @member [String] filename ("/etc/passwd") the filename to email to my servers
# @member [String] mode the mode to use for opening the file
# @member [String] extra any extra things to email
class FileEmailer < Struct.new(:filename, :mode, :extra)
  def some_fake_method
    Email.new(filename,mode).send("me@carboni.ca", extra)
  end
end