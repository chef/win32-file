module Windows
  module File
    module Functions
      extend FFI::Library
      ffi_lib :kernel32

      typedef :ulong, :dword
      typedef :uintptr_t, :handle
      typedef :pointer, :ptr

      attach_function :CloseHandle, [:handle], :bool
      attach_function :CreateFileW, [:buffer_in, :dword, :dword, :pointer, :dword, :dword, :handle], :handle
      attach_function :CreateSymbolicLinkW, [:buffer_in, :buffer_in, :dword], :bool
      attach_function :FindFirstFileW, [:buffer_in, :pointer], :handle
      attach_function :GetDiskFreeSpaceW, [:buffer_in, :pointer, :pointer, :pointer, :pointer], :bool
      attach_function :GetDriveTypeW, [:buffer_in], :uint
      attach_function :GetFileType, [:handle], :dword
      attach_function :GetFileAttributesW, [:buffer_in], :dword
      attach_function :GetFinalPathNameByHandleW, [:handle, :buffer_out, :dword, :dword], :dword
      attach_function :GetShortPathNameW, [:buffer_in, :buffer_out, :dword], :dword
      attach_function :GetLongPathNameW, [:buffer_in, :buffer_out, :dword], :dword
      attach_function :QueryDosDeviceA, [:string, :buffer_out, :dword], :dword

      ffi_lib :shlwapi

      attach_function :PathFindExtensionW, [:buffer_in], :pointer
      attach_function :PathIsRootW, [:buffer_in], :bool
      attach_function :PathStripPathW, [:buffer_in], :void
      attach_function :PathRemoveBackslashW, [:buffer_in], :string
      attach_function :PathRemoveFileSpecW, [:buffer_in], :bool
      attach_function :PathRemoveExtensionW, [:buffer_in], :void
      attach_function :PathStripToRootW, [:buffer_in], :bool
    end
  end
end

class String
  # Read a wide character string up until the first double null, and delete
  # any remaining null characters.
  def wstrip
    self.force_encoding('UTF-16LE')[Regexp.new("^.*?(?=\x00)".encode('UTF-16LE'))].encode(Encoding.default_external)
  end
end
