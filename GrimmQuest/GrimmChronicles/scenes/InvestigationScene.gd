extends Node2D
## Investigation scene — canvas-drawn world + CanvasLayer UI
## Direct port of grimm_chronicles_v5_action_combat.html investigation logic

# ─── canvas dimensions (matches HTML original) ────────────────────────────
const W     := 680.0
const H     := 380.0
const SPEED := 180.0
const NEAR_DIST := 70.0

# ─── palette ─────────────────────────────────────────────────────────────────
const C_BG     := Color("#0a0a0a")
const C_CREAM  := Color("#FAEEDA")
const C_DARK   := Color("#1a1208")
const C_BROWN  := Color("#3a2a14")
const C_PARCH  := Color("#F5E9CC")
const C_BLOOD  := Color("#993C1D")
const C_GOLD   := Color("#BA7517")
const C_GLOW   := Color("#FAC775")
const C_GREEN  := Color("#0F6E56")
const C_BLUE   := Color("#5DADE2")

# ─── input state ─────────────────────────────────────────────────────────────
var _keys     := {}   # currently held key names
var _pressed  := {}   # keys pressed this frame (consumed each _process)

# ─── game world state ────────────────────────────────────────────────────────
var _elapsed     := 0.0
var _mouse       := Vector2(340, 200)
var _hover_hs    = null   # hovered hotspot dict or null
var _near_hs     = null   # nearest hotspot dict or null

# ─── modal state (drawn in _draw, blocks game updates) ───────────────────────
var _modal       := {}    # empty = no modal
var _modal_scroll := 0.0
var _modal_btns  := []    # Array of {rect: Rect2, action: Callable}
var _modal_tab   := ""    # diary tab id
var _modal_sel   := ""    # accusation selection

# ─── HUD click regions ───────────────────────────────────────────────────────
var _hud_btns    := []    # same format as _modal_btns
var _exit_btns   := []

# ─── fonts ───────────────────────────────────────────────────────────────────
var _font: Font

# ─── wesen art cache ──────────────────────────────────────────────────────────
var _wesen_tex: Dictionary = {}   # wid -> Texture2D or null
var _diary_art_mode := true       # true = show illustration, false = show text stats

# ─── random encounter ─────────────────────────────────────────────────────────
const ENCOUNTER_POOL := ["blutbad", "jagerbar", "klaustreich", "coyotl", "fuchsbau"]
var _encounter_timer := 0.0
var _active_evid: Dictionary = {}   # scene_id -> active evidence hotspot id ("" = none)

# ─── debug ────────────────────────────────────────────────────────────────────
var _dbg_wheel_clicks    := 0
var _dbg_wheel_last_time := -999.0

# ─── scene / sheet texture caches ─────────────────────────────────────────────
var _bg_tex:    Dictionary = {}   # bg_key -> Texture2D or null
var _sheet_tex: Dictionary = {}   # sheet_name -> Texture2D or null

func _get_wesen_tex(wid: String) -> Texture2D:
	if _wesen_tex.has(wid):
		return _wesen_tex[wid]
	var path := "res://assets/wesen/%s.png" % wid
	var tex: Texture2D = null
	if FileAccess.file_exists(path):
		tex = load(path) as Texture2D
	_wesen_tex[wid] = tex
	return tex

func _get_bg_tex(bg: String) -> Texture2D:
	if _bg_tex.has(bg):
		return _bg_tex[bg]
	var path := "res://assets/backgrounds/%s.png" % bg
	var tex: Texture2D = null
	if FileAccess.file_exists(path):
		tex = load(path) as Texture2D
	_bg_tex[bg] = tex
	return tex

func _get_sheet_tex(sheet: String) -> Texture2D:
	if _sheet_tex.has(sheet):
		return _sheet_tex[sheet]
	var path := "res://assets/sheets/%s.png" % sheet
	var tex: Texture2D = null
	if FileAccess.file_exists(path):
		tex = load(path) as Texture2D
	_sheet_tex[sheet] = tex
	return tex

func _ready() -> void:
	_font = ThemeDB.fallback_font
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_encounter_timer = randf_range(45.0, 80.0)
	_enter_scene(GameState.scene)

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# ─── scene entry ─────────────────────────────────────────────────────────────
func _enter_scene(sid: String) -> void:
	GameState.scene = sid
	var s: Dictionary = Data.SCENES[sid]
	var sp: Array = s["spawn"]
	GameState.pc = {
		"x": float(sp[0]), "y": float(sp[1]),
		"tx": float(sp[0]), "ty": float(sp[1]),
		"facing": 1, "anim": 0.0,
		"walking": false, "pending_interact": "",
	}
	_hover_hs = null
	_near_hs  = null
	_modal    = {}
	_roll_active_evid(sid)
	_rebuild_exit_btns()
	queue_redraw()

func _roll_active_evid(sid: String) -> void:
	var pool: Array = []
	for h: Dictionary in Data.SCENES[sid].get("hotspots", []):
		if h.get("interact", "").begins_with("evid:"):
			pool.append(h["id"])
	for p: Dictionary in GameState.placed_objects.get(sid, []):
		if p.get("interact", "").begins_with("evid:"):
			pool.append(p.get("item_id", p.get("slot", "")))
	if pool.is_empty() or randf() < 0.2:
		_active_evid[sid] = ""
	else:
		_active_evid[sid] = pool[randi() % pool.size()]

func _rebuild_exit_btns() -> void:
	_exit_btns.clear()
	var exits: Array = _available_exits()
	var total := exits.size()
	if total == 0:
		return
	var btn_w := 160.0
	var gap   := 10.0
	var start_x := (W - (total * btn_w + (total - 1) * gap)) / 2.0
	var y     := H - 36.0
	for i in total:
		var e: Dictionary = exits[i]
		var rx := start_x + i * (btn_w + gap)
		_exit_btns.append({"rect": Rect2(rx, y, btn_w, 28), "exit": e})

func _available_exits() -> Array:
	var s: Dictionary = Data.SCENES[GameState.scene]
	var result := []
	for e in s.get("exits", []):
		var req: String = e.get("requires", "")
		if req == "" or GameState.player.get("contract", "") == req:
			result.append(e)
	return result

# ─── main loop ────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	_elapsed += delta
	_mouse = get_local_mouse_position()

	if _modal.is_empty():
		_update_movement(delta)
		_update_hotspot_detection()
		# E key interaction
		if _pressed.get("e", false) and _near_hs:
			_trigger(_near_hs["interact"])
		# Random encounter countdown — only outside hub with an active contract
		if GameState.scene != "hub" and not GameState.player.get("contract", "").is_empty():
			_encounter_timer -= delta
			if _encounter_timer <= 0.0:
				_trigger_encounter()
	else:
		# Keyboard scroll when modal is open (held keys = smooth, ~180px/s)
		if _keys.get("up", false) or _keys.get("w", false):
			_modal_scroll = max(0.0, _modal_scroll - 300.0 * delta)
		if _keys.get("down", false) or _keys.get("s", false):
			_modal_scroll += 300.0 * delta

	queue_redraw()
	_pressed.clear()

func _update_movement(delta: float) -> void:
	var p := GameState.pc
	var kx := 0.0
	var ky := 0.0
	if _keys.get("a", false) or _keys.get("left", false): kx -= 1.0
	if _keys.get("d", false) or _keys.get("right", false): kx += 1.0
	if _keys.get("w", false) or _keys.get("up", false):    ky -= 1.0
	if _keys.get("s", false) or _keys.get("down", false):  ky += 1.0

	if kx != 0.0 or ky != 0.0:
		var sp := SPEED * delta
		p["x"] += kx * sp; p["y"] += ky * sp
		if kx != 0.0: p["facing"] = 1 if kx > 0.0 else -1
		if not p.get("walking", false): p["anim"] = 0.0  # start cycle from frame 0
		p["walking"] = true
		p["tx"] = p["x"]; p["ty"] = p["y"]
		p["pending_interact"] = ""
	elif p["walking"]:
		var dx: float = p["tx"] - p["x"]
		var dy: float = p["ty"] - p["y"]
		var dist := sqrt(dx * dx + dy * dy)
		if dist < 3.0:
			p["x"] = p["tx"]; p["y"] = p["ty"]
			p["walking"] = false
			var pending: String = p["pending_interact"]
			if pending != "":
				p["pending_interact"] = ""
				_trigger(pending)
		else:
			var sp := SPEED * delta
			p["x"] += dx / dist * sp
			p["y"] += dy / dist * sp

	# Floor clamp
	var f: Array = Data.SCENES[GameState.scene]["floor"]
	p["x"] = clamp(p["x"], float(f[0]), float(f[2]))
	p["y"] = clamp(p["y"], float(f[1]), float(f[3]))

	if p["walking"] or kx != 0.0 or ky != 0.0:
		p["anim"] = p.get("anim", 0.0) + delta * 8.0

func _effective_hotspots() -> Array:
	var s: Dictionary = Data.SCENES[GameState.scene]
	var hs: Array = s["hotspots"].duplicate()
	var bg: String = s.get("bg", "")
	var slots: Dictionary = Data.SCENE_TEMPLATES.get(bg, {}).get("slots", {})
	for p: Dictionary in GameState.placed_objects.get(GameState.scene, []):
		var slot_id: String = p.get("slot", "")
		if not slots.has(slot_id):
			continue
		var slot: Dictionary = slots[slot_id]
		var pos: Array = slot["pos"]
		hs.append({
			"id":       p.get("item_id", slot_id),
			"x":        pos[0],
			"y":        pos[1],
			"r":        float(slot.get("r", 28)),
			"name":     p.get("label", ""),
			"interact": p.get("interact", ""),
			"stand_x":  pos[0],
			"stand_y":  pos[1] + 30.0,
		})
	# Only one evidence hotspot visible per visit
	var active: String = _active_evid.get(GameState.scene, "")
	hs = hs.filter(func(h: Dictionary) -> bool:
		return not h.get("interact", "").begins_with("evid:") or h["id"] == active)
	return hs

func _update_hotspot_detection() -> void:
	var p := GameState.pc
	var px: float = p["x"]; var py: float = p["y"]
	var all_hs := _effective_hotspots()

	# Mouse hover
	_hover_hs = null
	for h: Dictionary in all_hs:
		var dx: float = _mouse.x - float(h["x"])
		var dy: float = _mouse.y - float(h["y"])
		if dx * dx + dy * dy < float(h["r"]) * float(h["r"]):
			_hover_hs = h
			break

	# Proximity (E key)
	_near_hs = null
	var best := NEAR_DIST * NEAR_DIST
	for h: Dictionary in all_hs:
		var dx := px - float(h["x"])
		var dy := py - float(h["y"])
		var d2 := dx * dx + dy * dy
		if d2 < best:
			best = d2
			_near_hs = h

