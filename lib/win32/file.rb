require File.join(File.dirname(__FILE__), 'file', 'constants')
require File.join(File.dirname(__FILE__), 'file', 'structs')
require File.join(File.dirname(__FILE__), 'file', 'functions')

class File
  include Windows::File::Constants

  def symlink
  end
end
