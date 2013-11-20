#############################################################################
# test_win32_file_link.rb
#
# Test case for the link related methods of win32-file. You should run this
# test via the 'rake test' or 'rake test:link' task.
#############################################################################
require 'test-unit'
require 'win32/security'
require 'win32/file'

class TC_Win32_File_Link < Test::Unit::TestCase
  def self.startup
    Dir.chdir(File.expand_path(File.dirname(__FILE__)))
    @@file = File.join(Dir.pwd, 'link_test.txt')
    File.open(@@file, 'w'){ |fh| fh.puts "This is a link test." }
  end

  def setup
    @link  = "this_is_a_symlink"
    @file  = "link_test.txt"
    @admin = Win32::Security.elevated_security?
  end

  test "symlink basic functionality" do
    assert_respond_to(File, :symlink)
  end

  test "symlink to a file works as expected" do
    omit_unless(@admin)
    assert_nothing_raised{ File.symlink(@file, @link) }
    assert_true(File.exists?(@link))
    assert_true(File.symlink?(@link))
  end

  test "symlink method returns zero" do
    omit_unless(@admin)
    assert_equal(0, File.symlink(@file, @link))
  end

  test "symlink requires two arguments" do
    assert_raise(ArgumentError){ File.symlink }
    assert_raise(ArgumentError){ File.symlink(@link) }
    assert_raise(ArgumentError){ File.symlink(@file, @link, @link) }
  end

  test "symlink fails if link already exists" do
    omit_unless(@admin)
    File.symlink(@file, @link)
    assert_raise(SystemCallError){ File.symlink(@file, @link) }
  end

  test "symlink does not fail if target does not exist" do
    omit_unless(@admin)
    assert_nothing_raised{ File.symlink('bogus.txt', @link) }
  end

  test "symlink? basic functionality" do
    assert_respond_to(File, :symlink?)
    assert_boolean(File.symlink?(@file))
  end

  test "symlink? returns expected result" do
    omit_unless(@admin)
    File.symlink(@file, @link)
    assert_true(File.symlink?(@link))
    assert_false(File.symlink?(@file))
  end

  test "symlink? requires one argument only" do
    assert_raise(ArgumentError){ File.symlink? }
    assert_raise(ArgumentError){ File.symlink?(@file, @file) }
  end

  test "readlink basic functionality" do
    assert_respond_to(File, :readlink)
  end

  test "readlink returns the expected value when reading a symlink" do
    omit_unless(@admin)
    File.symlink(@file, @link)
    expected = File.expand_path(@file).tr("/", "\\")
    assert_equal(expected, File.readlink(@link))
  end

  test "readlink raises an error when reading a regular file" do
    assert_raise(Errno::EINVAL){ File.readlink(@file) }
  end

  test "readlink requires one argument only" do
    assert_raise(ArgumentError){ File.readlink }
    assert_raise(ArgumentError){ File.readlink(@link, @link) }
  end

  test "readlink raises an error if the file is not found" do
    assert_raise(Errno::ENOENT){ File.readlink('bogus.txt') }
  end

  test "realpath basic functionality" do
    assert_respond_to(File, :realpath)
  end

  test "realpath returns the expected value for a regular file" do
    assert_equal(Dir.pwd, File.realpath(Dir.pwd))
    assert_equal(@@file, File.realpath(@file).tr("/", "\\"))
  end

  test "realpath returns the expected value for a symlink" do
    omit_unless(@admin)
    File.symlink(@file, @link)
    expected = File.expand_path(@file).tr("/", "\\")
    assert_equal(expected, File.realpath(@link))
  end

  def teardown
    File.delete(@link) if File.exists?(@link)
    @link  = nil
    @admin = nil
    @file  = nil
  end

  def self.shutdown
    File.delete(@@file) if File.exists?(@@file)
    @@file = nil
  end
end