# ─── input handling ──────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := _kname(event.keycode)
		if k.is_empty():
			return
		if event.pressed and not event.echo:
			if not _keys.get(k, false):
				_pressed[k] = true
			_keys[k] = true
		elif not event.pressed:
			_keys.erase(k)

		if event.pressed and event.keycode == KEY_ESCAPE and not _modal.is_empty():
			_modal = {}
			_modal_btns.clear()
			queue_redraw()
			get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_handle_click(get_local_mouse_position())
			MOUSE_BUTTON_WHEEL_UP:
				if not _modal.is_empty():
					_modal_scroll = max(0.0, _modal_scroll - 100.0)
					queue_redraw()
					get_viewport().set_input_as_handled()
			MOUSE_BUTTON_WHEEL_DOWN:
				if not _modal.is_empty():
					_modal_scroll += 100.0
					queue_redraw()
					get_viewport().set_input_as_handled()

func _kname(kc: Key) -> String:
	match kc:
		KEY_A:      return "a"
		KEY_D:      return "d"
		KEY_W:      return "w"
		KEY_S:      return "s"
		KEY_J:      return "j"
		KEY_K:      return "k"
		KEY_E:      return "e"
		KEY_LEFT:   return "left"
		KEY_RIGHT:  return "right"
		KEY_UP:     return "up"
		KEY_DOWN:   return "down"
		KEY_ESCAPE: return "escape"
	return ""

func _handle_click(pos: Vector2) -> void:
	# Modal buttons first
	if not _modal.is_empty():
		for b: Dictionary in _modal_btns:
			if b["rect"].has_point(pos):
				b["action"].call()
				return
		return

	# HUD buttons
	for b: Dictionary in _hud_btns:
		if b["rect"].has_point(pos):
			b["action"].call()
			return

	# Exit buttons
	for b: Dictionary in _exit_btns:
		if b["rect"].has_point(pos):
			_enter_scene(b["exit"]["to"])
			return

	# Secret debug trigger: click either carriage wheel 4× within 2s → fight
	# Wheel positions match horse_hub_clean.png at Rect2(45,165,260,145)
	if GameState.scene == "hub":
		var lw := Vector2(66, 279)
		var rw := Vector2(116, 280)
		if pos.distance_to(lw) < 18 or pos.distance_to(rw) < 18:
			if _elapsed - _dbg_wheel_last_time > 2.0:
				_dbg_wheel_clicks = 0
			_dbg_wheel_clicks += 1
			_dbg_wheel_last_time = _elapsed
			if _dbg_wheel_clicks >= 4:
				_dbg_wheel_clicks = 0
				_show_accusation()
			return

	# Hotspot click → walk to stand point
	var s: Dictionary = Data.SCENES[GameState.scene]
	for h: Dictionary in _effective_hotspots():
		var dx: float = pos.x - float(h["x"])
		var dy: float = pos.y - float(h["y"])
		if dx * dx + dy * dy < float(h["r"]) * float(h["r"]):
			var p := GameState.pc
			p["tx"] = float(h["stand_x"]); p["ty"] = float(h["stand_y"])
			p["anim"] = 0.0
			p["walking"] = true
			p["pending_interact"] = h["interact"]
			p["facing"] = 1 if float(h["x"]) > p["x"] else -1
			return

	# Floor walk
	var f: Array = s["floor"]
	if pos.x >= float(f[0]) and pos.x <= float(f[2]) and \
	   pos.y >= float(f[1]) and pos.y <= float(f[3]):
		var p := GameState.pc
		p["tx"] = pos.x; p["ty"] = pos.y
		p["anim"] = 0.0
		p["walking"] = true
		p["pending_interact"] = ""
		p["facing"] = 1 if pos.x > p["x"] else -1

# ─── interaction dispatch ─────────────────────────────────────────────────────
func _trigger(action: String) -> void:
	if   action == "enter_trailer": _show_trailer()
	elif action == "rest":          _show_rest()
	elif action == "contracts":     _show_contracts()
	elif action.begins_with("evid:"): _examine_evidence(action.substr(5))

func _examine_evidence(eid: String) -> void:
	var ev: Dictionary = Data.EVIDENCE[eid]
	var pl := GameState.player
	if not eid in pl["evidence"]:
		pl["evidence"].append(eid)
	_open_modal("evidence_detail", {
		"title": ev["name"],
		"eyebrow": "You bend close",
		"body": ev["detail"],
		"red_herring": ev.get("red_herring", false),
		"eid": eid,
	})
	GameState.save()

func _show_trailer() -> void:
	var pl := GameState.player
	_open_modal("simple", {
		"title": "Aunt Marie's trailer",
		"eyebrow": "A small kingdom of ink",
		"body": "Books, weapons, ink.\n\nHunts: %d  ·  Level: %d  ·  XP: %d" % [pl["hunts"], pl["level"], pl["xp"]],
		"buttons": [
			{"label": "Read the diary", "action": _show_diary},
			{"label": "Close"},
		]
	})

func _show_rest() -> void:
	var pl := GameState.player
	pl["hp"] = pl["max_hp"]
	pl["stam"] = pl["max_stam"]
	_open_modal("simple", {
		"title": "Rest at the fire",
		"eyebrow": "A small kindness",
		"body": "You sit. The fire is warm.\nVigor fully restored.",
		"buttons": [{"label": "Stand", "action": null}]
	})
	GameState.save()

func _show_contracts() -> void:
	if _modal_tab.is_empty() or not Data.HUNTS.has(_modal_tab):
		_modal_tab = Data.HUNTS.keys()[0]
	_open_modal("contracts", {})

func _show_diary() -> void:
	if _modal_tab.is_empty():
		_modal_tab = "blutbad"
	_open_modal("diary", {"tab": _modal_tab})

func _show_evidence_list() -> void:
	_open_modal("evidence_list", {})

func _trigger_encounter() -> void:
	_encounter_timer = randf_range(50.0, 100.0)
	var contract: String = GameState.player.get("contract", "")
	if contract.is_empty() or not Data.HUNTS.has(contract):
		return
	var true_killer: String = Data.HUNTS[contract]["true_killer"]
	var pool: Array = ENCOUNTER_POOL.filter(func(wid: String) -> bool: return wid != true_killer)
	var wid: String = pool[randi() % pool.size()]
	var wesen_name: String = Data.WESEN[wid]["name"]
	var fight_fn := func():
		_close_modal()
		GameState.pending_combat = {"wid": wid, "correct": false, "is_encounter": true}
		SceneNav.go_combat()
	_open_modal("simple", {
		"title": "Something in the dark",
		"eyebrow": "An encounter",
		"body": "A %s has caught your scent. There is no talking your way clear of this." % wesen_name,
		"buttons": [{"label": "Draw steel", "primary": true, "blood": true, "action": fight_fn}],
	})

func _show_accusation() -> void:
	_modal_sel = ""
	_open_modal("accusation", {})

func _open_modal(kind: String, data: Dictionary) -> void:
	_modal = data.duplicate()
	_modal["_kind"] = kind
	_modal_scroll = 0.0
	_modal_btns.clear()
	queue_redraw()

# ─── DRAW ─────────────────────────────────────────────────────────────────────
func _draw() -> void:
	_draw_background()
	_draw_bg_fx()
	_draw_objects()
	_draw_hotspots()
	_draw_player()
	_draw_lantern_vignette()
	_draw_hud()
	_draw_exits()
	if not _modal.is_empty():
		_draw_modal()
	_draw_cursor()  # always last so it's on top of everything

func _draw_bg_fx() -> void:
	var bg: String = Data.SCENES[GameState.scene].get("bg", "")
	if not _get_bg_tex(bg):
		return
	var t := _elapsed
	match bg:
		"campsite_night":
			# Star twinkles over the painted sky
			for i in 28:
				var sx := fmod(float(i) * 137.508, W)
				var sy := fmod(float(i) * 89.31, 200.0)
				var tw: float = 0.0 + 0.55 * abs(sin(t * (0.4 + float(i) * 0.07) + float(i)))
				draw_circle(Vector2(sx, sy), 0.9, Color(1.0, 0.97, 0.88, tw))
			# Smoke rising from campfire hotspot
			var s: Dictionary = Data.SCENES[GameState.scene]
			var cf_x := 340.0; var cf_y := 292.0
			for h: Dictionary in s["hotspots"]:
				if h["id"] == "campfire":
					cf_x = float(h["x"]); cf_y = float(h["y"])
					break
			for i in 7:
				var pt := fmod(t * 0.6 + float(i) * 0.9, 1.0)
				var sx2 := cf_x + sin(t * 1.2 + float(i) * 1.7) * 5.0
				var sy2 := cf_y - 38.0 - pt * 55.0
				var alpha := (1.0 - pt) * 0.18
				draw_circle(Vector2(sx2, sy2), 3.5 + pt * 5.0, Color(0.7, 0.65, 0.6, alpha))

func _draw_objects() -> void:
	var bg: String = Data.SCENES[GameState.scene].get("bg", "")
	var template: Dictionary = Data.SCENE_TEMPLATES.get(bg, {})
	var slots: Dictionary = template.get("slots", {})
	var placements: Array = GameState.placed_objects.get(GameState.scene, [])
	for p: Dictionary in placements:
		var slot_id: String = p.get("slot", "")
		if not slots.has(slot_id):
			continue
		var slot: Dictionary = slots[slot_id]
		var item: Dictionary = Data.OBJECT_POOL.get(p.get("item_id", ""), {})
		if item.is_empty():
			continue
		var sheet_tex := _get_sheet_tex(item["sheet"])
		if not sheet_tex:
			continue
		var s: Array = item["src"]
		var pos: Array = slot["pos"]
		var sz: Array = slot["size"]
		var dest := Rect2(pos[0] - sz[0] * 0.5, pos[1] - sz[1] * 0.5, sz[0], sz[1])
		draw_texture_rect_region(sheet_tex, dest, Rect2(s[0], s[1], s[2], s[3]))

