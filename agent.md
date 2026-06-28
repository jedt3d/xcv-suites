# Agent Notes

This repo is not a finished component library yet. It is a structured start for a cross-platform Xojo component suite built around custom canvas rendering.

Use this file as the fast orientation note before touching code.

## Mission

Build a set of canvas-based components that preserve the same overall look, feel, and interaction model across:

- `web/`
- `desktop/`
- `ios/`
- `android/`

The rule is consistency first, not native divergence first. Platform differences still matter, but they should be handled deliberately.

This repo is building components first, not a general-purpose theming framework.

## Current reality

- The active checked-in Xojo project is `xcv-suites.xojo_project`.
- It is currently a minimal **Web 2** shell with:
  - `App.xojo_code`
  - `Session.xojo_code`
  - `WebRectangleTest.xojo_code`
- `web/WebXCV/` is the web Xojo library that holds web component classes.
- `web/WebXCV/WebRectangleXCV.xojo_code` is the first completed component milestone.
- the current project version is aligned to `0.1.0`
- `desktop/`, `ios/`, and `android/` are still structural placeholders.
- `xoji` should be part of the normal agent workflow here so source navigation stays fast once this repo stops being tiny.

Do not read more maturity into the repo than the files justify. One real component exists now, but the suite as a whole is still small.

## Xojo inspector constraint

Treat Xojo's `Inspector Behavior` feature as a static exposure layer only.

For source-defined classes and controls in this repo, it can:

- show or hide properties
- reorder properties
- regroup properties
- set default values
- expose enum dropdown values

It does not dynamically enable or disable one property based on another property's current value in the IDE.

That means `WebRectangleXCV` must enforce dependency logic at runtime:

- `BorderEnabled = False` means border thickness and border color stay visible in the Inspector but are ignored for drawing
- `FillColor` is the only custom fill property on `WebRectangleXCV`; a transparent fill color means no interior fill is drawn
- `CornerAllEnabled = False` or a per-corner enabled flag set to `False` means the stored corner value and style may stay editable but the resolved corner is square

If the project later requires truly conditional Inspector UI, that is a separate IDE extension or plugin problem, not a plain `#tag ViewBehavior` problem.

## Development order

Start with **web**.

That means:

1. The first component abstractions should be designed against the web runtime.
2. The first visual language should be proven in the web target.
3. The first behavior contracts should be written from the web implementation.
4. Desktop, iOS, and Android should follow only after the web reference is coherent.

When in doubt, make the web version the source of truth for behavior and state naming.

Also treat `WebFlexLayoutManager` as a first-class dependency during web work, not as a later integration step.

## Architectural direction

Favor this split:

- **appearance surface**
  - font size, colors, fill color, border, spacing, radii
- **component model**
  - state, properties, events, layout inputs
- **renderer**
  - drawing logic for each platform
- **interaction layer**
  - hit testing, hover, pressed, focus, keyboard, gesture handling
- **layout contract**
  - base size, minimum useful size, resize expectations inside flex containers
- **demo/test host**
  - pages or windows that exercise every component state visibly

The key idea is that the component contract should survive a platform port even when the rendering code does not.

## Styling rule

Do not design this library like Bootstrap or a CSS theme system.

Allowed direction:

- explicit component-level appearance control
- shared property semantics across components
- good defaults with a small customization surface

Avoid:

- global skinning as the main product
- a large theme API before the components are functionally correct
- style systems that hide or complicate component behavior

Minimum appearance options currently expected:

- font size
- text color
- border
- fill color

## Layout manager dependency

Two existing layout managers are part of the design foundation:

- `../xojo-web-layout-manager`
- `../xojo-desktop-layout-manager`

Use their compiled Xojo components separately. Do not plan to fold them into this repo as temporary copies.

Every xcv component should be designed to cooperate with them:

- accept externally assigned bounds cleanly
- redraw correctly after resize
- keep a stable base size
- document a minimum useful size
- avoid assumptions that bypass the parent layout container

