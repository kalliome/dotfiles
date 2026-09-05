---
name: work-server
description: Set up, deploy, and operate the workd work server (the work-app Super App at https://work.teppo.dev, port 11400 behind nginx + launchd on macOS). Use when the user asks to set up, install, deploy, restart, reload, build, or troubleshoot the work server, its nginx vhost, or its LaunchAgent, or asks what the workd commands and env vars are.
---

# Work Server (workd)

`workd` is the Go backend for the work-app Super App. It serves the built React
frontend and its API/WebSockets on `http://localhost:11400`, stores state in a
SQLite DB at `~/.work-app/workd.db`, and runs in production behind nginx at
`https://work.teppo.dev` (Tailnet-only), kept alive by a macOS LaunchAgent.

Repo: `~/dev/work-app`. Run all `make` targets from that directory.

## First-time setup

Two one-time manual steps precede the first `make deploy`. Both touch
root-owned resources, so print the `sudo` commands for the user to run rather
than assuming they will succeed unattended.

### 1. nginx vhost

`/opt/homebrew/etc/nginx/servers` is user-owned (copy needs no sudo); the
reload needs sudo (nginx master runs as root):

```sh
cp deploy/nginx/work.teppo.dev /opt/homebrew/etc/nginx/servers/
sudo nginx -t && sudo nginx -s reload
```

Run `nginx -t` (without sudo) first to catch syntax errors early. The vhost
restricts access to the Tailnet (`100.64.0.0/10`) plus loopback and terminates
TLS with the `*.teppo.dev` Let's Encrypt cert.

### 2. launchd service

The plist has no placeholders — it runs the installed
`/opt/homebrew/bin/workd`. Install the binary, copy the plist, bootstrap it,
then confirm health:

```sh
make install
cp deploy/launchd/dev.teppo.workd.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.teppo.workd.plist
curl -s http://127.0.0.1:11400/api/health
```

The service is a **LaunchAgent**, not a LaunchDaemon, on purpose: it runs as
the logged-in user so workd can reach `~/.work-app`. It sets `RunAtLoad` and
`KeepAlive`, and injects `WORK_APP_OMP_BIN` and
`WORK_ALLOWED_ORIGINS=https://work.teppo.dev`.

## Make commands

Run from `~/dev/work-app`:

- `make dev` — local development. Runs the Go backend (`go run ./cmd/workd`,
  with `WORK_APP_OMP_BIN` set) plus the Vite dev server, which proxies `/api`
  and `/ws` to `:11400`. Point agent-browser at the Vite URL; test the built
  binary on `:11400` directly for acceptance.
- `make build` — `npm ci` the format sidecar (`internal/workspace/sidecar`),
  `npm run build` the frontend, then `go build -o bin/workd ./cmd/workd`.
- `make install` — `build`, then install the binary to
  `/opt/homebrew/bin/workd`.
- `make restart` — `launchctl kickstart -k` the running LaunchAgent to re-exec
  the installed binary. Use after `make install` to pick up a new binary
  **without** re-reading the plist.
- `make reload` — reinstall the plist and fully bootout/bootstrap the job.
  **Required after editing the plist** (env vars, args); `restart`'s kickstart
  keeps the old in-memory job definition and ignores plist changes.
- `make deploy` — `install` + `restart`. The normal ship command for the
  service behind work.teppo.dev.
- `make test` — `go test ./...` and the frontend test suite.
- `make lint` — `go vet ./...` and the frontend lint.
- `make smoke` — `build`, then the end-to-end smoke test
  (`scripts/smoke/smoke.sh`) against a throwaway environment.

**Which restart do I need?** Changed only Go/frontend code →
`make deploy` (or `make install && make restart`). Changed the plist →
`make reload`.

## workd CLI

- `workd` (no args) or `workd serve` — start the server. `serve` flags:
  `-host`, `-port`, `-db`.
- `workd omp-bridge` — run one durable OMP RPC bridge (internal; spawned by the
  server, not invoked by hand).
- `workd version` / `workd -v` — print version.
- `workd help` / `workd -h` — help.

## Environment variables

- `HOST` — bind address (default `localhost`).
- `PORT` — bind port (default `11400`).
- `WORK_APP_DB` — SQLite DB path (default `~/.work-app/workd.db`).
- `WORK_APP_OMP_BIN` — OMP executable each agent runtime launches (default
  first `omp` on PATH). The plist and `make dev` point it at
  `/Users/tkallio/omp/omp.sh` (sandbox-exec wrapper).
- `WORK_APP_REGISTRY` — project registry path (default: the `work` CLI registry
  at `<user config dir>/work/config.json`).
- `WORK_APP_FS_ROOTS` — colon-separated roots the directory picker may browse
  (default `~/dev:/Volumes/clients`).
- `WORK_APP_TMUX_SOCKET` — tmux socket name for terminal sessions (default
  `work`).
- `WORK_ALLOWED_ORIGINS` — comma-separated origins allowed to reach the API and
  WebSockets. Required when serving beyond localhost (loopback always allowed);
  the plist sets `https://work.teppo.dev`.

## Operate & troubleshoot

- **Health:** `curl -s http://127.0.0.1:11400/api/health`.
- **Logs:** `/tmp/workd.out.log` and `/tmp/workd.err.log`.
- **Manual restart:** `launchctl kickstart -k gui/$(id -u)/dev.teppo.workd`.
- **Remove the service:** `launchctl bootout gui/$(id -u)/dev.teppo.workd`.
- Service label is `dev.teppo.workd`; installed binary is
  `/opt/homebrew/bin/workd`.