# ── backgrounds ───────────────────────────────────────────────────────────────
func _draw_background() -> void:
	var bg: String = Data.SCENES[GameState.scene].get("bg", "")
	var tex := _get_bg_tex(bg)
	if tex:
		draw_texture_rect(tex, Rect2(0, 0, W, H), false)
		return
	var t := _elapsed
	match bg:
		"campsite_night":
			draw_rect(Rect2(0,0,W,250), Color("#1a2540"))
			# Stars — twinkling
			for i in 55:
				var sx := fmod(float(i) * 137.508, W)
				var sy := fmod(float(i) * 89.31, 220.0)
				var tw: float = 0.35 + 0.65 * abs(sin(t * (0.4 + float(i) * 0.07) + float(i)))
				draw_circle(Vector2(sx, sy), 0.8, Color(1.0, 0.97, 0.88, tw))
			# Moon + shadow bite
			draw_circle(Vector2(560,55), 18, Color(0.98,0.93,0.85,0.85))
			draw_circle(Vector2(556,52), 18, Color("#1a2540"))
			# Distant hill silhouette
			var hill_pts := PackedVector2Array([Vector2(0,250)])
			for i in range(0, int(W)+1, 18):
				hill_pts.append(Vector2(float(i), 236.0 + sin(float(i)/90.0)*8.0 + cos(float(i)/37.0)*4.0))
			hill_pts.append(Vector2(W,250))
			draw_colored_polygon(hill_pts, Color("#111d0e"))
			# Trees — varied heights
			for i in 10:
				var x := 10.0 + i * 70
				var th := 28.0 + fmod(float(i) * 17.3, 18.0)
				var tree_r := 18.0 + fmod(float(i) * 5.1, 8.0)
				draw_rect(Rect2(x+10, 248-th, 8, th+2), Color("#0d1408"))
				_draw_ellipse(Vector2(x+14, 246-th), tree_r, tree_r+8.0, Color("#0d1408"))
			draw_rect(Rect2(0,250,W,H-250), Color("#2a1f15"))
			# Ground fog wisps
			for i in 5:
				var fx := float(i) * 138.0 + sin(t * 0.4 + float(i)) * 14.0
				var fw := 130.0 + sin(t * 0.28 + float(i) * 1.5) * 22.0
				draw_rect(Rect2(fx - fw*0.5, 246, fw, 15), Color(0.7, 0.82, 1.0, 0.06))

		"forest_clearing":
			draw_rect(Rect2(0,0,W,250), Color("#0d1828"))
			# Stars
			for i in 40:
				var sx := fmod(float(i) * 137.508, W)
				var sy := fmod(float(i) * 89.31, 210.0)
				var tw: float = 0.3 + 0.7 * abs(sin(t * (0.33 + float(i) * 0.09) + float(i) * 2.1))
				draw_circle(Vector2(sx, sy), 0.8, Color(1.0, 0.97, 0.88, tw))
			# Trees — varied
			for i in 12:
				var x := float(i * 60) - 10.0
				var th := 30.0 + fmod(float(i) * 19.7, 20.0)
				var tree_r := 18.0 + fmod(float(i) * 4.3, 10.0)
				draw_rect(Rect2(x+12, 248-th, 8, th+2), Color("#0a0d05"))
				_draw_ellipse(Vector2(x+16, 244-th), tree_r, tree_r+10.0, Color("#0a0d05"))
			draw_rect(Rect2(0,250,W,H-250), Color("#1a1408"))
			# Fireflies — drifting animated dots
			for i in 8:
				var ft := t * 0.7 + float(i) * 1.57
				var fx := 40.0 + fmod(float(i) * 82.3, W - 80.0) + sin(ft * 0.8) * 28.0
				var fy := 172.0 + sin(ft * 1.1 + float(i)) * 38.0
				var gw: float = max(0.0, sin(t * 1.8 + float(i) * 2.3))
				if gw > 0.15:
					draw_circle(Vector2(fx, fy), 1.4, Color(0.65, 1.0, 0.35, gw * 0.9))
					draw_circle(Vector2(fx, fy), 3.5, Color(0.65, 1.0, 0.35, gw * 0.18))
			# Ground mist
			for i in 5:
				var mx := float(i) * 138.0 + sin(t * 0.35 + float(i)) * 12.0
				var mw := 150.0 + sin(t * 0.22 + float(i) * 1.2) * 28.0
				draw_rect(Rect2(mx - mw * 0.5, 244, mw, 18), Color(0.75, 0.85, 1.0, 0.06))

		"forest_path":
			draw_rect(Rect2(0,0,W,250), Color("#0d1828"))
			# Stars
			for i in 35:
				var sx := fmod(float(i) * 137.508, W)
				var sy := fmod(float(i) * 89.31, 200.0)
				var tw: float = 0.3 + 0.7 * abs(sin(t * (0.45 + float(i) * 0.06) + float(i)))
				draw_circle(Vector2(sx, sy), 0.75, Color(1.0, 0.97, 0.88, tw))
			# Dense trees
			for i in 14:
				var x := -10.0 + i * 50
				draw_rect(Rect2(x+10,200,8,50), Color("#0a0d05"))
				_draw_ellipse(Vector2(x+14,190), 18, 28, Color("#0a0d05"))
			draw_rect(Rect2(0,200,W,40), Color("#1a1408"))
			# Path — layered for depth
			var path_pts := PackedVector2Array([
				Vector2(0,290), Vector2(340,260), Vector2(W,300),
				Vector2(W,360), Vector2(0,360)
			])
			draw_colored_polygon(path_pts, Color("#3a2a14"))
			# Packed-earth centre strip
			var path_hi := PackedVector2Array([
				Vector2(120,296), Vector2(340,264), Vector2(555,303),
				Vector2(555,332), Vector2(120,324)
			])
			draw_colored_polygon(path_hi, Color("#4a3520"))
			# Ruts
			draw_line(Vector2(175,313), Vector2(390,273), Color("#2a1a0a"), 1.5)
			draw_line(Vector2(260,322), Vector2(445,282), Color("#2a1a0a"), 1.5)
			# Fallen leaves
			for i in 9:
				var lx := 80.0 + fmod(float(i) * 73.1, 520.0)
				var ly := 290.0 + fmod(float(i) * 17.3, 58.0)
				draw_circle(Vector2(lx, ly), 2.5, Color(0.45, 0.27, 0.08, 0.75))
			# Ground mist at path edges
			for i in 4:
				var mx := float(i) * 178.0 + sin(t * 0.3 + float(i)) * 10.0
				draw_rect(Rect2(mx, 254, 185, 12), Color(0.7, 0.8, 1.0, 0.05))

		"cottage_interior":
			draw_rect(Rect2(0,0,W,260), Color("#3a2a14"))
			# Ceiling beams
			for i in 3:
				var bx := 50.0 + float(i) * 195.0
				draw_rect(Rect2(bx, 0, 22, 260), Color("#241a0a"))
				draw_rect(Rect2(bx+2, 0, 4, 260), Color(1.0, 0.9, 0.6, 0.04))
			# Back-wall plank lines
			for i in 8:
				draw_line(Vector2(0, 22.0 + float(i) * 30.0), Vector2(W, 22.0 + float(i) * 30.0), Color(0,0,0,0.08), 1)
			# Shelf + jars (left wall)
			draw_rect(Rect2(10, 122, 55, 6), Color("#241a0a"))
			draw_rect(Rect2(14, 98, 10, 24), Color("#1a1208"))
			draw_rect(Rect2(30, 102, 8, 20), Color("#3a5a30"))
			draw_rect(Rect2(44, 104, 12, 18), Color("#5a3a14"))
			draw_rect(Rect2(16, 96, 6, 3), Color(1.0,0.9,0.8,0.2))
			draw_rect(Rect2(46, 102, 5, 3), Color(1.0,0.9,0.8,0.2))
			# Window
			draw_rect(Rect2(60,80,80,100), Color("#0d1828"))
			draw_circle(Vector2(100,110), 20, Color(0.98,0.93,0.85,0.18))
			draw_circle(Vector2(100,110), 11, Color(0.98,0.93,0.85,0.38))
			draw_line(Vector2(100,80), Vector2(100,180), Color("#5a4630"), 2)
			draw_line(Vector2(60,130), Vector2(140,130), Color("#5a4630"), 2)
			draw_rect(Rect2(60,80,80,100), Color("#5a4630"), false, 2)
			# Moonlight pool on floor
			var pool := PackedVector2Array([Vector2(55,260),Vector2(145,260),Vector2(190,H),Vector2(0,H)])
			draw_colored_polygon(pool, Color(0.98,0.93,0.85,0.045))
			# Fireplace opening + mantel
			draw_rect(Rect2(375,135,110,12), Color("#2a1f0e"))
			draw_rect(Rect2(380,140,100,120), Color("#1a1208"))
			# Fire glow on wall (animated radius)
			var glow_r := 65.0 + sin(t * 3.1) * 6.0
			draw_circle(Vector2(430,195), glow_r, Color(0.85, 0.32, 0.08, 0.07))
			var flick := sin(t * 6.0) * 2.0
			_draw_bezier_fill(
				Vector2(415,240), Vector2(425, 200+flick), Vector2(430, 180+flick),
				Vector2(445,240), Color("#D85A30"))
			_draw_bezier_fill(
				Vector2(421,240), Vector2(428, 212+flick), Vector2(432, 196+flick),
				Vector2(440,240), Color("#FAC775"))
			# Embers
			for i in 5:
				var ex := 402.0 + fmod(float(i) * 19.3, 48.0)
				draw_circle(Vector2(ex, 237.0 + sin(t * 4.2 + float(i)) * 1.5), 1.1, Color(1.0, 0.5, 0.1, 0.85))
			# Candle on small table (right of fireplace)
			draw_rect(Rect2(318, 222, 22, 8), Color("#2a1f0e"))
			draw_rect(Rect2(325, 212, 8, 10), Color("#FAC775"))
			var cflick := sin(t * 8.7 + 1.2) * 1.5
			draw_circle(Vector2(329, 210 + cflick), 1.5, Color(1.0, 0.9, 0.5, 0.9))
			draw_circle(Vector2(329, 210 + cflick), 6.0, Color(1.0, 0.8, 0.3, 0.11))
			# Floor boards
			draw_rect(Rect2(0,260,W,H-260), Color("#2a1f15"))
			for i in 4:
				draw_line(Vector2(0, 268.0 + float(i) * 14.0), Vector2(W, 268.0 + float(i) * 14.0), Color(0,0,0,0.12), 1)
			# Firelight tint on floor
			draw_rect(Rect2(340,260,200,H-260), Color(0.65, 0.28, 0.07, 0.06))

		"tavern_interior":
			draw_rect(Rect2(0,0,W,260), Color("#4a3620"))
			# Ceiling beams
			for i in 4:
				var bx := 20.0 + float(i) * 165.0
				draw_rect(Rect2(bx, 0, 18, 260), Color("#2a1808"))
				draw_rect(Rect2(bx+2, 0, 3, 260), Color(1.0,0.9,0.6,0.04))
			# Back-wall plank lines
			for i in 7:
				draw_line(Vector2(0, 30.0 + float(i) * 32.0), Vector2(W, 30.0 + float(i) * 32.0), Color(0,0,0,0.09), 1)
			# High window (right)
			draw_rect(Rect2(W-102, 38, 76, 90), Color("#0d1828"))
			draw_circle(Vector2(W-64, 73), 16, Color(0.98,0.93,0.85,0.18))
			draw_line(Vector2(W-64, 38), Vector2(W-64, 128), Color("#5a4630"), 2)
			draw_line(Vector2(W-102, 83), Vector2(W-26, 83), Color("#5a4630"), 2)
			draw_rect(Rect2(W-102,38,76,90), Color("#5a4630"), false, 2)
			# Hanging lantern
			draw_line(Vector2(W*0.5, 0), Vector2(W*0.5, 48), Color("#5a4630"), 2)
			draw_rect(Rect2(W*0.5-11, 48, 22, 30), Color("#BA7517"))
			draw_rect(Rect2(W*0.5-7,  52, 14, 22), Color("#0d1828"))
			var lflick := sin(t * 5.3) * 1.5
			draw_circle(Vector2(W*0.5, 63 + lflick), 3.0, Color(1.0, 0.86, 0.4, 0.9))
			draw_circle(Vector2(W*0.5, 63 + lflick), 26.0, Color(1.0, 0.7, 0.2, 0.06))
			# Bar counter (left)
			draw_rect(Rect2(60,235,180,30), Color("#3a2a14"))
			draw_rect(Rect2(60,233,180,5), Color("#4a3218"))
			# Bottles on bar
			var bottle_cols := [Color("#2a4510"), Color("#4a3218"), Color("#1a2540"), Color("#501313")]
			for i in 4:
				var bx2 := 74.0 + float(i) * 38.0
				draw_rect(Rect2(bx2, 208, 10, 27), bottle_cols[i])
				draw_rect(Rect2(bx2+3, 203, 4, 8), bottle_cols[i])
				draw_rect(Rect2(bx2+2, 205, 6, 3), Color(0.9,0.9,0.8,0.28))
			# Stools at bar
			for i in 3:
				var sx := 84.0 + float(i) * 55.0
				draw_rect(Rect2(sx-10, 248, 20, 5), Color("#5a4630"))
				draw_rect(Rect2(sx-7, 253, 14, 4), Color("#5a4630"))
				draw_rect(Rect2(sx-1, 257, 3, 9), Color("#3a2a14"))
			# Table (right)
			draw_rect(Rect2(422,218,158,11), Color("#3a2a14"))
			draw_rect(Rect2(422,216,158,5), Color("#4a3218"))
			draw_rect(Rect2(430,229,6,32), Color("#3a2a14"))
			draw_rect(Rect2(566,229,6,32), Color("#3a2a14"))
			# Tankard
			draw_rect(Rect2(466,204,18,15), Color("#888780"))
			draw_rect(Rect2(484,208,4,7), Color("#888780"))
			draw_rect(Rect2(468,201,14,5), Color(0.38,0.28,0.1,0.6))
			# Candle on table
			draw_rect(Rect2(540, 207, 7, 12), Color("#FAC775"))
			var tflick := sin(t * 7.3 + 0.5) * 1.5
			draw_circle(Vector2(543, 205 + tflick), 1.4, Color(1.0, 0.9, 0.5, 0.9))
			draw_circle(Vector2(543, 205 + tflick), 9.0, Color(1.0, 0.75, 0.2, 0.08))
			# Lantern light tint on ceiling
			draw_rect(Rect2(200, 0, 280, 80), Color(1.0, 0.75, 0.25, 0.04))
			# Floor — dark planks
			draw_rect(Rect2(0,260,W,H-260), Color("#854F0B"))
			for i in 4:
				draw_line(Vector2(0, 270.0 + float(i) * 14.0), Vector2(W, 270.0 + float(i) * 14.0), Color(0,0,0,0.18), 1)
			for i in 9:
				draw_line(Vector2(float(i) * 78.0, 260), Vector2(float(i) * 78.0, H), Color(0,0,0,0.09), 1)

		"mill_yard":
			# Overcast sky
			draw_rect(Rect2(0,0,W,260), Color("#5F5E5A"))
			# Clouds (slow drift)
			for i in 3:
				var cloud_x := 80.0 + float(i) * 220.0 + sin(t * 0.07 + float(i)) * 8.0
				var cloud_y := 38.0 + float(i) * 18.0
				_draw_ellipse(Vector2(cloud_x,      cloud_y),    55, 22, Color(0.86, 0.85, 0.83, 0.72))
				_draw_ellipse(Vector2(cloud_x+28,   cloud_y+6),  38, 18, Color(0.88, 0.87, 0.85, 0.68))
				_draw_ellipse(Vector2(cloud_x-24,   cloud_y+8),  30, 15, Color(0.84, 0.83, 0.81, 0.68))
			# Mill building
			draw_rect(Rect2(80,80,180,180), Color("#5a4630"))
			draw_rect(Rect2(80,80,180,180), Color("#3a2a14"), false, 2)
			var roof_pts := PackedVector2Array([Vector2(70,80),Vector2(170,22),Vector2(270,80)])
			draw_colored_polygon(roof_pts, Color("#3a2a14"))
			# Mill door
			draw_rect(Rect2(149,196,42,64), Color("#2a1f0e"))
			draw_rect(Rect2(149,196,42,64), Color("#3a2a14"), false, 1)
			draw_circle(Vector2(187,228), 2.5, Color("#BA7517"))
			# Mill window
			draw_rect(Rect2(96,120,40,40), Color("#0d1828"))
			draw_line(Vector2(116,120), Vector2(116,160), Color("#3a2a14"), 1)
			draw_line(Vector2(96,140), Vector2(136,140), Color("#3a2a14"), 1)
			draw_rect(Rect2(96,120,40,40), Color("#3a2a14"), false, 2)
			# Spinning wheel housing
			draw_rect(Rect2(420,120,140,140), Color("#0d1828"))
			var rot := t * 0.33
			for i in 8:
				var a := rot + float(i) * TAU / 8.0
				draw_line(
					Vector2(490,200) + Vector2(cos(a),sin(a)) * 14,
					Vector2(490,200) + Vector2(cos(a),sin(a)) * 55,
					Color("#3a2a14"), 3)
			draw_arc(Vector2(490,200), 55, 0, TAU, 32, Color("#3a2a14"), 3)
			draw_circle(Vector2(490,200), 8, Color("#5a4630"))
			# Grain sacks
			for i in 3:
				_draw_ellipse(Vector2(302.0 + float(i) * 35.0, 252), 14, 10, Color("#BA7517"))
				draw_line(Vector2(288.0 + float(i)*35, 252), Vector2(316.0 + float(i)*35, 252), Color("#3a2a14"), 1)
			# Wheat stalks at base
			for i in 12:
				var wx := 10.0 + float(i) * 58.0
				var wsway := sin(t * 0.55 + float(i)) * 3.0
				draw_line(Vector2(wx, 262), Vector2(wx + wsway, 236), Color("#BA7517"), 1.5)
				draw_circle(Vector2(wx + wsway, 233), 3.2, Color("#D4A017"))
			# Ground
			draw_rect(Rect2(0,260,W,H-260), Color("#5a4630"))
			for i in 4:
				draw_line(Vector2(0, 268.0 + float(i) * 12.0), Vector2(W, 268.0 + float(i) * 12.0), Color(0,0,0,0.1), 1)

		"river_bank":
			# Dusk sky
			draw_rect(Rect2(0,0,W,110), Color("#3a3a55"))
			draw_rect(Rect2(0,110,W,90), Color("#4a3842"))
			# Faint early stars
			for i in 20:
				var sx := fmod(float(i) * 137.508, W)
				var sy := fmod(float(i) * 89.31, 105.0)
				var tw: float = 0.2 + 0.4 * abs(sin(t * 0.6 + float(i)))
				draw_circle(Vector2(sx, sy), 0.6, Color(1.0, 0.95, 0.85, tw))
			# Distant treeline
			for i in 18:
				var x := float(i) * 40.0
				draw_rect(Rect2(x+8, 164, 6, 36), Color("#0d1820"))
				_draw_ellipse(Vector2(x+11, 157), 13, 17, Color("#0d1820"))
			# Rolling land
			var land_pts := PackedVector2Array([Vector2(0,200)])
			for i in range(0, int(W)+1, 20):
				land_pts.append(Vector2(float(i), 180.0 + sin(float(i)/60.0)*11.0 + cos(float(i)/25.0)*4.0))
			land_pts.append(Vector2(W,200))
			draw_colored_polygon(land_pts, Color("#1a3010"))
			# Water body
			draw_rect(Rect2(0,200,W,80), Color("#1a3048"))
			# Animated shimmer lines
			for i in 16:
				var wy := 210.0 + fmod(float(i) * 13.7, 65.0)
				var wx_s := fmod(float(i) * 37.3, W - 100.0)
				var ww := 28.0 + fmod(float(i) * 11.1, 55.0)
				var wa: float = 0.1 + 0.15 * abs(sin(t * 1.2 + float(i) * 0.8))
				var wsway := sin(t * 0.85 + float(i) * 0.5) * 1.5
				draw_line(Vector2(wx_s, wy + wsway), Vector2(wx_s + ww, wy + wsway + 0.5), Color(0.65, 0.8, 1.0, wa), 1.2)
			# Moon/lantern reflection column
			for i in 5:
				var ry := 212.0 + float(i) * 8.0
				var rw := 18.0 - float(i) * 2.0
				draw_line(
					Vector2(482.0 - rw, ry + sin(t * 1.5 + float(i)) * 1.5),
					Vector2(482.0 + rw, ry + sin(t * 1.5 + float(i)) * 1.5),
					Color(0.98, 0.93, 0.85, 0.22 - float(i) * 0.03), 1.5)
			# Reeds / cattails
			for i in 9:
				var rx := 25.0 + fmod(float(i) * 83.7, 220.0)
				var rh := 34.0 + fmod(float(i) * 11.3, 24.0)
				draw_line(Vector2(rx, 276), Vector2(rx + sin(t * 0.6 + float(i)) * 3.0, 276 - rh), Color("#27500A"), 1.5)
				draw_rect(Rect2(rx - 2, 276 - rh - 10, 4, 12), Color("#412402"))
			# Shore
			draw_rect(Rect2(0,260,W,H-260), Color("#c8a96e"))
			# Pebbles
			for i in 14:
				var px := fmod(float(i) * 71.3, W - 20.0)
				var py := 265.0 + fmod(float(i) * 13.7, 22.0)
				draw_circle(Vector2(px, py), 2.2 + fmod(float(i) * 3.1, 2.8), Color("#888780"))
		_:
			draw_rect(Rect2(0,0,W,H), C_BG)

