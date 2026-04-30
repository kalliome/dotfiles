#!/usr/bin/env python3
import curses
import json
import os
import subprocess
import sys
from typing import List, Optional

SESSION = os.environ.get("ZELLIJ_SESSION_NAME")


class PaneItem(dict):
    pass


def run(*args: str) -> str:
    return subprocess.check_output(args, text=True)


def run_json(*args: str):
    return json.loads(run(*args))


def shorten(text: str, width: int) -> str:
    if width <= 0:
        return ""
    if len(text) <= width:
        return text
    if width == 1:
        return "…"
    return text[: width - 1] + "…"


def current_picker_pane_id(session: str) -> Optional[str]:
    try:
        output = run("zellij", "--session", session, "action", "list-clients")
    except subprocess.CalledProcessError:
        return None

    lines = [line.strip() for line in output.splitlines() if line.strip()]
    rows = []
    for line in lines[1:]:
        parts = line.split(None, 2)
        if len(parts) >= 2:
            rows.append(parts)

    if len(rows) == 1:
        return rows[0][1]

    for parts in rows:
        running_command = parts[2] if len(parts) > 2 else ""
        if running_command.startswith("python") or "pane-picker" in running_command:
            return parts[1]
    return None


def load_panes(session: str) -> List[PaneItem]:
    panes = run_json(
        "zellij",
        "--session",
        session,
        "action",
        "list-panes",
        "--json",
        "--tab",
        "--state",
        "--command",
    )
    current_tab = run_json("zellij", "--session", session, "action", "current-tab-info", "--json")
    active_tab_id = current_tab.get("tab_id")
    picker_pane_id = current_picker_pane_id(session)

    items: List[PaneItem] = []
    for pane in panes:
        if pane.get("is_plugin"):
            continue
        if pane.get("exited"):
            continue
        if not pane.get("is_selectable"):
            continue

        pane_id = f"terminal_{pane['id']}"
        if pane_id == picker_pane_id:
            continue

        title = (pane.get("title") or pane.get("pane_command") or pane_id).strip()
        is_active_tab = pane.get("tab_id") == active_tab_id
        is_active_pane = is_active_tab and bool(pane.get("is_focused")) and not bool(pane.get("is_floating"))

        items.append(
            PaneItem(
                pane_id=pane_id,
                title=title,
                tab_name=(pane.get("tab_name") or f"Tab {pane.get('tab_id', '?')}").strip(),
                tab_id=pane.get("tab_id"),
                tab_position=pane.get("tab_position", 0),
                is_active_tab=is_active_tab,
                is_active_pane=is_active_pane,
                is_floating=bool(pane.get("is_floating")),
            )
        )

    items.sort(key=lambda p: (not p["is_active_pane"], not p["is_active_tab"], p["tab_position"], p["pane_id"]))
    return items


