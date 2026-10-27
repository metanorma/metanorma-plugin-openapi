# Changelog

All notable changes to this project are documented in this file.

## [0.1.1] - 2026-10-26

### Fixed

- The coradoc monorepo is an optional enhancement: soft-require it and pass CommonMark descriptions through with only the link bridge when absent (metanorma-plugin-lutaml pins coradoc ~> 1.1.8, excluding the 2.0 hub from metanorma-cli bundles).
- Resolve `Lutaml::Openapi` against the top level — metanorma-plugin-lutaml's namespace lexically shadowed the lookup, crashing every metanorma-cli bundle.

### Changed

- Splice rendered sections through an Asciidoctor **preprocessor** instead of a block: the preprocessor is the only mechanism that yields real sections (numbering, TOC); the renderer's preface drops to `==` level.
- Render operation **summaries** as well as descriptions (most corpora carry summary alone).

## [0.1.0] - 2026-10-24

### Added

- First release: the `[openapi,path=...]` block, the AsyncAPI-style preprocessor splice and the section renderer over lutaml-openapi.
