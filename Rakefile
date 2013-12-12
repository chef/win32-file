require 'rake'
require 'rake/testtask'
require 'rake/clean'

CLEAN.include("**/*.txt", "**/*.gem", "**/*.rbc")

namespace 'gem' do
  desc 'Create the win32-file gem'
  task :create => [:clean] do
    spec = eval(IO.read('win32-file.gemspec'))
    if Gem::VERSION < "2.0"
      Gem::Builder.new(spec).build  
    else
      require 'rubygems/package'
      Gem::Package.build(spec)
    end  
  end

  desc 'Install the win32-file gem'
  task :install => [:create] do
    file = Dir['win32-file*.gem'].first
    sh "gem install #{file}"
  end
end

namespace 'test' do
  Rake::TestTask.new("all") do |t|
    t.verbose = true
    t.warning = true
  end

  Rake::TestTask.new("link") do |t|
    t.verbose = true
    t.warning = true
    t.test_files = FileList['test/test_win32_file_link.rb']
  end

  Rake::TestTask.new("path") do |t|
    t.verbose = true
    t.warning = true
    t.test_files = FileList['test/test_win32_file_path.rb']
  end

  Rake::TestTask.new("stat") do |t|
    t.verbose = true
    t.warning = true
    t.test_files = FileList['test/test_win32_file_stat.rb']
  end
end

task :test => ['test:all']
task :default => ['test:all']
