# frozen_string_literal: true

require "lutaml/openapi"

module Metanorma
  module Plugin
    module Openapi
      # metanorma-plugin-lutaml pins coradoc ~> 1.1.8, which excludes the
      # 2.0 hub in every metanorma-cli bundle, so the monorepo (and its
      # markdown spoke) may be absent at runtime; without it,
      # CommonMark descriptions pass through with only the link bridge.
      begin
        require "coradoc"
        require "coradoc/markdown"
        require "coradoc/asciidoc"
        MONOREPO = true
      rescue LoadError
        MONOREPO = false
      end

      # Renders an OpenAPI document as normative AsciiDoc sections.
      # Descriptions are CommonMark (per the OpenAPI spec) and convert
      # to AsciiDoc through the coradoc tree — the metanorma-ogc#153
      # pipeline: OpenAPI(Markdown) → Coradoc → Metanorma.
      class Renderer
        def initialize(document)
          @document = document
        end

        def render
          [preface, schemas_section, paths_section].compact.join("\n\n")
        end

        private

        # The preface is a section: spliced content must stay at `==`
        # level (a level-0 line mid-document degrades to a paragraph)
        def preface
          info = @document.info || {}
          lines = ["== #{info['title'] || 'OpenAPI document'}", ""]
          lines << "API version: #{@document.openapi}" if @document.openapi
          if (desc = info["description"])
            lines << to_asciidoc(desc) << ""
          end
          lines.join("\n")
        end

        def schemas_section
          schemas = @document.schemas
          return nil if schemas.empty?

          lines = ["== Schemas", ""]
          schemas.each do |name, schema|
            lines.concat(schema_lines(schema, name))
          end
          lines.join("\n")
        end

        def schema_lines(schema, name)
          lines = ["=== #{name}", ""]
          if (desc = schema.description) && !desc.empty?
            lines << to_asciidoc(desc) << ""
          end
          lines << "Type: `#{schema.type}`" << "" if schema.type
          lines
        end

        def paths_section
          paths = @document.paths
          return nil if paths.nil? || paths.empty?

          lines = ["== Paths", ""]
          paths.sort.each do |path, item|
            lines.concat(operation_lines(path, item))
          end
          lines.join("\n")
        end

        def operation_lines(path, item)
          entries = (item["operations"] || item).select do |_, op|
            op.is_a?(Hash)
          end
          entries.flat_map do |method, operation|
            lines = ["=== #{method.to_s.upcase} #{path}", ""]
            if (desc = operation["description"])
              lines << to_asciidoc(desc) << ""
            end
            lines
          end
        end

        def to_asciidoc(markdown)
          adoc = convert_markdown(markdown)
          # coradoc-markdown does not convert CommonMark links yet (they
          # pass through raw); bridge the dominant inline form to
          # AsciiDoc's https://url[text]. Remove once coradoc grows
          # native link support (metanorma/coradoc issue to follow).
          adoc.gsub(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/) do
            "#{Regexp.last_match(2)}[#{Regexp.last_match(1)}]"
          end
        end

        def convert_markdown(markdown)
          return markdown unless MONOREPO

          Coradoc.convert(markdown, from: :markdown, to: :asciidoc)
        end
      end
    end
  end
end
