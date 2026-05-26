#!/usr/bin/env python3
"""
build_items.py — one-time migration
Reads wesen.json and hunts.json, generates available_items for each hunt
(2 correct items from true_killer + 2 decoys from each other suspect = 6 total),
shuffles them, and writes back to hunts.json.
"""
import json, random, pathlib

BASE = pathlib.Path("/Users/stephenpolentarutti/grimm/GrimmQuest/GrimmChronicles/data")
wesen = json.loads((BASE / "wesen.json").read_text())
hunts = json.loads((BASE / "hunts.json").read_text())

random.seed(42)  # reproducible shuffle

for hid, hunt in hunts.items():
    suspects = hunt.get("suspects", [])
    true_killer = hunt["true_killer"]
    pool = []
    for wid in suspects:
        items = wesen.get(wid, {}).get("weakness_items", [])
        pool.extend(items)
    # Deduplicate while preserving order
    seen = set(); unique = []
    for item in pool:
        if item not in seen:
            seen.add(item); unique.append(item)
    random.shuffle(unique)
    hunt["available_items"] = unique
    correct = wesen[true_killer]["weakness_items"]
    print(f"{hid}: {len(unique)} items  correct={correct}")

(BASE / "hunts.json").write_text(json.dumps(hunts, indent=2, ensure_ascii=False))
print("\nhunts.json updated.")
