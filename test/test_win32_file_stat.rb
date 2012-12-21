#####################################################################
# test_win32_file_stat.rb
#
# Test case for stat related methods of win32-file. You should run
# this via the 'rake test' or 'rake test:stat' task.
#####################################################################
require 'test-unit'
require 'win32/file'

class TC_Win32_File_Stat < Test::Unit::TestCase
   def self.startup
      Dir.chdir(File.expand_path(File.dirname(__FILE__)))
      @@file = File.join(Dir.pwd, 'stat_test.txt')
      File.open(@@file, 'w'){ |fh| fh.puts "This is a test." }

      @@block_dev = nil

=begin
      # Find a block device
      'A'.upto('Z'){ |volume|
         volume += ":\\"
         case GetDriveType(volume)
            when DRIVE_REMOVABLE, DRIVE_CDROM, DRIVE_RAMDISK
               @@block_dev = volume
               break
         end
      }
=end
   end

  def setup
    @blksize = 4096 # Most likely
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

=begin
   # The test for a block device will fail unless the D: drive is a CDROM.
   def test_blockdev
      assert_respond_to(File, :blockdev?)
      assert_nothing_raised{ File.blockdev?("C:\\") }
      assert_equal(false, File.blockdev?("NUL"))

      omit_unless(@@block_dev, "Could not find block device")
      omit_unless(File.exists?(@@block_dev), "No media in device - skipping")
      assert_equal(true, File.blockdev?(@@block_dev))
   end

   def test_blockdev_expected_errors
      assert_raises(ArgumentError){ File.blockdev? }
      assert_raises(ArgumentError){ File.blockdev?(@@file, "foo") }
   end

   def test_chardev
      assert_respond_to(File, :chardev?)
      assert_nothing_raised{ File.chardev?("NUL") }
      assert_equal(true, File.chardev?("NUL"))
      assert_equal(false, File.chardev?(@@file))
   end

   def test_chardev_expected_errors
      assert_raises(ArgumentError){ File.chardev? }
      assert_raises(ArgumentError){ File.chardev?(@@file, "foo") }
   end

   # Ensure that not only does the File class respond to the stat method,
   # but also that it's returning the File::Stat class from the
   # win32-file-stat package.
   #
   def test_stat_class
      assert_respond_to(File, :stat)
      assert_kind_of(File::Stat, File.stat(@@file))
      assert_equal(false, File.stat(@@file).hidden?)
   end

   # This was added after it was discovered that lstat is not aliased
   # to stat automatically on Windows.
   #
   def test_lstat_class
      assert_respond_to(File, :lstat)
      assert_kind_of(File::Stat, File.lstat(@@file))
      assert_equal(false, File.stat(@@file).hidden?)
   end

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
    @@file = nil
    @@block_dev = nil
  end
end