# ── lantern vignette ──────────────────────────────────────────────────────────
const LANTERN_R    := 60.0    # bright radius around player
const REVEAL_DIST  := 72.0    # distance at which evidence hotspots become visible

func _player_dist_sq(h: Dictionary) -> float:
	var px: float = GameState.pc["x"]
	var py: float = GameState.pc["y"]
	var dx := px - float(h["x"])
	var dy := py - float(h["y"])
	return dx * dx + dy * dy

func _is_evidence_hs(h: Dictionary) -> bool:
	return h.get("interact", "").begins_with("evid:")

func _draw_lantern_vignette() -> void:
	var px: float = GameState.pc["x"]
	var py: float = GameState.pc["y"]
	const MAX_R   := 820.0
	const STEPS   := 36
	const MAX_DARK := 0.72
	var step := (MAX_R - LANTERN_R) / float(STEPS)
	for i in range(STEPS + 1):
		var t := float(i) / float(STEPS)
		draw_arc(Vector2(px, py), LANTERN_R + step * float(i), 0, TAU, 52,
			Color(0.0, 0.0, 0.0, MAX_DARK * t * t), step * 1.35)
	# Warm glow ring at lantern edge
	draw_arc(Vector2(px, py), LANTERN_R, 0, TAU, 52,
		Color(0.95, 0.75, 0.35, 0.18), 14.0)

