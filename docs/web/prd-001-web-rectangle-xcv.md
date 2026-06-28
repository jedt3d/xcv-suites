# PRD-001: WebRectangleXCV

## Status

Implemented

Tagged release target: `v0.1.0`

The core `WebRectangleXCV` component is complete for the first web milestone.

What is complete:

- single-color fill rendering, border rendering, and corner rendering
- rounded and bevel corner support
- per-corner configuration
- inspector-visible property surface
- anti-aliased edge rendering for cleaner corner output
- successful use in the current web host project

What is still intentionally light:

- the demo host is still a minimal compile/run page, not a full showcase page
- the broader web component set is still to come

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
2. Support one explicit fill color plus the rectangle border and corner treatments without reopening a broader fill API.
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

The current milestone exposes one custom fill property on `WebRectangleXCV`.

Current rule:

- fill is resolved directly from `FillColor`
- if `FillColor` is transparent, no interior fill is drawn

Implications:

- `FillColor` is the only fill property on the component
- there is no custom fill enable flag on the component
- there is no custom gradient surface on the component
- a transparent fill color produces an effectively unfilled interior

## Inspector behavior constraint

Xojo's `Inspector Behavior` for a source-defined control is static. It can expose, hide, reorder, regroup, and default properties, but it does not dynamically disable dependent properties when another property changes in the IDE.

For `WebRectangleXCV`, treat the following as the required semantic contract:

- `BorderEnabled = False` means no border is drawn, even though `BorderThickness` and `BorderColor` remain editable in the Inspector
- `FillColor` is the only custom fill inspector property on the component in the current milestone
- `CornerAllEnabled = False` or a per-corner enabled flag set to `False` means that corner resolves as disabled even though its stored value and style remain editable in the Inspector

This is an IDE limitation, not a rendering bug. If conditional Inspector enable/disable behavior is required later, that should be planned as a separate IDE plugin or extension track.

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

- `BorderEnabled As Boolean`
- `BorderThickness As Double`
- `BorderColor As Color`

### Fill

- `FillColor As Color`

### Corners

- `CornerAllEnabled As Boolean`
- `CornerUnit As XCVCornerUnit`
- `CornerTopLeftEnabled As Boolean`
- `CornerTopLeftValue As Double`
- `CornerTopLeftStyle As XCVCornerStyle`
- `CornerTopRightEnabled As Boolean`
- `CornerTopRightValue As Double`
- `CornerTopRightStyle As XCVCornerStyle`
- `CornerBottomLeftEnabled As Boolean`
- `CornerBottomLeftValue As Double`
- `CornerBottomLeftStyle As XCVCornerStyle`
- `CornerBottomRightEnabled As Boolean`
- `CornerBottomRightValue As Double`
- `CornerBottomRightStyle As XCVCornerStyle`

### Suggested enums

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

### Rule 5: Edge quality matters

Rounded and bevel corners should not snap harshly to full-pixel edges when a smoother result is possible. For this first component, edge coverage should be rendered cleanly enough that corner borders do not look visibly jagged at ordinary sizes.

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
2. A rectangle can be shown using a single explicit fill color.
3. A rectangle can be shown with border only when `FillColor` is transparent.
4. A rectangle can be shown with both `FillColor` and border.
5. Rounded corners render correctly.
6. Bevel corners render correctly.
7. Individual corner settings work independently.
8. The component behaves correctly inside `WebFlexLayoutManager`.

## Demo Requirements

The implementation phase should include a simple demo surface showing:

- border only
- single fill color
- single fill color with border
- rounded corners
- bevel corners
- mixed corner settings
- at least one example inside `WebFlexLayoutManager`

For this milestone, the checked-in host page remains a minimal validation surface rather than the full demo matrix above. The full showcase page is still a follow-up task, not a blocker for considering the base rectangle component finished.

The current checked-in validation host is `WebRectangleTest.xojo_code`.

## Resolved Decisions

These were settled during implementation:

1. The fill API is intentionally limited to one explicit `FillColor` property.
2. The fill path now resolves directly from `FillColor`, and transparency is the only no-fill mechanism.
3. Percent-based corners use half of the smaller rectangle dimension as the reference.
4. The API is normalized to `TopLeft`, `TopRight`, `BottomLeft`, and `BottomRight`.
5. Border thickness accepts `Double` input but is rounded and clamped to integer pixel thickness in v1.
6. `WebCanvas.DiffEngineDisabled` is not part of the component API surface. It remains an instance-level runtime setting that can be tuned separately from the rectangle appearance contract.

## Implementation Order

Recommended order:

1. define fill, border, and corner property surface
2. implement normalized geometry model
3. implement single fill color path
4. implement border
5. implement rounded corners
6. implement bevel corners
7. place component inside `WebFlexLayoutManager`
8. build demo page

## Release Intent

This document describes the `WebRectangleXCV` surface that ships with the first repository release tag, `v0.1.0`.