class UI:
    def __init__(self, stdscr, panes: List[PaneItem], session: str):
        self.stdscr = stdscr
        self.panes = panes
        self.session = session
        self.selected = 0
        self.offset = 0
        self.result: Optional[PaneItem] = None
        self.colors = {}

    def init(self):
        curses.curs_set(0)
        self.stdscr.keypad(True)
        curses.mousemask(curses.ALL_MOUSE_EVENTS | curses.REPORT_MOUSE_POSITION)
        curses.use_default_colors()

        if curses.has_colors():
            curses.start_color()
            curses.init_pair(1, curses.COLOR_CYAN, -1)
            curses.init_pair(2, curses.COLOR_BLACK, curses.COLOR_CYAN)
            curses.init_pair(3, curses.COLOR_WHITE, -1)
            curses.init_pair(4, curses.COLOR_BLUE, -1)
            curses.init_pair(5, curses.COLOR_BLACK, curses.COLOR_GREEN)
            curses.init_pair(6, curses.COLOR_CYAN, -1)
            curses.init_pair(7, curses.COLOR_MAGENTA, -1)
            self.colors = {
                "accent": curses.color_pair(1) | curses.A_BOLD,
                "selected": curses.color_pair(2) | curses.A_BOLD,
                "normal": curses.color_pair(3),
                "dim": curses.color_pair(4),
                "active_badge": curses.color_pair(5) | curses.A_BOLD,
                "active_title": curses.color_pair(6) | curses.A_BOLD,
                "tab": curses.color_pair(7) | curses.A_BOLD,
            }
        else:
            self.colors = {
                "accent": curses.A_BOLD,
                "selected": curses.A_REVERSE | curses.A_BOLD,
                "normal": curses.A_NORMAL,
                "dim": curses.A_DIM,
                "active_badge": curses.A_REVERSE | curses.A_BOLD,
                "active_title": curses.A_BOLD,
                "tab": curses.A_BOLD,
            }

    def visible_height(self) -> int:
        h, _ = self.stdscr.getmaxyx()
        return max(1, h - 1)

    def ensure_visible(self):
        vh = self.visible_height()
        if self.selected < self.offset:
            self.offset = self.selected
        elif self.selected >= self.offset + vh:
            self.offset = self.selected - vh + 1

    def draw_footer(self, height: int, width: int):
        footer = f"{len(self.panes)} panes • j/k or ↑/↓ • Enter switch • Esc cancel • click"
        self.stdscr.addstr(height - 1, 1, shorten(footer, width - 2), self.colors["dim"])

    def draw_line(self, y: int, x: int, text: str, attr: int, width: int):
        self.stdscr.addstr(y, x, shorten(text, width).ljust(max(0, width)), attr)

    def draw_empty(self, height: int, width: int):
        msg = "No other panes found in this session."
        hint = "Press Esc or Enter to close"
        self.stdscr.addstr(max(1, height // 2 - 1), max(1, (width - len(msg)) // 2), msg, self.colors["normal"])
        self.stdscr.addstr(max(2, height // 2), max(1, (width - len(hint)) // 2), hint, self.colors["dim"])

    def draw_panes(self, height: int, width: int):
        top = 0
        vh = self.visible_height()
        visible = self.panes[self.offset : self.offset + vh]

        for row, pane in enumerate(visible):
            y = top + row
            is_selected = self.offset + row == self.selected
            row_attr = self.colors["selected"] if is_selected else self.colors["normal"]
            self.stdscr.addstr(y, 1, " " * max(0, width - 2), row_attr)

            marker = "▶" if is_selected else " "
            prefix = f" {marker} "
            x = 1
            self.stdscr.addstr(y, x, prefix, row_attr)
            x += len(prefix)

            tab_label = f"[{pane['tab_name']}] "
            tab_attr = row_attr if is_selected else (self.colors["accent"] if pane["is_active_tab"] else self.colors["tab"])
            self.stdscr.addstr(y, x, shorten(tab_label, max(0, width - 2 - (x - 1))), tab_attr)
            x += len(tab_label)

            active_badge = " active " if pane["is_active_pane"] else ""
            badge_width = len(active_badge)
            title_width = max(0, width - 2 - (x - 1) - badge_width)
            title_attr = row_attr if is_selected else (self.colors["active_title"] if pane["is_active_pane"] else self.colors["normal"])
            self.draw_line(y, x, pane["title"], title_attr, title_width)

            if active_badge:
                badge_x = max(x, width - 1 - badge_width)
                self.stdscr.addstr(y, badge_x, active_badge, row_attr if is_selected else self.colors["active_badge"])

    def draw(self):
        self.stdscr.erase()
        height, width = self.stdscr.getmaxyx()

        if self.panes:
            self.draw_panes(height, width)
        else:
            self.draw_empty(height, width)
        self.draw_footer(height, width)
        self.stdscr.refresh()

    def select_row_from_mouse(self, y: int):
        top = 0
        index = self.offset + (y - top)
        if top <= y < top + self.visible_height() and 0 <= index < len(self.panes):
            self.selected = index
            self.result = self.panes[index]
            return True
        return False

    def run(self) -> Optional[PaneItem]:
        self.init()

        while True:
            if self.panes:
                self.selected = max(0, min(self.selected, len(self.panes) - 1))
            else:
                self.selected = 0
            self.ensure_visible()
            self.draw()

            key = self.stdscr.getch()

            if key in (27, ord("q")):
                return None
            if key in (curses.KEY_ENTER, 10, 13):
                if not self.panes:
                    return None
                return self.panes[self.selected]
            if key in (curses.KEY_UP, ord("k")):
                if self.panes:
                    self.selected = (self.selected - 1) % len(self.panes)
            elif key in (curses.KEY_DOWN, ord("j")):
                if self.panes:
                    self.selected = (self.selected + 1) % len(self.panes)
            elif key == curses.KEY_NPAGE:
                if self.panes:
                    self.selected = min(len(self.panes) - 1, self.selected + self.visible_height())
            elif key == curses.KEY_PPAGE:
                if self.panes:
                    self.selected = max(0, self.selected - self.visible_height())
            elif key == curses.KEY_MOUSE:
                try:
                    _, mx, my, _, state = curses.getmouse()
                except curses.error:
                    continue
                if state & (
                    curses.BUTTON1_CLICKED
                    | curses.BUTTON1_DOUBLE_CLICKED
                    | curses.BUTTON1_PRESSED
                    | curses.BUTTON1_RELEASED
                ):
                    if self.select_row_from_mouse(my):
                        return self.result
                elif hasattr(curses, "BUTTON4_PRESSED") and state & curses.BUTTON4_PRESSED:
                    if self.panes:
                        self.selected = max(0, self.selected - 1)
                elif hasattr(curses, "BUTTON5_PRESSED") and state & curses.BUTTON5_PRESSED:
                    if self.panes:
                        self.selected = min(len(self.panes) - 1, self.selected + 1)
            elif key == curses.KEY_RESIZE:
                continue


def focus_pane(session: str, pane_id: str):
    subprocess.check_call(["zellij", "--session", session, "action", "focus-pane-id", pane_id])


def main():
    if not SESSION:
        print("pane-picker.py must run inside a Zellij session", file=sys.stderr)
        return 1

    panes = load_panes(SESSION)

    selected = curses.wrapper(lambda stdscr: UI(stdscr, panes, SESSION).run())
    if not selected:
        return 0

    focus_pane(SESSION, selected["pane_id"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
