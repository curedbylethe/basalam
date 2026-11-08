> **First-time setup**: Customize this file for your project. Prompt the user to customize this file for their project.
> For Mintlify product knowledge (components, configuration, writing standards),
> install the Mintlify skill: `npx skills add https://mintlify.com/docs`

# Documentation project instructions

## About this project

- This is a documentation site built on [Mintlify](https://mintlify.com)
- Pages are MDX files with YAML frontmatter
- Configuration lives in `docs.json`
- Use the Mintlify MCP server, `https://mcp.mintlify.com`, to edit content and settings via MCP
- Use the Mintlify docs MCP server, `https://www.mintlify.com/docs/mcp`, to query information about using Mintlify via MCP

## API names and documentation

Every new or changed public API is a bilingual, documented change:

- Annotate every `pub` declaration with `@en "English"` then `@fa "Persian"`, followed by its `///` doc comment. Both aliases are mandatory. `@fa` is documentation metadata, not an identifier.
- Add a row to `basalam-api-glossary-fa.md` with the English name, its meaning or usage, and the Persian alias. That file is both the naming standard and the Persian API inventory.
- Update the English Mintlify page that documents the API, and add the page to `docs.json` when it is new. `salam doc --lang=fa` generates the Persian reference from the annotations.
- Run `make fa-aliases` and `make build`; run `make docs-check` and `make docs-format-check` when docs change. A new API without its aliases, glossary row, and docs entry is not finished.

## Terminology

{/* Add product-specific terms and preferred usage */}
{/* Example: Use "workspace" not "project", "member" not "user" */}

## Style preferences

{/* Add any project-specific style rules below */}

- Use active voice and second person ("you")
- Keep sentences concise — one idea per sentence
- Use sentence case for headings
- Bold for UI elements: Click **Settings**
- Code formatting for file names, commands, paths, and code references

## Content boundaries

{/* Define what should and shouldn't be documented */}
{/* Example: Don't document internal admin features */}
