require 'ffi'

module Windows
  module File
    module Constants
      FILE_ATTRIBUTE_REPARSE_POINT = 0x00000400
      INVALID_HANDLE_VALUE = 0xFFFFFFFF
      INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF
      IO_REPARSE_TAG_SYMLINK = 0xA000000C
    end
  end
end
