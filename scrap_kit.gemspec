lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scrap_kit/version"

Gem::Specification.new do |spec|
  spec.name          = "scrap_kit"
  spec.version       = ScrapKit::VERSION
  spec.authors       = ["Gustavo Leon"]
  spec.email         = ["hpneo@hotmail.com"]

  spec.summary       = %q{Scrap web sites using recipes.}
  spec.description   = %q{Run JSON-based recipes to scrap web sites.}
  spec.homepage      = "https://hpneo.dev/scrap_kit/"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hpneo/scrap_kit"
  spec.metadata["changelog_uri"] = "https://github.com/hpneo/scrap_kit/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "activesupport", "6.0.2.1"
  spec.add_development_dependency "watir", "~> 6.16.5"
end
