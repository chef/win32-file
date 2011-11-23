##############################################################################
# test_win32_file_security.rb
#
# Test case for security related methods of win32-file. You should use the
# 'rake test' or 'rake test_security' task to run this.
#
# Note that I've removed some tests that looked for explicit security
# accounts, since it's impossible to determine how any given system is setup.
##############################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'win32/file'
require 'socket'

class TC_Win32_File_Security < Test::Unit::TestCase
  def self.startup
    Dir.chdir(File.dirname(File.expand_path(File.basename(__FILE__))))
    @@host = Socket.gethostname
    @@file = File.join(Dir.pwd, 'security_test.txt')
    File.open(@@file, 'w'){ |fh| fh.puts "This is a security test." }
  end

  def setup
    @perms = nil
  end

  # This will fail if there is no "Users" builtin.  Not to worry.
  def test_get_permissions
    assert_respond_to(File, :get_permissions)
    assert_nothing_raised{ File.get_permissions(@@file) }
    assert_kind_of(Hash, File.get_permissions(@@file))
  end

  def test_get_permissions_with_host
    assert_nothing_raised{ File.get_permissions(@@file, @@host) }
    assert_kind_of(Hash, File.get_permissions(@@file))
  end

  def test_set_permissions
    assert_respond_to(File, :set_permissions)
    assert_nothing_raised{ @perms = File.get_permissions(@@file) }
    assert_nothing_raised{ File.set_permissions(@@file, @perms) }
  end

  def test_securities
    assert_respond_to(File, :securities)
    assert_nothing_raised{ @perms = File.get_permissions(@@file) }

    @perms.each{ |acct, mask|
      assert_nothing_raised{ File.securities(mask) }
      assert_kind_of(Array, File.securities(mask))
    }
  end

  def teardown
    @perms = nil
  end

  def self.shutdown
    File.delete(@@file) if File.exists?(@@file)
    @@file  = nil
    @@host  = nil
  end
end