# ── hotspots ──────────────────────────────────────────────────────────────────
func _draw_hotspots() -> void:
	for h: Dictionary in _effective_hotspots():
		_draw_hotspot_prop(h)

	# Hover ring (hidden for evidence hotspots outside lantern range)
	if _hover_hs and (not _is_evidence_hs(_hover_hs) or _player_dist_sq(_hover_hs) <= REVEAL_DIST * REVEAL_DIST):
		var pulse := 0.4 + 0.3 * sin(_elapsed * TAU / 0.6)
		var hx := float(_hover_hs["x"]); var hy := float(_hover_hs["y"])
		var hr := float(_hover_hs["r"])
		draw_arc(Vector2(hx, hy), hr, 0, TAU, 32,
			Color(C_GLOW.r, C_GLOW.g, C_GLOW.b, pulse), 2.0)

	# Proximity ring (same gate)
	if _near_hs and _near_hs != _hover_hs and (not _is_evidence_hs(_near_hs) or _player_dist_sq(_near_hs) <= REVEAL_DIST * REVEAL_DIST):
		var hx := float(_near_hs["x"]); var hy := float(_near_hs["y"])
		var hr := float(_near_hs["r"])
		draw_arc(Vector2(hx, hy), hr, 0, TAU, 32,
			Color(C_BLUE.r, C_BLUE.g, C_BLUE.b, 0.3), 1.5)

func _draw_hotspot_prop(h: Dictionary) -> void:
	if _is_evidence_hs(h) and _player_dist_sq(h) > REVEAL_DIST * REVEAL_DIST:
		return
	var hid: String = h["id"]
	var x := float(h["x"]); var y := float(h["y"])
	const EVID_SCALE := 0.6
	if _is_evidence_hs(h):
		draw_set_transform(Vector2(x, y), 0.0, Vector2(EVID_SCALE, EVID_SCALE))
		x = 0.0; y = 0.0
	match hid:
		"trailer":
			var _horse_tex := _get_sheet_tex("horse_hub_clean")
			if _horse_tex:
				# horse_hub_clean.png 608×338: background-removed stagecoach + horses.
				# 260×145 display; carriage sits left of campfire, wheels at ~y=280.
				draw_texture_rect(_horse_tex, Rect2(45.0, 165.0, 260.0, 145.0), false)
			else:
				# Procedural fallback — original Aunt Marie's trailer (kept for reference)
				draw_set_transform(Vector2(x, y), 0.0, Vector2(1.5, 1.5))
				draw_rect(Rect2(-46,-6,92,8), Color("#484C52"))
				draw_circle(Vector2(-28,5), 9, Color("#222428"))
				draw_circle(Vector2(-28,5), 4, Color("#424650"))
				draw_circle(Vector2(28,5), 9, Color("#222428"))
				draw_circle(Vector2(28,5), 4, Color("#424650"))
				draw_rect(Rect2(-48,-44,96,40), Color("#B2B6BA"))
				_draw_ellipse(Vector2(-48,-24), 10, 20, Color("#B2B6BA"))
				_draw_ellipse(Vector2(48,-24), 10, 20, Color("#B2B6BA"))
				draw_rect(Rect2(-40,-44,80,11), Color("#D2D6DA"))
				_draw_ellipse(Vector2(-48,-38), 10, 6, Color("#C4C8CC"))
				_draw_ellipse(Vector2(48,-38), 10, 6, Color("#C4C8CC"))
				for ri in 5:
					draw_line(Vector2(-46, -38.0+float(ri)*6.0),
						Vector2(46, -38.0+float(ri)*6.0), Color("#8A9098"), 0.8)
				draw_circle(Vector2(-18,-28), 7, Color("#3a5878"))
				draw_circle(Vector2(-18,-28), 7, Color("#6A90B0"), false, 1.2)
				draw_circle(Vector2(-20,-30), 2.5, Color(1,1,1,0.28))
				draw_circle(Vector2(8,-28), 7, Color("#3a5878"))
				draw_circle(Vector2(8,-28), 7, Color("#6A90B0"), false, 1.2)
				draw_circle(Vector2(6,-30), 2.5, Color(1,1,1,0.28))
				draw_rect(Rect2(22,-40,15,36), Color("#8E9296"))
				draw_rect(Rect2(22,-40,15,36), Color("#76797E"), false, 1)
				draw_circle(Vector2(24,-22), 1.5, Color("#D0D4D8"))
				draw_rect(Rect2(-7,-44,14,5), Color("#C6CACC"))
				draw_rect(Rect2(-5,-47,10,4), Color("#9CA0A4"))
				draw_line(Vector2(-50,-7), Vector2(-61,-1), Color("#7A7E84"), 2)
				draw_circle(Vector2(-62,-1), 3, Color("#9CA0A4"))
				draw_set_transform(Vector2.ZERO)
		"campfire":
			var flick  := sin(_elapsed * 8.3) * 1.5
			var flick2 := sin(_elapsed * 11.7 + 1.2) * 1.2
			var h_outer: float = 16.0 + absf(sin(_elapsed * 5.1)) * 5.0
			var h_inner: float = 10.0 + absf(sin(_elapsed * 7.3 + 0.8)) * 3.5
			_draw_bezier_fill(Vector2(x-7,y),Vector2(x-4,y-h_outer*0.6+flick),Vector2(x+flick2,y-h_outer+flick),Vector2(x+7,y),Color("#D85A30"))
			_draw_bezier_fill(Vector2(x-4,y),Vector2(x-2,y-h_inner*0.6+flick),Vector2(x+flick2*0.5,y-h_inner+flick),Vector2(x+4,y),C_GLOW)
		"post":
			draw_set_transform(Vector2(x, y), 0.0, Vector2(0.75, 0.75))
			draw_rect(Rect2(-4,-60,8,60), C_BROWN)
			draw_rect(Rect2(-26,-55,52,5), C_BROWN)
			for i in 3:
				draw_rect(Rect2(-22+i*17,-50,14,16), C_PARCH)
			draw_set_transform(Vector2.ZERO)
		"body", "miller_body":
			draw_rect(Rect2(x-20,y-3,40,12), Color("#3a2a14"))
			draw_rect(Rect2(x-18,y-2,5,10), Color("#854F0B"))
			draw_rect(Rect2(x+13,y-2,5,10), Color("#854F0B"))
			_draw_ellipse(Vector2(x-22,y+3), 7, 5, Color("#5F5E5A"))
			_draw_ellipse(Vector2(x-15,y+10), 18, 4, Color("#501313"))
		"axe":
			draw_line(Vector2(x-15,y+8),Vector2(x+12,y-8),Color("#5a4630"),3)
			var blade := PackedVector2Array([Vector2(x+8,y-12),Vector2(x+18,y-8),Vector2(x+15,y-2),Vector2(x+5,y-6)])
			draw_colored_polygon(blade, Color("#888780"))
		"briar_fur":
			_draw_bezier_stroke(Vector2(x-15,y-15),Vector2(x,y),Vector2(x+15,y-12),Color("#3a2a14"),2)
			for i in 6:
				var a := float(i) * 1.04
				draw_line(Vector2(x,y), Vector2(x+cos(a)*6,y+sin(a)*6), Color("#888780"),1)
		"paw_print":
			_draw_ellipse(Vector2(x,y), 8, 10, C_DARK)
			_draw_ellipse(Vector2(x-7,y-8), 2.5, 3, C_DARK)
			_draw_ellipse(Vector2(x-3,y-11), 2.5, 3, C_DARK)
			_draw_ellipse(Vector2(x+3,y-11), 2.5, 3, C_DARK)
			_draw_ellipse(Vector2(x+7,y-8), 2.5, 3, C_DARK)
		"small_track":
			for i in 4:
				_draw_ellipse(Vector2(x-12+i*8, y+(i%2)*4), 3, 4, C_DARK)
		"broken_branch":
			draw_line(Vector2(x-20,y),Vector2(x-2,y+5),Color("#2a1f12"),4)
			draw_line(Vector2(x+5,y+8),Vector2(x+22,y+3),Color("#2a1f12"),4)
		"cloak_scrap":
			draw_line(Vector2(x-12,y-20),Vector2(x+12,y+15),Color("#412402"),2)
			var scrap := PackedVector2Array([Vector2(x-4,y-2),Vector2(x+8,y+8),Vector2(x+5,y+12),Vector2(x-7,y+4)])
			draw_colored_polygon(scrap, Color("#3a2a14"))
		"flour_print":
			_draw_ellipse(Vector2(x,y), 28, 15, C_PARCH)
			_draw_ellipse(Vector2(x,y+3), 14, 8, Color("#5a4630"))
			for i in 5:
				_draw_ellipse(Vector2(x-10+i*5,y-7), 2.5, 3, Color("#5a4630"))
		"cracked_beam":
			draw_rect(Rect2(x-30,y,60,12), C_BROWN)
			var crack := PackedVector2Array([Vector2(x-3,y),Vector2(x+4,y+12),Vector2(x-1,y+12),Vector2(x-5,y)])
			draw_colored_polygon(crack, C_BG)
		"bear_tooth":
			draw_line(Vector2(x-8,y),Vector2(x-2,y-3),Color("#5a4630"),1)
			var tooth := PackedVector2Array([Vector2(x-2,y-4),Vector2(x+3,y-2),Vector2(x+4,y+6),Vector2(x+1,y+8),Vector2(x-2,y+6),Vector2(x-4,y+1)])
			draw_colored_polygon(tooth, C_PARCH)
		"journal", "mill_journal":
			draw_rect(Rect2(x-20,y+5,40,18), Color("#5a4630"))
			draw_rect(Rect2(x-15,y-8,30,18), Color("#412402"))
			draw_rect(Rect2(x-13,y-6,28,14), C_PARCH)
			for i in 5:
				draw_line(Vector2(x-11,y-4+i*3),Vector2(x+11,y-4+i*3),Color("#5a4630"),0.5)
		"bed":
			draw_rect(Rect2(x-30,y-3,60,25), Color("#2a1f12"))
			draw_rect(Rect2(x-28,y-5,56,8), Color("#854F0B"))
			_draw_ellipse(Vector2(x-18,y-4), 8, 4, C_PARCH)
		"meal":
			draw_rect(Rect2(x-25,y,50,15), Color("#5a4630"))
			_draw_ellipse(Vector2(x,y-2), 18, 6, Color("#D3D1C7"))
			_draw_ellipse(Vector2(x-6,y-3), 5, 3, Color("#854F0B"))
			draw_rect(Rect2(x+2,y-5,8,5), C_GLOW)
		"drawing":
			draw_rect(Rect2(x-12,y-10,24,18), Color("#2C2C2A"))
			draw_rect(Rect2(x-14,y-12,28,3), Color("#5a4630"))
			draw_line(Vector2(x-7,y-4),Vector2(x-5,y+5),C_PARCH,1)
			draw_arc(Vector2(x+5,y-2), 2.5, 0, TAU, 12, C_PARCH, 1)
		"notice", "bailiff_notice":
			draw_rect(Rect2(x-12,y-15,24,30), C_BROWN)
			draw_rect(Rect2(x-9,y-12,18,24), C_PARCH)
			for i in 3:
				draw_line(Vector2(x-7,y-10+i*3),Vector2(x+7,y-10+i*3),C_DARK,1)
		"knife":
			draw_line(Vector2(x-8,y),Vector2(x+4,y-2),Color("#888780"),2)
			draw_rect(Rect2(x+4,y-3,4,4), C_BROWN)
		"scales":
			draw_rect(Rect2(x-2,y-5,4,15), C_BROWN)
			draw_rect(Rect2(x-12,y+10,24,4), Color("#5a4630"))
			draw_line(Vector2(x-14,y-5),Vector2(x+14,y-5),C_BROWN,2)
			_draw_ellipse(Vector2(x-14,y+2), 8, 3, Color("#888780"))
			_draw_ellipse(Vector2(x+14,y-1), 8, 3, Color("#888780"))
		"hearth":
			draw_rect(Rect2(x-15,y-15,30,28), C_DARK)
			draw_rect(Rect2(x-12,y-12,24,22), C_BROWN)
			_draw_ellipse(Vector2(x,y+6), 8, 3, Color("#5F5E5A"))
			draw_rect(Rect2(x-3,y-2,6,8), C_GOLD)
		"bank_tracks":
			for i in 3:
				var px := x - 15.0 + i * 15.0
				var py := y + float(i % 2) * 3.0
				_draw_ellipse(Vector2(px,py+2), 7, 4, Color("#412402"))
				for j in 5:
					_draw_ellipse(Vector2(px-5+j*2.5,py-3), 1.3, 1.8, Color("#412402"))
		"bank_fur":
			_draw_bezier_stroke(Vector2(x-8,y-15),Vector2(x,y),Vector2(x+8,y+15),Color("#27500A"),1.5)
			_draw_ellipse(Vector2(x,y), 8, 5, Color("#412402"))
		"scarecrow":
			draw_rect(Rect2(x-2,y-30,4,40), Color("#5a4630"))
			draw_rect(Rect2(x-20,y-20,40,3), Color("#5a4630"))
			draw_rect(Rect2(x-10,y-22,20,16), C_GLOW)
			draw_circle(Vector2(x,y-30), 7, C_PARCH)
		"fish_basket":
			_draw_ellipse(Vector2(x,y), 18, 8, Color("#854F0B"))
			for i in 3:
				_draw_ellipse(Vector2(x-12+i*10, y-2+float(i%2)*4), 7, 2.5, Color("#5F5E5A"))
		"hidden_purse":
			var purse := PackedVector2Array([Vector2(x-7,y-4),Vector2(x,y-8),Vector2(x+7,y-4),Vector2(x+8,y+5),Vector2(x,y+8),Vector2(x-8,y+5)])
			draw_colored_polygon(purse, Color("#412402"))
			draw_circle(Vector2(x+1,y-3), 1.5, C_GLOW)
		_: # Generic character (innkeeper, trapper, farmhand, etc.)
			var cloth := Color("#854F0B")
			match hid:
				"trapper":      cloth = Color("#27500A")
				"farmhand":     cloth = Color("#412402")
				"prentice":     cloth = Color("#888780")
				"wife_bed":     cloth = Color("#5a4630")
				"mill_drunkard":cloth = Color("#5F5E5A")
				"mill_innkeep": cloth = Color("#3a2a14")
			draw_rect(Rect2(x-6,y+18,5,15), C_DARK)
			draw_rect(Rect2(x+1,y+18,5,15), C_DARK)
			var body_pts := PackedVector2Array([Vector2(x-12,y+18),Vector2(x-10,y-12),Vector2(x+10,y-12),Vector2(x+12,y+18)])
			draw_colored_polygon(body_pts, cloth)
			draw_circle(Vector2(x,y-18), 8, C_PARCH)
			draw_arc(Vector2(x,y-22), 7, PI, TAU, 12, Color("#412402"))
			draw_circle(Vector2(x-3,y-18), 0.8, C_DARK)
			draw_circle(Vector2(x+3,y-18), 0.8, C_DARK)
	if _is_evidence_hs(h):
		draw_set_transform(Vector2.ZERO)

