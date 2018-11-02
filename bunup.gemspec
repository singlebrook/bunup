lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bunup/version'

Gem::Specification.new do |spec|
  spec.name = 'bunup'
  spec.version = Bunup::VERSION
  spec.authors = ['Jared Beck', 'Shane Cavanaugh', 'Leon Miller-Out']
  spec.email = %w[jared@jaredbeck.com shane@shanecav.net leon@singlebrook.com]
  spec.homepage = 'https://github.com/singlebrook/bunup'
  spec.summary = 'Bundle update and commit to git with one command'
  spec.license = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.1'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'byebug', '~> 9.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '>= 0.57.2'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
end
