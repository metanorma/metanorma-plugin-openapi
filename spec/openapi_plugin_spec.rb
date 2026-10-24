# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Plugin::Openapi do
  it "reports its version" do
    expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end

RSpec.describe Metanorma::Plugin::Openapi::Block do
  it "resolves ::Lutaml past the metanorma-plugin-lutaml namespace" do
    stub_const("Metanorma::Plugin::Lutaml", Module.new)
    docfile = File.expand_path("fixtures/ogcapi-features-1-oas31.yaml",
                               __dir__)
    registry = Asciidoctor::Extensions.create do
      block Metanorma::Plugin::Openapi::Block
    end

    doc = Asciidoctor.load(
      "[openapi,path=ogcapi-features-1-oas31.yaml]\n--\n--\n",
      extension_registry: registry,
      attributes: { "docfile" => docfile },
    )

    expect(doc.blocks[0].lines).to include("== Schemas")
  end
end
