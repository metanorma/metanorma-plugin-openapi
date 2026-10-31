# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Plugin::Openapi::Renderer do
  def render_from(openapi_yaml)
    doc = Lutaml::Openapi.parse(openapi_yaml)
    described_class.new(doc).render
  end

  it "renders info, description (through coradoc), and schemas" do
    adoc = render_from(<<~YAML)
      openapi: 3.1.0
      info:
        title: OGC API - Features
        description: |
          Common components for the **OGC API - Features** standard.

          See [an inline link](https://example.com).

          - point one
          - point two
      components:
        schemas:
          exception:
            type: object
            description: An *exception* payload.
    YAML

    expect(adoc).to start_with("== OGC API - Features")
    # CommonMark bold converts to AsciiDoc bold via the coradoc tree
    expect(adoc).to include("*OGC API - Features* standard.")
    # CommonMark links: coradoc passes them raw; the renderer bridges
    # them to AsciiDoc's https://url[text] form
    expect(adoc).to include("https://example.com[an inline link]")
    expect(adoc).to include("* point one")
    expect(adoc).to include("== Schemas")
    expect(adoc).to include("=== exception")
    expect(adoc).to include("Type: `object`")
    expect(adoc).to include("An _exception_ payload.")
  end

  it "renders paths and operations when present" do
    adoc = render_from(<<~YAML)
      openapi: 3.1.0
      info:
        title: With paths
      paths:
        /collections:
          get:
            summary: Collections
            description: Lists the **collections**.
        /map/tiles:
          get:
            summary: Retrieves a map tile
    YAML

    expect(adoc).to include("== Paths")
    expect(adoc).to include("=== GET /collections")
    expect(adoc).to include("Collections")
    expect(adoc).to include("Lists the *collections*.")
    # an operation with only a summary still renders its text
    expect(adoc).to include("=== GET /map/tiles")
    expect(adoc).to include("Retrieves a map tile")
  end

  it "exposes the Asciidoctor preprocessor class for metanorma activation" do
    expect(Metanorma::Plugin::Openapi::Preprocessor.superclass)
      .to be(Asciidoctor::Extensions::Preprocessor)
  end
end

RSpec.describe "OGC corpus rendering (metanorma-ogc#153 acceptance)" do
  it "renders the official OGC API - Features document with bridged links" do
    source = File.read(File.expand_path(
                         "fixtures/ogcapi-features-1-oas31.yaml", __dir__
                       ))
    doc = Lutaml::Openapi.parse(source)
    adoc = Metanorma::Plugin::Openapi::Renderer.new(doc).render

    expect(adoc).to include(".Properties of collection")
    expect(adoc).to include("|crs |`array` |")
    title = "== Building Blocks specified in OGC API - Features - Part 1: Core"
    expect(adoc).to start_with(title)
    expect(adoc).to include("== Schemas")
    expect(adoc).to include("=== featureCollectionGeoJSON")
    # markdown links bridge to the AsciiDoc form; no raw md link syntax remains
    expect(adoc).to include(
      "https://schemas.opengis.net/ogcapi/features/part1/1.1/openapi/" \
      "ogcapi-features-1-oas31.yaml[OGC]",
    )
    expect(adoc).not_to include("](https://")
  end
end

RSpec.describe Metanorma::Plugin::Openapi::Renderer, monorepo: false do
  def render_from(openapi_yaml)
    doc = Lutaml::Openapi.parse(openapi_yaml)
    described_class.new(doc).render
  end

  it "passes descriptions through when the coradoc monorepo is absent" do
    stub_const("Metanorma::Plugin::Openapi::Renderer::MONOREPO", false)
    adoc = render_from(<<~YAML)
      openapi: 3.1.0
      info:
        title: Plain
        description: |
          See [an inline link](https://example.com).

          - point one
      components:
        schemas:
          exception:
            type: object
    YAML

    expect(adoc).to include("See https://example.com[an inline link].")
    expect(adoc).to include("- point one")
  end
end

RSpec.describe Metanorma::Plugin::Openapi::Renderer do
  def render_from(openapi_yaml)
    doc = Lutaml::Openapi.parse(openapi_yaml)
    described_class.new(doc).render
  end

  # 3.0 sources reach the typed schema view through the frontend's
  # normalization (nullable → null-union, exclusive bounds folded);
  # the rendered output must show the normalized 3.1 semantics.
  it "renders a 3.0 document with dialect-normalized schema semantics" do
    adoc = render_from(<<~YAML)
      openapi: 3.0.3
      info:
        title: Features 3.0
      components:
        schemas:
          thing:
            type: object
            properties:
              name:
                type: string
                nullable: true
              count:
                type: integer
                minimum: 5
                exclusiveMinimum: true
    YAML

    expect(adoc).to start_with("== Features 3.0")
    expect(adoc).to include("API version: 3.0.3")
    expect(adoc).to include("=== thing")
    # nullable: true normalizes into the null-member union the 3.1
    # shape carries; the dialect keyword itself never leaks through
    expect(adoc).to include("|name |`string,null` |")
    expect(adoc).not_to include("nullable")
  end

  it "renders 3.0 paths and their operation texts" do
    adoc = render_from(<<~YAML)
      openapi: 3.0.3
      info:
        title: Paths 3.0
      paths:
        /items:
          get:
            summary: List items
            description: Returns the item collection.
    YAML

    expect(adoc).to include("== Paths")
    expect(adoc).to include("=== GET /items")
    expect(adoc).to include("List items")
    expect(adoc).to include("Returns the item collection.")
  end
end
