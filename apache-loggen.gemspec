# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apache-loggen/version'

Gem::Specification.new do |gem|
  gem.name          = "apache-loggen"
  gem.version       = LogGenerator::VERSION
  gem.authors       = ["tamtam180"]
  gem.email         = ["kirscheless@gmail.com"]
  gem.description   = %q{dummy apache-log generator}
  gem.summary       = %q{dummy apache-log generator}
  gem.homepage      = "https://github.com/tamtam180/apache_log_gen"
  gem.license       = 'Apache 2.0'

  gem.files         = `git ls-files`.split($/) - %w[.gitignore]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "json"
end
