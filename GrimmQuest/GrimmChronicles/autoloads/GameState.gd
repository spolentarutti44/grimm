extends Node

# ─── player & world state ───────────────────────────────────────────────────
var player: Dictionary = {}
var pc:     Dictionary = {}       # player-character position/animation
var scene:  String     = "hub"    # current investigation scene id

# ─── transient state ─────────────────────────────────────────────────────────
var result: Dictionary = {}
var pending_resolution: Dictionary = {}  # set by InvestigationScene before switching

# ─── scene object placements ─────────────────────────────────────────────────
var placed_objects: Dictionary = {}

const SAVE_PATH := "user://grimm_chronicles.json"

func _ready() -> void:
	reset()

func reset() -> void:
	player = _make_player()
	pc     = _make_pc()
	scene  = "hub"
	result = {}
	pending_resolution = {}
	placed_objects = {}

func _make_player() -> Dictionary:
	return {
		"gold": 30,
		"hunts": 0,
		"started": false,
		"completed_hunts": [],
		"contract": "",
		"evidence": [],
		"flagged_evidence": [],
		"deduction": "",
		"unlocked_wesen": [],
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
