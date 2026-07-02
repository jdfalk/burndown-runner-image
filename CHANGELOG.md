<!-- file: CHANGELOG.md -->
<!-- version: 0.3.0 -->
<!-- guid: c4a4ce10-0000-4000-8000-000000000001 -->
<!-- last-edited: 2026-07-02 -->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- **`release.yml` — image-pin auto-updater now covers `reusable-triage-poll.yml` too.**
  The retag job only ever patched `reusable-burndown.yml` in `falkcorp/github-common`
  after each image build, never `reusable-triage-poll.yml` — so that file's pin
  was guaranteed to drift stale on every future release (which it did: every
  30-min triage-poll cron run failed at `docker pull` on a tag that no longer
  existed in the registry). `PINNED_FILES` now lists both files; confirmed
  working live — the very next release auto-updated both
  (`falkcorp/github-common@9446ed3`).

## [ob-18f0014] — 2026-06-10

### Fixed

- Rebuilt image from `overnight-burndown@18f0014` (PR #23). The previous image
  `ob-77dfdfa` baked a binary that passed `ContextManagement={type:"compaction"}`
  to OpenAI's Responses API, which rejects it with
  `400 "Unsupported context_management type: ''"`. Every `dispatch-one` call failed
  at iter 1 before any agent work. Fixed upstream in
  `falkcorp/overnight-burndown#62`: `ContextManagement` removed; proactive
  compaction now uses the explicit `/responses/compact` endpoint after 80K tokens.
- `reusable-burndown.yml` in `falkcorp/github-common` auto-updated to use
  `ob-18f0014` by the retag CI job (PR #306).

## [ob-77dfdfa] — 2026-06-07

### Added

- Initial scaffold of burndown-runner-image.
