require_relative 'file/constants'
require_relative 'file/structs'
require_relative 'file/functions'
require 'win32/file/stat'

class File
  include Windows::File::Constants
  include Windows::File::Structs
  extend Windows::File::Functions

  # The version of the win32-file library
  WIN32_FILE_VERSION = '0.7.1'

  class << self
    alias_method :join_orig, :join
    alias_method :realpath_orig, :realpath
    alias_method :realdirpath_orig, :realdirpath

    remove_method :basename, :blockdev?, :chardev?, :dirname, :directory?
    remove_method :executable?, :executable_real?, :file?, :ftype, :grpowned?
    remove_method :join, :lstat, :owned?, :pipe?, :socket?
    remove_method :readable?, :readable_real?, :readlink, :realpath
    remove_method :realdirpath
    remove_method :split, :stat
    remove_method :symlink
    remove_method :symlink?
    remove_method :world_readable?, :world_writable?
    remove_method :writable?, :writable_real?
  end

  ## Path methods

  # Returns the last component of the filename given in +filename+.  If
  # +suffix+ is given and present at the end of +filename+, it is removed.
  # Any extension can be removed by giving an extension of ".*".
  #
  # This was reimplemented because the current version does not handle UNC
  # paths properly, i.e. it should not return anything less than the root.
  # In most other respects it is identical to the current implementation,
  # except that it does not strip the drive letter on a root path.
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
    file = string_check(file)
    suffix = string_check(suffix) if suffix

    return file if file.empty? # Return an empty path as-is.

    encoding = file.encoding
    wfile = file.wincode

    # Return a root path as-is.
    if PathIsRootW(wfile)
      return file.tr(File::SEPARATOR, File::ALT_SEPARATOR)
    end

    ptr = FFI::MemoryPointer.from_string(wfile)

    PathStripPathW(ptr) # Gives us the basename

    if suffix
      if suffix == '.*'
        PathRemoveExtensionW(ptr)
      else
        ext = PathFindExtensionW(ptr).read_string(suffix.length * 2).wstrip

        if ext == suffix
          PathRemoveExtensionW(ptr)
        end
      end
    end

    wfile = ptr.read_bytes(wfile.size * 2).split("\000\000").first.tr(0.chr, '')
    file = wfile.encode(encoding)[/^[^\0]*/]
    file.sub!(/\\+\z/, '') # Trim trailing slashes

    file
  end

  # Returns all components of the filename given in +filename+ except the
  # last one.
  #
  # This was reimplemented because the current version does not handle UNC
  # paths properly, i.e. it should not return anything less than the root.
  # In all other respects it is identical to the current implementation.
  #
  # Also, this method will convert all forward slashes to backslashes.
  #
  # Examples:
  #
  #    File.dirname("C:\\foo\\bar\\baz.txt") -> "C:\\foo\\bar"
  #    File.dirname("\\\\foo\\bar")          -> "\\\\foo\\bar"
  #
  def self.dirname(file)
    file = string_check(file)

    # Short circuit for empty paths
    return '.' if file.empty?

    # Store original encoding, restore it later
    encoding = file.encoding

    # Convert to UTF-16LE
    wfile = file.wincode

    # Return a root path as-is.
    if PathIsRootW(wfile)
      return file.tr(File::SEPARATOR, File::ALT_SEPARATOR)
    end

    ptr = FFI::MemoryPointer.from_string(wfile)

    # Remove trailing slashes if present
    while result = PathRemoveBackslashW(ptr)
      break unless result.empty?
    end

    # Remove trailing file name if present
    unless PathRemoveFileSpecW(ptr)
      raise SystemCallError.new("PathRemoveFileSpec", FFI.errno)
    end

    wfile = ptr.read_bytes(wfile.size * 2).split("\000\000").first

    # Empty paths, short relative paths
    if wfile.nil? or wfile.empty?
      return '.'
    end

    # Return to original encoding
    file = wfile.tr(0.chr, '').encode(encoding)

    file
  end

  # Join path string components together into a single string.
  #
  # This method was reimplemented so that it automatically converts
  # forward slashes to backslashes. It is otherwise identical to
  # the core File.join method.
  #
  # Examples:
  #
  #   File.join("C:", "foo", "bar") # => C:\foo\bar
  #   File.join("foo", "bar")       # => foo\bar
  #
  def self.join(*args)
    return join_orig(*args).tr("/", "\\")
  end

  # Splits the given string into a directory and a file component and
  # returns them in a two element array. This was reimplemented because
  # the current version does not handle UNC paths properly.
  #
  def self.split(file)
    file = string_check(file)
    array = []

    if file.empty? || PathIsRootW(file.wincode)
      array.push(file, '')
    else
      array.push(File.dirname(file), File.basename(file))
    end

    array
  end

  # Returns +path+ in long format. For example, if 'SOMEFI~1.TXT'
  # was the argument provided, and the short representation for
  # 'somefile.txt', then this method would return 'somefile.txt'.
  #
  # Note that certain file system optimizations may prevent this method
  # from working as expected. In that case, you will get back the file
  # name in 8.3 format.
  #
  def self.long_path(file)
    buffer = FFI::Buffer.new(:wint_t, 1024, true)
    wfile  = string_check(file).wincode

    length = GetLongPathNameW(wfile, buffer, buffer.size)

    if length == 0 || length > buffer.size / 2
      raise SystemCallError.new('GetLongPathName', FFI.errno)
    end

    buffer.read_bytes(length * 2).wstrip
  end

  # Returns +path+ in 8.3 format. For example, 'c:\documentation.doc'
  # would be returned as 'c:\docume~1.doc'.
  #
  def self.short_path(file)
    buffer = FFI::Buffer.new(:wint_t, 1024, true)
    wfile  = string_check(file).wincode

    length = GetShortPathNameW(wfile, buffer, buffer.size)

    if length == 0 || length > buffer.size / 2
      raise SystemCallError.new('GetShortPathName', FFI.errno)
    end

    buffer.read_bytes(length * 2).wstrip
  end

  # Creates a symbolic link called +new_name+ for the file or directory
  # +old_name+.
  #
  # This method requires Windows Vista or later to work. Otherwise, it
  # returns nil as per MRI.
  #
  def self.symlink(target, link)
    target = string_check(target)
    link = string_check(link)

    flags = File.directory?(target) ? 1 : 0

    wlink = link.wincode
    wtarget = target.wincode

    unless CreateSymbolicLinkW(wlink, wtarget, flags)
      raise SystemCallError.new('CreateSymbolicLink', FFI.errno)
    end

    0 # Comply with spec
  end

  # Returns whether or not +file+ is a symlink.
  #
  def self.symlink?(file)
    return false unless File.exists?(file)

    bool  = false
    wfile = string_check(file).wincode

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

  # Converts path to a full file path, with all symlinks resolved and relative
  # paths made absolute. If a second parameter if present, it is used as the
  # base for resolving leading relative path segments.
  #
  # Unlike File.realpath, an error is not raised if the final path created
  # using a relative path argument doesn't exist.
  #--
  # On Windows we only modify the realpath method if the file is a symlink.
  #
  def self.realdirpath(file, relative_to = nil)
    file = string_check(file)

    if symlink?(file)
      if relative_to
        File.join(relative_to, File.basename(readlink(file)))
      else
        readlink(file)
      end
    else
      realdirpath_orig(file, relative_to)
    end
  end

  # Converts path to a full file path, with all symlinks resolved and relative
  # paths made absolute. If a second parameter if present, it is used as the
  # base for resolving leading relative path segments.
  #--
  # On Windows we only modify the realpath method if the file is a symlink.
  #
  def self.realpath(file, relative_to = nil)
    file = string_check(file)
    relative_to = string_check(relative_to) if relative_to

    if symlink?(file)
      if relative_to
        result = File.join(relative_to, File.basename(readlink(file)))
        if File.exists?(result)
          result
        else
          raise SystemCallError.new(result, 2) # Errno::ENOENT
        end
      else
        readlink(file)
      end
    else
      realpath_orig(file, relative_to)
    end
  end

  # Returns the path of the of the symbolic link referred to by +file+.
  #
  def self.readlink(file)
    file = string_check(file)

    if exists?(file) && !symlink?(file)
      raise SystemCallError.new(22) # EINVAL, match the spec
    end

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

      if GetFinalPathNameByHandleW(handle, path, path.size/2, 0) == 0
        raise SystemCallError.new('GetFinalPathNameByHandle', FFI.errno)
      end
    ensure
      CloseHandle(handle)
    end

    path.wstrip[4..-1] # Remove leading backslashes + question mark
  end

  ## STAT METHODS

  # Returns the filesystem's block size.
  #
  def self.blksize(file)
    File::Stat.new(file).blksize
  end

  # Returns whether or not the file is a block device. For MS Windows a
  # block device is a removable drive, cdrom or ramdisk.
  #
  def self.blockdev?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).blockdev?
  end

  # Returns whether or not the file is a character device.
  #
  def self.chardev?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).chardev?
  end

  # Returns whether or not the file is a directory.
  #
  def self.directory?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).directory?
  end

  # Returns whether or not the file is executable.
  #
  def self.executable?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).executable?
  end

  # Returns whether or not the file is a regular file.
  #
  def self.file?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).file?
  end

  # Identifies the type of file. The return string is one of 'file',
  # 'directory', 'characterSpecial', 'socket' or 'unknown'.
  #
  def self.ftype(file)
    File::Stat.new(file).ftype
  end

  # Returns true if the process owner's ID is the same as one of the file's groups.
  #
  def self.grpowned?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).grpowned?
  end

  # Returns whether or not the current process owner is the owner of the file.
  #
  def self.owned?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).owned?
  end

  # Returns whether or not the file is a pipe.
  #
  def self.pipe?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).pipe?
  end

  # Returns whether or not the file is readable by the process owner.
  #
  def self.readable?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).readable?
  end

  # Synonym for File.readable?
  #
  def self.readable_real?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).readable_real?
  end

  # Returns a File::Stat object as defined in the win32-file-stat library.
  #
  def self.stat(file)
    File::Stat.new(file)
  end

  # Returns whether or not the file is readable by others. Note that this
  # merely returns true or false, not permission bits (or nil).
  #
  def self.world_readable?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).world_readable?
  end

  # Returns whether or not the file is writable by others. Note that this
  # merely returns true or false, not permission bits (or nil).
  #
  def self.world_writable?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).world_writable?
  end

  # Returns whether or not the file is writable by the current process owner.
  #
  def self.writable?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).writable?
  end

  # Synonym for File.writable?
  #
  def self.writable_real?(file)
    return false unless File.exists?(file)
    File::Stat.new(file).writable_real?
  end

  # Singleton aliases
  class << self
    alias lstat stat
    alias executable_real? executable?
    alias socket? pipe?
  end

  ## Instance Methods

  # Same as MRI, except it returns a stat object using the win32-file-stat gem.
  #
  def stat
    File::Stat.new(self.path)
  end

  # Private singleton methods
  class << self
    private

    # Simulate Ruby's string checking
    def string_check(arg)
      return arg if arg.is_a?(String)
      return arg.send(:to_str) if arg.respond_to?(:to_str, true) # MRI allows private to_str
      return arg.to_path if arg.respond_to?(:to_path)
      raise TypeError
    end
  end
end
