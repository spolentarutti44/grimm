extends Node

# ─── player & world state ───────────────────────────────────────────────────
var player: Dictionary = {}
var pc:     Dictionary = {}       # player-character position/animation
var scene:  String     = "hub"    # current investigation scene id

# ─── transient state ─────────────────────────────────────────────────────────
var combat = null          # Dictionary while in combat, null otherwise
var result: Dictionary = {} # aftermath result dict
var pending_combat: Dictionary = {}  # set by InvestigationScene before switching

# ─── scene object placements ─────────────────────────────────────────────────
# Keyed by scene_id. Each value is an Array of placement dicts:
#   { slot, item_id, label, interact, evidence }
# Populated by CaseGen at case start; empty = no placed objects for that scene.
var placed_objects: Dictionary = {}

const SAVE_PATH := "user://grimm_chronicles.json"

# ─── level thresholds ────────────────────────────────────────────────────────
const XP_LEVELS := [0, 100, 260, 500, 850, 1300]

func _ready() -> void:
	reset()

# Full reset — call for New Game
func reset() -> void:
	player = _make_player()
	pc     = _make_pc()
	scene  = "hub"
	combat = null
	result = {}
	pending_combat = {}
	placed_objects = {}

func _make_player() -> Dictionary:
	return {
		"hp": 60, "max_hp": 60,
		"stam": 5, "max_stam": 5,
		"gold": 30, "xp": 0,
		"level": 1, "hunts": 0,
		"trust": {},
		"started": false,
		"completed_hunts": [],
		"contract": "",
		"evidence": [],
		"flagged_evidence": [],
		"deduction": "",
	}

func _make_pc() -> Dictionary:
	return {
		"x": 340.0, "y": 310.0,
		"tx": 340.0, "ty": 310.0,
		"facing": 1, "anim": 0.0,
		"walking": false,
		"pending_interact": "",
	}

# ─── save / load ─────────────────────────────────────────────────────────────
func save() -> void:
	var data := {"player": player, "scene": scene}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if not parsed is Dictionary:
		return
	var template := _make_player()
	var saved_p: Dictionary = parsed.get("player", {})
	for key in template:
		if saved_p.has(key):
			player[key] = saved_p[key]
	scene = parsed.get("scene", "hub")

# ─── helpers ─────────────────────────────────────────────────────────────────
func current_level_from_xp() -> int:
	var lvl := 1
	for i in range(1, XP_LEVELS.size()):
		if player["xp"] >= XP_LEVELS[i]:
			lvl = i + 1
	return lvl

func gain_xp_and_level(amount: int) -> bool:
	var old_level: int = player["level"]
	player["xp"] += amount
	var new_level := current_level_from_xp()
	if new_level > old_level:
		var gained := new_level - old_level
		player["level"] = new_level
		player["max_hp"] += 10 * gained
		player["hp"] = player["max_hp"]
		return true
	return false
