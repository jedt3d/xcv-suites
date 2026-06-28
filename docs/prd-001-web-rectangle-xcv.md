# PRD-001: WebRectangleXCV

## Status

Draft

## Purpose

`WebRectangleXCV` is the first planned `xcv-suites` web component.

It should behave like a practical Xojo-style rectangle view for Web projects, but with a stricter and more explicit appearance model than the built-in rectangle control. The goal is not to build a theme engine. The goal is to build one useful, reliable drawable component with a small but clear styling surface.

This component is the first proving ground for:

- custom canvas-style rendering in the web target
- the `xcv-suites` appearance model
- compatibility with `WebFlexLayoutManager`
- future cross-platform ports

## Goals

1. Create a web rectangle component that is simple to understand and predictable to render.
2. Support the requested border, fill, gradient, and corner treatments without introducing a broad theming system.
3. Make the component layout-safe inside `WebFlexLayoutManager`.
4. Use this component as the reference for later `DesktopRectangleXCV` or equivalent platform ports.

## Non-Goals

This first component is not trying to:

- become a full generic drawing engine
- support arbitrary CSS gradients
- support radial gradients
- support side-specific border colors or thickness
- support shadows, blur, textures, or image fills
- solve all future shape requirements

Keep the scope tight.

## Component Name

`WebRectangleXCV`

## Platform

Web first.

The first implementation target is Xojo Web. Porting to other platforms comes later, after the web behavior and property model are stable.

## Design Principles

### 1. Functionality before style breadth

The component must render correctly and resize correctly before any extra polish work.

### 2. Explicit appearance surface

All styling should be represented by named properties, not hidden conventions or global theme behavior.

### 3. Layout-manager friendly

The component must behave correctly when its bounds are assigned externally by `WebFlexLayoutManager`.

### 4. Portable property model

The naming and semantics should be chosen so that a later desktop port can follow the same contract.

## Required Capabilities

### A. Border / line

The component must support a border with these controls:

- visible: `True/False`
- thickness: pixels
- color: RGB

Functional expectations:

- when border is disabled, no border is drawn
- when border is enabled, thickness must be respected consistently
- border rendering must cooperate with fill and corner geometry

## B. Fill

The component must support either no fill, solid fill, or linear gradient fill.

### Solid fill

Required controls:

- visible: `True/False`
- color: RGB
- opacity: percent

Functional expectations:

- opacity is applied to the fill only
- solid fill must render cleanly inside the border and corner shape

### Linear gradient fill

Supported direction for v1:

- top -> bottom only

Required controls:

- begin color: RGB
- end color: RGB
- midline shift: percent

#### Midline shift definition

This value controls where the transition midpoint visually occurs between the start and end colors.

Examples:

- `50%` means the transition midpoint sits around the center of the rectangle
- `25%` means the shift happens nearer the top, so the end color dominates more of the lower area
- `75%` means the shift happens nearer the bottom, so the begin color occupies more of the upper area

This should be implemented as a controlled top-to-bottom gradient bias, not as an arbitrary gradient editor.

### Fill exclusivity

For v1, the component should have one effective fill mode at a time:

- none
- solid
- gradient

Do not allow ambiguous combinations.

## C. Corners

The component must support configurable corners with these ideas:

- rounded corners can be enabled globally
- corners can also be controlled individually
- corner size can be expressed in pixels or percent
- corner style can be either rounded or bevel

### Individual corners

The requested corner identifiers are:

- `tl`
- `tr`
- `lw`
- `lr`

Before implementation, these should be normalized into the intended internal meaning. Most likely this means:

- top-left
- top-right
- lower-left
- lower-right

If the current naming is meant literally as `lw` and `lr`, document that explicitly in code comments or docs. Do not leave the mapping ambiguous.

### Corner controls

The model should support:

- all corners on/off together
- per-corner enable/disable
- per-corner size
- per-corner mode: rounded or bevel

### Corner units

Support:

- pixels
- percent

Percent should be interpreted relative to the available rectangle size in a consistent way and must never produce impossible geometry.

## Suggested Property Model

