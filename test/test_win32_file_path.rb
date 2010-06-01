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
   
  test "basename method basic functionality" do
    assert_respond_to(File, :basename)
    assert_nothing_raised{ File.basename("C:\\foo") }
    assert_kind_of(String, File.basename("C:\\foo"))
  end
      
  test "basename method handles standard paths" do
    assert_equal("baz.txt", File.basename("C:\\foo\\bar\\baz.txt"))
    assert_equal("baz", File.basename("C:\\foo\\bar\\baz.txt", ".txt"))
    assert_equal("baz.txt", File.basename("C:\\foo\\bar\\baz.txt", ".zip"))
    assert_equal("bar", File.basename("C:\\foo\\bar"))
    assert_equal("bar", File.basename("C:\\foo\\bar\\"))
    assert_equal("foo", File.basename("C:\\foo"))
    assert_equal("C:\\", File.basename("C:\\"))
  end
      
  test "basename method handles unc paths" do
    assert_equal("baz.txt", File.basename("\\\\foo\\bar\\baz.txt"))
    assert_equal("baz", File.basename("\\\\foo\\bar\\baz"))
    assert_equal("\\\\foo", File.basename("\\\\foo"))
    assert_equal("\\\\foo\\bar", File.basename("\\\\foo\\bar"))
  end
 
  test "basename method handles forward slashes in standard unix paths" do
    assert_equal("bar", File.basename("/foo/bar"))
    assert_equal("bar.txt", File.basename("/foo/bar.txt"))
    assert_equal("bar.txt", File.basename("bar.txt"))
    assert_equal("bar", File.basename("/bar"))
    assert_equal("bar", File.basename("/bar/"))
    assert_equal("baz", File.basename("//foo/bar/baz"))
  end

  test "basename method handles forward slashes in unc unix paths" do
    assert_equal("\\\\foo", File.basename("//foo"))
    assert_equal("\\\\foo\\bar", File.basename("//foo/bar"))
  end
      
  test "basename method handles forward slashes in windows paths" do
    assert_equal("bar", File.basename("C:/foo/bar"))
    assert_equal("bar", File.basename("C:/foo/bar/"))
    assert_equal("foo", File.basename("C:/foo"))
    assert_equal("C:\\", File.basename("C:/"))
    assert_equal("bar", File.basename("C:/foo/bar//"))
  end
         
  test "basename handles edge cases as expected" do
    assert_equal("", File.basename(""))
    assert_equal(".", File.basename("."))
    assert_equal("..", File.basename(".."))
    assert_equal("foo", File.basename("//foo/"))
  end
 
  test "basename handles path names with suffixes" do
    assert_equal("bar", File.basename("bar.txt", ".txt"))
    assert_equal("bar", File.basename("/foo/bar.txt", ".txt"))
    assert_equal("bar.txt", File.basename("bar.txt", ".exe"))
    assert_equal("bar.txt", File.basename("bar.txt.exe", ".exe"))
    assert_equal("bar.txt.exe", File.basename("bar.txt.exe", ".txt"))
    assert_equal("bar", File.basename("bar.txt", ".*"))
    assert_equal("bar.txt", File.basename("bar.txt.exe", ".*"))
  end
      
  test "basename method does not modify its argument" do
    path = "C:\\foo\\bar"
    assert_nothing_raised{ File.basename(path) }
    assert_equal("C:\\foo\\bar", path)    
  end
   
  test "dirname basic functionality" do
    assert_respond_to(File, :dirname)
    assert_nothing_raised{ File.dirname("C:\\foo") }
    assert_kind_of(String, File.dirname("C:\\foo"))
  end
     
  test "dirname handles standard windows paths as expected" do
    assert_equal("C:\\foo", File.dirname("C:\\foo\\bar.txt"))
    assert_equal("C:\\foo", File.dirname("C:\\foo\\bar"))
    assert_equal("C:\\", File.dirname("C:\\foo"))
    assert_equal("C:\\", File.dirname("C:\\"))
    assert_equal(".", File.dirname("foo"))
  end
      
  test "dirname handles unc windows paths as expected" do
    assert_equal("\\\\foo\\bar", File.dirname("\\\\foo\\bar\\baz"))
    assert_equal("\\\\foo\\bar", File.dirname("\\\\foo\\bar"))
    assert_equal("\\\\foo", File.dirname("\\\\foo"))
    assert_equal("\\\\", File.dirname("\\\\"))
  end
    
  test "dirname handles forward slashes in standard windows path names" do
    assert_equal("C:\\foo", File.dirname("C:/foo/bar.txt"))
    assert_equal("C:\\foo", File.dirname("C:/foo/bar"))
    assert_equal("C:\\", File.dirname("C:/foo"))
    assert_equal("C:\\", File.dirname("C:/"))
  end

  test "dirname handles forward slashes in unc windows path names" do
    assert_equal("\\\\foo\\bar", File.dirname("//foo/bar/baz"))
    assert_equal("\\\\foo\\bar", File.dirname("//foo/bar"))
    assert_equal("\\\\foo", File.dirname("//foo"))
    assert_equal("\\\\", File.dirname("//"))
  end

  test "dirname handles forward slashes in relative path names" do
    assert_equal(".", File.dirname("./foo"))
    assert_equal(".\\foo", File.dirname("./foo/bar"))
  end
    
  test "dirname handles various edge cases as expected" do
    assert_equal(".", File.dirname(""))
    assert_equal(".", File.dirname("."))
    assert_equal(".", File.dirname("."))
    assert_equal(".", File.dirname("./"))
    assert_raises(TypeError){ File.dirname(nil) }
  end
      
  test "dirname method does not modify its argument" do
    path = "C:\\foo\\bar"
    assert_nothing_raised{ File.dirname(path) }
    assert_equal("C:\\foo\\bar", path)
  end
   
  test "split method basic functionality" do
    assert_respond_to(File, :split)
    assert_nothing_raised{ File.split("C:\\foo\\bar") }
    assert_kind_of(Array, File.split("C:\\foo\\bar"))
  end
      
  test "split method handles standard windows path names" do
    assert_equal(["C:\\foo", "bar"], File.split("C:\\foo\\bar"))     
    assert_equal([".", "foo"], File.split("foo"))
  end

  test "split method handles windows paths with forward slashes" do
    assert_equal(["C:\\foo", "bar"], File.split("C:/foo/bar"))
    assert_equal([".", "foo"], File.split("foo"))
  end
      
  test "split method handles standard unix paths as expected" do
    assert_equal(["\\foo","bar"], File.split("/foo/bar"))
    assert_equal(["\\", "foo"], File.split("/foo"))
    assert_equal([".", "foo"], File.split("foo"))
  end
      
  test "split method handles unc paths as expected" do
    assert_equal(["\\\\foo\\bar", "baz"], File.split("\\\\foo\\bar\\baz"))
    assert_equal(["\\\\foo\\bar", ""], File.split("\\\\foo\\bar"))
    assert_equal(["\\\\foo", ""], File.split("\\\\foo"))
    assert_equal(["\\\\", ""], File.split("\\\\"))
  end

  test "split method handles various edge cases as expected" do
    assert_equal(["C:\\", ""], File.split("C:\\"))
    assert_equal(["", ""], File.split(""))
  end
      
  test "split method does not modify its arguments" do
    path = "C:\\foo\\bar"
    assert_nothing_raised{ File.split(path) }
    assert_equal("C:\\foo\\bar", path)
  end
   
  test "long_path method works as expected" do
    assert_respond_to(File, :long_path)
    assert_equal(@long_file, File.long_path(@short_file))
    assert_equal('PATH_T~1.TXT', File.basename(@short_file))
  end
   
  test "short_path method works as expected" do
    assert_respond_to(File, :short_path)
    assert_equal('path_test.txt', File.basename(@long_file))
  end

  test "join method works as expected" do
    assert_respond_to(File, :join)
  end

  test "join handles multiple arguments as expected" do
    assert_equal("C:\\foo\\bar", File.join("C:", "foo", "bar"))
    assert_equal("foo\\bar", File.join("foo", "bar"))
  end

  test "join handles multiple arguments as expected with unc paths" do
    assert_equal("\\\\foo", File.join("\\\\foo"))
    assert_equal("\\\\foo\\bar", File.join("\\\\foo", "bar"))
  end

  test "join does not normalize paths" do
    assert_equal("C:\\.\\foo\\..", File.join("C:", ".", "foo", ".."))
  end

  test "join with no arguments returns an empty string" do
    assert_equal('', File.join)
  end

  test "join with one argument returns the argument" do
    assert_equal('foo', File.join('foo'))
    assert_equal('c:', File.join('c:'))
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
