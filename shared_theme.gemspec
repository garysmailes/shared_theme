# frozen_string_literal: true

require_relative "lib/shared_theme/version"

Gem::Specification.new do |spec|
  spec.name = "shared_theme"
  spec.version = SharedTheme::VERSION
  spec.authors = ["Gary Smailes"]
  spec.email = ["garysmailes@gmail.com"]

  spec.summary = "Shared vanilla CSS theme for Rails websites."
  spec.description = "Reusable reset, typography and theme settings, with local site overrides."
  spec.homepage = "https://github.com/garysmailes/shared_theme"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "#{spec.homepage}#readme"
  # This gem is distributed through Git, not a gem registry.
  spec.metadata["allowed_push_host"] = "https://github.com/garysmailes/shared_theme"

  spec.required_ruby_version = ">= 3.2.0"

  # Include assets even before they have been staged in Git.
  spec.files = Dir.chdir(__dir__) do
    Dir["app/assets/stylesheets/**/*.css", "lib/**/*.rb", "lib/generators/**/templates/**/*.css", "README.md"]
  end
  spec.require_paths = ["lib"]

  # Initially supported and checked against the demo's Rails 8.1 setup.
  spec.add_dependency "railties", "~> 8.1"
end
