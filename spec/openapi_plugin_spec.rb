# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Plugin::Openapi do
  it "reports its version" do
    expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end

RSpec.describe Metanorma::Plugin::Openapi::Preprocessor do
  it "splices real sections past the plugin-lutaml namespace" do
    stub_const("Metanorma::Plugin::Lutaml", Module.new)
    docfile = File.expand_path("fixtures/ogcapi-features-1-oas31.yaml",
                               __dir__)
    registry = Asciidoctor::Extensions.create do
      preprocessor Metanorma::Plugin::Openapi::Preprocessor
    end

    doc = Asciidoctor.load(
      "[openapi,path=ogcapi-features-1-oas31.yaml]\n--\n--\n",
      extension_registry: registry,
      attributes: { "docfile" => docfile },
    )

    schemas = doc.find_by(context: :section) { |s| s.title == "Schemas" }
    expect(schemas).not_to be_empty
  end

  it "raises on a missing -- -- envelope" do
    docfile = File.expand_path("fixtures/ogcapi-features-1-oas31.yaml",
                               __dir__)
    registry = Asciidoctor::Extensions.create do
      preprocessor Metanorma::Plugin::Openapi::Preprocessor
    end

    expect do
      Asciidoctor.load("[openapi,path=ogcapi-features-1-oas31.yaml]\n",
                       extension_registry: registry,
                       attributes: { "docfile" => docfile })
    end.to raise_error(ArgumentError, /envelope/)
  end
end
