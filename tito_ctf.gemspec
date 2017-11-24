# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tito_ctf/version"

Gem::Specification.new do |spec|
  spec.name          = "tito_ctf"
  spec.version       = TitoCtf::VERSION
  spec.authors       = ["Kent 'picat' Gruber"]
  spec.email         = ["kgruber1@emich.edu"]

  spec.summary       = %q{Slack Chat based CTF platform that is in development.}
  #spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"
  
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executable    = "tito"
  spec.require_paths = ["lib"]

  spec.add_dependency "slack-ruby-bot", "~> 0.10.0"
  spec.add_dependency "eventmachine", "~> 1.2.5"
  spec.add_dependency "faye-websocket", "~> 0.10.7"
  
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
