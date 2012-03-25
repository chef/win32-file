#############################################################################
# test_win32_file_attributes.rb
#
# Test case for the attribute related methods of win32-file. You should run
# this via the 'rake test' or 'rake test_attributes' task.
#############################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'win32/file'

class TC_Win32_File_Attributes < Test::Unit::TestCase
   include Windows::File
   extend Windows::File

   def self.startup
      Dir.chdir(File.dirname(File.expand_path(File.basename(__FILE__))))
      @@file = File.join(Dir.pwd, 'test_file.txt')
      File.open(@@file, 'w'){ |fh| fh.puts "This is a test." }
   end

   def setup
      @fh   = File.open(@@file)
      @attr = GetFileAttributes(@@file)
   end

   def test_version
      assert_equal('0.6.8', File::WIN32_FILE_VERSION)
   end

   def test_is_directory
      assert_true(File.directory?(Dir.pwd))
      assert_false(File.directory?(@@file))
      assert_false(File.directory?('C:/aaabbbccc'))
   end

   def test_temporary
      assert_respond_to(File, :temporary?)
      assert_nothing_raised{ File.temporary?(@@file) }
      assert_equal(false, File.temporary?(@@file))
   end

   def test_temporary_instance
      assert_respond_to(@fh, :temporary=)
      assert_nothing_raised{ @fh.temporary = true }
      assert(File.temporary?(@@file))
   end

   def test_temporary_expected_errors
      assert_raises(ArgumentError){ File.temporary? }
      assert_raises(ArgumentError){ File.temporary?(@@file, 'foo') }
   end

   def test_system
      assert_respond_to(File, :system?)
      assert_nothing_raised{ File.system?(@@file) }
      assert_equal(false, File.system?(@@file))
   end

   def test_system_instance
      assert_respond_to(@fh, :system=)
      assert_nothing_raised{ @fh.system = true }
      assert(File.system?(@@file))
   end

   def test_system_expected_errors
      assert_raises(ArgumentError){ File.system? }
      assert_raises(ArgumentError){ File.system?(@@file, 'foo') }
   end

   def test_sparse
      assert_respond_to(File, :sparse?)
      assert_nothing_raised{ File.sparse?(@@file) }
      assert_equal(false, File.sparse?(@@file))
   end

   # I don't actually test assignment here since making a file a sparse
   # file can't be undone.
   def test_sparse_instance
      assert_respond_to(@fh, :sparse=)
   end

   def test_sparse_file_expected_errors
      assert_raises(ArgumentError){ File.sparse? }
      assert_raises(ArgumentError){ File.sparse?(@@file, 'foo') }
   end

   def test_reparse_point
      assert_respond_to(File, :reparse_point?)
      assert_nothing_raised{ File.reparse_point?(@@file) }
      assert_equal(false, File.reparse_point?(@@file))
   end

   def test_reparse_point_expected_errors
      assert_raises(ArgumentError){ File.reparse_point? }
      assert_raises(ArgumentError){ File.reparse_point?(@@file, 'foo') }
   end

   def test_readonly
      assert_respond_to(File, :readonly?)
      assert_nothing_raised{ File.readonly?(@@file) }
      assert_equal(false, File.readonly?(@@file))
   end

   def test_read_only_alias
      assert_respond_to(File, :read_only?)
      assert_equal(true, File.method(:readonly?) == File.method(:read_only?))
   end

   def test_readonly_instance
      assert_respond_to(@fh, :readonly=)
      assert_nothing_raised{ @fh.readonly = true }
      assert(File.readonly?(@@file))
   end

   def test_read_only_expected_errors
      assert_raises(ArgumentError){ File.read_only? }
      assert_raises(ArgumentError){ File.read_only?(@@file, 'foo') }
   end

   def test_offline
      assert_respond_to(File, :offline?)
      assert_nothing_raised{ File.offline?(@@file) }
      assert_equal(false, File.offline?(@@file))
   end

   def test_offline_instance
      assert_respond_to(@fh, :offline=)
      assert_nothing_raised{ @fh.offline =  true }
      assert(File.offline?(@@file))
   end

   def test_offline_expected_errors
      assert_raises(ArgumentError){ File.offline? }
      assert_raises(ArgumentError){ File.offline?(@@file, 'foo') }
   end

   def test_normal
      assert_respond_to(File, :normal?)
      assert_nothing_raised{ File.normal?(@@file) }
      assert_equal(false, File.normal?(@@file))
   end

   def test_normal_instance
      assert_respond_to(@fh, :normal=)
      assert_nothing_raised{ @fh.normal = true }
      assert(File.normal?(@@file))
   end

   def test_normal_expected_errors
      assert_raises(ArgumentError){ File.normal? }
      assert_raises(ArgumentError){ File.normal?(@@file, 'foo') }
      assert_raises(ArgumentError){ @fh.normal = false }
   end

   def test_hidden
      assert_respond_to(File, :hidden?)
      assert_nothing_raised{ File.hidden?(@@file) }
      assert_equal(false, File.hidden?(@@file))
   end

   def test_hidden_instance
      assert_respond_to(@fh, :hidden=)
      assert_nothing_raised{ @fh.hidden = true }
      assert(File.hidden?(@@file))
   end

   def test_hidden_expected_errors
      assert_raises(ArgumentError){ File.hidden? }
      assert_raises(ArgumentError){ File.hidden?(@@file, 'foo') }
   end

   def test_encrypted
      assert_respond_to(File, :encrypted?)
      assert_nothing_raised{ File.encrypted?(@@file) }
      assert_equal(false, File.encrypted?(@@file))
   end

   def test_encrypted_expected_errors
      assert_raises(ArgumentError){ File.encrypted? }
      assert_raises(ArgumentError){ File.encrypted?(@@file, 'foo') }
   end

   def test_indexed
      assert_respond_to(File, :indexed?)
      assert_nothing_raised{ File.indexed?(@@file) }
      assert_equal(true, File.indexed?(@@file))
   end

   def test_content_indexed_alias
      assert_respond_to(File, :content_indexed?)
      assert(File.method(:content_indexed?) == File.method(:indexed?))
   end

   def test_indexed_instance
      assert_respond_to(@fh, :indexed=)
      assert_nothing_raised{ @fh.indexed = true }
      assert(File.indexed?(@@file))
   end

   def test_indexed_expected_errors
      assert_raises(ArgumentError){ File.indexed? }
      assert_raises(ArgumentError){ File.indexed?(@@file, 'foo') }
   end

   def test_compressed
      assert_respond_to(File, :compressed?)
      assert_nothing_raised{ File.compressed?(@@file) }
      assert_equal(false, File.compressed?(@@file))
   end

   # We have to explicitly reset the compressed attribute to false as
   # the last of these assertions.
   def test_compressed_instance
      assert_respond_to(@fh, :compressed=)
      assert_equal(false, File.compressed?(@@file))

      assert_nothing_raised{ @fh.compressed = true }
      assert_equal(true, File.compressed?(@@file))

      assert_nothing_raised{ @fh.compressed = false }
      assert_equal(false, File.compressed?(@@file))
   end

   def test_compressed_expected_errors
      assert_raises(ArgumentError){ File.compressed? }
      assert_raises(ArgumentError){ File.compressed?(@@file, 'foo') }
   end

   def test_archive
      assert_respond_to(File, :archive?)
      assert_nothing_raised{ File.archive?(@@file) }
      assert_equal(true, File.archive?(@@file))
   end

   def test_archive_instance
      assert_respond_to(@fh, :archive=)
      assert_nothing_raised{ @fh.archive = false }
      assert_equal(false, File.archive?(@@file))
   end

   def test_archive_expected_errors
      assert_raises(ArgumentError){ File.archive? }
      assert_raises(ArgumentError){ File.archive?(@@file, 'foo') }
   end

   def test_attributes
      assert_respond_to(File, :attributes)
      assert_kind_of(Array, File.attributes(@@file))
      assert_equal(['archive', 'indexed'], File.attributes(@@file))
   end

   def test_set_attributes
      assert_respond_to(File, :set_attributes)
      assert_nothing_raised{ File.set_attributes(@@file, File::HIDDEN) }
      assert(File.hidden?(@@file))
   end

   def test_set_attr_alias
      assert_respond_to(File, :set_attr)
      assert(File.method(:set_attr) == File.method(:set_attributes))
   end

   def test_remove_attributes
      assert_respond_to(File, :remove_attributes)
      assert_nothing_raised{ File.remove_attributes(@@file, File::ARCHIVE) }
      assert_equal(false, File.archive?(@@file))
   end

   def test_unset_attr_alias
      assert_respond_to(File, :unset_attr)
      assert(File.method(:unset_attr) == File.method(:remove_attributes))
   end

   def teardown
      SetFileAttributesA(@@file, @attr)
      @fh.close
   end

   def self.shutdown
      File.delete(@@file)
      @@file = nil
   end
end
