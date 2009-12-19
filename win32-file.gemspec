require 'rubygems'

spec = Gem::Specification.new do |gem|
  gem.name       = 'win32-file'
  gem.version    = '0.6.2'
  gem.authors    = ['Daniel J. Berger', 'Park Heesob']
  gem.license    = 'Artistic 2.0'
  gem.email      = 'djberg96@gmail.com'
  gem.homepage   = 'http://www.rubyforge.org/projects/win32utils'
  gem.platform   = Gem::Platform::RUBY
  gem.summary    = 'Extra or redefined methods for the File class on Windows.'
  gem.test_files = Dir['test/test*']
  gem.has_rdoc   = true
  gem.files      = Dir['**/*'].reject{ |f| f.include?('CVS') }

  gem.rubyforge_project = 'win32utils'
  gem.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

  gem.add_dependency('win32-api', '>= 1.2.1')
  gem.add_dependency('win32-file-stat', '>= 1.3.2')
  gem.add_dependency('windows-pr', '>= 0.9.7')

  gem.add_development_dependency('test-unit', '>= 2.0.3')

  gem.description = <<-EOF
    The win32-file library adds several methods to the core File class which
    are specific to MS Windows, such as the ability to set and retrieve file
    attributes. In addition, several core methods have been redefined in
    order to work properly on MS Windows, such as File.blksize. See the
    README file for more details.
  EOF
end
