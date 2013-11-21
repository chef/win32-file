module Windows
  module File
    module Structs
      class FILETIME < FFI::Struct
        layout(:dwLowDateTime, :ulong, :dwHighDateTime, :ulong)
      end

      class WIN32_FIND_DATA < FFI::Struct
        layout(
          :dwFileAttributes, :ulong,
          :ftCreationTime, FILETIME,
          :ftLastAccessTime, FILETIME,
          :ftLastWriteTime, FILETIME,
          :nFileSizeHigh, :ulong,
          :nFileSizeLow, :ulong,
          :dwReserved0, :ulong,
          :dwReserved1, :ulong,
          :cFileName, [:uint8, 260*2],
          :cAlternateFileName, [:uint8, 14*2]
        )
      end
    end
  end
end
