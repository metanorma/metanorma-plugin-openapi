# frozen_string_literal: true

require_relative "lib/metanorma/plugin/openapi/version"

Gem::Specification.new do |spec|
  spec.name = "metanorma-plugin-openapi"
  spec.version = Metanorma::Plugin::Openapi::VERSION
  spec.authors = ["Ribose Inc."]
  spec.email = ["open.source@ribose.com"]

  spec.summary = "Metanorma plugin for OpenAPI"
  spec.description = "Metanorma plugin rendering model-driven normative " \
                     "sections from OpenAPI documents"
  spec.homepage = "https://github.com/metanorma/metanorma-plugin-openapi"
  spec.license = "BSD-2-Clause"

  gemspec_file = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__,
                                             err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec_file) ||
        f.start_with?(*%w[Gemfile .gitignore .rspec spec/ .github/
                          .rubocop.yml])
    end
  end
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0.0" # rubocop:disable Gemspec/RequiredRubyVersion

  spec.add_dependency "asciidoctor"
  spec.add_dependency "coradoc", "~> 1.1"
  spec.add_dependency "lutaml-model", "~> 0.8.122"

  spec.metadata["rubygems_mfa_required"] = "true"
end
