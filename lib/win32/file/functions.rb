module Windows
  module File
    module Functions
      extend FFI::Library
      ffi_lib :kernel32

      typedef :ulong, :dword
      typedef :uintptr_t, :handle
      typedef :pointer, :ptr

      def self.attach_pfunc(*args)
        attach_function(*args)
        private args[0]
      end

      attach_pfunc :CloseHandle, [:handle], :bool
      attach_pfunc :CreateFileW, [:buffer_in, :dword, :dword, :pointer, :dword, :dword, :handle], :handle
      attach_pfunc :CreateSymbolicLinkW, [:buffer_in, :buffer_in, :dword], :bool
      attach_pfunc :FindFirstFileW, [:buffer_in, :pointer], :handle
      attach_pfunc :GetDiskFreeSpaceW, [:buffer_in, :pointer, :pointer, :pointer, :pointer], :bool
      attach_pfunc :GetDriveTypeW, [:buffer_in], :uint
      attach_pfunc :GetFileType, [:handle], :dword
      attach_pfunc :GetFileAttributesW, [:buffer_in], :dword
      attach_pfunc :GetFinalPathNameByHandleW, [:handle, :buffer_out, :dword, :dword], :dword
      attach_pfunc :GetShortPathNameW, [:buffer_in, :buffer_out, :dword], :dword
      attach_pfunc :GetLongPathNameW, [:buffer_in, :buffer_out, :dword], :dword
      attach_pfunc :QueryDosDeviceA, [:string, :buffer_out, :dword], :dword
      attach_pfunc :SetFileTime, [:handle, :ptr, :ptr, :ptr], :bool
      attach_pfunc :SystemTimeToFileTime, [:ptr, :ptr], :bool

      ffi_lib :shlwapi

      attach_pfunc :PathFindExtensionW, [:buffer_in], :pointer
      attach_pfunc :PathIsRootW, [:buffer_in], :bool
      attach_pfunc :PathStripPathW, [:pointer], :void
      attach_pfunc :PathRemoveBackslashW, [:buffer_in], :string
      attach_pfunc :PathRemoveFileSpecW, [:pointer], :bool
      attach_pfunc :PathRemoveExtensionW, [:buffer_in], :void
      attach_pfunc :PathStripToRootW, [:buffer_in], :bool
    end
  end
end
