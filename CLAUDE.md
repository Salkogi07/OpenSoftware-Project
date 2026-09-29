# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Flutter app for Korean vocabulary learning ("한국어 단어 학습 애플리케이션"), built as a team project
(동양미래대학교 오픈소프트웨어 팀프로젝트). The codebase is currently the stock `flutter create` counter-app
scaffold (`lib/main.dart`) — the actual vocabulary features have not been implemented yet.

## Commands

All commands run from the repo root (Windows/PowerShell).

```powershell
flutter pub get              # install dependencies (run after pulling or editing pubspec.yaml)
flutter analyze              # static analysis; run after every change
flutter test                 # run all tests
flutter test test/widget_test.dart   # run a single test file
flutter devices              # list available run targets
flutter run -d <device-id>   # run the app on a specific device/emulator
```

Analyzer config (`analysis_options.yaml`) excludes `build/`, `android/`, `ios/`, `web/`, `windows/`,
`macos/`, `linux/` and extends `package:flutter_lints/flutter.yaml`.

## Architecture and conventions

- Single Dart package rooted at `lib/`; entry point is `lib/main.dart`. Platform folders
  (`android/`, `ios/`, `windows/`, `linux/`, `macos/`, `web/`) are the standard generated Flutter
  runners — do not hand-edit generated files under `build/` or `.dart_tool/`.
- Windows desktop runner sets a fixed initial window size in `windows/runner/main.cpp` (currently
  `393 x 852`) to preview a phone-like portrait aspect ratio on desktop; Android emulator/device runs
  use the real device screen size instead.
- **Separation of concerns (required for new features):** vocabulary data models, learning progress,
  and spaced-repetition/wrong-answer review logic must be kept separate from screen/widget code —
  do not embed word data or learning-progress logic directly in UI widgets.
- State management and routing libraries are intentionally not yet chosen — pick the minimal
  dependency needed only once a concrete need is confirmed; don't add one speculatively.
- Must handle async loading state, empty state, and error state for any UI that loads data — these
  are treated as required, not optional, per team convention.

## Project-specific rules

- All user-facing strings must be Korean.
- Do not replicate Duolingo's branding, imagery, copy, or source code — this app must have its own
  distinct UX for word learning.
- Keep changes scoped to what was requested; don't touch unrelated files.
- Never commit secrets, personal information, or local environment files.
- Make small, incremental changes; run `flutter analyze` and relevant tests after each change and
  report the verification results.

---

# Behavioral Guidelines (from andrej-karpathy-skills)

Source: https://github.com/multica-ai/andrej-karpathy-skills

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