This is a proposed API direction, not yet implementation law:

### Border

- `BorderVisible As Boolean`
- `BorderThickness As Double`
- `BorderColor As Color`

### Fill

- `FillVisible As Boolean`
- `FillMode As XCVFillMode`
- `FillColor As Color`
- `FillOpacityPercent As Double`
- `GradientBeginColor As Color`
- `GradientEndColor As Color`
- `GradientMidpointPercent As Double`

### Corners

- `CornersEnabled As Boolean`
- `CornerUnit As XCVCornerUnit`
- `TopLeftCornerEnabled As Boolean`
- `TopRightCornerEnabled As Boolean`
- `BottomLeftCornerEnabled As Boolean`
- `BottomRightCornerEnabled As Boolean`
- `TopLeftCornerValue As Double`
- `TopRightCornerValue As Double`
- `BottomLeftCornerValue As Double`
- `BottomRightCornerValue As Double`
- `TopLeftCornerStyle As XCVCornerStyle`
- `TopRightCornerStyle As XCVCornerStyle`
- `BottomLeftCornerStyle As XCVCornerStyle`
- `BottomRightCornerStyle As XCVCornerStyle`

### Suggested enums

- `XCVFillMode`
  - `None`
  - `Solid`
  - `LinearGradient`
- `XCVCornerUnit`
  - `Pixels`
  - `Percent`
- `XCVCornerStyle`
  - `Rounded`
  - `Bevel`

## Rendering Rules

### Rule 1: Deterministic geometry

Rendering should come from one normalized internal geometry model. Do not scatter special-case drawing rules across unrelated branches if a normalized shape model can be computed first.

### Rule 2: Fill first, border second

Draw order should be predictable:

1. background/fill shape
2. border shape

### Rule 3: Geometry clamping

Corner values, border thickness, and percent-derived radii must be clamped so the shape remains valid.

### Rule 4: Respect assigned bounds

The component must render cleanly in whatever rectangle the parent gives it.

## Layout Contract

`WebRectangleXCV` must be safe inside `WebFlexLayoutManager`.

Required behavior:

- redraw correctly after resize
- no hardcoded absolute positioning assumptions outside its own bounds
- stable minimum useful size
- no visual corruption when made very small
- visible and hidden state changes should not break future layout passes

## Acceptance Criteria

The first implementation is acceptable when all of these are true:

1. The component compiles and runs in the web host project.
2. A rectangle can be shown with no border and no fill.
3. A rectangle can be shown with solid fill only.
4. A rectangle can be shown with border only.
5. A rectangle can be shown with both border and solid fill.
6. A rectangle can be shown with top-to-bottom gradient fill.
7. Gradient midpoint shifting is visibly correct at example values like `25`, `50`, and `75`.
8. Rounded corners render correctly.
9. Bevel corners render correctly.
10. Individual corner settings work independently.
11. The component behaves correctly inside `WebFlexLayoutManager`.

## Demo Requirements

The implementation phase should include a simple demo surface showing:

- no fill / no border
- border only
- solid fill
- gradient fill with three midpoint examples
- rounded corners
- bevel corners
- mixed corner settings
- at least one example inside `WebFlexLayoutManager`

## Open Questions

These should be settled during implementation:

1. Should fill visibility remain a separate Boolean, or should `FillMode = None` be the only no-fill state?
2. Should opacity affect only solid fill, or also gradient colors?
3. Should percent-based corners use width, height, or the smaller dimension as the reference?
4. Do we want the requested `lw` / `lr` names exposed in API, or should they be normalized to `BottomLeft` / `BottomRight` immediately?
5. Should border thickness accept fractional pixels, or clamp to integer pixels in v1?

## Implementation Order

Recommended order:

1. define enums and property surface
2. implement normalized geometry model
3. implement solid fill
4. implement border
5. implement rounded corners
6. implement bevel corners
7. implement top-to-bottom gradient with midpoint shift
8. place component inside `WebFlexLayoutManager`
9. build demo page

## Branch Intent

This document is the first PRD artifact for the first component on the feature branch dedicated to `WebRectangleXCV`.
