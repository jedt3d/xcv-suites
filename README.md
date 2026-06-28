# xcv-suites

`xcv-suites` is a workspace for building a family of Xojo canvas-based UI components that keep as much visual and behavioral consistency as possible across four targets:

- Web
- Desktop
- iOS
- Android

The point is not to pretend every platform is identical. The point is to define one component language, one interaction model, and one visual system that can survive platform differences without turning into four unrelated codebases.

We are starting with **Web first**.

That choice is deliberate. Web gives the fastest feedback loop for layout, rendering, hover states, focus handling, and component behavior. It is the best place to shape the first reference implementation before the same ideas are ported to the other platforms.

## Current state

Right now this repo is still at the setup stage.

- `xcv-suites.xojo_project` is a minimal Xojo Web 2 shell.
- `WebPage1.xojo_code` is still a very small starter page used to prove the compile/debug/run loop.
- `web/`, `desktop/`, `ios/`, and `android/` exist as platform folders.
- `docs/` is reserved for design notes, specs, and implementation decisions.
- `xoji` indexing should be used here as the codebase grows so agents can navigate Xojo source with less scanning and lower token cost.

So the structure is ahead of the component code. That is fine. I would rather make the platform boundaries clear now than retrofit them after the first few controls land.

## Project goal

The long-term goal is a reusable suite of custom-drawn components built on canvas-style rendering, not a thin wrapper around whatever the native control set happens to provide on each platform.

That gives us three important advantages:

1. We control the visuals.
2. We control the component behavior.
3. We can keep the same mental model when a component moves from Web to Desktop to mobile.

It also creates real engineering pressure. Custom rendering means we own layout, hit testing, focus, selection, scrolling behavior, disabled states, keyboard behavior, accessibility strategy, and appearance rules. That is why this repo needs a clear platform strategy instead of ad hoc experiments.

## Styling model

This repo is **not** trying to build a Bootstrap-style theming layer.

We do want style customization, but it should stay close to each component. At minimum, components should be able to expose controlled options such as:

- font size
- text color
- border
- background
- background gradient

That is enough to let a control adapt without turning the whole suite into a theme engine. Functionality still comes first.

## Platform layout

The intended structure is:

```text
xcv-suites/
├── web/        # First implementation target and reference behavior
├── desktop/    # Desktop port once the web model is stable
├── ios/        # Mobile touch-first port
├── android/    # Mobile touch-first port
├── docs/       # Specs, design rules, notes, decisions
└── xcv-suites.xojo_project
```

For now, the root Xojo project is still the active web host. As the web suite takes shape, the `web/` folder should become the main home for web-specific component code, examples, and supporting documentation.

## Working principles

### 1. Web is the reference implementation

The first serious component work happens in the web target. That version should establish:

- appearance rules
- sizing rules
- component states
- event model
- keyboard behavior where relevant
- pointer and touch assumptions

Later platforms should follow those decisions unless a platform constraint makes that a bad idea.

### 2. Shared behavior matters more than shared files

I do not expect perfect source sharing across all four targets. Different Xojo targets have different event models, lifecycle rules, and rendering constraints. The real goal is consistent behavior and appearance, not forcing one code file to serve every runtime.

### 3. Canvas ownership is the whole point

These components should draw themselves. If a control falls back to native widgets for the hard parts, we lose the reason for building the suite in the first place.

### 4. Appearance rules before expansion

Before building a large set of controls, define the shared appearance surface:

- spacing scale
- corner radius rules
- border rules
- type scale
- base palette
- elevation or separation rules
- interaction colors for hover, focus, active, disabled, selected

Without that, the suite will drift.

### 5. Build small, reusable primitives

The first useful output is probably not a giant widget. It is a small set of repeatable primitives:

- surface
- button
- icon button
- segmented control
- tab strip
- list row
- text input shell
- popup/dropdown shell

Those primitives can then support larger controls later.

### 6. Flex layout is part of the foundation

This suite depends on the existing flex-style layout managers already present elsewhere in the workspace:

- `WebFlexLayoutManager`
- `DesktopFlexLayoutManager`

These should be compiled and installed in Xojo separately. New components should be designed so they behave correctly inside those layout managers from the beginning.

## Suggested first milestone

The first milestone for the web target should be modest and strict:

1. Establish the shared appearance surface.
2. Prove one base canvas component inside `WebFlexLayoutManager`.
3. Create one base canvas component abstraction for drawing and interaction.
4. Ship a small set of core controls in the web target.
5. Build one demo page that shows all supported states.
6. Treat that result as the visual and behavioral reference for later ports.

If this milestone is weak, every later platform port will get harder.

## Running the current project

At the moment the checked-in Xojo project is a plain Web 2 app shell.

Open `xcv-suites.xojo_project` in Xojo and run it normally. Expect a mostly empty starter page until the first web components are added.

## What to document as the repo grows

The `docs/` folder should carry the decisions that shape all four platforms. In practice that means:

- component inventory
- appearance rules
- state model
- event naming
- layout rules
- keyboard and pointer behavior
- platform exceptions
- porting notes from web to desktop/mobile

This repo will stay manageable only if those decisions are written down while the suite is still small.

Start with [docs/foundation-plan.md](docs/foundation-plan.md). It defines the current position on styling, layout-manager dependency, and the first implementation order.

For the active Xojo compile/debug/run loop in this repo, use [docs/xojo-km-harness.md](docs/xojo-km-harness.md).

For agent navigation and token efficiency, this repo should also keep `xoji` indexes fresh and use `.xojo_index/` before scanning large Xojo files directly.
