# frozen_string_literal: true

require "asciidoctor/extensions"

module Metanorma
  module Plugin
    module Openapi
      autoload :VERSION, "metanorma/plugin/openapi/version"
      autoload :Renderer, "metanorma/plugin/openapi/renderer"
      autoload :Preprocessor, "metanorma/plugin/openapi/preprocessor"
    end
  end
end
