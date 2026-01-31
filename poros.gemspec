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
  spec.email         = ["sean.r.earle@gmail.com"]
  spec.homepage      = "https://github.com/HellRok/Poros"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
