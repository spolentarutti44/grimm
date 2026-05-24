#!/usr/bin/env python3
"""
sprite_sheet_cleanup.py  (v3 - smart despeckle)
------------------------------------------------
Cleans up a sprite sheet PNG:
  - Edge-flood-fill background removal → true transparency
  - Smart despeckling: removes JPEG noise far from sprite content
  - Strips text labels / title rows
  - Extracts sprites from a detected grid
  - Enforces human-form / wessen pose ratio
  - Packs result into a clean 8x4 (32-sprite) output grid

Usage:
  python sprite_sheet_cleanup.py --input my_sheet.png
  python sprite_sheet_cleanup.py --input hexenbiest.png --bg-color black --label-height 32 --no-strip-title
"""

import argparse
import sys
from pathlib import Path
from collections import deque

import numpy as np
from PIL import Image


# ---------------------------------------------------------------------------
# Edge flood-fill background removal
# ---------------------------------------------------------------------------

def flood_fill_bg_mask(arr: np.ndarray, tolerance: int = 30) -> np.ndarray:
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


def remove_background(img: Image.Image, tolerance: int = 30) -> Image.Image:
    rgba = img.convert("RGBA")
    data = np.array(rgba, dtype=np.uint8)
    mask = flood_fill_bg_mask(data, tolerance=tolerance)
    data[mask, 3] = 0
    return Image.fromarray(data, mode="RGBA")


# ---------------------------------------------------------------------------
# Smart despeckling
# ---------------------------------------------------------------------------

def despeckle(arr: np.ndarray, min_size: int = 200, dilation_px: int = 8) -> np.ndarray:
    """
    Remove isolated pixel noise far from real sprite content.
    Labels all opaque regions, builds a safe zone around large ones,
    then removes any small cluster outside that zone.
    """
    try:
        from scipy import ndimage
    except ImportError:
        print("  ⚠  scipy not found; skipping despeckle (pip install scipy)")
        return arr

    arr = arr.copy()
    opaque = arr[:, :, 3] > 30
    labeled, n = ndimage.label(opaque)
    if n == 0:
        return arr

    sizes = np.array(ndimage.sum(opaque, labeled, range(1, n + 1)))

    # Build safe zone: dilation of all large sprite components
    large_mask = np.zeros_like(opaque)
    for cid, sz in enumerate(sizes, start=1):
        if sz >= min_size:
            large_mask |= (labeled == cid)
    safe_zone = ndimage.binary_dilation(large_mask, iterations=dilation_px)

    removed = 0
    for cid, sz in enumerate(sizes, start=1):
        if sz < min_size:
            comp = labeled == cid
            if not (comp & safe_zone).any():
                arr[comp, 3] = 0
                removed += 1

    print(f"   Despeckle: removed {removed} isolated noise clusters.")
    return arr


# ---------------------------------------------------------------------------
# Grid detection
# ---------------------------------------------------------------------------

def build_bands(arr: np.ndarray, n: int, axis: int, dark_threshold: int = 8):
    brightness = arr.mean(axis=(1, 2)) if axis == 0 else arr.mean(axis=(0, 2))
    is_sep = brightness < dark_threshold
    bands, in_band, start = [], False, 0
    for i, sep in enumerate(is_sep):
        if not sep and not in_band:
            start, in_band = i, True
        elif sep and in_band:
            bands.append((start, i)); in_band = False
    if in_band:
        bands.append((start, len(is_sep)))
    if len(bands) == n:
        return bands
    dim = arr.shape[axis]
    cell = dim // n
    return [(i * cell, (i + 1) * cell) for i in range(n)]


# ---------------------------------------------------------------------------
# Title row detection
# ---------------------------------------------------------------------------

def find_title_offset(arr: np.ndarray, bright_threshold: int = 200) -> int:
    """
    Return the Y offset where sprite content begins, skipping the title bar.
    Uses RGB channels only (alpha=255 would otherwise inflate all values).
    - Light bg (corners > 150): find the first non-bright row (white/grey header).
    - Dark bg (corners ≤ 150):  find the first 3-row window with RGB brightness > 5
      (actual sprite content). Skips dim title text and the pure-black gap.
    """
    rgb = arr[:, :, :3]   # drop alpha channel
    row_mean = rgb.mean(axis=(1, 2))
    corner_rgb = np.concatenate([
        rgb[:5, :5].reshape(-1, 3), rgb[:5, -5:].reshape(-1, 3),
        rgb[-5:, :5].reshape(-1, 3), rgb[-5:, -5:].reshape(-1, 3),
    ])
    corner_brightness = float(corner_rgb.mean())
    if corner_brightness > 150:
        # Light bg: first non-bright row = end of title bar
        for y, brightness in enumerate(row_mean):
            if brightness < bright_threshold:
                return y
    else:
        # Dark bg: first 3-row window of sustained sprite brightness
        for y in range(len(row_mean) - 3):
            if row_mean[y:y + 3].mean() > 5:
                return y
    return 0


