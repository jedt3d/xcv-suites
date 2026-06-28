# Xojo Keyboard Maestro Harness

This document captures the compile/debug/run loop currently used for `xcv-suites`.

It replaces the older analyze-script workflow for this repo.

## Purpose

Use a human-in-the-loop harness for Xojo compile, error capture, fixing, and run verification.

The loop is intentionally simple:

1. trigger compile/debug capture
2. read the error result from the clipboard
3. fix compile errors in source
4. repeat until the build is clean
5. ask before running the app
6. collect human feedback about runtime behavior

This is the active workflow for this repo.

Before scanning a large amount of Xojo source during this loop, prefer `.xojo_index/` if it exists. The compile harness and the indexing workflow should work together, not compete.

## Commands

### Step 1: compile and capture debug result

Run:

```sh
keyboardmaestro "Get Xojo Debug Message"
```

The output error should be read from the macOS clipboard immediately after the macro completes.

Expected clean result:

```text
No error or warning
```

Expected error result:

```text
WebRectangleTest.Shown, line 1
Syntax error
...
```

The current checked-in validation page is `WebRectangleTest.xojo_code`, but the harness rules are the same for any future test host page or window.

## Step 2: fix source

If the clipboard contains compile errors:

- inspect the referenced Xojo file and line
- make the smallest valid source fix
- restart from step 1

Do not run the app while compile errors remain.

## Capture failures we have seen

This harness is useful, but it is not perfect. In this repo we have already seen these failure modes:

- OCR failure caused by macOS Dark Mode making the Xojo issue area harder for the macro to read
- clipboard garbage such as random alphanumeric strings instead of a structured Xojo compiler message
- stale clipboard content when the result is not read immediately after the macro finishes
- macro execution succeeding while the captured text is still not trustworthy

Treat these as capture failures, not trusted compiler output.

## What to do when capture looks wrong

If the clipboard result is not one of these:

- `No error or warning`
- a structured Xojo error that clearly names a file/member and line

then:

1. assume the capture is bad
2. rerun `Get Xojo Debug Message`
3. read the clipboard again immediately
4. only act on the result if the second capture is structured and believable

If repeated retries still produce garbage, note the likely OCR issue rather than inventing a source fix from bad text.

## Step 3: ask before running

If the clipboard result is exactly:

```text
No error or warning
```

ask the user:

```text
Do you want me to run the app now with `keyboardmaestro "Run Xojo App"`?
```

Do not run automatically without that confirmation.

## Step 4: run the app

After user approval, run:

```sh
keyboardmaestro "Run Xojo App"
```

## Step 5: ask for runtime feedback

After the run macro completes, ask the user to choose one:

1. It's running as expected
2. No — let me type what's going on.

If the user reports a runtime problem, treat that as the next bug to fix and restart the loop from source edits and compile capture.

## Behavior rules

- Prefer clipboard truth over assumptions.
- Treat `No error or warning` as the only clean compile signal.
- Treat unstructured clipboard text as capture failure, not as a compiler diagnosis.
- Keep the user in the loop before runtime launch.
- Keep the feedback collection structured after each run.
- Ignore the older `xojo-run` analyze-script flow for this repo unless the workflow is intentionally changed again.

## Current known details

- `keyboardmaestro` may exist only as a shell alias in `~/.zshrc`.
- In Codex tool execution, the direct binary path is more reliable:

```sh
/Applications/Keyboard Maestro.app/Contents/MacOS/keyboardmaestro "Get Xojo Debug Message"
/Applications/Keyboard Maestro.app/Contents/MacOS/keyboardmaestro "Run Xojo App"
```

- Clipboard reads may require access to the live system clipboard rather than a sandboxed shell clipboard.
- When the clipboard contains OCR noise, a second immediate macro run is the first recovery step.
