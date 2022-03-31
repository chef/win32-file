# win32-file Changelog 

<!-- latest_release 0.8.2 -->
<!-- latest_release -->

<!-- release_rollup -->
<!-- release_rollup -->

<!-- latest_stable_release -->
<!-- latest_stable_release -->

## Previous Release

== 0.8.2 - 29-May-2018
* Fixes of Pathname.parent for root directory

== 0.8.1 - 25-Jun-2016
* Removed the custom wstrip method, use ffi-win32-extensions instead,
  which was added as a dependency.
* Added appveyor.yml file.

== 0.8.0 - 30-Oct-2015
* The File.atime, File.ctime and File.mtime methods now accept an optional
  second argument. If present, those values are set to whatever value that
  you provided.

== 0.7.3 - 26-Oct-2015
* This gem is now signed.
* Fixed a test for File.file?
* Added a win32-file.rb file for convenience.

== 0.7.2 - 7-Oct-2014
* Replaced File.exists? with File.exist? to avoid deprecation warnings
  for Ruby 2.x.
* Some minor memory improvements by explicitly freeing some pointers.
* Minor README updates.

== 0.7.1 - 28-Apr-2014
* Modified all custom singleton methods to accept arguments that define either
  to_str or to_path to be in line with MRI's behavior.
* Some internal changes for the long_path and short_path methods.
* Added some path tests.

== 0.7.0 - 16-Dec-2013
* Now requires Ruby 1.9 or later.
* Converted to use FFI instead of win32-api. Now works with JRuby, too.
* Removed the atribute methods (hidden?, normal?, etc). These are now in
  the win32-file-attributes gem instead.
* The encryption and security related methods were removed. These are now in
  the win32-security and win32-file-security gems instead.
* Added implementations of readable?, readable_real?, writable?,
  writable_real?, world_readable? and world_writable?, courtesy of the
  win32-file-stat library.

== 0.6.8 - 6-Apr-2012
* Fixed some unused variable warnings for 1.9.3.
* Minor cleanup of the Rakefile.
* Fixed an issue with a blockdev test.

== 0.6.7 - 23-Nov-2011
* Fixed an encoding problem with File.set_permissions for Ruby 1.9.x.
* Fixed a bug in File.basename where an error could be caused by trailing
  slashes. Thanks go to paz for the spot and patch.
* Updated the clean task in the Rakefile.

== 0.6.6 - 3-Sep-2010
* Fixed a bug in the custom File.dirname where trailing slashes were
  affecting the result. Trailing slashes are now ignored.
* Added a global test task and a default rake task. Both run all tests.

== 0.6.5 - 19-Jul-2010
* Removed debug print statement (oops!).

== 0.6.4 - 3-Jun-2010
* Redefined the File.join method so that it converts all forward slashes
  to back slashes.
* Refactored the Rakefile and path tests a bit.
* Bumped the minimum test-unit version to 2.0.7.

== 0.6.3 - 24-Aug-2009
* Refactored the File.directory? method so that it checks against the
  INVALID_FILE_ATTRIBUTES constant instead of a hard coded value.
* Updated windows-pr dependency to 1.0.8.

== 0.6.2 - 19-Dec-2009
* Changed the license to Artistic 2.0.
* Several gemspec updates, including the license and description.

== 0.6.1 - 9-Feb-2009
* Fixed a bug in the custom File.directory? method with regards to
  non-existent directories. Thanks go to Montgomery Kosma for the spot.

== 0.6.0 - 14-Nov-2008
* Converted methods to use wide character handling.
* Added working implementations for the File.readlink, File.symlink and
  File.symlink? singleton methods. These require Windows Vista or later to
  work properly. Otherwise, they follow current MRI behavior.
* To work properly in conjunction with win32-file-stat, a custom version
  of the File.directory? method was implemented.
* Changed VERSION to WIN32_FILE_VERSION to be more consistent with other
  Win32Utils libraries, and to avoid any potential conflicts with Ruby itself.
* Prerequisite updates.

== 0.5.6 - 30-Sep-2008
* The File.long_path and File.short_path methods now return the full path
  instead of just the basename of the path. I really have no idea why I was
  doing that before, but it's fixed now.
* Fixed error handling in the File#compressed= and File#sparse= methods.
* All tests were renamed and refactored to use test-unix 2.x, which is now
  a pre-requisite for this library.
* Some gemspec updates, including a rubyforge project.

== 0.5.5 - 22-Nov-2007
* Fixed a bug in the File.dirname method with regards to relative paths.
  Thanks go to an Laust Rud for the spot.
* Removed the install.rb file. Use the 'rake install' task instead.
* Added more tests to ensure the File.dirname method works properly and
  did some test refactoring in general.

== 0.5.4 - 8-Apr-2007
* Now runs -w clean.
* Added a Rakefile. Manual installation and testing should now be handled
  by the Rake tasks.
* Some updates to the README file.

== 0.5.3 - 2-Nov-2006
* Added the File.lstat method.  It's abscence caused problems for cross
  platform packages (such as the 'find' module) which were expecting a result
  for File.lstat.  Thanks go to "Oliver" (python152) from the mailing list
  for the spot.