# ---------------------------------------------------------------------------
# Sprite extraction
# ---------------------------------------------------------------------------

def is_blank(cell_arr: np.ndarray, threshold: float = 0.95) -> bool:
    return (cell_arr[:, :, 3] < 10).mean() > threshold


def extract_sprites(img_rgba, row_bands, col_bands, label_height=0):
    sprites = []
    for r, (y0, y1) in enumerate(row_bands):
        for c, (x0, x1) in enumerate(col_bands):
            cell_arr = np.array(img_rgba.crop((x0, y0, x1, y1)))
            if label_height > 0:
                cell_arr = cell_arr.copy()
                cell_arr[:label_height, :, 3] = 0
            if not is_blank(cell_arr):
                sprites.append({
                    "img": Image.fromarray(cell_arr, "RGBA"),
                    "row": r, "col": c,
                    "cell_w": x1 - x0, "cell_h": y1 - y0,
                })
    return sprites


# ---------------------------------------------------------------------------
# Pose-ratio selection
# ---------------------------------------------------------------------------

def select_sprites(sprites, total=32, human_ratio=0.30,
                   human_col_cutoff=2, human_row_cutoff=None):
    """
    Separate human-form from wessen sprites, then select `total` honoring the ratio.

    Two classification modes:
    - Column-based (default): sprites whose source column < human_col_cutoff are human.
      Works for sheets where cols 0-N are always human across all rows (fox, bear, etc.)
    - Row-based (human_row_cutoff set): sprites whose source row < human_row_cutoff
      are human.  Use for sheets where only the first row(s) contain human poses and
      the column position doesn't distinguish form (e.g. Spinnetod).
    """
    n_human  = round(total * human_ratio)
    n_wessen = total - n_human

    if human_row_cutoff is not None:
        human  = [s for s in sprites if s["row"] < human_row_cutoff]
        wessen = [s for s in sprites if s["row"] >= human_row_cutoff]
        mode   = f"row-based (human rows 0-{human_row_cutoff-1})"
    else:
        human  = [s for s in sprites if s["col"] < human_col_cutoff]
        wessen = [s for s in sprites if s["col"] >= human_col_cutoff]
        mode   = f"col-based (human cols 0-{human_col_cutoff-1})"

    print(f"  Selection mode: {mode}")
    print(f"  Found {len(human)} human-form, {len(wessen)} wessen sprites.")
    print(f"  Target: {n_human} human ({human_ratio*100:.0f}%), {n_wessen} wessen.")

    sel_h, sel_w = human[:n_human], wessen[:n_wessen]
    if len(sel_h) < n_human:
        gap = n_human - len(sel_h)
        print(f"  ⚠  Only {len(sel_h)} human available; filling {gap} from wessen.")
        sel_w = wessen[:n_wessen + gap]
    if len(sel_w) < n_wessen:
        gap = n_wessen - len(sel_w)
        print(f"  ⚠  Only {len(sel_w)} wessen available; filling {gap} from human.")
        sel_h = human[:n_human + gap]
    return (sel_h + sel_w)[:total]


# ---------------------------------------------------------------------------
# Output composition
# ---------------------------------------------------------------------------

def compose_sheet(sprites, out_cols, out_rows):
    if not sprites:
        raise ValueError("No sprites to compose.")
    cw, ch = sprites[0]["cell_w"], sprites[0]["cell_h"]
    out = Image.new("RGBA", (out_cols * cw, out_rows * ch), (0, 0, 0, 0))
    for i, s in enumerate(sprites[:out_cols * out_rows]):
        col, row = i % out_cols, i // out_cols
        simg = s["img"].resize((cw, ch), Image.LANCZOS)
        out.paste(simg, (col * cw, row * ch), simg)
    return out


# ---------------------------------------------------------------------------
# Pipeline
# ---------------------------------------------------------------------------

