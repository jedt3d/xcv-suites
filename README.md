# xcv-suites

`xcv-suites` is a web-first workspace for building Xojo canvas-based UI component suites that keep a consistent look, behavior, and component model across:

- Web
- Desktop
- iOS
- Android

The repo is focused on reusable components, not on a broad theming framework.

Primary agent-facing orientation lives in [agent.md](agent.md). Keep that file aligned with the actual workflow, project structure, and harness behavior.

## Status

- current release line: `v0.1.0`
- current active Xojo project: `xcv-suites.xojo_project`
- current validation host: `WebRectangleTest.xojo_code`
- current implementation focus: `web/`

## Repo layout

```text
xcv-suites/
├── web/
├── desktop/
├── ios/
├── android/
├── docs/
└── xcv-suites.xojo_project
```

## Documentation rule

The root README stays brief.

Component-specific detail does not belong here. Store it under `docs/` in the subfolder for the relevant platform:

- `docs/web/`
- `docs/desktop/`
- `docs/ios/`
- `docs/android/`

Shared repo-wide notes can stay at the root of `docs/`.

Current examples:

- shared foundation: [docs/foundation-plan.md](docs/foundation-plan.md)
- shared Xojo compile/run harness: [docs/xojo-km-harness.md](docs/xojo-km-harness.md)
- web rectangle component detail: [docs/web/prd-001-web-rectangle-xcv.md](docs/web/prd-001-web-rectangle-xcv.md)

## Working direction

- Web is the reference implementation first.
- Components should cooperate with the existing flex layout managers.
- Styling stays explicit and limited at the component level.
- Detailed component behavior and API notes belong in platform docs, not in the root README.
