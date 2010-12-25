# prepend lib directory
$:.unshift File.expand_path('lib', File.dirname(__FILE__))

begin
  require 'isolate/now'
rescue LoadError
  abort "This project requires Isolate to work, please 'gem install isolate' first."
end

require 'isolate/lockdown'
require 'rubygems/package_task'

GEM_SPEC = Gem::Specification.new do |s|
  # basic information
  s.name    = 'isolate-lockdown'
  s.version = '0.2.0'
  s.platform = Gem::Platform::RUBY

  # description and details
  s.summary     = 'Lockdown your isolated gems, give them speed.'
  s.description = "Extension for Isolate that extracts dependent gem contents\ninto a single, monolithic directory to reduce Ruby load time."

  # requirements
  s.required_ruby_version = ">= 1.8.6"
  s.required_rubygems_version = ">= 1.3.7"

  # dependencies
  s.add_dependency  'isolate'

  # components, files and paths
  s.files = FileList["lib/**/*.rb", "Rakefile", "Isolate", "*.{textile,txt}"]

  s.require_path = 'lib'

  # documentation
  s.has_rdoc = false

  # project information
  s.homepage          = 'http://github.com/luislavena/isolate-lockdown'
  s.licenses          = ['MIT']

  # author and contributors
  s.author      = 'Luis Lavena'
  s.email       = 'luislavena@gmail.com'
end

Gem::PackageTask.new(GEM_SPEC) do |pkg|
  pkg.need_tar = false
  pkg.need_zip = false
end
