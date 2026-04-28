<!-- file: .github/instructions/general-coding.instructions.md -->
<!-- version: 1.0.0 -->
<!-- guid: 1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d -->

<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
---
applyTo: "**"
description: |
    General coding, documentation, and workflow rules for all Copilot/AI agents and VS Code Copilot customization. These rules apply to all files and languages unless overridden by a more specific instructions file.
---
<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->

# General Coding Instructions

- Follow conventional commit message standards and pull request guidelines.
- Document code, classes, functions, and tests extensively.
- Use Arrange-Act-Assert pattern for tests.
- Do not duplicate rules; reference this file from specific instructions.

## Required File Header (File Identification)

All source, script, and documentation files MUST begin with a standard header
containing file path, version, and GUID as comments.

## Version Update Requirements

- Patch: bug fixes/typos
- Minor: new features/significant content
- Major: breaking changes/overhauls
