#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from __future__ import annotations

import json
import os
import re
import shutil
import sqlite3
import subprocess
import tempfile
import urllib.parse
from pathlib import Path

HOME = Path.home()
ROFI_THEME = str(HOME / ".config/rofi/web-spotlight.rasi")
MAX_HISTORY = 450
MAX_BOOKMARKS = 300
SEARCH_URL = "https://www.google.com/search?q={}"

profiles = [
    HOME / ".config/google-chrome/Default",
    HOME / ".config/chromium/Default",
    HOME / ".config/google-chrome-pi-debug/Default",
]


def is_url(text: str) -> bool:
    text = text.strip()
    if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*://", text):
        return True
    if " " in text or not text:
        return False
    return bool(re.match(r"^([\w-]+\.)+[\w-]{2,}(/.*)?$", text))


def normalize_url(text: str) -> str:
    text = text.strip()
    if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*://", text):
        return text
    return "https://" + text


def search_url(text: str) -> str:
    shortcuts = {
        "g ": "https://www.google.com/search?q={}",
        "ddg ": "https://duckduckgo.com/?q={}",
        "yt ": "https://www.youtube.com/results?search_query={}",
        "gh ": "https://github.com/search?q={}",
        "wiki ": "https://en.wikipedia.org/wiki/Special:Search?search={}",
    }
    lowered = text.lower()
    engine = SEARCH_URL
    query = text
    for prefix, url in shortcuts.items():
        if lowered.startswith(prefix):
            engine = url
            query = text[len(prefix):].strip()
            break
    return engine.format(urllib.parse.quote_plus(query))


def clean_title(title: str, url: str) -> str:
    title = " ".join((title or "").split())
    return (title or url)[:76]


def history_rows(profile: Path) -> list[tuple[str, str, str]]:
    db = profile / "History"
    if not db.exists():
        return []

    tmp = Path(tempfile.gettempdir()) / f"web-spotlight-history-{os.getpid()}-{profile.parent.name}-{profile.name}.sqlite"
    try:
        shutil.copy2(db, tmp)
        con = sqlite3.connect(tmp)
        rows = con.execute(
            """
            SELECT title, url
            FROM urls
            WHERE url LIKE 'http%'
            ORDER BY last_visit_time DESC
            LIMIT ?
            """,
            (MAX_HISTORY,),
        ).fetchall()
        con.close()
        return [("hist", str(title or ""), str(url or "")) for title, url in rows if url]
    except Exception:
        return []
    finally:
        try:
            tmp.unlink(missing_ok=True)
        except Exception:
            pass


def walk_bookmarks(node: dict, out: list[tuple[str, str, str]]) -> None:
    if node.get("type") == "url" and node.get("url", "").startswith("http"):
        out.append(("mark", node.get("name", ""), node.get("url", "")))
        return
    for child in node.get("children", []) or []:
        if isinstance(child, dict):
            walk_bookmarks(child, out)


def bookmark_rows(profile: Path) -> list[tuple[str, str, str]]:
    bookmarks = profile / "Bookmarks"
    if not bookmarks.exists():
        return []
    try:
        data = json.loads(bookmarks.read_text(encoding="utf-8", errors="replace"))
        out: list[tuple[str, str, str]] = []
        for root in data.get("roots", {}).values():
            if isinstance(root, dict):
                walk_bookmarks(root, out)
        return out[:MAX_BOOKMARKS]
    except Exception:
        return []


seen: set[str] = set()
entries: list[str] = []
for profile in profiles:
    for kind, title, url in bookmark_rows(profile) + history_rows(profile):
        if not url or url in seen:
            continue
        seen.add(url)
        icon = "" if kind == "mark" else "󰋚"
        entries.append(f"{icon} {clean_title(title, url)}  —  {url}")

input_data = "\n".join(entries)
header = "Type to filter Chrome history/bookmarks · Enter opens result/URL · Shift+Enter searches the web"

result = subprocess.run(
    [
        "rofi",
        "-dmenu",
        "-i",
        "-format",
        "s|||f",
        "-p",
        "󰖟 Web",
        "-mesg",
        header,
        "-theme",
        ROFI_THEME,
        "-kb-accept-alt",
        "",
        "-kb-custom-1",
        "Shift+Return",
    ],
    input=input_data,
    text=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL,
    check=False,
)

selected, _, typed = result.stdout.partition("|||")
choice = selected.strip()
query = typed.strip()
if not choice and not query:
    raise SystemExit(0)

# Shift+Enter returns code 10 for kb-custom-1: force web search with the typed input only.
if result.returncode == 10:
    target = normalize_url(query) if is_url(query) else search_url(query)
elif "  —  " in choice:
    target = choice.rsplit("  —  ", 1)[1].strip()
else:
    target = normalize_url(choice) if is_url(choice) else search_url(choice)

subprocess.Popen(["xdg-open", target], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
PY
