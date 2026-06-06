#!/usr/bin/env python3
"""Remove white backgrounds from weapon PNGs using edge flood-fill."""

import sys
from pathlib import Path
from collections import deque

import numpy as np
from PIL import Image


def flood_fill_bg_mask(arr: np.ndarray, tolerance: int = 35) -> np.ndarray:
    h, w = arr.shape[:2]
    rgb = arr[:, :, :3].astype(np.int32)
    corners = np.concatenate([
        rgb[:5,  :5 ].reshape(-1, 3), rgb[:5,  -5:].reshape(-1, 3),
        rgb[-5:, :5 ].reshape(-1, 3), rgb[-5:, -5:].reshape(-1, 3),
    ])
    bg = np.median(corners, axis=0)
    diff = np.abs(rgb - bg).max(axis=2)
    close = diff < tolerance
    visited = np.zeros((h, w), dtype=bool)
    q = deque()
    for x in range(w):
        for ye in [0, h - 1]:
            if close[ye, x] and not visited[ye, x]:
                visited[ye, x] = True; q.append((ye, x))
    for y in range(h):
        for xe in [0, w - 1]:
            if close[y, xe] and not visited[y, xe]:
                visited[y, xe] = True; q.append((y, xe))
    while q:
        y, x = q.popleft()
        for dy, dx in ((-1,0),(1,0),(0,-1),(0,1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx] and close[ny, nx]:
                visited[ny, nx] = True; q.append((ny, nx))
    return visited


def remove_background(img: Image.Image, tolerance: int = 35) -> Image.Image:
    img = img.convert("RGBA")
    arr = np.array(img)
    mask = flood_fill_bg_mask(arr, tolerance)
    arr[mask, 3] = 0
    return Image.fromarray(arr, "RGBA")


def process_weapon(path: Path) -> None:
    img = Image.open(path)
    result = remove_background(img)
    result.save(path)
    print(f"  cleaned: {path.name}")


def main():
    weapons_dir = Path(__file__).parent.parent / "GrimmQuest" / "GrimmChronicles" / "assets" / "weapons"
    pngs = sorted(weapons_dir.glob("*.png"))
    print(f"Processing {len(pngs)} weapon images in {weapons_dir}")
    for p in pngs:
        process_weapon(p)
    print(f"\nDone. {len(pngs)} weapons cleaned.")


if __name__ == "__main__":
    main()
