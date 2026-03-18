#!/usr/bin/env python3
"""Ingest a document into Cornerstone-backed memory from ClaudeClaw."""

import os
import sys
from pathlib import Path

from dotenv import load_dotenv


def resolve_backend_root() -> str:
    repo_root = os.environ.get("CORNERSTONE_REPO_ROOT")
    if not repo_root:
        raise RuntimeError("CORNERSTONE_REPO_ROOT is required")
    return os.path.abspath(os.path.expanduser(repo_root))


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: ingest_doc.py <file_path>")
        return 0

    backend_root = resolve_backend_root()
    sys.path.insert(0, backend_root)
    load_dotenv(os.path.join(backend_root, ".env"))

    path = Path(os.path.expanduser(sys.argv[1]))

    try:
        from src.memory.documents import ingest_document

        if not path.exists():
            print(f"Error: file not found: {path}")
            return 0

        chunk_count = ingest_document(path)
        if chunk_count == 0:
            print(f"Skipped: {path.name} (already ingested or no text extracted)")
        else:
            print(f"Ingested {chunk_count} chunks from {path.name}")
    except ValueError as exc:
        print(f"Error: {exc}")
    except Exception as exc:  # pragma: no cover - runtime dependency path
        print(f"Error ingesting {path.name}: {type(exc).__name__}: {exc}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
