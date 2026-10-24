# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
# the hub-and-spoke coradoc monorepo (the 2.0-generation markdown
# spoke is not yet on rubygems; the gemspec pins the released stack at
# plugin-release time)
coradoc_repo = "https://github.com/metanorma/coradoc.git"
gem "coradoc", git: coradoc_repo, glob: "coradoc/*.gemspec"
gem "coradoc-adoc", git: coradoc_repo, glob: "coradoc-adoc/*.gemspec"
gem "coradoc-markdown", git: coradoc_repo, glob: "coradoc-markdown/*.gemspec"

# the renderer consumes the model gem from its main branch until it
# releases
gem "lutaml-openapi", github: "lutaml/lutaml-openapi", branch: "main"

gem "rubocop", "~> 1.21"
gem "rubocop-performance", "~> 1.0"

# unitsml 0.4.x ships a unitsdb artifact that crashes Bundler 4's
# setup_manpath glob on Windows (Errno::EINVAL on **/*.yaml); 0.5+
# vendored unitsdb as its own gem
gem "unitsml", ">= 0.5.1"
