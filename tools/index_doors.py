#!/usr/bin/env python3
"""
PhiSHRI Door Indexer - Embeds all doors into LanceDB for semantic search.
Run once to build the index, re-run when doors change.
"""

import json
from pathlib import Path
from typing import Optional
import lancedb
from sentence_transformers import SentenceTransformer

# Paths
PHISHRI_ROOT = Path("/mnt/x/dev/PhiSHRI/PhiSHRI")
CONTEXTS_DIR = PHISHRI_ROOT / "CONTEXTS"
HASH_TABLE = PHISHRI_ROOT / "HASH_TABLE.json"
DB_PATH = Path("/mnt/x/dev/PhiSHRI/vector_db")

# Model - all-mpnet-base-v2 is the best general-purpose encoder
MODEL_NAME = "sentence-transformers/all-mpnet-base-v2"


def load_door(door_path: Path) -> Optional[dict]:
    """Load a door JSON file."""
    try:
        with open(door_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except (json.JSONDecodeError, FileNotFoundError) as e:
        print(f"[WARN] Failed to load {door_path}: {e}")
        return None


def extract_embeddable_text(door_code: str, door_data: dict) -> str:
    """Extract text to embed from a door's JSON structure."""
    parts = [door_code]

    # Get context_bundle if it exists
    ctx = door_data.get("context_bundle", door_data)

    # Summary
    if summary := ctx.get("summary"):
        parts.append(summary)

    # Aliases
    if aliases := door_data.get("aliases", []):
        parts.append(f"Aliases: {', '.join(aliases)}")

    # Semantic path
    if sem_path := door_data.get("semantic_path"):
        parts.append(f"Path: {sem_path}")

    # Quick start / onboarding
    if onboarding := ctx.get("onboarding", {}):
        if quick := onboarding.get("quick_start"):
            parts.append(f"Quick start: {quick}")

    # Tags
    if metadata := ctx.get("metadata", {}):
        if tags := metadata.get("tags", []):
            parts.append(f"Tags: {', '.join(tags)}")
        if category := metadata.get("category"):
            parts.append(f"Category: {category}")

    # Common patterns
    if onboarding := ctx.get("onboarding", {}):
        if patterns := onboarding.get("common_patterns", []):
            parts.append("Patterns: " + "; ".join(patterns[:3]))  # First 3

    return "\n".join(parts)


def find_all_doors() -> list[tuple[str, Path]]:
    """Find all door JSON files and their codes."""
    doors = []

    # Load hash table to get door codes
    with open(HASH_TABLE, "r", encoding="utf-8") as f:
        hash_table = json.load(f)

    for door_code, rel_path in hash_table.items():
        full_path = PHISHRI_ROOT / rel_path
        if full_path.exists():
            doors.append((door_code, full_path))
        else:
            print(f"[WARN] Door {door_code} points to missing file: {rel_path}")

    return doors


def build_index():
    """Build the LanceDB index from all doors."""
    print(f"[INFO] Loading embedding model: {MODEL_NAME}")
    model = SentenceTransformer(MODEL_NAME)

    print(f"[INFO] Finding doors in {CONTEXTS_DIR}")
    doors = find_all_doors()
    print(f"[INFO] Found {len(doors)} doors")

    # Prepare data for LanceDB
    records = []

    for door_code, door_path in doors:
        door_data = load_door(door_path)
        if not door_data:
            continue

        text = extract_embeddable_text(door_code, door_data)

        # Generate embedding
        embedding = model.encode(text, normalize_embeddings=True)

        records.append({
            "door_code": door_code,
            "path": str(door_path.relative_to(PHISHRI_ROOT)),
            "text": text[:1000],  # Truncate for storage
            "vector": embedding.tolist(),
        })

        if len(records) % 50 == 0:
            print(f"[INFO] Processed {len(records)} doors...")

    print(f"[INFO] Creating LanceDB at {DB_PATH}")
    DB_PATH.mkdir(parents=True, exist_ok=True)

    db = lancedb.connect(str(DB_PATH))

    # Drop existing table if it exists
    if "doors" in db.table_names():
        db.drop_table("doors")

    # Create table
    table = db.create_table("doors", records)

    # Create vector index for fast search
    table.create_index(
        metric="cosine",
        num_partitions=16,
        num_sub_vectors=32,
    )

    print(f"[OK] Indexed {len(records)} doors into LanceDB")
    print(f"[OK] Database location: {DB_PATH}")


if __name__ == "__main__":
    build_index()