# ── player character ──────────────────────────────────────────────────────────
func _draw_player() -> void:
	var p := GameState.pc
	var px: float = p["x"]; var py: float = p["y"]
	var facing: int = p["facing"]
	var anim: float = p.get("anim", 0.0)
	var walking: bool = p["walking"]

	# medieval_sprite_grimm.png — 1024×590, FW=128, actual row bounds:
	# Row 0 (y=10,  h=146): profile walk cycle — walking / idle (8 frames, all clean)
	# Row 1 (y=165, h=145): combat stances     — near-hotspot (armed/ready)
	const FW     := 128.0
	const DISP_H := 72.0

	var tex := _get_sheet_tex("medieval_sprite_grimm")
	if not tex:
		# Procedural fallback
		var leg_off := sin(anim) * 5.0 if walking else 0.0
		draw_set_transform(Vector2(px, py), 0.0, Vector2(float(facing) * 1.6, 1.6))
		_draw_ellipse(Vector2(0, 2), 12, 3, Color(0, 0, 0, 0.4))
		draw_rect(Rect2(-5, -8 + leg_off, 4, 10), C_DARK)
		draw_rect(Rect2(1, -8 - leg_off, 4, 10), C_DARK)
		var cloak := PackedVector2Array()
		for i in range(5):
			var bt := float(i) / 4.0
			var bx := (1-bt)*(1-bt)*(-10.0) + 2*(1-bt)*bt*0.0 + bt*bt*10.0
			var by := (1-bt)*(1-bt)*(-32.0) + 2*(1-bt)*bt*(-37.0) + bt*bt*(-32.0)
			cloak.append(Vector2(bx, by))
		cloak.append(Vector2(8, -8)); cloak.append(Vector2(-8, -8))
		draw_colored_polygon(cloak, Color("#2a1f12"))
		_draw_ellipse(Vector2(0, -34), 7, 9, C_DARK)
		_draw_ellipse(Vector2(1, -34), 4, 5, C_BG)
		draw_circle(Vector2(2, -34), 0.8, C_CREAM)
		draw_line(Vector2(6, -24), Vector2(10, -6), Color("#888780"), 2)
		draw_rect(Rect2(5, -26, 3, 3), Color("#3a2a14"))
		draw_set_transform(Vector2.ZERO)
		return

	var y_start: float; var src_h: float
	var frame_idx: int

	if _near_hs != null and not walking:
		# Stopped at hotspot — combat-ready stance (row 1, frame 0)
		y_start = 165.0; src_h = 145.0
		frame_idx = 0
	elif walking:
		y_start = 10.0; src_h = 146.0
		frame_idx = int(anim) % 8
	else:
		# Idle: row 0 frame 0 (neutral standing)
		y_start = 10.0; src_h = 146.0
		frame_idx = 0

	var disp_w := FW / src_h * DISP_H
	var src    := Rect2(float(frame_idx) * FW, y_start, FW, src_h)

	_draw_ellipse(Vector2(px, py + 2.0), disp_w * 0.45, 4.0, Color(0, 0, 0, 0.4))
	draw_set_transform(Vector2(px, py), 0.0, Vector2(float(facing), 1.0))
	draw_texture_rect_region(tex, Rect2(-disp_w * 0.5, -DISP_H, disp_w, DISP_H), src)
	draw_set_transform(Vector2.ZERO)

# ── cursor ────────────────────────────────────────────────────────────────────
func _draw_cursor() -> void:
	var cx := _mouse.x; var cy := _mouse.y
	draw_line(Vector2(cx-6,cy), Vector2(cx-2,cy), C_CREAM, 1.2)
	draw_line(Vector2(cx+2,cy), Vector2(cx+6,cy), C_CREAM, 1.2)
	draw_line(Vector2(cx,cy-6), Vector2(cx,cy-2), C_CREAM, 1.2)
	draw_line(Vector2(cx,cy+2), Vector2(cx,cy+6), C_CREAM, 1.2)
	if _hover_hs:
		draw_arc(Vector2(cx,cy), 4, 0, TAU, 12, C_GLOW, 1)
		# Tooltip above cursor
		var lbl: String = _hover_hs["name"]
		_draw_tooltip(Vector2(cx+12, cy+12), lbl)

# ── HUD ───────────────────────────────────────────────────────────────────────
func _draw_hud() -> void:
	_hud_btns.clear()
	var pl := GameState.player

	# ── left card: scene + stats
	var scene_name: String = Data.SCENES[GameState.scene]["name"]
	_draw_card(Rect2(8,8,220,44))
	draw_string(_font, Vector2(16,22), scene_name, HORIZONTAL_ALIGNMENT_LEFT,-1,12,C_CREAM)
	var stats := "Vigor %d/%d  ·  Gold %d" % [pl["hp"], pl["max_hp"], pl["gold"]]
	draw_string(_font, Vector2(16,36), stats, HORIZONTAL_ALIGNMENT_LEFT,-1,11,C_CREAM)

	# ── right card: buttons
	var bx := W - 8.0
	# Accuse button (only when contract + enough evidence)
	var _contract: String = pl.get("contract", "")
	var _min: int = Data.HUNTS[_contract].get("min_clues", 4) if _contract != "" else 4
	if _contract != "" and pl["evidence"].size() >= _min:
		var rect := Rect2(bx-90, 10, 82, 20)
		bx -= 96
		_draw_hud_btn(rect, "Accuse", Color(C_BLOOD.r,C_BLOOD.g,C_BLOOD.b,0.35))
		_hud_btns.append({"rect": rect, "action": _show_accusation})

	var rect_ev := Rect2(bx-130,10,122,20); bx -= 136
	_draw_hud_btn(rect_ev, "Evidence (%d)" % pl["evidence"].size())
	_hud_btns.append({"rect": rect_ev, "action": _show_evidence_list})

	var rect_di := Rect2(bx-60,10,52,20)
	_draw_hud_btn(rect_di, "Diary")
	_hud_btns.append({"rect": rect_di, "action": _show_diary})

	# ── near-hotspot prompt (E key)
	if _near_hs and _modal.is_empty():
		var label: String = "[E]  " + str(_near_hs["name"])
		var pw := 240.0; var ph := 24.0
		var px := (W - pw) / 2.0; var py := H - 60.0
		draw_rect(Rect2(px,py,pw,ph), Color(0.08,0.06,0.04,0.92))
		draw_rect(Rect2(px,py,pw,ph), Color(0.98,0.93,0.85,0.3), false, 1)
		draw_string(_font, Vector2(px+8,py+16), label, HORIZONTAL_ALIGNMENT_LEFT,-1,12,C_CREAM)

