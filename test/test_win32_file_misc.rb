########################################################################
# Miscellaneous tests for win32-file that didn't fit anywhere else.
########################################################################
require 'win32/file'
require 'test-unit'

class TC_Win32_File_Misc < Test::Unit::TestCase
  test "version constant is set to expected value" do
    assert_equal('0.8.2', File::WIN32_FILE_VERSION)
  end

  test "ffi functions are private" do
    assert_not_respond_to(File, :CloseHandle)
    assert_not_respond_to(File, :CreateFileW)
  end
end
