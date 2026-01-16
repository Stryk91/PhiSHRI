#!/usr/bin/env python3
"""
PhiSHRI Semantic Query - Find doors by meaning, not just keywords.
"""

import json
import sys
from pathlib import Path
from typing import Optional
import lancedb
from sentence_transformers import SentenceTransformer

# Paths
PHISHRI_ROOT = Path("/mnt/x/dev/PhiSHRI/PhiSHRI")
DB_PATH = Path("/mnt/x/dev/PhiSHRI/vector_db")
MODEL_NAME = "sentence-transformers/all-mpnet-base-v2"

# Confidence threshold - below this, fall back to keyword matching
CONFIDENCE_THRESHOLD = 0.5

# Cache model globally
_model: Optional[SentenceTransformer] = None


def get_model() -> SentenceTransformer:
    """Lazy load the embedding model."""
    global _model
    if _model is None:
        _model = SentenceTransformer(MODEL_NAME)
    return _model


def query_doors(query: str, top_k: int = 5) -> list[dict]:
    """
    Query PhiSHRI doors by semantic similarity.

    Returns list of {door_code, path, score, text} dicts.
    """
    model = get_model()
    db = lancedb.connect(str(DB_PATH))
    table = db.open_table("doors")

    # Embed query
    query_embedding = model.encode(query, normalize_embeddings=True)

    # Search
    results = table.search(query_embedding.tolist()).limit(top_k).to_list()

    output = []
    for r in results:
        # LanceDB returns _distance for cosine (lower = more similar)
        # Convert to similarity score (1 - distance for cosine)
        score = 1 - r.get("_distance", 0)

        output.append({
            "door_code": r["door_code"],
            "path": r["path"],
            "score": round(score, 3),
            "text": r["text"][:200] + "..." if len(r["text"]) > 200 else r["text"],
        })

    return output


def get_best_door(query: str) -> Optional[dict]:
    """
    Get the single best matching door, or None if confidence too low.
    """
    results = query_doors(query, top_k=1)

    if not results:
        return None

    best = results[0]
    if best["score"] < CONFIDENCE_THRESHOLD:
        return None

    return best


def load_door_content(door_code: str) -> Optional[dict]:
    """Load the full door JSON for a given code."""
    hash_table_path = PHISHRI_ROOT / "HASH_TABLE.json"

    with open(hash_table_path, "r") as f:
        hash_table = json.load(f)

    if door_code not in hash_table:
        return None

    door_path = PHISHRI_ROOT / hash_table[door_code]

    try:
        with open(door_path, "r") as f:
            return json.load(f)
    except (json.JSONDecodeError, FileNotFoundError):
        return None


def main():
    """CLI interface for querying doors."""
    if len(sys.argv) < 2:
        print("Usage: query_doors.py <query> [top_k]")
        print("Example: query_doors.py 'MCP connection failing'")
        sys.exit(1)

    query = sys.argv[1]
    top_k = int(sys.argv[2]) if len(sys.argv) > 2 else 5

    print(f"[QUERY] {query}")
    print("-" * 60)

    results = query_doors(query, top_k=top_k)

    if not results:
        print("[WARN] No results found")
        sys.exit(1)

    for i, r in enumerate(results, 1):
        confidence = "HIGH" if r["score"] >= 0.7 else "MED" if r["score"] >= 0.5 else "LOW"
        print(f"\n{i}. [{confidence}] {r['door_code']} (score: {r['score']})")
        print(f"   Path: {r['path']}")
        print(f"   {r['text']}")

    # Show best match recommendation
    best = results[0]
    if best["score"] >= CONFIDENCE_THRESHOLD:
        print(f"\n[RECOMMENDED] Use door: {best['door_code']}")
    else:
        print(f"\n[LOW CONFIDENCE] Consider keyword search or refine query")


if __name__ == "__main__":
    main()
