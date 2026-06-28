# Foundation Plan

This document sets the first real boundaries for `xcv-suites`.

I am writing it now because the repo is still small. This is the best time to be precise about what the suite is trying to become, what it is not trying to become, and which dependencies are part of the design from the start.

## 1. Core purpose

`xcv-suites` is a cross-platform family of Xojo canvas-based components.

The goal is to keep the same overall behavior, visual language, and component model across:

- Web
- Desktop
- iOS
- Android

The suite should feel like one system, even if the code for each platform is different.

## 2. This is not a theming framework

The component suite needs style customization, but it is **not** trying to become a Bootstrap-like theme engine or a CSS-style token system that exists mainly to reskin everything globally.

What matters more is component behavior.

That means:

- the components must work well first
- styling should support the component, not replace the component
- visual customization should stay understandable and local

At minimum, the style surface should allow controlled adjustment of:

- font size
- text color
- border
- background
- background gradient

This is enough to let a component adapt to different use cases without turning the whole library into a skinning framework.

## 3. Styling philosophy

The right model here is **component-level appearance control**, not full theme orchestration.

In practice, that means:

- each component can expose a small, explicit appearance surface
- the appearance surface should be consistent across components where it makes sense
- we should avoid a giant global theme layer early on
- default visuals should already be good without requiring configuration

If a shared style object is introduced later, it should exist to reduce repetition and improve consistency, not to mimic CSS.

## 4. Functionality comes before visual breadth

The minimum standard for any component is:

1. it behaves correctly
2. it resizes correctly
3. it handles interaction states correctly
4. it draws itself predictably
5. only then do we expand its styling surface

This matters because canvas components are expensive to fake. Once behavior is wrong, extra style controls do not help.

## 5. Layout managers are foundation dependencies

Two existing components are already part of the real foundation:

- `WebFlexLayoutManager`
- `DesktopFlexLayoutManager`

These come from the separate projects:

- `../xojo-web-layout-manager`
- `../xojo-desktop-layout-manager`

Both are flex-style layout managers modeled after CSS Flexbox behavior.

### Important rule

These layout managers should be **compiled and installed separately in Xojo**.

`xcv-suites` should not treat them as temporary experiments. Component design should assume that these layout managers are part of the working environment.

## 6. What this means for component design

Every new component should be designed so it can live inside the flex layout managers without surprises.

That means each component should:

- tolerate externally assigned bounds cleanly
- redraw correctly on every resize
- have a stable base size
- document its minimum useful size
- avoid hidden assumptions about fixed pixel positions outside its own bounds
- behave correctly when shown, hidden, or resized by a parent layout container

For practical purposes, each component should be thought of as a box that the layout manager controls.

The component owns:

- drawing
- state
- input handling
- internal geometry

The layout manager owns:

- position
- outer size allocation
- spacing between components
- overall arrangement

If those responsibilities blur too much, the suite will be hard to port and hard to compose.

## 7. Web first, but with layout awareness from day one

We are still starting with **Web first**.

But the web work should not be designed as if layout is an afterthought. The first web components should be built and tested inside `WebFlexLayoutManager`, not only on absolute-position demo pages.

That is the only honest way to know whether the component model will survive later ports.

## 8. First implementation batch

The first batch should stay small. The goal is to prove the architecture, not to fill out a catalog.

I would use this order:

### Phase 0: layout integration

Before building many controls, prove that a custom canvas component behaves correctly inside the web flex layout manager.

Deliverables:

- one base web canvas component
- resize behavior
- visible/hidden behavior
- basic style properties
- one demo page inside `WebFlexLayoutManager`

### Phase 1: core primitives

Build a very small reference set:

- `Surface` or `Panel`
- `Button`
- `IconButton`
- `TextInput` shell
- `SegmentedControl` or `Tabs`
- `ListRow` or `ItemRow`

This set is small on purpose. It covers:

- text drawing
- background and border drawing
- pressed/hover/focus/selected states
- sizing rules
- composition inside flex layouts

### Phase 2: desktop port foundation

After the web reference set is coherent:

- port the same primitives to desktop
- keep the same naming and state model where possible
- validate them inside `DesktopFlexLayoutManager`

Only after that should the suite expand aggressively.

## 9. Shared contracts that should stay stable

Even if implementation differs by platform, these contracts should stay aligned:

- state names
- property naming
- event naming
- layout expectations
- default spacing behavior
- border/background/font option semantics

If a platform needs an exception, document the exception directly instead of silently drifting.

## 10. Immediate next decisions

The next docs worth writing in `docs/` are:

1. `component-inventory.md`
   - first list of planned components and their status
2. `style-surface.md`
   - exact appearance properties shared across components
3. `layout-contract.md`
   - base size, minimum size, resize expectations, visibility rules
4. `web-first-milestone.md`
   - concrete build order for the first web components

## 11. Short version

If I reduce this plan to the essential rules:

- build components, not themes
- keep styling explicit and limited
- treat `WebFlexLayoutManager` and `DesktopFlexLayoutManager` as real dependencies
- make every component cooperate with flex layout from the beginning
- use web as the first reference implementation
- prove a small primitive set before expanding the suite