== 0.5.2 - 12-May-2006
* Added explicit File.stat and File#stat methods to ensure that the File::Stat
  object returned is the one defined in the win32-file-stat package.

== 0.5.1 - 27-Apr-2006
* Added the File.content_indexed? alias for File.indexed?
* Added the corresponding File::CONTENT_INDEXED constant alias.
* Fixed an issue with the Windows::Error module not being extended the way
  it should have been.
* Updated the ts_all.rb file to actually include *all* the tests.

== 0.5.0 - 22-Apr-2006
* Replaced C version with pure Ruby version.
* Added a gem.
* Requires the win32-file-stat package.  Some methods are just a facade for
  File::Stat methods.
* Removed the native IO methods and related attributes - nread, nwrite, flags,
  creation_mode, share_mode, access_mode.  These will be moved into their own
  package (win32-io) eventually.
* The File.get_permissions method now takes an optional hostname as the second
  argument.  If it isn't provided, it defaults to localhost.
* The File.set_attr method was renamed to File.set_attributes (though an alias
  has been provided for backwards compatibility). 
* The File.unset_attr method was renamed to File.remove_attributes.  Again, an
  alias was created for backwards compatibility.
* The File.content_indexed? method is now just File.indexed?  Likewise, the
  File::CONTENT_INDEXED constant is now just File::INDEXED.

== 0.4.6 - 20-Nov-2005
* Fixed potential segfaults caused by passing invalid types.  This affects
  most methods.
* Added more tests to look for explicit TypeError's.

== 0.4.5 - 17-Sep-2005
* Fixed bug in File.basename and File.dirname where receiver was being
  modified.
* Overrode the File.split method to handle UNC paths properly.
* More tests.

== 0.4.4 - 20-Aug-2005
* Fixed some bugs in the File.basename method.
* Added more tests for the File.basename method.

== 0.4.3 - 25-May-2005
* Added custom versions of File.basename and File.dirname so that they work
  with UNC paths correctly.  This requires linking against libshlwapi, which
  was added in the extconf.rb file.
* Better Unicode support (I think).
* Added some safe string handling.
* Tests added for File.basename and File.dirname.
* Removed the file.rd file.  You can run rdoc over the file.txt file to
  generate html documentation if you wish.

== 0.4.2 - 1-Feb-2005
* Added a macro check for EncryptFile(), which turns out to only be supported
  on Windows 2000 or later.  Thanks go to Takaaki Tateishi for the spot.

== 0.4.1 - 30-Nov-2004
* Added working implementations for File.blockdev? and File.chardev?
* Corresponding test suite and doc additions.
* Corrected the release date for 0.4.0.

== 0.4.0 - 26-Nov-2004
* Added the File.nopen class method, and File#nread and File#nwrite instance
  methods.  These are wrappers for Window's native methods.  See documentation
  for more details.  Also see some examples in the 'examples' directory.
* Added my own implementation of File.size, because the current version is not
  64 bit aware (i.e. does not return correct values for sizes over 2 GB).  I
  will remove this once Ruby has been updated.
* Modified File#path to use GetFullPathName() internally if Ruby's own
  File#path method fails.  This was mostly done for internal usage, but it
  has the effect of making File#path a little more robust on Windows I think.

== 0.3.0 - 10-Nov-2004
* Added the archive=, hidden=, normal=, compressed=, content_indexed=,
  offline=, readonly=, sparse=, system=, and temporary= instance methods.
* Changed set_permission to set_permissions, and get_permission to
  get_permissions, respectively.
* Moved the examples directory to the toplevel directory.
* Added and/or modified some files to be rdoc friendly.
* Documentation and test suite updates.

== 0.2.2 - 17-Aug-2004
* Added the encrypt() and decrypt() class methods.  These are wrappers
  for the EncryptFile() and DecryptFile() Win32 functions.
* Corresponding test suite and documentation additions.
* Added a crypt and decrypt test example, crypt_test.rb, under doc/examples.

== 0.2.1 - 10-Aug-2004
* Replaced all occurrences of the deprecated STR2CSTR() function with
  StringValuePtr().  That means that, as of this release, this package
  requires Ruby 1.8.0 or later.
* Added the long_path method (may not be supported on NT).
* Documentation and test suite additions
* Some code cleanup and reorganization.
* Moved sample scripts to doc/examples.
* Removed the file.html file from the doc directory.  You can generate the
  html documentation with rd2 if you like.

== 0.2.0 - 8-May-2004
* Removed the toplevel Win32 module/namespace (except for the require line).
  I felt that having to put "Win32::" in front of all the methods was too
  painful.
* Added the CACLS attribute getter and setter (Park).
* Updated docs to reflect changes, added warranty information.
* Moved the pure ruby version to its own directory.  In lieu of the installer
  now available for our packages, this version is no longer guaranteed to be
  maintained, but I'll leave it in the package for now.

== 0.1.1 - 3-Nov-2003
* Added the content_indexed? method
* Added the set_attr and unset_attr methods
* Added constants that apply to set_attr and unset_attr
* Replaced GetFileAttributesEx() with the simpler GetFileAttributes().
  The former provides no additional information that isn't already covered by File::Stat.
* Test suite additions
* Documentation additions

== 0.1.0 - 29-Oct-2003
* Initial release
