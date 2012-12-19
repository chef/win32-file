module Windows
  module File
    module Functions
      extend FFI::Library
      ffi_lib :kernel32

      attach_function :CloseHandle, [:ulong], :bool
      attach_function :CreateFileW, [:buffer_in, :ulong, :ulong, :pointer, :ulong, :ulong, :ulong], :ulong
      attach_function :CreateSymbolicLinkW, [:buffer_in, :buffer_in, :ulong], :bool
      attach_function :FindFirstFileW, [:buffer_in, :pointer], :ulong
      attach_function :GetFileAttributesW, [:buffer_in], :ulong
      attach_function :GetFinalPathNameByHandleW, [:ulong, :buffer_out, :ulong, :ulong], :ulong
      attach_function :GetShortPathNameW, [:buffer_in, :buffer_out, :ulong], :ulong
      attach_function :GetLongPathNameW, [:buffer_in, :buffer_out, :ulong], :ulong
    end
  end
end

class String
  # Convenience method for converting strings to UTF-16LE for wide character
  # functions that require it.
  def wincode
    (self.tr(File::SEPARATOR, File::ALT_SEPARATOR) + 0.chr).encode('UTF-16LE')
  end
end
