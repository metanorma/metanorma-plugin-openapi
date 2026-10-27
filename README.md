# metanorma-plugin-openapi

Renders [OpenAPI](https://spec.openapis.org) documents as normative
Metanorma sections — the `[openapi,path=...]` preprocessor and renderer
over [lutaml-openapi](https://github.com/lutaml/lutaml-openapi).

```adoc
[openapi,path=openapi.yaml]
--
--
```

The splice runs as an Asciidoctor preprocessor, so the rendered
schemas, operations and property tables become real numbered sections
of the document (TOC and cross-references included).

CommonMark descriptions are converted to AsciiDoc through the coradoc
monorepo when present; otherwise they pass through with the inline
link bridge applied.
