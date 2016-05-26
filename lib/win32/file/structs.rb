module Windows
  module File
    module Structs
      class FILETIME < FFI::Struct
        layout(:dwLowDateTime, :ulong, :dwHighDateTime, :ulong)
      end

      class SYSTEMTIME < FFI::Struct
        layout(
          :wYear, :ushort,
          :wMonth, :ushort,
          :wDayOfWeek, :ushort,
          :wDay, :ushort,
          :wHour, :ushort,
          :wMinute, :ushort,
          :wSecond, :ushort,
          :wMilliseconds, :ushort
        )

        # Allow a time object or raw numeric in constructor
        def initialize(time = nil)
          super()

          time = Time.at(time) if time.is_a?(Numeric)
          time = time.utc unless time.utc?

          self[:wYear] = time.year
          self[:wMonth] = time.month
          self[:wDayOfWeek] = time.wday
          self[:wDay] = time.day
          self[:wHour] = time.hour
          self[:wMinute] = time.min
          self[:wSecond] = time.sec
          self[:wMilliseconds] = time.nsec / 1000000
        end
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

      class LUID < FFI::Struct
        layout(:LowPart, :ulong, :HighPart, :long)
      end

      class LUID_AND_ATTRIBUTES < FFI::Struct
        layout(:Luid, LUID, :Attributes, :ulong)
      end

      class TOKEN_PRIVILEGES < FFI::Struct
        layout(
          :PrivilegeCount, :ulong,
          :Privileges, [LUID_AND_ATTRIBUTES, 1]
        )
      end
    end
  end
end