func _draw_card(r: Rect2) -> void:
	draw_rect(r, Color(0.08,0.06,0.04,0.85))
	draw_rect(r, Color(0.98,0.93,0.85,0.2), false, 0.5)

func _draw_hud_btn(r: Rect2, label: String, bg_col := Color(0.98,0.93,0.85,0.15)) -> void:
	draw_rect(r, bg_col)
	draw_rect(r, Color(0.98,0.93,0.85,0.2), false, 0.5)
	draw_string(_font, Vector2(r.position.x+6, r.position.y+14), label,
		HORIZONTAL_ALIGNMENT_LEFT,-1,11,C_CREAM)

# ── exits ─────────────────────────────────────────────────────────────────────
func _draw_exits() -> void:
	for b: Dictionary in _exit_btns:
		var r: Rect2 = b["rect"]
		draw_rect(r, Color(0.08,0.06,0.04,0.85))
		draw_rect(r, Color(0.98,0.93,0.85,0.3), false, 0.5)
		draw_string(_font, Vector2(r.position.x+8, r.position.y+18),
			b["exit"]["label"], HORIZONTAL_ALIGNMENT_LEFT,-1,13,C_CREAM)

# ── tooltip ──────────────────────────────────────────────────────────────────
func _draw_tooltip(pos: Vector2, text: String) -> void:
	var tw: float = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT,-1,12).x + 18
	var r := Rect2(pos.x, pos.y, tw, 22)
	if r.end.x > W - 4: r.position.x = W - tw - 4
	if r.end.y > H - 4: r.position.y = pos.y - 28
	draw_rect(r, Color(0.08,0.06,0.04,0.88))
	draw_rect(r, Color(0.98,0.93,0.85,0.3), false, 0.5)
	draw_string(_font, Vector2(r.position.x+9, r.position.y+15), text,
		HORIZONTAL_ALIGNMENT_LEFT,-1,12,C_CREAM)

# ── modal drawing ─────────────────────────────────────────────────────────────
func _draw_modal() -> void:
	_modal_btns.clear()
	# Dark overlay
	draw_rect(Rect2(0,0,W,H), Color(0.04,0.03,0.02,0.78))

	var kind: String = _modal.get("_kind","simple")
	var panel := Rect2(50, 30, 580, 330)
	# Panel background
	draw_rect(panel, C_PARCH)
	draw_rect(panel, Color("#8a6f3d"), false, 1)

	# Clip content inside panel with scroll
	var cx := panel.position.x + 16.0
	var cy := panel.position.y + 16.0 - _modal_scroll
	var max_y := panel.end.y - 16.0

	match kind:
		"simple":     _draw_modal_simple(cx, cy, max_y, panel)
		"evidence_detail": _draw_modal_evid_detail(cx, cy, max_y, panel)
		"contracts":  _draw_modal_contracts(cx, cy, max_y, panel)
		"diary":      _draw_modal_diary(cx, cy, max_y, panel)
		"evidence_list":  _draw_modal_evidence_list(cx, cy, max_y, panel)
		"accusation": _draw_modal_accusation(cx, cy, max_y, panel)

func _modal_text(cx: float, cy_ref: float, text: String, size: int, col: Color, max_y: float) -> float:
	if cy_ref > max_y or cy_ref < 20.0:
		return cy_ref + size + 4
	draw_string(_font, Vector2(cx, cy_ref), text, HORIZONTAL_ALIGNMENT_LEFT, 540, size, col)
	return cy_ref + size + 6

func _modal_btn(cx: float, cy: float, label: String, w: float, action: Callable, primary := false, blood := false, mercy := false) -> float:
	var h := 26.0
	var r := Rect2(cx, cy, w, h)
	var bg := Color("#E8D9B2")
	if primary: bg = Color("#3a2a14")
	if blood:   bg = Color("#993C1D")
	if mercy:   bg = Color("#E1F5EE")
	draw_rect(r, bg)
	draw_rect(r, Color("#8a6f3d"), false, 0.5)
	var fc := Color("#3a2a14")
	if primary or blood: fc = C_PARCH
	if mercy: fc = Color("#0F6E56")
	draw_string(_font, Vector2(cx+8, cy+17), label, HORIZONTAL_ALIGNMENT_LEFT,-1,12,fc)
	_modal_btns.append({"rect": r, "action": action})
	return cy + h + 8

func _draw_modal_simple(cx: float, cy: float, max_y: float, _panel: Rect2) -> void:
	var eyebrow: String = _modal.get("eyebrow","")
	var title:   String = _modal.get("title","")
	var body:    String = _modal.get("body","")
	var buttons: Array  = _modal.get("buttons",[])
	var col_dark := Color("#3a2a14")
	var col_brow := Color("#8a6f3d")
	var cy2 := cy
	if eyebrow: cy2 = _modal_text(cx, cy2, eyebrow.to_upper(), 10, col_brow, max_y)
	cy2 = _modal_text(cx, cy2, title, 18, col_dark, max_y)
	cy2 += 4
	for line in body.split("\n"):
		cy2 = _modal_text(cx, cy2, line, 13, col_dark, max_y)
	cy2 += 8
	for b: Dictionary in buttons:
		var act: Callable
		if b.get("action") != null:
			act = b["action"]
		else:
			act = _close_modal
		cy2 = _modal_btn(cx, cy2, b["label"], 160, act,
			b.get("primary",false), b.get("blood",false), b.get("mercy",false))

func _draw_modal_evid_detail(cx: float, cy: float, max_y: float, _panel: Rect2) -> void:
	var col_dark := Color("#3a2a14")
	var col_brow := Color("#8a6f3d")
	var cy2 := cy
	cy2 = _modal_text(cx, cy2, "YOU BEND CLOSE", 10, col_brow, max_y)
	cy2 = _modal_text(cx, cy2, _modal.get("title",""), 18, col_dark, max_y)
	cy2 += 4
	for line in _modal.get("body","").split("\n"):
		cy2 = _modal_text(cx, cy2, line, 13, col_dark, max_y)
	if _modal.get("red_herring", false):
		cy2 += 4
		cy2 = _modal_text(cx, cy2, "Hard to say if this is part of the killing.", 11, col_brow, max_y)
	cy2 += 8
	var eid: String = _modal.get("eid","")
	var pl := GameState.player
	var is_flagged: bool = eid in pl["flagged_evidence"]
	var flag_label := ("★ Flagged — unflag" if is_flagged else "☆ Flag as key evidence")
	cy2 = _modal_btn(cx, cy2, flag_label, 220, func():
		if eid in pl["flagged_evidence"]:
			pl["flagged_evidence"].erase(eid)
		else:
			pl["flagged_evidence"].append(eid)
		GameState.save()
		_close_modal())
	_modal_btn(cx+228, cy2-34, "Close", 80, _close_modal, true)

