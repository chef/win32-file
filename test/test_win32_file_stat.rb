#####################################################################
# test_win32_file_stat.rb
#
# Test case for stat related methods of win32-file. You should run
# this via the 'rake test' or 'rake test:stat' task.
#####################################################################
require 'test-unit'
require 'fileutils'
require 'win32/file'
require 'win32/security'
require 'ffi'

class TC_Win32_File_Stat < Test::Unit::TestCase
  extend FFI::Library
  ffi_lib :kernel32

  attach_function :GetDriveTypeA, [:string], :uint

  def self.startup
    @@txt_file = File.join(Dir.pwd, 'stat_test.txt')
    @@exe_file = File.join(Dir.pwd, 'stat_test.exe')
    @@sys_file = "C:/pagefile.sys"

    Dir.chdir(File.expand_path(File.dirname(__FILE__)))
    File.open(@@txt_file, 'w'){ |fh| fh.puts "This is a test." }

    FileUtils.touch(@@exe_file)

    @@java = RUBY_PLATFORM == 'java'
    @@block_dev = nil
    @@elevated = Win32::Security.elevated_security?

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
    assert_kind_of(File::Stat, File.stat(@@txt_file))
    assert_nothing_raised{ File.stat(@@txt_file).hidden? }
  end

  test "blksize basic functionality" do
    assert_respond_to(File, :blksize)
    assert_kind_of(Fixnum, File.blksize(@@txt_file))
  end

  test "blksize returns the expected value" do
    assert_equal(@blksize, File.blksize(@@txt_file))
    assert_equal(@blksize, File.blksize("C:/"))
  end

  test "blksize requires a single argument" do
    assert_raises(ArgumentError){ File.blksize }
    assert_raises(ArgumentError){ File.blksize(@@txt_file, 'foo') }
  end

  test "blockdev? basic functionality" do
    assert_respond_to(File, :blockdev?)
    assert_nothing_raised{ File.blockdev?("C:\\") }
    assert_boolean(File.blockdev?('NUL'))
  end

  test "blockdev? returns false for non-block devices" do
    assert_false(File.blockdev?(@@txt_file))
    assert_false(File.blockdev?('NUL'))
    assert_false(File.blockdev?('bogus'))
  end

  test "blockdev? returns true for block devices" do
    omit_unless(@@block_dev)
    omit_unless(File.exist?(@@block_dev), "No media in device - skipping")
    assert_true(File.blockdev?(@@block_dev))
  end

  test "blockdev? requires a single argument" do
    assert_raises(ArgumentError){ File.blockdev? }
    assert_raises(ArgumentError){ File.blockdev?(@@txt_file, 'foo') }
  end

  test "chardev? basic functionality" do
    assert_respond_to(File, :chardev?)
    assert_nothing_raised{ File.chardev?("NUL") }
    assert_boolean(File.chardev?(@@txt_file))
  end

  test "chardev? method returns the expected result for regular files" do
    assert_false(File.chardev?(@@txt_file))
    assert_false(File.chardev?('bogus'))
  end

  test "chardev? method returns the expected result for character devices" do
    omit_if(@@java)
    assert_true(File.chardev?('NUL'))
  end

  test "chardev? requires a single argument" do
    assert_raises(ArgumentError){ File.chardev? }
    assert_raises(ArgumentError){ File.chardev?(@@txt_file, 'foo') }
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
    assert_false(File.directory?(@@txt_file))
    assert_false(File.directory?('NUL'))
    assert_false(File.directory?('bogus'))
  end

  test "executable? method basic functionality" do
    assert_respond_to(File, :executable?)
    assert_nothing_raised{ File.executable?(Dir.pwd) }
    assert_boolean(File.executable?(Dir.pwd))
  end

  test "executable? method returns expected results" do
    assert_true(File.executable?(@@exe_file))
    assert_false(File.executable?(@@txt_file))
    assert_false(File.directory?('NUL'))
    assert_false(File.directory?('bogus'))
  end

  test "file? method basic functionality" do
    assert_respond_to(File, :file?)
    assert_nothing_raised{ File.file?(Dir.pwd) }
    assert_boolean(File.file?(Dir.pwd))
  end

  test "file? method returns expected results" do
    assert_true(File.file?(@@txt_file))
    assert_false(File.file?(Dir.pwd))
    assert_false(File.file?('NUL'))
    assert_false(File.file?('bogus'))
  end

  test "ftype method basic functionality" do
    assert_respond_to(File, :ftype)
    assert_nothing_raised{ File.ftype(Dir.pwd) }
    assert_kind_of(String, File.ftype(Dir.pwd))
  end

  test "ftype returns the expected string" do
    assert_equal('file', File.ftype(@@txt_file))
    assert_equal('directory', File.ftype(Dir.pwd))
    assert_equal('characterSpecial', File.ftype('NUL'))
  end

  test "grpowned? method basic functionality" do
    assert_respond_to(File, :grpowned?)
    assert_nothing_raised{ File.grpowned?(Dir.pwd) }
    assert_boolean(File.grpowned?(Dir.pwd))
  end

  test "grpowned? returns expected results" do
    assert_true(File.grpowned?(@@txt_file))
    assert_false(File.grpowned?('NUL'))
    assert_false(File.grpowned?('bogus'))
  end

  test "owned? method basic functionality" do
    assert_respond_to(File, :owned?)
    assert_nothing_raised{ File.owned?(Dir.pwd) }
    assert_boolean(File.owned?(Dir.pwd))
  end

  test "owned? returns expected results" do
    if @@elevated
      assert_false(File.owned?(@@txt_file))
    else
      assert_true(File.owned?(@@txt_file))
    end
    assert_false(File.owned?('NUL'))
    assert_false(File.owned?('bogus'))
  end

  test "pipe? method basic functionality" do
    assert_respond_to(File, :pipe?)
    assert_nothing_raised{ File.pipe?(Dir.pwd) }
    assert_boolean(File.pipe?(Dir.pwd))
  end

  test "pipe? returns expected results" do
    assert_false(File.pipe?(@@txt_file))
    assert_false(File.pipe?(Dir.pwd))
    assert_false(File.pipe?('NUL'))
    assert_false(File.pipe?('bogus'))
  end

  test "readable? basic functionality" do
    assert_respond_to(File, :readable?)
    assert_boolean(File.readable?(@@txt_file))
  end

  test "readable? returns expected value" do
    assert_true(File.readable?(@@txt_file))
    assert_true(File::Stat.new(Dir.pwd).readable?)
    assert_false(File::Stat.new(@@sys_file).readable?)
  end

  test "readable_real? basic functionality" do
    assert_respond_to(File, :readable_real?)
    assert_boolean(File.readable_real?(@@txt_file))
  end

  test "readable_real? returns expected value" do
    assert_true(File.readable_real?(@@txt_file))
  end

  test "socket? is an alias for pipe?" do
    assert_respond_to(File, :socket?)
    assert_alias_method(File, :socket?, :pipe?)
  end

  test "world_readable? basic functionality" do
    assert_respond_to(File, :world_readable?)
    assert_boolean(File.world_readable?(@@txt_file))
  end

  test "world_writable? returns expected value" do
    assert_false(File.world_writable?(@@txt_file))
  end

  test "writable? basic functionality" do
    assert_respond_to(File, :writable?)
    assert_boolean(File.writable?(@@txt_file))
  end

  test "writable? returns expected value" do
    assert_true(File.writable?(@@txt_file))
    assert_true(File::Stat.new(Dir.pwd).writable?)
    assert_false(File::Stat.new(@@sys_file).writable?)
  end

  test "writable_real? basic functionality" do
    assert_respond_to(File, :writable_real?)
    assert_boolean(File.writable_real?(@@txt_file))
  end

  test "writable_real? returns expected value" do
    assert_true(File.writable_real?(@@txt_file))
  end

  test "check underlying custom stat attributes" do
    File.open(@@txt_file){ |f|
      assert_respond_to(f, :stat)
      assert_kind_of(File::Stat, f.stat)
      assert_false(f.stat.hidden?)
    }
  end

  def teardown
    @blksize = nil
  end

  def self.shutdown
    File.delete(@@txt_file) if File.exist?(@@txt_file)
    File.delete(@@exe_file) if File.exist?(@@exe_file)
    @@txt_file = nil
    @@exe_file = nil
    @@elevated = nil
    @@block_dev = nil
    @@java = nil
  end
end
