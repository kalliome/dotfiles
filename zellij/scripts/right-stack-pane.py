#!/usr/bin/env python3
"""Move the focused Zellij pane to/from a per-tab right-side stack.

Run this from a Zellij keybinding with `in_place true`. A small sentinel pane is
used to create/hold the right-side split because `MovePane "right"` cannot create
one from a full-width layout on its own.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path
from typing import Any

STATE_DIR = Path(os.environ.get("TMPDIR", "/tmp")) / "zellij-right-stack"
SENTINEL_NAME = "__zellij_right_stack_sentinel__"
MOVE_DELAY = 0.05


def zellij(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["zellij", "action", *args],
        check=check,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )


def zellij_json(*args: str) -> Any:
    return json.loads(zellij(*args).stdout)


def pane_ref(pane_id: int) -> str:
    return f"terminal_{pane_id}"


def pane_id_from_ref(pane_ref_text: str) -> int | None:
    match = re.search(r"(\d+)$", pane_ref_text.strip())
    return int(match.group(1)) if match else None


def state_path() -> Path:
    session = os.environ.get("ZELLIJ_SESSION_NAME", "unknown-session")
    safe_session = "".join(c if c.isalnum() or c in "._-" else "_" for c in session)
    return STATE_DIR / f"{safe_session}.json"


def load_state() -> dict[str, dict[str, Any]]:
    try:
        return json.loads(state_path().read_text())
    except Exception:
        return {}


def save_state(state: dict[str, dict[str, Any]]) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    state_path().write_text(json.dumps(state, sort_keys=True))


def current_tab_id() -> int:
    return int(zellij_json("current-tab-info", "--json")["tab_id"])


def panes_for_tab(tab_id: int) -> list[dict[str, Any]]:
    return [p for p in zellij_json("list-panes", "--json") if p.get("tab_id") == tab_id]


def terminal_panes(tab_id: int) -> list[dict[str, Any]]:
    return [
        p
        for p in panes_for_tab(tab_id)
        if not p.get("is_plugin")
        and not p.get("is_floating")
        and p.get("is_selectable", True)
        and not p.get("exited", False)
    ]


def focused_terminal_pane(tab_id: int) -> dict[str, Any] | None:
    env_id = pane_id_from_ref(os.environ.get("ZELLIJ_PANE_ID", ""))
    panes = terminal_panes(tab_id)
    if env_id is not None:
        for pane in panes:
            if int(pane["id"]) == env_id:
                return pane

    for pane in panes:
        if pane.get("is_focused"):
            return pane
    return None


def live_terminal_ids(tab_id: int) -> set[int]:
    return {int(p["id"]) for p in terminal_panes(tab_id)}


def clean_tab_state(tab_id: int, tab_state: dict[str, Any]) -> dict[str, Any]:
    live_ids = live_terminal_ids(tab_id)
    shelf: list[int] = []
    for pane_id in tab_state.get("shelf", []):
        pane_id = int(pane_id)
        if pane_id in live_ids and pane_id not in shelf:
            shelf.append(pane_id)

    sentinel = tab_state.get("sentinel")
    sentinel = int(sentinel) if sentinel in live_ids else None
    return {"shelf": shelf, "sentinel": sentinel}


def focus(pane_id: int) -> None:
    zellij("focus-pane-id", pane_ref(pane_id), check=False)
    time.sleep(MOVE_DELAY)


def new_sentinel_right() -> int | None:
    created = zellij(
        "new-pane",
        "--direction",
        "right",
        "--name",
        SENTINEL_NAME,
        "--",
        "zsh",
        "-c",
        "sleep 365d",
        check=False,
    ).stdout
    time.sleep(MOVE_DELAY)
    return pane_id_from_ref(created)


def move_right() -> None:
    tab_id = current_tab_id()
    active = focused_terminal_pane(tab_id)
    if active is None:
        return

    active_id = int(active["id"])
    tab_key = str(tab_id)
    state = load_state()
    tab_state = clean_tab_state(tab_id, state.get(tab_key, {}))
    shelf: list[int] = tab_state["shelf"]
    sentinel: int | None = tab_state["sentinel"]

    if active_id in shelf:
        focus(active_id)
        zellij("move-pane", "right", check=False)
    elif shelf:
        focus(active_id)
        zellij("stack-panes", "--", *[pane_ref(p) for p in [*shelf, active_id]], check=False)
        shelf.append(active_id)
    else:
        focus(active_id)
        sentinel = new_sentinel_right()
        focus(active_id)
        zellij("move-pane", "right", check=False)
        shelf = [active_id]

    state[tab_key] = clean_tab_state(tab_id, {"shelf": shelf, "sentinel": sentinel})
    save_state(state)


def move_left() -> None:
    tab_id = current_tab_id()
    active = focused_terminal_pane(tab_id)
    if active is None:
        return

    active_id = int(active["id"])
    tab_key = str(tab_id)
    state = load_state()
    tab_state = clean_tab_state(tab_id, state.get(tab_key, {}))
    shelf: list[int] = tab_state["shelf"]
    sentinel: int | None = tab_state["sentinel"]

    focus(active_id)
    zellij("move-pane", "left", check=False)
    shelf = [pane_id for pane_id in shelf if pane_id != active_id]

    if not shelf:
        if sentinel is not None:
            zellij("close-pane", "--pane-id", pane_ref(sentinel), check=False)
        state.pop(tab_key, None)
    else:
        state[tab_key] = clean_tab_state(tab_id, {"shelf": shelf, "sentinel": sentinel})
    save_state(state)


def main() -> int:
    if len(sys.argv) != 2 or sys.argv[1] not in {"right", "left"}:
        print("usage: right-stack-pane.py right|left", file=sys.stderr)
        return 2

    if sys.argv[1] == "right":
        move_right()
    else:
        move_left()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
