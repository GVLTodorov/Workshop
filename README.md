# Workshop

Self-hosted, real-time agile-ceremony tools. Each project lives in its own folder and keeps its own
solution, docs, and Docker image.

| Project | What it is | Image | Version tags |
| --- | --- | --- | --- |
| [RetroBoard](RetroBoard) | Sprint retrospective board | `ghcr.io/gvltodorov/workshop/retroboard` | `RetroBoard-vX.Y.Z` |
| [PlanningPoker](PlanningPoker) | Planning Poker for agile estimation | `ghcr.io/gvltodorov/workshop/planningpoker` | `PlanningPoker-vX.Y.Z` |

[![RetroBoard](https://github.com/GVLTodorov/Workshop/actions/workflows/retroboard.yml/badge.svg)](https://github.com/GVLTodorov/Workshop/actions/workflows/retroboard.yml)
[![PlanningPoker](https://github.com/GVLTodorov/Workshop/actions/workflows/planningpoker.yml/badge.svg)](https://github.com/GVLTodorov/Workshop/actions/workflows/planningpoker.yml)

## Working on a project

Open the project's own folder in VS Code (for example `Workshop/RetroBoard`) so that its F5 launch
config and tasks work. Run `dotnet` and `docker compose` commands from that folder too. Each
project's README covers the details.

## How the pipelines work

There are two pipelines, one per project: [`retroboard.yml`](.github/workflows/retroboard.yml) and
[`planningpoker.yml`](.github/workflows/planningpoker.yml).

| What you do | What runs |
| --- | --- |
| Push to `main` or `beta` | Tests, then a release, for each project the push changed |
| Open a pull request | Tests only; nothing is published |
| **Run workflow** on `main` | Tests, a release, then the load test and demo recordings |
| **Run workflow** on `beta` | Tests, then a release |
| **Run workflow** on any other branch | Tests only |

A release bumps the project's version, tags it, and pushes its Docker image, tagged with the version
and, on `main`, `latest`. **Run workflow** is in the Actions tab, and it releases even if nothing has
changed since the last release.

The demo recordings commit refreshed GIFs and charts to the project's `docs/` folder, so they only
run when started by hand. PlanningPoker's recordings need the `GIPHY_API_BASE_URL` and
`GIPHY_API_QUERY` repo secrets to show real gifs.
