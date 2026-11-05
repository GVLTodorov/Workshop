# Workshop

Self-hosted, real-time agile-ceremony tools. Each project lives in its own folder and keeps its own
solution, docs, and Docker image.

| Project | What it is | Image | Version tags |
| --- | --- | --- | --- |
| [RetroBoard](RetroBoard) | Sprint retrospective board | `ghcr.io/gvltodorov/retroboard` | `RetroBoard-vX.Y.Z` |
| [PlanningPoker](PlanningPoker) | Planning Poker for agile estimation | `ghcr.io/gvltodorov/planningpoker` | `PlanningPoker-vX.Y.Z` |

[![RetroBoard CI](https://github.com/GVLTodorov/Workshop/actions/workflows/retroboard-ci.yml/badge.svg)](https://github.com/GVLTodorov/Workshop/actions/workflows/retroboard-ci.yml)
[![PlanningPoker CI](https://github.com/GVLTodorov/Workshop/actions/workflows/planningpoker-ci.yml/badge.svg)](https://github.com/GVLTodorov/Workshop/actions/workflows/planningpoker-ci.yml)

## Working on a project

Open the project's own folder in VS Code (for example `Workshop/RetroBoard`) so that its F5 launch
config and tasks work. Run `dotnet` and `docker compose` commands from that folder too. Each
project's README covers the details.

## How images get built

A push to `main` or `beta` runs the pipeline only for the projects it changed; a change to both
runs both, independently:

1. Build and test the project.
2. Bump that project's version from the conventional commits since its last tag, and tag it.
3. Build the project's Dockerfile and push the image, tagged with the version. On `main` it's also
   tagged `latest`.

Pull requests run the build, tests, and performance checks but publish nothing. To publish from a
GitHub release, name its tag after the project, for example `RetroBoard-v1.2.3`.

To release by hand, open the project's CI workflow in the Actions tab, choose **Run workflow**, and
pick `main` or `beta`. It runs the same steps, and bumps the version even if nothing has changed
since the last release. On any other branch it runs the build and tests but publishes nothing.

| Workflow | Purpose |
| --- | --- |
| [`dotnet-ci.yml`](.github/workflows/dotnet-ci.yml) | Shared pipeline; a change here rebuilds both projects |
| [`retroboard-ci.yml`](.github/workflows/retroboard-ci.yml), [`planningpoker-ci.yml`](.github/workflows/planningpoker-ci.yml) | Decide when each project's pipeline runs |
| `retroboard-demo-*.yml`, `planningpoker-demo-*.yml` | Manual demo recordings and load tests, started from the Actions tab |

Adding a project means giving it a folder with a `<Name>.slnx`, `src/<Name>.Client`,
`src/<Name>.Tests.Benchmarks`, and a Dockerfile, plus a copy of one of the `*-ci.yml` callers.