def process_sheet(args):
    src = Path(args.input)
    if not src.exists():
        sys.exit(f"Error: file not found: {src}")

    print(f"\n🖼  Loading: {src}")
    img = Image.open(src).convert("RGBA")
    w, h = img.size
    print(f"   Size: {w}×{h}")

    # ── Strip title bar ──────────────────────────────────────────────────
    if args.strip_title:
        offset = find_title_offset(np.array(img))
        if offset > 0:
            print(f"   Title bar detected: cropping top {offset}px")
            img = img.crop((0, offset, w, h))

    # ── Remove background ────────────────────────────────────────────────
    print(f"   Removing background (flood-fill, tolerance={args.tolerance}) …")
    img_clean = remove_background(img, tolerance=args.tolerance)

    # ── Detect grid (on ORIGINAL image before bg removal) ────────────────
    # IMPORTANT: build_bands must run on the original image. After flood-fill,
    # transparent gaps between sprites look like separator lines and produce
    # wrong (too-small) cell boundaries.
    print(f"   Building {args.cols}×{args.rows} grid …")
    arr_orig = np.array(img)   # img is pre-bg-removal (only title-stripped)
    row_bands = build_bands(arr_orig, args.rows, axis=0)
    col_bands = build_bands(arr_orig, args.cols, axis=1)

    # ── Smart despeckle ──────────────────────────────────────────────────
    if args.despeckle:
        print("   Running smart despeckle …")
        img_clean = Image.fromarray(
            despeckle(np.array(img_clean),
                      min_size=args.despeckle_min_size,
                      dilation_px=args.despeckle_dilation),
            "RGBA"
        )

    # ── Extract sprites ──────────────────────────────────────────────────
    print(f"   Extracting sprites (label strip: {args.label_height}px) …")
    sprites = extract_sprites(img_clean, row_bands, col_bands,
                               label_height=args.label_height)
    print(f"   Extracted {len(sprites)} non-blank sprites.")

    # ── Select by ratio ──────────────────────────────────────────────────
    print("   Selecting by pose ratio …")
    selected = select_sprites(sprites,
                               total=args.out_cols * args.out_rows,
                               human_ratio=args.human_ratio,
                               human_col_cutoff=args.human_cols,
                               human_row_cutoff=args.human_rows)
    print(f"   Selected {len(selected)} sprites.")

    # ── Compose & save ───────────────────────────────────────────────────
    print(f"   Composing {args.out_cols}×{args.out_rows} sheet …")
    out = compose_sheet(selected, args.out_cols, args.out_rows)
    out_path = Path(args.output)
    out.save(out_path, "PNG")
    ow, oh = out.size
    print(f"\n✅  Saved: {out_path}  ({ow}×{oh} px, {out_path.stat().st_size//1024} KB)")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args():
    p = argparse.ArgumentParser(
        description="Sprite sheet cleanup: remove bg, strip labels, despeckle, enforce pose ratio.")
    p.add_argument("--input",                required=True)
    p.add_argument("--output",               default="cleaned_spritesheet.png")
    p.add_argument("--cols",                 type=int,   default=8)
    p.add_argument("--rows",                 type=int,   default=4)
    p.add_argument("--human-ratio",          type=float, default=0.30)
    p.add_argument("--human-cols",           type=int,   default=2,
                                             help="Cols < N are human-form (col-based mode, default)")
    p.add_argument("--human-rows",           type=int,   default=None,
                                             help="Rows < N are human-form (row-based mode; overrides --human-cols). "
                                                  "Use for sheets like Spinnetod where only the first row(s) are human.")
    p.add_argument("--tolerance",            type=int,   default=30)
    p.add_argument("--label-height",         type=int,   default=0)
    p.add_argument("--out-cols",             type=int,   default=8)
    p.add_argument("--out-rows",             type=int,   default=4)
    p.add_argument("--despeckle",            action="store_true",  default=True)
    p.add_argument("--no-despeckle",         dest="despeckle",     action="store_false")
    p.add_argument("--despeckle-min-size",   type=int,   default=200,
                                             help="Components larger than this form the safe zone (default 200)")
    p.add_argument("--despeckle-dilation",   type=int,   default=1,
                                             help="Safe zone dilation in px (default 1 = tight, catches edge labels)")
    p.add_argument("--no-strip-title",       dest="strip_title",   action="store_false")
    p.set_defaults(strip_title=True)
    return p.parse_args()


if __name__ == "__main__":
    process_sheet(parse_args())
