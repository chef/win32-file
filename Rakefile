require 'rake'
require 'rake/testtask'
require 'rbconfig'
include Config

desc 'Clean any text files that may have been left over from tests'
task :clean do 
  Dir['test/*'].each{ |file|
    rm file if File.extname(file) == '.txt'
  }
end

desc 'Install the win32-file library (non-gem)'
task :install do
  sitelibdir = CONFIG['sitelibdir']
  installdir = File.join(sitelibdir, 'win32')
  file = 'lib\win32\file.rb'

  Dir.mkdir(installdir) unless File.exists?(installdir)
  FileUtils.cp(file, installdir, :verbose => true)
end

desc 'Build the gem'
task :gem do
  spec = eval(IO.read('win32-file.gemspec'))
  Gem::Builder.new(spec).build
end

desc 'Install the win32-file library as a gem'
task :install_gem => [:clean, :gem] do
  file = Dir['win32-file*.gem'].first
  sh "gem install #{file}"
end

Rake::TestTask.new("test") do |t|
  t.verbose = true
  t.warning = true
end

Rake::TestTask.new("test_attributes") do |t|
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/test_win32_file_attributes.rb']
end

Rake::TestTask.new("test_constants") do |t|
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/test_win32_file_constants.rb']
end

Rake::TestTask.new("test_encryption") do |t|
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/test_win32_file_encryption.rb']
end

Rake::TestTask.new("test_path") do |t|
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/test_win32_file_path.rb']
end

Rake::TestTask.new("test_security") do |t|
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/test_win32_file_security.rb']
end

Rake::TestTask.new("test_stat") do |t|
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/test_win32_file_stat.rb']
end
