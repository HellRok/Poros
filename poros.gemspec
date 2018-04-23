lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "poros/version"

Gem::Specification.new do |spec|
  spec.name          = 'poros'
  spec.version       = Poros::VERSION
  spec.date          = '2018-04-22'
  spec.summary       = 'Persist and query your objects'
  spec.description   = 'Persist your objects and query them in an active record like way'
  spec.authors       = ["Sean Ross Earle"]
  spec.email         = ["sean.earle@oeQuacki.com"]
  spec.homepage      = "https://github.com/HellRok/YAMLCache"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
