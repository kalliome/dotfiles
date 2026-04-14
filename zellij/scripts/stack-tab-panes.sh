#!/bin/bash
python3 - <<'PY'
import json
import subprocess

tab = json.loads(subprocess.check_output(["zellij", "action", "current-tab-info", "--json"]))
panes = json.loads(subprocess.check_output(["zellij", "action", "list-panes", "--json"]))
tab_id = tab.get("tab_id")

ids = []
for pane in panes:
    if pane.get("tab_id") == tab_id and pane.get("is_selectable") and not pane.get("is_floating"):
        prefix = "plugin_" if pane.get("is_plugin") else "terminal_"
        ids.append(prefix + str(pane.get("id")))

if len(ids) > 1:
    subprocess.check_call(["zellij", "action", "stack-panes", "--"] + ids)
PY