## Platform folder intent

### `web/`

Primary implementation target right now.

Use this folder for:

- web-specific component code
- web demos
- web-only utilities
- notes that exist only because of web runtime constraints

Inside `web/`, treat `WebXCV/` as the Xojo library boundary for reusable web component classes.

### `desktop/`

Reserved for the desktop port after the web behavior is stable.

### `ios/`

Reserved for the mobile touch-first port.

### `android/`

Reserved for the second mobile touch-first port.

### `docs/`

Use for durable decisions, not temporary scratch notes. Prefer documents that explain rules another agent can reuse.

Good examples:

- component inventory
- appearance rules
- event and state conventions
- rendering rules
- layout contract
- porting notes
- workflow harness notes

## Guardrails

### 1. Do not let the first implementation become accidental doctrine

The web target is first, but not because everything should stay web-shaped forever. Capture the right abstractions, not incidental Web 2 limitations.

### 2. Do not hide behavior in giant canvas classes

If every component becomes one large mixed class with rendering, state, input, and layout tangled together, later platform ports will be slow and error-prone.

### 3. Preserve a named state model

States should be explicit and consistent across platforms:

- normal
- hover
- pressed
- focused
- disabled
- selected
- active

If a platform cannot express one of them cleanly, document that as an exception instead of silently dropping it.

### 4. Prefer reference demos early

Before adding many components, build one demo host that exposes all states visually. It is much easier to preserve cross-platform consistency when the reference is concrete.

### 5. Write the rules down while the code is still small

Do not wait until three platforms exist before documenting appearance rules, geometry rules, or interaction behavior.

## Immediate next work

The most sensible near-term path is:

1. Keep the current root project as the temporary web host.
2. Integrate the first test work with `WebFlexLayoutManager`.
3. Define the shared appearance surface.
4. Define a small component taxonomy.
5. Build a base web canvas component model.
6. Implement a very small starter set of controls.
7. Add a demo page that shows states and layout behavior.
8. Only then begin the desktop port.

The rectangle milestone is complete enough to serve as the first rendering and property reference, but the broader demo surface is still a follow-up task.

## Active Xojo harness

For compile/debug/run work in this repo, use the Keyboard Maestro clipboard harness documented in [docs/xojo-km-harness.md](docs/xojo-km-harness.md).

That harness is currently the preferred loop:

1. run `Get Xojo Debug Message`
2. read clipboard
3. fix compile errors
4. repeat until `No error or warning`
5. ask before `Run Xojo App`
6. ask the user whether it is running as expected

Important real-world caveats from this repo:

- the macro can fail to OCR the Xojo issue area correctly under macOS Dark Mode
- clipboard content can occasionally be garbage OCR text rather than a real Xojo message
- clipboard content can occasionally be stale if it is not read immediately after the macro run
- a non-structured clipboard result should be treated as capture failure first, not as a trusted compiler result
- the practical response is to rerun `Get Xojo Debug Message` before changing code based on suspicious clipboard text

Do not default back to older analyze-script workflows for this repo unless the user changes the process.

## Xoji indexing

Use `xoji` indexing for this repo when available.

Preferred pattern:

1. keep `.xojo_index/` fresh
2. query indexes before reading full Xojo files
3. use direct file reads only after the index points to the right file and line

Important files:

- `.xojo_index/codetree.json`
- `.xojo_index/manifest.json`
- `.xojo_index/dependencies.json`
- `.xojo_index/meta.json`

This matters more as the component catalog grows.

## File strategy

For now:

- root `.xojo_project` stays as the runnable web shell
- new docs belong in `docs/`
- new web-specific source should trend toward `web/`

Start with [docs/foundation-plan.md](docs/foundation-plan.md) before making architecture decisions.

If the project layout changes later, update this file and `README.md` in the same edit so future agents do not work from stale structure.
