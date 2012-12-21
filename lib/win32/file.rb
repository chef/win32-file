require File.join(File.dirname(__FILE__), 'file', 'constants')
require File.join(File.dirname(__FILE__), 'file', 'structs')
require File.join(File.dirname(__FILE__), 'file', 'functions')

class File
  include Windows::File::Constants
  include Windows::File::Structs
  extend Windows::File::Functions

  WIN32_FILE_VERSION = '0.7.0'

  class << self
    remove_method :basename
    remove_method :readlink
    remove_method :symlink
    remove_method :symlink?
  end

  ## Path methods

  # Returns the last component of the filename given in +filename+.  If
  # +suffix+ is given and present at the end of +filename+, it is removed.
  # Any extension can be removed by giving an extension of ".*".
  #
  # This was reimplemented because the current version does not handle UNC
  # paths properly, i.e. it should not return anything less than the root.
  # In most other respects it is identical to the current implementation.
  #
  # Unlike MRI, this version will convert all forward slashes to
  # backslashes automatically.
  #
  # Examples:
  #
  #    File.basename("C:\\foo\\bar.txt")         -> "bar.txt"
  #    File.basename("C:\\foo\\bar.txt", ".txt") -> "bar"
  #    File.basename("\\\\foo\\bar")             -> "\\\\foo\\bar"
  #
  def self.basename(file, suffix = nil)
    raise TypeError unless file.is_a?(String)
    raise TypeError unless suffix.is_a?(String) if suffix

    return file if file.empty? # Return an empty path as-is.

    # Required for Windows API functions to work properly.
    file.tr!(File::SEPARATOR, File::ALT_SEPARATOR)

    encoding = file.encoding
    wfile = file.wincode

    # Return a root path as-is.
    return file if PathIsRootW(wfile)

    PathStripPathW(wfile) # Gives us the basename

    if suffix
      if suffix == '.*'
        PathRemoveExtensionW(wfile)
      else
        ext = PathFindExtensionW(wfile).read_string(suffix.length * 2).delete(0.chr)

        if ext == suffix
          PathRemoveExtensionW(wfile)
        end
      end
    end

    file = wfile.encode(encoding)[/^[^\0]*/]
    file.sub!(/\\+\z/, '') # Trim trailing slashes

    file
  end

  def self.long_path(file)
    buffer = 0.chr * 512
    wfile  = file.wincode

    if GetLongPathNameW(wfile, buffer, buffer.size) == 0
      raise SystemCallError.new('GetLongPathName', FFI.errno)
    end

    buffer.tr(0.chr, '').strip
  end

  def self.short_path(file)
    buffer = 0.chr * 512
    wfile  = file.wincode

    if GetShortPathNameW(wfile, buffer, buffer.size) == 0
      raise SystemCallError.new('GetShortPathName', FFI.errno)
    end

    buffer.tr(0.chr, '').strip
  end

  def self.symlink(target, link)
    flags = File.directory?(target) ? 1 : 0

    wlink = link.wincode
    wtarget = target.wincode

    unless CreateSymbolicLinkW(wlink, wtarget, flags)
      raise SystemCallError.new('CreateSymbolicLink', FFI.errno)
    end

    0 # Comply with spec
  end

  def self.symlink?(file)
    bool  = false
    wfile = file.wincode

    attrib = GetFileAttributesW(wfile)

    if attrib == INVALID_FILE_ATTRIBUTES
      raise SystemCallError.new('GetFileAttributes', FFI.errno)
    end

    if attrib & FILE_ATTRIBUTE_REPARSE_POINT > 0
      begin
        find_data = WIN32_FIND_DATA.new
        handle = FindFirstFileW(wfile, find_data)

        if handle == INVALID_HANDLE_VALUE
          raise SystemCallError.new('FindFirstFile', FFI.errno)
        end

        if find_data[:dwReserved0] == IO_REPARSE_TAG_SYMLINK
          bool = true
        end
      ensure
        CloseHandle(handle)
      end
    end

    bool
  end

  def self.readlink(file)
    wfile = file.wincode
    path  = 0.chr * 512

    if File.directory?(file)
      flags = FILE_FLAG_BACKUP_SEMANTICS
    else
      flags = FILE_ATTRIBUTE_NORMAL
    end

    begin
      handle = CreateFileW(
        wfile,
        GENERIC_READ,
        FILE_SHARE_READ,
        nil,
        OPEN_EXISTING,
        flags,
        0
      )

      if handle == INVALID_HANDLE_VALUE
        raise SystemCallError.new('CreateFile', FFI.errno)
      end

      if GetFinalPathNameByHandleW(handle, path, path.size, 0) == 0
        raise SystemCallError.new('GetFinalPathNameByHandle', FFI.errno)
      end
    ensure
      CloseHandle(handle)
    end

    path.tr(0.chr, '').strip[4..-1]
  end
end

p File.basename("C:/foo/bar.txt", ".txt")
