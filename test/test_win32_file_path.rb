#############################################################################
# test_win32_file_path.rb
#
# Test case for the path related methods of win32-file. You should run this
# test via the 'rake test' or 'rake test_path' task.
#############################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'win32/file'

class TC_Win32_File_Path < Test::Unit::TestCase
   def self.startup
      Dir.chdir(File.dirname(File.expand_path(File.basename(__FILE__))))
      @@file = File.join(Dir.pwd, 'path_test.txt')
      File.open(@@file, 'w'){ |fh| fh.puts "This is a path test." }
   end

   def setup
      @long_file  = File.join(Dir.pwd, 'path_test.txt')      
      @short_file = File.join(Dir.pwd, 'PATH_T~1.TXT')
   end
   
   def test_basename_basic
      assert_respond_to(File, :basename)
      assert_nothing_raised{ File.basename("C:\\foo") }
      assert_kind_of(String, File.basename("C:\\foo"))
   end
      
   def test_basename_standard_paths
      assert_equal("baz.txt", File.basename("C:\\foo\\bar\\baz.txt"))
      assert_equal("baz", File.basename("C:\\foo\\bar\\baz.txt", ".txt"))
      assert_equal("baz.txt", File.basename("C:\\foo\\bar\\baz.txt", ".zip"))
      assert_equal("bar", File.basename("C:\\foo\\bar"))
      assert_equal("bar", File.basename("C:\\foo\\bar\\"))
      assert_equal("foo", File.basename("C:\\foo"))
      assert_equal("C:\\", File.basename("C:\\"))
   end
      
   def test_basename_unc_paths
      assert_equal("baz.txt", File.basename("\\\\foo\\bar\\baz.txt"))
      assert_equal("baz", File.basename("\\\\foo\\bar\\baz"))
      assert_equal("\\\\foo", File.basename("\\\\foo"))
      assert_equal("\\\\foo\\bar", File.basename("\\\\foo\\bar"))
   end
      
   def test_basename_unix_style_paths
      assert_equal("bar", File.basename("/foo/bar"))
      assert_equal("bar.txt", File.basename("/foo/bar.txt"))
      assert_equal("bar.txt", File.basename("bar.txt"))
      assert_equal("bar", File.basename("/bar"))
      assert_equal("bar", File.basename("/bar/"))
      assert_equal("baz", File.basename("//foo/bar/baz"))
      assert_equal("\\\\foo", File.basename("//foo"))
      assert_equal("\\\\foo\\bar", File.basename("//foo/bar"))
   end
      
   def test_basename_with_forward_slashes
      assert_equal("bar", File.basename("C:/foo/bar"))
      assert_equal("bar", File.basename("C:/foo/bar/"))
      assert_equal("foo", File.basename("C:/foo"))
      assert_equal("C:\\", File.basename("C:/"))
      assert_equal("bar", File.basename("C:/foo/bar//"))
   end
         
   def test_basename_edge_cases
      assert_equal("", File.basename(""))
      assert_equal(".", File.basename("."))
      assert_equal("..", File.basename(".."))
      assert_equal("foo", File.basename("//foo/"))
   end
      
   def test_basename_with_suffixes
      assert_equal("bar", File.basename("bar.txt", ".txt"))
      assert_equal("bar", File.basename("/foo/bar.txt", ".txt"))
      assert_equal("bar.txt", File.basename("bar.txt", ".exe"))
      assert_equal("bar.txt", File.basename("bar.txt.exe", ".exe"))
      assert_equal("bar.txt.exe", File.basename("bar.txt.exe", ".txt"))
      assert_equal("bar", File.basename("bar.txt", ".*"))
      assert_equal("bar.txt", File.basename("bar.txt.exe", ".*"))
   end
      
   def test_basename_does_not_modify_argument
      path = "C:\\foo\\bar"
      assert_nothing_raised{ File.basename(path) }
      assert_equal("C:\\foo\\bar", path)    
   end
   
   def test_dirname_basic
      assert_respond_to(File, :dirname)
      assert_nothing_raised{ File.dirname("C:\\foo") }
      assert_kind_of(String, File.dirname("C:\\foo"))
   end
      
   def test_dirname_standard_paths
      assert_equal("C:\\foo", File.dirname("C:\\foo\\bar.txt"))
      assert_equal("C:\\foo", File.dirname("C:\\foo\\bar"))
      assert_equal("C:\\", File.dirname("C:\\foo"))
      assert_equal("C:\\", File.dirname("C:\\"))
      assert_equal(".", File.dirname("foo"))
   end
      
   def test_dirname_unc_paths
      assert_equal("\\\\foo\\bar", File.dirname("\\\\foo\\bar\\baz"))
      assert_equal("\\\\foo\\bar", File.dirname("\\\\foo\\bar"))
      assert_equal("\\\\foo", File.dirname("\\\\foo"))
      assert_equal("\\\\", File.dirname("\\\\"))
   end
    
   def test_dirname_forward_slashes
      assert_equal("C:\\foo", File.dirname("C:/foo/bar.txt"))
      assert_equal("C:\\foo", File.dirname("C:/foo/bar"))
      assert_equal("C:\\", File.dirname("C:/foo"))
      assert_equal("C:\\", File.dirname("C:/"))
      assert_equal("\\\\foo\\bar", File.dirname("//foo/bar/baz"))
      assert_equal("\\\\foo\\bar", File.dirname("//foo/bar"))
      assert_equal("\\\\foo", File.dirname("//foo"))
      assert_equal("\\\\", File.dirname("//"))
      assert_equal(".", File.dirname("./foo"))
      assert_equal(".\\foo", File.dirname("./foo/bar"))
   end
      
   def test_dirname_edge_cases
      assert_equal(".", File.dirname(""))
      assert_equal(".", File.dirname("."))
      assert_equal(".", File.dirname("."))
      assert_equal(".", File.dirname("./"))
      assert_raises(TypeError){ File.dirname(nil) }
   end
      
   def test_dirname_does_not_modify_argument
      path = "C:\\foo\\bar"
      assert_nothing_raised{ File.dirname(path) }
      assert_equal("C:\\foo\\bar", path)
   end
   
   def test_split_basic
      assert_respond_to(File, :split)
      assert_nothing_raised{ File.split("C:\\foo\\bar") }
      assert_kind_of(Array, File.split("C:\\foo\\bar"))
   end
      
   def test_split_standard_paths
      assert_equal(["C:\\foo", "bar"], File.split("C:\\foo\\bar"))     
      assert_equal([".", "foo"], File.split("foo"))
   end
      
   def test_split_forward_slashes
      assert_equal(["C:\\foo", "bar"], File.split("C:/foo/bar"))
      assert_equal([".", "foo"], File.split("foo"))
   end
      
   def test_split_unix_paths
      assert_equal(["\\foo","bar"], File.split("/foo/bar"))
      assert_equal(["\\", "foo"], File.split("/foo"))
      assert_equal([".", "foo"], File.split("foo"))
   end
      
   def test_split_unc_paths
      assert_equal(["\\\\foo\\bar", "baz"], File.split("\\\\foo\\bar\\baz"))
      assert_equal(["\\\\foo\\bar", ""], File.split("\\\\foo\\bar"))
      assert_equal(["\\\\foo", ""], File.split("\\\\foo"))
      assert_equal(["\\\\", ""], File.split("\\\\"))
   end

   def test_split_edge_cases
      assert_equal(["C:\\", ""], File.split("C:\\"))
      assert_equal(["", ""], File.split(""))
   end
      
   def test_split_does_not_modify_arguments
      path = "C:\\foo\\bar"
      assert_nothing_raised{ File.split(path) }
      assert_equal("C:\\foo\\bar", path)
   end
   
   def test_long_path
      assert_respond_to(File, :long_path)
      assert_equal(@long_file, File.long_path(@short_file))
      assert_equal('PATH_T~1.TXT', File.basename(@short_file))
   end
   
   def test_short_path
      assert_respond_to(File, :short_path)
      assert_equal('path_test.txt', File.basename(@long_file))
   end
   
   def teardown
      @short_file = nil
      @long_file  = nil
   end

   def self.shutdown
      File.delete(@@file) if File.exists?(@@file)
      @@file = nil
   end
end
