lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "codeslave/version"

Gem::Specification.new do |spec|
  spec.name          = "codeslave"
  spec.version       = Codeslave::VERSION
  spec.authors       = ["Curt Howard"]
  spec.email         = ["curt@portugly.com"]

  spec.summary       = "A CLI for making changes to many Github repos"
  spec.description   = "A CLI for making changes to many Github repos"
  spec.homepage      = "https://github.com/meowsus/codeslave"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/meowsus/codeslave"

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "slop", "~> 4.7"
  spec.add_dependency "colorize", "~> 0.8"
  spec.add_dependency "octokit", "~> 4.14"
end
