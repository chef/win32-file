#############################################################################
# test_win32_file_path.rb
#
# Test case for the path related methods of win32-file. You should run this
# test via the 'rake' or 'rake test:path' task.
#############################################################################
require 'test-unit'
require 'win32/file'
require 'pathname'

class TC_Win32_File_Path < Test::Unit::TestCase
  def self.startup
    Dir.chdir(File.expand_path(File.dirname(__FILE__)))
    @@file = File.join(Dir.pwd, 'path_test.txt')
    File.open(@@file, 'w'){ |fh| fh.puts "This is a path test." }
  end

  def setup
    @long_file  = File.join(Dir.pwd, 'path_test.txt').tr("/", "\\")
    @short_file = File.join(Dir.pwd, 'PATH_T~1.TXT').tr("/", "\\")
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

  test "basename removes all trailing slashes" do
    assert_equal("foo.txt", File.basename("C:/foo.txt/"))
    assert_equal("foo.txt", File.basename("C:/foo.txt//"))
    assert_equal("foo.txt", File.basename("C:/foo.txt///"))
    assert_equal("foo.txt", File.basename("C:\\foo.txt\\"))
    assert_equal("foo.txt", File.basename("C:\\foo.txt\\\\"))
    assert_equal("foo.txt", File.basename("C:\\foo.txt\\\\\\"))
    assert_equal("foo.txt", File.basename("foo.txt\\\\\\"))
  end

  test "basename method handles arguments that honor to_str or to_path" do
    assert_equal("foo.txt", File.basename(Pathname.new("C:/blah/blah/foo.txt")))
    assert_equal("foo", File.basename(Pathname.new("C:/blah/blah/foo.txt"), Pathname.new(".*")))
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
    assert_equal(".", File.dirname(".."))
    assert_equal(".", File.dirname("./"))
  end

  test "dirname method does not modify its argument" do
    path = "C:\\foo\\bar"
    assert_nothing_raised{ File.dirname(path) }
    assert_equal("C:\\foo\\bar", path)
  end

  test "dirname method ignores trailing slashes" do
    assert_equal("C:\\foo\\bar", File.dirname("C:/foo/bar/baz/"))
    assert_equal("C:\\foo\\bar", File.dirname("C:/foo/bar/baz//"))
    assert_equal("C:\\foo\\bar", File.dirname("C:/foo/bar/baz///"))
    assert_equal("C:\\foo\\bar", File.dirname("C:\\foo\\bar\\baz\\"))
    assert_equal("\\\\foo\\bar", File.dirname("\\\\foo\\bar\\baz\\"))
  end

  test "argument to dirname must be a stringy object" do
    assert_raises(TypeError){ File.dirname(nil) }
    assert_raises(TypeError){ File.dirname(['foo', 'bar']) }
  end

  test "dirname method handles arguments that honor to_str or to_path" do
    assert_equal("C:\\blah\\blah", File.dirname(Pathname.new("C:/blah/blah/foo.txt")))
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

  test "split method accepts stringy arguments" do
    assert_equal(["C:\\foo", "bar"], File.split(Pathname.new("C:/foo/bar")))
  end

  test "split requires a stringy argument or a TypeError is raised" do
    assert_raise(TypeError){ File.split(nil) }
    assert_raise(TypeError){ File.split([]) }
  end

  test "File.long_path basic functionality" do
    assert_respond_to(File, :long_path)
    assert_nothing_raised{ File.long_path(@short_file) }
    assert_kind_of(String, File.long_path(@short_file))
  end

  test "File.long_path returns the expected result" do
    assert_equal(@long_file, File.long_path(@short_file))
  end

  test "File.short_path basic functionality" do
    assert_respond_to(File, :short_path)
    assert_nothing_raised{ File.short_path(@short_file) }
    assert_kind_of(String, File.short_path(@short_file))
  end

  test "File.short_path returns the expected result" do
    path = File.short_path(@long_file)
    assert_equal('PATH_T~1.TXT', File.basename(path))
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
    File.delete(@@file) if File.exist?(@@file)
    @@file = nil
  end
end
