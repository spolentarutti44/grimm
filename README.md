# Grimm Chronicles

A medieval investigation and combat game built in **Godot 4**, ported from an original HTML5 canvas prototype. You play as a Grimm — a hunter who can see Wesen (creature-people from folklore) for what they truly are. Take contracts, investigate crime scenes, gather evidence, name your suspect, and fight.

---

## Setup

1. Open Godot 4 and import `GrimmQuest/GrimmChronicles/project.godot`
2. Godot will auto-generate `.godot/imported/` cache on first open — this is normal
3. Run the project from `TitleScreen.tscn`

**Requirements:** Godot 4.2+

---

## Project Structure

```
GrimmQuest/GrimmChronicles/
├── autoloads/
│   ├── Data.gd          # Loads all JSON data, exposes SCENES / HUNTS / WESEN / EVIDENCE
│   ├── GameState.gd     # All runtime state — player, position, contract, save/load
│   └── SceneNav.gd      # Scene transition helpers
├── scenes/
│   ├── TitleScreen.gd/tscn
│   ├── InvestigationScene.gd/tscn   # Canvas-drawn investigation world
│   ├── CombatScene.gd/tscn          # Canvas-drawn real-time combat
│   └── AftermathScreen.gd/tscn      # Post-combat result screen
├── data/
│   ├── scenes_data.json   # All investigation scenes: layout, hotspots, exits
│   ├── hunts.json         # 12 cases: killer, suspects, reward, first scene
│   ├── evidence.json      # Evidence entries keyed by ID
│   ├── wesen.json         # 13 Wesen species: stats, signs, weakness, moves
│   ├── object_pool.json
│   └── scene_templates.json
└── assets/
    ├── backgrounds/       # PNG backgrounds per scene
    └── wesen/             # Wesen portrait PNGs
```

> **Note:** All background images must be genuine PNGs. Images exported from tools as JPEG then renamed `.png` will cause a Godot runtime error. Verify with `file <name>.png` before committing — convert with `sips -s format png <name>.png` on macOS if needed.

---

## How It Works

### Investigation

The investigation world is a 680×380 canvas drawn entirely via Godot's `_draw()` API — no scene nodes for gameplay. The current scene key is stored in `GameState.scene` and maps to an entry in `scenes_data.json`.

Each scene has:
- A background image
- A floor rect (walkable area)
- **Hotspots** — interactive points with a radius; approach and press `E` to trigger
- **Exits** — move to another scene (some require an active contract)

The player character is procedurally drawn at `GameState.pc.x/y` with a 1.6× scale.

### Contracts

Accepted from the contract post at the hub. One contract active at a time. Each contract has a `first_scene` the player travels to, a `min_clues` threshold before the Accuse button appears, and a `suspects` list of 3 accusable Wesen (always includes the true killer).

### Evidence

Collected by interacting with hotspots. Stored in `GameState.player["evidence"]`. Players can flag evidence with `★` to mark it as significant. The Accuse button only appears once `min_clues` are collected.

### Accusation

Opens a modal showing the 3 case suspects (not all 13 Wesen). Selecting one and confirming triggers a combat encounter against the case's `true_killer` regardless of who was accused — being wrong affects the aftermath result text and XP but you still fight the real killer.

### Random Encounters

While investigating (not at the hub), a timer counts down from a random 45–80 seconds. When it fires, a random patrol Wesen from the encounter pool attacks. The encounter:
- Does **not** clear your active contract or evidence
- Gives a small gold/XP reward on win
- Returns you to the investigation via the aftermath screen

**Encounter pool:** blutbad, jagerbar, klaustreich, coyotl, fuchsbau

### Combat

Real-time, keyboard driven:

| Key | Action |
|-----|--------|
| `A` | Dodge left |
| `D` | Dodge right |
| `J` | Parry (precise timing) |
| `K` | Strike |
| `Shift` | Block (hold) |

Watch the Wesen's aura colour before each attack — yellow = parry window, blue = dodge, red = block.

---

## The Cases

| # | Name | True Killer | Scene Entry |
|---|------|-------------|-------------|
| 1 | A Killing at the Schwarzwald | Blutbad | `clearing` |
| 2 | Trouble at the River-Mill | Jägerbar | `millyard` |
| 3 | The Tailor's Widow | Spinnetod | `c3_shop` |
| 4 | Red in the Snow | Blutbad | `c4_forest` |
| 5 | The Patient Dark | Lausenschlange | `c5_cellar` |
| 6 | The Glass Coffin | Hexenbiest | `c6_manor` |
| 7 | The Red Feast | Skalenzähne | `c7_yard` |
| 8 | The Beautiful Shepherd | Ziegevolk | `c8_market` |
| 9 | The Running Night | Coyotl | `c9_crossroads` |
| 10 | Dead Men Walking | Cracher-Mortel | `c10_grave` |
| 11 | The Good Neighbour | Klaustreich | `c11_tenement` |
| 12 | The Clean Hand | Gevatter Tod | `c12_guildhall` |

---

## Adding a New Case

1. **`hunts.json`** — add a new entry with `contract_name`, `contract_flavor`, `contract_gold`, `true_killer`, `first_scene`, `min_clues`, and `suspects` (3 Wesen IDs, true killer must be one of them)
2. **`scenes_data.json`** — add each scene in the chain with `name`, `bg`, `floor`, `spawn`, `hotspots`, and `exits`
3. **`evidence.json`** — add evidence entries for each hotspot `interact` value (format: `evid:<id>`)
4. **`assets/backgrounds/`** — add a real PNG for each new background key (verify format, see note above)
5. **Hub** (`scenes_data.json` → `"hub"` → `exits`) — add a new exit with `"requires": "<hunt_key>"`

---

## Adding a New Wesen

1. **`wesen.json`** — add entry with `name`, `desc`, `signs`, `weakness`, `hp`, `reward`, `moves`
2. **`assets/wesen/`** — add `<wid>.png` portrait (shown in the Grimm Diary)
3. **`CombatScene.gd:_draw_wesen_combat()`** — add a `match` branch for the new wid, or it falls back to the Blutbad silhouette
4. Add the new wid to any relevant case's `suspects` array in `hunts.json`

---

## Save File

Saved to `user://grimm_chronicles.json`. Stores player stats, active contract, collected evidence, and completed hunts. Delete to reset. In Godot, `user://` resolves to the OS app data directory.
