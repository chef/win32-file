#####################################################################
# test_win32_file_stat.rb
#
# Test case for stat related methods of win32-file. You should run
# this via the 'rake test' or 'rake test:stat' task.
#####################################################################
require 'test-unit'
require 'fileutils'
require 'win32/file'
require 'ffi'

class TC_Win32_File_Stat < Test::Unit::TestCase
  extend FFI::Library
  ffi_lib :kernel32

  attach_function :GetDriveTypeA, [:string], :uint

  def self.startup
    Dir.chdir(File.expand_path(File.dirname(__FILE__)))
    @@file = File.join(Dir.pwd, 'stat_test.txt')
    File.open(@@file, 'w'){ |fh| fh.puts "This is a test." }

    @@exe_file = File.join(Dir.pwd, 'stat_test.exe')
    FileUtils.touch(@@exe_file)

    @@block_dev = nil

    # Find a block device
    'A'.upto('Z'){ |volume|
       volume += ":\\"
       if [2,5,6].include?(GetDriveTypeA(volume))
         @@block_dev = volume
         break
       end
    }
  end

  def setup
    @blksize = 4096 # Most likely
  end

  test "File::Stat class returned is from win32-file-stat library" do
    assert_respond_to(File, :stat)
    assert_kind_of(File::Stat, File.stat(@@file))
    assert_nothing_raised{ File.stat(@@file).hidden? }
  end

  test "blksize basic functionality" do
    assert_respond_to(File, :blksize)
    assert_kind_of(Fixnum, File.blksize(@@file))
  end

  test "blksize returns the expected value" do
    assert_equal(@blksize, File.blksize(@@file))
    assert_equal(@blksize, File.blksize("C:/"))
  end

  test "blksize requires a single argument" do
    assert_raises(ArgumentError){ File.blksize }
    assert_raises(ArgumentError){ File.blksize(@@file, 'foo') }
  end

  test "blockdev? basic functionality" do
    assert_respond_to(File, :blockdev?)
    assert_nothing_raised{ File.blockdev?("C:\\") }
    assert_boolean(File.blockdev?("NUL"))
  end

  test "blockdev? returns false for non-block devices" do
    assert_false(File.blockdev?(@@file))
    assert_false(File.blockdev?("NUL"))
  end

  test "blockdev? returns true for block devices" do
    omit_unless(@@block_dev)
    omit_unless(File.exists?(@@block_dev), "No media in device - skipping")
    assert_true(File.blockdev?(@@block_dev))
  end

  test "blockdev? requires a single argument" do
    assert_raises(ArgumentError){ File.blockdev? }
    assert_raises(ArgumentError){ File.blockdev?(@@file, "foo") }
  end

  test "chardev? basic functionality" do
    assert_respond_to(File, :chardev?)
    assert_nothing_raised{ File.chardev?("NUL") }
    assert_boolean(File.chardev?(@@file))
  end

  test "chardev? method returns the expected result" do
    assert_true(File.chardev?("NUL"))
    assert_false(File.chardev?(@@file))
  end

  test "chardev? requires a single argument" do
    assert_raises(ArgumentError){ File.chardev? }
    assert_raises(ArgumentError){ File.chardev?(@@file, "foo") }
  end

  test "lstat is an alias for stat" do
    assert_respond_to(File, :lstat)
    assert_alias_method(File, :stat, :lstat)
  end

  test "directory? method basic functionality" do
    assert_respond_to(File, :directory?)
    assert_nothing_raised{ File.directory?(Dir.pwd) }
    assert_boolean(File.directory?(Dir.pwd))
  end

  test "directory? method returns expected results" do
    assert_true(File.directory?(Dir.pwd))
    assert_false(File.directory?(@@file))
    assert_false(File.directory?("NUL"))
  end

  test "executable? method basic functionality" do
    assert_respond_to(File, :executable?)
    assert_nothing_raised{ File.executable?(Dir.pwd) }
    assert_boolean(File.executable?(Dir.pwd))
  end

  test "executable? method returns expected results" do
    assert_true(File.executable?(@@exe_file))
    assert_false(File.executable?(@@file))
    assert_false(File.directory?("NUL"))
  end

  test "file? method basic functionality" do
    assert_respond_to(File, :file?)
    assert_nothing_raised{ File.file?(Dir.pwd) }
    assert_boolean(File.file?(Dir.pwd))
  end

  test "file? method returns expected results" do
    assert_true(File.file?(@@file))
    assert_true(File.file?(Dir.pwd))
    assert_false(File.file?('NUL'))
  end

  test "ftype method basic functionality" do
    assert_respond_to(File, :ftype)
    assert_nothing_raised{ File.ftype(Dir.pwd) }
    assert_kind_of(String, File.ftype(Dir.pwd))
  end

  test "ftype returns the expected string" do
    assert_equal('file', File.ftype(@@file))
    assert_equal('directory', File.ftype(Dir.pwd))
    assert_equal('characterSpecial', File.ftype('NUL'))
  end

  test "grpowned? method basic functionality" do
    assert_respond_to(File, :grpowned?)
    assert_nothing_raised{ File.grpowned?(Dir.pwd) }
    assert_boolean(File.grpowned?(Dir.pwd))
  end

  test "grpowned? returns expected results" do
    assert_true(File.grpowned?(@@file))
    assert_false(File.grpowned?('NUL'))
  end

  test "owned? method basic functionality" do
    assert_respond_to(File, :owned?)
    assert_nothing_raised{ File.owned?(Dir.pwd) }
    assert_boolean(File.owned?(Dir.pwd))
  end

  test "owned? returns expected results" do
    assert_true(File.owned?(@@file))
    assert_false(File.owned?('NUL'))
  end

  test "pipe? method basic functionality" do
    assert_respond_to(File, :pipe?)
    assert_nothing_raised{ File.pipe?(Dir.pwd) }
    assert_boolean(File.pipe?(Dir.pwd))
  end

  test "pipe? returns expected results" do
    assert_false(File.pipe?(@@file))
    assert_false(File.pipe?(Dir.pwd))
    assert_false(File.pipe?('NUL'))
  end

  test "socket? is an alias for pipe?" do
    assert_respond_to(File, :socket?)
    assert_alias_method(File, :socket?, :pipe?)
  end

=begin
   def test_stat_instance
      File.open(@@file){ |f|
         assert_respond_to(f, :stat)
         assert_kind_of(File::Stat, f.stat)
         assert_equal(false, f.stat.hidden?)
      }
   end
=end

  def teardown
    @blksize = nil
  end

  def self.shutdown
    File.delete(@@file) if File.exists?(@@file)
    File.delete(@@exe_file) if File.exists?(@@exe_file)
    @@file = nil
    @@exe_file = nil
    @@block_dev = nil
  end
end
