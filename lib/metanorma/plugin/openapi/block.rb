# frozen_string_literal: true

require "asciidoctor"

module Metanorma
  module Plugin
    module Openapi
      # [openapi,path=/path/to/document.yaml]
      # --
      # --
      #
      # Loads an OpenAPI document and renders it as normative AsciiDoc
      # sections. The path resolves against the source document.
      class Block < ::Asciidoctor::Extensions::BlockProcessor
        use_dsl
        named :openapi
        on_context :open

        def process(parent, _reader, attrs)
          source = attrs["path"] || parent.document.attr("openapi_document")
          unless source
            raise ::ArgumentError,
                  "openapi block needs a path attribute"
          end

          content = Renderer.new(load_document(parent, source)).render
          parent.blocks << ::Asciidoctor::Block.new(
            parent, :open, source: content.split("\n"), attrs: {}
          )
          nil
        end

        private

        def load_document(parent, source)
          base = ::File.dirname(parent.document.attributes["docfile"] || ".")
          # ::Lutaml — metanorma-plugin-lutaml defines Metanorma::Plugin::Lutaml,
          # which would capture a lexically scoped Lutaml::Openapi lookup
          ::Lutaml::Openapi.parse(::File.read(::File.expand_path(source, base)))
        end
      end
    end
  end
end