func _draw_modal_contracts(cx: float, _cy: float, _max_y: float, panel: Rect2) -> void:
	var col_dark := Color("#3a2a14")
	var col_brow := Color("#8a6f3d")
	var col_gold := Color("#A07820")
	var col_done := Color("#2a6a3a")
	var pl       := GameState.player
	var taken:   String = pl.get("contract", "")
	var done: Array     = pl.get("completed_hunts", [])

	var keys: Array   = Data.HUNTS.keys()
	var total: int    = keys.size()
	var idx: int      = keys.find(_modal_tab)
	if idx < 0: idx   = 0
	var hid: String   = keys[idx]
	var h: Dictionary = Data.HUNTS[hid]
	var is_done  := hid in done
	var is_taken := hid == taken

	var nav_y := panel.end.y - 44.0
	var cy2   := panel.position.y + 16.0

	# Header
	cy2 = _modal_text(cx, cy2, "NAMES OF THE DEAD", 10, col_brow, nav_y)
	cy2 = _modal_text(cx, cy2, h["contract_name"], 20, col_dark, nav_y)
	cy2 += 6
	draw_line(Vector2(cx - 8, cy2), Vector2(cx + 548, cy2), Color("#8a6f3d"), 0.5)
	cy2 += 14

	# Reward
	cy2 = _modal_text(cx, cy2, "Reward  —  %d gold" % h["contract_gold"], 12, col_gold, nav_y)
	cy2 += 12

	# Flavor text — full, all lines
	draw_multiline_string(_font, Vector2(cx, cy2), h["contract_flavor"],
		HORIZONTAL_ALIGNMENT_LEFT, 540, 13, -1, col_brow)
	cy2 += _font.get_multiline_string_size(h["contract_flavor"],
		HORIZONTAL_ALIGNMENT_LEFT, 540, 13).y + 20

	# Status / Accept
	if is_taken:
		draw_rect(Rect2(cx - 8, cy2 - 6, 190, 30), Color("#04342C", 0.12))
		draw_rect(Rect2(cx - 8, cy2 - 6, 190, 30), Color("#04342C", 0.35), false, 0.5)
		draw_string(_font, Vector2(cx, cy2 + 12), "Active contract", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#04342C"))
	elif is_done:
		draw_string(_font, Vector2(cx, cy2 + 12), "✓  Completed", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, col_done)
	else:
		var captured_hid := hid
		var accept_fn := func():
			pl["contract"] = captured_hid
			pl["evidence"] = []
			pl["flagged_evidence"] = []
			pl["deduction"] = ""
			GameState.save()
			_rebuild_exit_btns()
			_close_modal()
		_modal_btn(cx, cy2, "Accept contract", 160, accept_fn, true)

	# Nav row — pinned at bottom
	draw_line(Vector2(panel.position.x + 10, nav_y - 6),
		Vector2(panel.end.x - 10, nav_y - 6), Color("#8a6f3d"), 0.5)

	var prev_hid: String = keys[(idx - 1 + total) % total]
	var next_hid: String = keys[(idx + 1) % total]

	_modal_btn(cx, nav_y, "← Prev", 88, func():
		_modal_tab = prev_hid
		queue_redraw())

	var page_lbl := "%d / %d" % [idx + 1, total]
	var plw := _font.get_string_size(page_lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	draw_string(_font, Vector2(cx + 274.0 - plw * 0.5, nav_y + 18),
		page_lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col_brow)

	_modal_btn(cx + 350, nav_y, "Next →", 88, func():
		_modal_tab = next_hid
		queue_redraw())

	_modal_btn(cx + 452, nav_y, "Close", 80, _close_modal)

func _draw_modal_diary(cx: float, cy: float, _max_y: float, panel: Rect2) -> void:
	var col_dark := Color("#3a2a14")
	var col_brow := Color("#8a6f3d")
	var col_red  := Color("#993C1D")

	var keys: Array = Data.WESEN.keys()
	var total: int  = keys.size()
	var idx: int    = keys.find(_modal_tab)
	if idx < 0: idx = 0
	var wid: String    = keys[idx]
	var w: Dictionary  = Data.WESEN[wid]
	var nav_y          := panel.end.y - 44.0
	var content_max    := nav_y - 6.0

	# ── Art mode — illustration fills the panel ───────────────────────────────
	var tex: Texture2D = _get_wesen_tex(wid)
	if tex and _diary_art_mode:
		var art_rect := Rect2(panel.position.x, panel.position.y, panel.size.x, nav_y - panel.position.y - 2)
		# Dark fill so image margins don't expose the parchment background
		draw_rect(art_rect, Color("#1a1210"))
		# Fit image centered, maintaining aspect ratio (letterbox with dark bars)
		var img_aspect := tex.get_width() / float(tex.get_height())
		var box_aspect := art_rect.size.x / art_rect.size.y
		var fit_w: float
		var fit_h: float
		if img_aspect > box_aspect:
			fit_w = art_rect.size.x
			fit_h = fit_w / img_aspect
		else:
			fit_h = art_rect.size.y
			fit_w = fit_h * img_aspect
		var offset := Vector2((art_rect.size.x - fit_w) * 0.5, (art_rect.size.y - fit_h) * 0.5)
		draw_texture_rect(tex, Rect2(art_rect.position + offset, Vector2(fit_w, fit_h)), false)
		# Subtle dark strip so nav row stays legible
		draw_rect(Rect2(panel.position.x, nav_y - 10, panel.size.x, 12), Color(0, 0, 0, 0.45))
	else:
		# ── Text / stats mode ────────────────────────────────────────────────
		var cy2 := cy
		cy2 = _modal_text(cx, cy2, "GRIMM DIARY  ·  %d / %d" % [idx + 1, total], 10, col_brow, content_max)
		cy2 = _modal_text(cx, cy2, w["name"], 18, col_dark, content_max)
		cy2 += 4
		cy2 = _modal_text(cx, cy2, w["desc"], 13, col_brow, content_max)
		cy2 += 6
		cy2 = _modal_text(cx, cy2, "THE SIGNS", 10, col_red, content_max)
		cy2 = _modal_text(cx, cy2, w["signs"], 13, col_dark, content_max)
		cy2 += 6
		cy2 = _modal_text(cx, cy2, "THE WEAKNESS", 10, col_red, content_max)
		cy2 = _modal_text(cx, cy2, w["weakness"], 13, col_dark, content_max)

	# ── Nav row — pinned, not scrolled ───────────────────────────────────────
	draw_line(Vector2(panel.position.x + 10, nav_y - 6),
		Vector2(panel.end.x - 10, nav_y - 6), Color("#8a6f3d"), 0.5)

	var prev_wid: String = keys[(idx - 1 + total) % total]
	var next_wid: String = keys[(idx + 1) % total]

	_modal_btn(cx, nav_y, "← Prev", 88, func():
		_modal_tab = prev_wid
		_modal_scroll = 0.0
		queue_redraw())

	var page_lbl := "%d / %d" % [idx + 1, total]
	var plw := _font.get_string_size(page_lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	draw_string(_font, Vector2(cx + 274.0 - plw * 0.5, nav_y + 18),
		page_lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col_brow)

	# Stats toggle — only shown when art is available
	if tex:
		var toggle_lbl := "Stats ↕" if _diary_art_mode else "Art ↕"
		_modal_btn(cx + 262, nav_y, toggle_lbl, 72, func():
			_diary_art_mode = not _diary_art_mode
			queue_redraw())

	_modal_btn(cx + 350, nav_y, "Next →", 88, func():
		_modal_tab = next_wid
		_modal_scroll = 0.0
		queue_redraw())

	_modal_btn(cx + 452, nav_y, "Close", 80, _close_modal)

func _draw_modal_evidence_list(cx: float, cy: float, max_y: float, _panel: Rect2) -> void:
	var col_dark := Color("#3a2a14")
	var col_brow := Color("#8a6f3d")
	var pl := GameState.player
	var cy2 := cy
	cy2 = _modal_text(cx, cy2, "WHAT YOU HAVE GATHERED", 10, col_brow, max_y)
	cy2 = _modal_text(cx, cy2, "Evidence", 17, col_dark, max_y)
	cy2 += 4
	if pl["evidence"].is_empty():
		cy2 = _modal_text(cx, cy2, "Nothing yet.", 13, col_brow, max_y)
	else:
		for eid: String in pl["evidence"]:
			var ev: Dictionary = Data.EVIDENCE[eid]
			var flagged: bool = eid in pl["flagged_evidence"]
			var row_bg := Color("#FCEBEB") if flagged else Color("#E8D9B2")
			draw_rect(Rect2(cx-8,cy2-4,556,46), row_bg)
			draw_rect(Rect2(cx-8,cy2-4,556,46), Color("#8a6f3d"),false,0.5)
			if flagged:
				draw_string(_font, Vector2(cx+530-8,cy2+10), "★", HORIZONTAL_ALIGNMENT_RIGHT,-1,11,C_BLOOD)
			cy2 = _modal_text(cx, cy2+2, ev["name"], 12, col_dark, max_y)
			cy2 = _modal_text(cx, cy2, _truncate(ev["detail"],60), 11, col_brow, max_y)
			cy2 += 4
	cy2 += 4
	_modal_btn(cx, cy2, "Close", 80, _close_modal)

func _draw_modal_accusation(cx: float, cy: float, max_y: float, _panel: Rect2) -> void:
	var col_dark := Color("#3a2a14")
	var col_brow := Color("#8a6f3d")
	var pl := GameState.player
	var cy2 := cy
	cy2 = _modal_text(cx, cy2, "NAME THE KILLER", 10, col_brow, max_y)
	cy2 = _modal_text(cx, cy2, "The accusation", 17, col_dark, max_y)
	cy2 = _modal_text(cx, cy2, "Read the signs against the diary. Name the species.", 13, col_brow, max_y)
	cy2 += 4

	# Flagged evidence
	if not pl["flagged_evidence"].is_empty():
		draw_rect(Rect2(cx-8,cy2-4,556,16+pl["flagged_evidence"].size()*16), Color("#FCEBEB"))
		cy2 = _modal_text(cx, cy2, "★ FLAGGED", 10, Color("#501313"), max_y)
		for eid: String in pl["flagged_evidence"]:
			cy2 = _modal_text(cx, cy2, "— " + Data.EVIDENCE[eid]["name"], 12, Color("#501313"), max_y)
		cy2 += 4

	# Wesen grid (2 columns) — filtered to case suspects only
	var contract: String = pl.get("contract", "")
	var suspects: Array = Data.HUNTS[contract].get("suspects", Data.WESEN.keys()) \
		if Data.HUNTS.has(contract) else Data.WESEN.keys()
	var col_w := 260.0
	var grid_x := [cx, cx + col_w + 16]
	var gi := 0
	var row_y := cy2
	for wid: String in suspects:
		if not Data.WESEN.has(wid): continue
		var w: Dictionary = Data.WESEN[wid]
		var gx: float = grid_x[gi % 2]
		if gi % 2 == 0 and gi > 0: row_y += 72
		var gy := row_y
		var is_sel := _modal_sel == wid
		var card_bg := Color("#FCEBEB") if is_sel else C_PARCH
		draw_rect(Rect2(gx-4,gy,col_w,66), card_bg)
		draw_rect(Rect2(gx-4,gy,col_w,66), Color("#993C1D") if is_sel else Color("#8a6f3d"), false, 1.0 if is_sel else 0.5)
		draw_string(_font, Vector2(gx+4,gy+16), w["name"], HORIZONTAL_ALIGNMENT_LEFT,-1,13,col_dark)
		draw_string(_font, Vector2(gx+4,gy+30), _truncate(w["signs"].split(".")[0]+".",40), HORIZONTAL_ALIGNMENT_LEFT,-1,11,col_brow)
		var captured_wid := wid
		_modal_btns.append({"rect": Rect2(gx-4,gy,col_w,66), "action": func():
			_modal_sel = captured_wid
			queue_redraw()})
		gi += 1

	cy2 = row_y + 78
	if not _modal_sel.is_empty():
		cy2 = _modal_btn(cx, cy2, "Draw steel and hunt", 200, _confirm_accusation, true, true)
	_modal_btn(cx+208, cy2-34, "Not yet", 90, _close_modal)

func _confirm_accusation() -> void:
	if _modal_sel.is_empty():
		return
	var accused := _modal_sel
	var contract: String = GameState.player.get("contract","")
	var wid: String
	var correct: bool
	if contract.is_empty():
		# Debug: no active contract — fight the accused wesen directly
		wid = accused
		correct = true
	else:
		var true_killer: String = Data.HUNTS[contract]["true_killer"]
		correct = accused == true_killer
		wid = true_killer
	GameState.player["deduction"] = accused
	_close_modal()

	if not correct:
		var go_hub := func():
			_close_modal()
			GameState.scene = "hub"
			SceneNav.go_investigation()
		_open_modal("simple", {
			"title": "A wrong hunt",
			"eyebrow": "The accusation fails",
			"body": "That is not the one. The signs led you astray — or you did not read them true.\n\nReturn to the waystation. The case is not closed.",
			"buttons": [{"label": "Back to the waystation", "primary": true, "blood": false, "action": go_hub}],
		})
		return

	GameState.pending_combat = {"wid": wid, "correct": true}
	var go_combat := func():
		_close_modal()
		SceneNav.go_combat()
	_open_modal("simple", {
		"title": "Sure of your quarry",
		"eyebrow": "The hunt begins",
		"body": "You read the signs true. You walk in armed with knowing.\n\nCombat: A/D dodge · J parry (precise!) · K strike · Shift block.\nWatch the Wesen's aura — yellow=parry, blue=dodge, red=block.",
		"buttons": [{"label": "Draw steel", "primary": true, "blood": true, "action": go_combat}],
	})

func _close_modal() -> void:
	_modal = {}
	_modal_btns.clear()
	queue_redraw()

# ─── drawing helpers ──────────────────────────────────────────────────────────
func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color, fill := true, width := 1.0) -> void:
	var pts := PackedVector2Array()
	for i in 25:
		var a := float(i) / 24.0 * TAU
		pts.append(center + Vector2(cos(a)*rx, sin(a)*ry))
	if fill:
		draw_colored_polygon(pts, color)
	else:
		draw_polyline(pts, color, width)

func _draw_bezier_stroke(p0: Vector2, ctrl: Vector2, p2: Vector2, color: Color, width: float) -> void:
	var pts := PackedVector2Array()
	for i in 13:
		var t := float(i) / 12.0
		pts.append((1-t)*(1-t)*p0 + 2*(1-t)*t*ctrl + t*t*p2)
	draw_polyline(pts, color, width)

func _draw_bezier_fill(p0: Vector2, ctrl: Vector2, p2: Vector2, close: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 13:
		var t := float(i) / 12.0
		pts.append((1-t)*(1-t)*p0 + 2*(1-t)*t*ctrl + t*t*p2)
	pts.append(close)
	draw_colored_polygon(pts, color)

func _truncate(s: String, max_len: int) -> String:
	if s.length() <= max_len: return s
	return s.substr(0, max_len) + "…"
