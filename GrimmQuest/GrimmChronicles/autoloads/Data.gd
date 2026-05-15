extends Node

# Loaded once at startup — all scene scripts read from these
var WESEN:            Dictionary = {}
var EVIDENCE:         Dictionary = {}
var HUNTS:            Dictionary = {}
var SCENES:           Dictionary = {}
var CASES:            Dictionary = {}  # keyed by case_id
var SCENE_TEMPLATES:  Dictionary = {}  # bg_key -> {slots: {slot_id -> {pos,size,r}}}
var OBJECT_POOL:      Dictionary = {}  # item_id -> {sheet, src, tags}

func _ready() -> void:
	WESEN           = _load("wesen")
	EVIDENCE        = _load("evidence")
	HUNTS           = _load("hunts")
	SCENES          = _load("scenes_data")
	CASES           = _load_cases("cases/grimm_cases_003_012")
	SCENE_TEMPLATES = _load("scene_templates")
	OBJECT_POOL     = _load("object_pool")

func _load(fname: String) -> Dictionary:
	var path := "res://data/" + fname + ".json"
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		push_error("Data: cannot open " + path)
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_error("Data: cannot parse " + path)
		return {}
	return parsed

func _load_cases(fname: String) -> Dictionary:
	var path := "res://data/" + fname + ".json"
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		push_error("Data: cannot open " + path)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if not parsed is Array:
		push_error("Data: cases file is not an array — " + path)
		return {}
	var indexed := {}
	for case_data in parsed:
		indexed[case_data["case_id"]] = case_data
	return indexed
