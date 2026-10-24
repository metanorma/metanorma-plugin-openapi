# frozen_string_literal: true

require "asciidoctor"

module Metanorma
  module Plugin
    module Openapi
      # Splices rendered AsciiDoc in place of an
      #
      #   [openapi,path=/to/document.yaml]
      #   --
      #   --
      #
      # envelope before the document parses. A preprocessor, not a block
      # processor: Parser.parse_blocks (what block processors get to
      # parse through) cannot create sections, and the rendered sections
      # must be real sections (numbering, TOC).
      class Preprocessor < ::Asciidoctor::Extensions::Preprocessor
        OPENAPI_ATTRS = /\A\[openapi([,\]].*)?\]\s*\z/

        def process(document, reader)
          ::Asciidoctor::Reader.new(splice(document, reader.readlines),
                                    reader.cursor)
        end

        private

        def splice(document, lines)
          out = []
          until lines.empty?
            line = lines.shift
            if line.match?(OPENAPI_ATTRS)
              out.concat(consume_and_render(document, line, lines))
            else
              out << line
            end
          end
          out
        end

        def dashed?(line)
          line&.strip == "--"
        end

        def consume_and_render(document, attr_line, lines)
          envelope(lines) or
            raise ::ArgumentError,
                  "openapi block needs a -- -- envelope: #{attr_line}"
          source = attrs_path(attr_line)
          content = Renderer.new(load_document(document, source)).render
          content.split("\n")
        end

        # The closing -- is optional; a missing opening envelope raises
        # from consume_and_render
        def envelope(lines)
          lines.shift while lines.first && lines.first.strip.empty?
          return nil unless dashed?(lines.shift)

          body = []
          while (line = lines.shift) && !dashed?(line)
            body << line
          end
          body
        end

        def attrs_path(attr_line)
          path = attr_line[/path=("([^"]+)"|(\S+?))\]/, 2] ||
            attr_line[/path=("([^"]+)"|(\S+?))\]/, 3] ||
            attr_line[/path=([^\]\s]+)/, 1]
          raise ::ArgumentError, "openapi block needs a path" unless path

          path
        end

        def load_document(document, source)
          base = ::File.dirname(document.attributes["docfile"] || ".")
          ::Lutaml::Openapi.parse(::File.read(::File.expand_path(source, base)))
        end
      end
    end
  end
end
