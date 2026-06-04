"""Manage .wolf/buglog.json — add, search, list known fixes."""
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

BUGLOG = Path(".wolf/buglog.json")


def _load():
    if BUGLOG.exists():
        return json.loads(BUGLOG.read_text(encoding="utf-8"))
    return []


def _save(entries):
    BUGLOG.parent.mkdir(parents=True, exist_ok=True)
    BUGLOG.write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding="utf-8")


def add(error_message, file_path, root_cause, fix, tags=None):
    entries = _load()
    # check if this error already exists
    for e in entries:
        if e.get("error_message") == error_message and e.get("file") == file_path:
            e["occurrences"] = e.get("occurrences", 1) + 1
            e["last_seen"] = datetime.now(timezone.utc).isoformat()
            _save(entries)
            print(f"Updated bug-{e['id']}: occurrences={e['occurrences']}")
            return
    # new bug
    bug_id = f"bug-{len(entries) + 1:03d}"
    now = datetime.now(timezone.utc).isoformat()
    entry = {
        "id": bug_id,
        "timestamp": now,
        "error_message": error_message,
        "file": file_path,
        "root_cause": root_cause,
        "fix": fix,
        "tags": tags or [],
        "related_bugs": [],
        "occurrences": 1,
        "last_seen": now,
    }
    entries.append(entry)
    _save(entries)
    print(f"Created {bug_id}")


def search(query):
    entries = _load()
    query = query.lower()
    results = [e for e in entries if query in json.dumps(e).lower()]
    if not results:
        print("No matches.")
        return
    for e in results:
        print(f"{e['id']}: {e['error_message'][:80]}")
        print(f"  file: {e['file']}, occurrences: {e['occurrences']}")
        print(f"  fix: {e['fix'][:100]}")
        print()


def list_recent(n=10):
    entries = _load()
    for e in entries[-n:]:
        print(f"{e['id']}: {e['error_message'][:60]} → {e['fix'][:60]}")


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "list"
    if cmd == "add":
        add(*sys.argv[2:])
    elif cmd == "search":
        search(sys.argv[2] if len(sys.argv) > 2 else "")
    elif cmd == "list":
        list_recent(int(sys.argv[2]) if len(sys.argv) > 2 else 10)
    else:
        print(f"Usage: buglog.py add|search|list [args]")
