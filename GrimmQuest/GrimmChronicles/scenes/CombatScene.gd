extends Node2D
## Action-timing duel — direct port of grimm_chronicles_v5 combat loop
## All times in MILLISECONDS to match the original JS exactly.

# ─── canvas size ─────────────────────────────────────────────────────────────
const W := 680.0
const H := 380.0

# ─── palette ─────────────────────────────────────────────────────────────────
const C_CREAM  := Color("#FAEEDA")
const C_DARK   := Color("#1a1208")
const C_BLOOD  := Color("#993C1D")
const C_GOLD   := Color("#BA7517")
const C_GLOW   := Color("#FAC775")
const C_GREEN  := Color("#0F6E56")
const C_BLUE   := Color("#5DADE2")
const C_RED    := Color("#E74C3C")

# ─── combat state ─────────────────────────────────────────────────────────────
var c: Dictionary = {}      # combat dict (mirrors JS state.combat)
var p: Dictionary = {}      # player dict (GameState.player shorthand)
var w: Dictionary = {}      # wesen dict

var _keys  := {}
var _pressed := {}
var _elapsed_ms := 0.0      # total ms since scene entered (for sin pulses)
var _font: Font
var _grimm_tex:          Texture2D = null
var _blutbad_tex:        Texture2D = null
var _hexenbiest_tex:     Texture2D = null
var _spinnetod_tex:      Texture2D = null
var _jagerbar_med_tex:   Texture2D = null
var _fuchsbau_med_tex:   Texture2D = null
var _lausenschlange_tex: Texture2D = null
var _skalengeck_tex:     Texture2D = null

# ─── init ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_font = ThemeDB.fallback_font
	_grimm_tex          = load("res://assets/sheets/grimm4.png")                          as Texture2D
	_blutbad_tex        = load("res://assets/sheets/blutbud_sprite.png")                  as Texture2D
	_hexenbiest_tex     = load("res://assets/sheets/medieval_sprite_hexenbiest.png")      as Texture2D
	_spinnetod_tex      = load("res://assets/sheets/medieval_sprite_spinnetod.png")       as Texture2D
	_jagerbar_med_tex   = load("res://assets/sheets/medieval_sprite_Jagerbar.png")        as Texture2D
	_fuchsbau_med_tex   = load("res://assets/sheets/medieval_sprite_fuchsbau.png")        as Texture2D
	_lausenschlange_tex = load("res://assets/sheets/medieval_sprite_lausenschlange.png")  as Texture2D
	_skalengeck_tex     = load("res://assets/sheets/medieval_sprite_skalengeck.png")      as Texture2D
	p = GameState.player
	var pc := GameState.pending_combat
	var wid: String = pc.get("wid", "blutbad")
	var correct: bool = pc.get("correct", false)
	w = Data.WESEN[wid]
	_start_combat(wid, correct)

func _start_combat(wid: String, deduced_correct: bool) -> void:
	c = {
		"wid":             wid,
		"enemy_hp":        int(w["hp"]),
		"enemy_max_hp":    int(w["hp"]),
		"enemy_state":     "idle",      # idle / windup / recover / stunned / dead
		"enemy_state_time":0.0,
		"enemy_move":      null,
		"next_attack_in":  1200.0,
		"player_state":    "idle",      # idle / dodging / parrying / blocking / striking / hit / dead
		"player_state_time":0.0,
		"player_dodge_dir":0,
		"deduced_correct": deduced_correct,
		"float_texts":     [],
		"flash_screen":    0.0,
		"flash_color":     C_BLOOD,
		"shake_amount":    0.0,
		"spare_offered":   false,
		"spare_declined":  false,
		"log":             "A Grimm faces a " + w["name"] + ".",
		"log_time":        2500.0,
		"combo":           0,
		"block_held":      false,
	}
	# Stamina penalty for wrong deduction
	if not deduced_correct:
		p["stam"] = max(2, p["max_stam"] - 2)
	else:
		p["stam"] = p["max_stam"]

# ─── main loop ────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if c.is_empty(): return
	var dt := delta * 1000.0  # convert to ms
	_elapsed_ms += dt
	_update_combat(dt)
	queue_redraw()
	_pressed.clear()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := _kname(event.keycode)
		if k.is_empty(): return
		if event.pressed and not event.echo:
			if not _keys.get(k, false): _pressed[k] = true
			_keys[k] = true
		elif not event.pressed:
			_keys.erase(k)

func _kname(kc: Key) -> String:
	match kc:
		KEY_A:     return "a"
		KEY_D:     return "d"
		KEY_J:     return "j"
		KEY_K:     return "k"
		KEY_S:     return "s"
		KEY_SHIFT: return "shift"
	return ""

# ─── update ───────────────────────────────────────────────────────────────────
func _update_combat(dt: float) -> void:
	if not c.has("player_state"): return
	c["enemy_state_time"]  = c["enemy_state_time"]  + dt
	c["player_state_time"] = c["player_state_time"] + dt
	c["log_time"]     = max(0.0, c["log_time"]     - dt)
	c["flash_screen"] = max(0.0, c["flash_screen"] - dt)
	c["shake_amount"] = max(0.0, c["shake_amount"] - dt * 0.03)

	# Fade floaters
	var ft_alive := []
	for ft: Dictionary in c["float_texts"]:
		ft["life"] -= dt
		ft["y"]    -= dt * 0.04
		if ft["life"] > 0: ft_alive.append(ft)
	c["float_texts"] = ft_alive

	c["block_held"] = _keys.get("shift", false)

	# Spare threshold
	if c["enemy_hp"] > 0 and c["enemy_hp"] <= int(c["enemy_max_hp"] * 0.22) and not c["spare_offered"]:
		c["spare_offered"] = true
		c["enemy_state"] = "stunned"
		c["enemy_state_time"] = 0.0
		_log("The Wesen falters. (K to strike, S to spare)")

	# Spare input pause
	if c["spare_offered"] and not c["spare_declined"]:
		if _pressed.get("k", false):
			_pressed.erase("k")
			c["spare_declined"] = true
			_end_combat("killed")
			return
		if _pressed.get("s", false):
			_pressed.erase("s")
			_end_combat("spared")
			return
		return

	# ── Enemy AI ──────────────────────────────────────────────────────────────
	match c["enemy_state"]:
		"idle":
			c["next_attack_in"] = c["next_attack_in"] - dt
			if c["next_attack_in"] <= 0.0:
				var move := _pick_move()
				c["enemy_move"] = move
				c["enemy_state"] = "windup"
				c["enemy_state_time"] = 0.0
		"windup":
			if c["enemy_state_time"] >= float(c["enemy_move"]["windup"]):
				_execute_enemy_strike()
				if c.is_empty(): return
		"recover":
			if c["enemy_state_time"] >= 400.0:
				c["enemy_state"] = "idle"
				c["enemy_state_time"] = 0.0
				c["next_attack_in"] = 900.0 + randf() * 500.0
		"stunned":
			if c["enemy_state_time"] >= 600.0 and not c["spare_offered"]:
				c["enemy_state"] = "idle"
				c["enemy_state_time"] = 0.0
				c["next_attack_in"] = 600.0

	# ── Player input ─────────────────────────────────────────────────────────
	if c["player_state"] == "idle" and not c["spare_offered"]:
		if _pressed.get("a", false):
			_pressed.erase("a"); c["player_state"]="dodging"; c["player_state_time"]=0.0; c["player_dodge_dir"]=-1
		elif _pressed.get("d", false):
			_pressed.erase("d"); c["player_state"]="dodging"; c["player_state_time"]=0.0; c["player_dodge_dir"]=1
		elif _pressed.get("j", false):
			_pressed.erase("j"); c["player_state"]="parrying"; c["player_state_time"]=0.0
		elif _pressed.get("k", false):
			_pressed.erase("k"); c["player_state"]="striking"; c["player_state_time"]=0.0; _execute_player_strike()
			if c.is_empty(): return

	# ── State timeouts ───────────────────────────────────────────────────────
	if c["player_state"]=="dodging"  and c["player_state_time"] >= 350.0: c["player_state"]="idle"; c["player_state_time"]=0.0
	if c["player_state"]=="parrying" and c["player_state_time"] >= 300.0: c["player_state"]="idle"; c["player_state_time"]=0.0
	if c["player_state"]=="striking" and c["player_state_time"] >= 250.0: c["player_state"]="idle"; c["player_state_time"]=0.0
	if c["player_state"]=="hit"      and c["player_state_time"] >= 400.0: c["player_state"]="idle"; c["player_state_time"]=0.0

func _pick_move() -> Dictionary:
	var moves: Array = w["moves"]
	var total := 0.0
	for m: Dictionary in moves: total += float(m["weight"])
	var roll := randf() * total
	for m: Dictionary in moves:
		roll -= float(m["weight"])
		if roll <= 0.0: return m
	return moves[0]

func _execute_player_strike() -> void:
	if c["enemy_state"] == "stunned":
		var dmg: int = randi_range(8, 12) + int(c["combo"]) * 3
		c["enemy_hp"] = max(0, c["enemy_hp"] - dmg)
		_float(450,150, "-"+str(dmg), C_GLOW, true)
		c["shake_amount"] = 6.0
		_log("A clean strike on the stagger! %d damage." % dmg)
		if c["enemy_hp"] <= 0: _end_combat("killed")
	elif c["enemy_state"] == "recover":
		var dmg := randi_range(5,8)
		c["enemy_hp"] = max(0, c["enemy_hp"] - dmg)
		_float(450,150, "-"+str(dmg), C_CREAM)
		c["shake_amount"] = 3.0
		if c["enemy_hp"] <= 0: _end_combat("killed")
	else:
		p["stam"] = max(0, p["stam"] - 1)
		_float(220,160, "miss", Color("#888780"))
		_log("You swing wild. The Wesen is set.")

func _execute_enemy_strike() -> void:
	var move: Dictionary = c["enemy_move"]
	var damage: int = int(move["dmg"])
	var mtype: String = move["type"]
	var pstate: String = c["player_state"]
	var outcome := "hit"

	if pstate == "dodging":
		if mtype == "dodge" or mtype == "parry":
			outcome = "dodged"; damage = 0
			_float(220,160,"evade",C_GREEN); _log("Evaded.")
		elif mtype == "block":
			damage = int(damage * 0.5); outcome = "partial"
	elif pstate == "parrying":
		if mtype == "parry":
			# PERFECT PARRY
			outcome = "parried"; damage = 0
			c["enemy_state"] = "stunned"; c["enemy_state_time"] = 0.0
			c["combo"] = min(2, c["combo"] + 1)
			_float(450,140,"PARRY!",C_GLOW,true)
			c["flash_screen"] = 180.0; c["flash_color"] = Color.WHITE
			c["shake_amount"] = 4.0
			p["stam"] = min(p["max_stam"], p["stam"] + 1)
			_log("Steel rings on tooth! The Wesen reels — strike now (K)!")
			return
		elif mtype == "dodge":
			damage = int(damage * 1.2); outcome = "punished"
		else:
			damage = int(damage * 0.8)
	elif c["block_held"]:
		damage = int(damage * 0.5)
		p["stam"] = max(0, p["stam"] - 2)
		outcome = "blocked"
		if p["stam"] <= 0:
			damage = int(move["dmg"]); outcome = "broken"
			_log("Your guard breaks!")

	# Steel drain (Jägerbar Roar)
	var drain: int = int(move.get("drain_steel", 0))
	if drain > 0: p["stam"] = max(0, p["stam"] - drain)

	if damage > 0:
		p["hp"] = max(0, p["hp"] - damage)
		c["player_state"] = "hit"; c["player_state_time"] = 0.0
		_float(180,160,"-"+str(damage),C_BLOOD,true)
		c["shake_amount"] = 7.0 if damage > 15 else 4.0
		c["flash_screen"] = 120.0; c["flash_color"] = C_BLOOD
		match outcome:
			"hit":     _log(move["name"] + " lands true. " + str(damage) + " damage.")
			"punished":_log("Wrong defense! " + str(damage) + " damage.")
			"blocked": _log("Blocked for half. " + str(damage) + " damage.")
			"broken":  _log("Guard broken! " + str(damage) + " damage.")

	c["enemy_state"] = "recover"; c["enemy_state_time"] = 0.0
	if outcome != "parried": c["combo"] = 0
	if p["hp"] <= 0: _end_combat("defeated")

func _float(x: float, y: float, text: String, color: Color, big := false) -> void:
	c["float_texts"].append({"x":x,"y":y,"text":text,"color":color,"life":900.0,"big":big})

func _log(text: String) -> void:
	c["log"] = text; c["log_time"] = 2200.0

func _end_combat(outcome: String) -> void:
	var is_enc: bool = GameState.pending_combat.get("is_encounter", false)
	var hunt_id: String = p.get("contract", "")
	var result := {"outcome": outcome, "gold": 0, "xp": 0, "trust_delta": 0,
		"narration": "", "correct": c["deduced_correct"],
		"hunt_id": hunt_id, "is_encounter": is_enc}

	if is_enc:
		# Random encounter — preserve contract and scene, small reward/penalty
		match outcome:
			"killed", "spared":
				result["gold"] = 8; result["xp"] = 25
				p["gold"] += 8; p["xp"] += 25
				result["narration"] = "The " + w["name"] + " falls. You dust yourself off and press on."
			"defeated":
				p["hp"] = max(10, int(p["max_hp"] * 0.4))
				result["gold"] = -min(5, p["gold"]); p["gold"] += result["gold"]
				result["narration"] = "You come round in the dark, bruised and lighter in the purse. The investigation is not over."
	else:
		match outcome:
			"killed":
				result["gold"] = int(w["reward"]["gold"]); result["xp"] = int(w["reward"]["xp"])
				p["gold"] += result["gold"]; p["xp"] += result["xp"]; p["hunts"] += 1
				if not hunt_id in p["completed_hunts"]: p["completed_hunts"].append(hunt_id)
				result["narration"] = "The " + w["name"] + " falls. The fur ebbs from a body that is mostly a man again."
			"spared":
				result["gold"] = int(w["reward"]["gold"] * 0.3); result["xp"] = int(w["reward"]["xp"] * 0.6)
				result["trust_delta"] = 1
				p["gold"] += result["gold"]; p["xp"] += result["xp"]; p["hunts"] += 1
				var wid: String = c["wid"]
				p["trust"][wid] = int(p["trust"].get(wid, 0)) + 1
				if not hunt_id in p["completed_hunts"]: p["completed_hunts"].append(hunt_id)
				result["narration"] = "It runs. You let it. You have done a difficult thing well."
			"defeated":
				p["hp"] = max(10, int(p["max_hp"] * 0.4))
				result["gold"] = -min(10, p["gold"]); p["gold"] += result["gold"]
				result["narration"] = "You wake on the road, stitched by some kind hand. The killer is gone."
		p["contract"] = ""; p["evidence"] = []; p["flagged_evidence"] = []; p["deduction"] = ""
		GameState.scene = "hub"

	# Level up check (applies to both paths)
	var old_lvl: int = p["level"]
	var new_lvl := GameState.current_level_from_xp()
	if new_lvl > old_lvl:
		var gained := new_lvl - old_lvl
		p["level"] = new_lvl
		p["max_hp"] += 10 * gained
		p["hp"] = p["max_hp"]
		result["level_up"] = true
	else:
		p["hp"] = min(p["max_hp"], p["hp"] + int(p["max_hp"] * 0.3))

	p["stam"] = p["max_stam"]
	GameState.result = result
	c = {}
	GameState.save()
	SceneNav.go_aftermath()

# ─── DRAW ─────────────────────────────────────────────────────────────────────
func _draw() -> void:
	if c.is_empty(): return
	var shake: float = c["shake_amount"]
	var ox := 0.0; var oy := 0.0
	if shake > 0.0:
		ox = randf_range(-shake, shake)
		oy = randf_range(-shake, shake)
	draw_set_transform(Vector2(ox, oy))

	# Night sky
	draw_rect(Rect2(0,0,W,H), Color("#0d1828"))
	# Moon
	draw_circle(Vector2(560,55), 20, Color(0.98,0.93,0.85,0.7))
	draw_circle(Vector2(555,50), 20, Color("#0d1828"))
	# Distant trees
	for i in 10:
		var tx := 20.0 + i * 70.0
		draw_rect(Rect2(tx-3,200,6,80), Color("#0a0d05"))
		_draw_ellipse(Vector2(tx,190), 18, 28, Color("#0a0d05"))
	# Ground
	draw_rect(Rect2(0,280,W,H-280), Color("#1a1408"))

	# Player
	var px_offset := 0.0
	if c["player_state"] == "dodging":
		px_offset = float(c["player_dodge_dir"]) * 30.0 * sin(c["player_state_time"] / 350.0 * PI)
	_draw_player_combat(180.0 + px_offset, 250.0, c["player_state"], c["player_state_time"], c["block_held"])

	# Wesen
	_draw_wesen_combat(c["wid"], 500.0, 250.0, c["enemy_state"], c["enemy_state_time"], c["enemy_move"])

	# Wind-up indicator
	if c["enemy_state"] == "windup" and c["enemy_move"]:
		_draw_windup_indicator()

	draw_set_transform(Vector2.ZERO)

	# HUD (no shake)
	_draw_combat_hud()

	# Float texts
	for ft: Dictionary in c["float_texts"]:
		var alpha: float = min(1.0, float(ft["life"]) / 600.0)
		var fs: int = 22 if ft["big"] else 16
		draw_string(_font, Vector2(ft["x"],ft["y"]), ft["text"],
			HORIZONTAL_ALIGNMENT_CENTER, -1, fs,
			Color(ft["color"].r, ft["color"].g, ft["color"].b, alpha))

	# Screen flash
	if c["flash_screen"] > 0.0:
		var alpha: float = float(c["flash_screen"]) / 180.0 * 0.4
		draw_rect(Rect2(0,0,W,H), Color(c["flash_color"].r,c["flash_color"].g,c["flash_color"].b,alpha))

	# Log line
	if c["log_time"] > 0.0:
		var alpha: float = min(1.0, float(c["log_time"]) / 600.0)
		draw_rect(Rect2(W/2.0-160,40,320,28), Color(0.08,0.06,0.04,0.85))
		draw_string(_font, Vector2(W/2.0,58), c["log"],
			HORIZONTAL_ALIGNMENT_CENTER,-1,13,Color(C_CREAM.r,C_CREAM.g,C_CREAM.b,alpha))

	# Spare prompt
	if c["spare_offered"] and not c["spare_declined"]:
		draw_rect(Rect2(0,0,W,H), Color(0.04,0.03,0.02,0.6))
		draw_string(_font, Vector2(W/2,140), "The Wesen falters before you.", HORIZONTAL_ALIGNMENT_CENTER,-1,20,C_CREAM)
		draw_string(_font, Vector2(W/2,170), "It is a creature again. Almost a man.",  HORIZONTAL_ALIGNMENT_CENTER,-1,14,C_CREAM)
		draw_string(_font, Vector2(W/2,210), "[K]  Strike the killing blow",           HORIZONTAL_ALIGNMENT_CENTER,-1,14,C_BLOOD)
		draw_string(_font, Vector2(W/2,240), "[S]  Sheath the blade. Let it run.",     HORIZONTAL_ALIGNMENT_CENTER,-1,14,C_GREEN)

func _draw_windup_indicator() -> void:
	var move: Dictionary = c["enemy_move"]
	var progress: float = min(1.0, float(c["enemy_state_time"]) / float(move["windup"]))
	var ex := 500.0
	var tell_col: Color
	var tell_lbl: String
	match move["type"]:
		"parry": tell_col = C_GLOW;  tell_lbl = "⚔"
		"dodge":  tell_col = C_BLUE; tell_lbl = "↘"
		_:        tell_col = C_RED;  tell_lbl = "🛡"

	# Pulsing icon
	var pulse := 1.0 + sin(_elapsed_ms / 100.0) * 0.15
	draw_string(_font, Vector2(ex, 148), tell_lbl,
		HORIZONTAL_ALIGNMENT_CENTER,-1, int(24.0*pulse), tell_col)

	# Wind-up bar
	draw_rect(Rect2(ex-50,165,100,8), Color(0.08,0.06,0.04,0.85))
	draw_rect(Rect2(ex-48,167,min(96.0, 96.0*progress),4), tell_col)
	draw_string(_font, Vector2(ex,185), move["name"], HORIZONTAL_ALIGNMENT_CENTER,-1,11,C_CREAM)

	# Red flash near strike
	if progress > 0.85:
		var pulse2 := (sin(_elapsed_ms / 50.0) * 0.4 + 0.4)
		draw_rect(Rect2(ex-50,165,100,8), Color(C_RED.r,C_RED.g,C_RED.b,pulse2))

	# Aura around enemy body
	var aura_col := tell_col
	var aura_alpha := 0.4 + sin(_elapsed_ms / 80.0) * 0.3
	draw_arc(Vector2(ex,-15+250), 50.0+progress*15.0, 0, TAU, 32,
		Color(aura_col.r,aura_col.g,aura_col.b,aura_alpha), 3.0)

func _draw_combat_hud() -> void:
	var php_pct := float(p["hp"]) / float(p["max_hp"])
	# Player bar
	draw_rect(Rect2(20,20,200,30), Color(0.08,0.06,0.04,0.85))
	draw_string(_font, Vector2(28,33), "Grimm  %d/%d" % [p["hp"],p["max_hp"]], HORIZONTAL_ALIGNMENT_LEFT,-1,11,C_CREAM)
	draw_rect(Rect2(28,36,184,8), Color("#3a1a0a"))
	draw_rect(Rect2(28,36,184.0*php_pct,8), C_BLOOD)
	# Steel bar
	var stam_pct := float(p["stam"]) / float(p["max_stam"])
	draw_rect(Rect2(28,46,184,3), Color("#3a1a0a"))
	draw_rect(Rect2(28,46,184.0*stam_pct,3), C_GOLD)
	# Combo
	if c["combo"] > 0:
		draw_string(_font, Vector2(28,68), "★ %d parry bonus" % c["combo"], HORIZONTAL_ALIGNMENT_LEFT,-1,12,C_GLOW)

	# Enemy bar
	var ehp_pct := float(c["enemy_hp"]) / float(c["enemy_max_hp"])
	draw_rect(Rect2(W-220,20,200,30), Color(0.08,0.06,0.04,0.85))
	draw_string(_font, Vector2(W-28,33), "%d/%d  %s" % [c["enemy_hp"],c["enemy_max_hp"],w["name"]],
		HORIZONTAL_ALIGNMENT_RIGHT,-1,11,C_CREAM)
	draw_rect(Rect2(W-212,36,184,8), Color("#3a1a0a"))
	draw_rect(Rect2(W-212,36,184.0*ehp_pct,8), C_BLOOD)

	# Legend
	draw_rect(Rect2(W/2.0-150,H-40,300,28), Color(0.08,0.06,0.04,0.65))
	draw_string(_font, Vector2(W/2.0,H-22), "⚔ yellow=PARRY(J)  ↘ blue=DODGE(A/D)  🛡 red=BLOCK(Shift)",
		HORIZONTAL_ALIGNMENT_CENTER,-1,11,C_CREAM)

# ─── character drawings ───────────────────────────────────────────────────────
func _draw_player_combat(x: float, y: float, pstate: String, t: float, blocking: bool) -> void:
	if _grimm_tex:
		# grimm4.png — 4 rows × 6 frames, ROW_H=140, FW=170.67, SKIP=13 (top margin)
		const ROW_H  := 140.0
		const DISP_H := 96.0
		const FW     := 1024.0 / 6.0
		const SKIP   := 13.0
		const N      := 6

		var row_y:    float
		var frame_idx: int
		var flip_x := 1.0

		if pstate == "striking":
			# Row 2: fire sequence — animate all 6 frames over 250ms
			row_y     = ROW_H * 2.0
			frame_idx = clamp(int(t / 250.0 * N), 0, N - 1)
		elif pstate == "parrying":
			# Row 1: aiming stances, cycle frames 2-3
			row_y     = ROW_H
			frame_idx = 2 + int(_elapsed_ms / 120.0) % 2
		elif pstate == "dodging":
			# Row 3: run frames 1-3, flip toward dodge direction
			row_y     = ROW_H * 3.0
			frame_idx = 1 + int(_elapsed_ms / 80.0) % 3
			flip_x    = float(c.get("player_dodge_dir", 1))
		elif pstate == "hit":
			# Row 1: last frame (recoil)
			row_y     = ROW_H
			frame_idx = 5
		else:
			# Row 1: ready stance — frame 1 for blocking, frame 0 otherwise
			row_y     = ROW_H
			frame_idx = 1 if blocking else 0

		var disp_w := FW / ROW_H * DISP_H
		var src    := Rect2(float(frame_idx) * FW, row_y + SKIP, FW, ROW_H - SKIP)
		_draw_ellipse(Vector2(x, y + 5.0), disp_w * 0.4, 5.0, Color(0, 0, 0, 0.5))
		draw_set_transform(Vector2(x, y), 0.0, Vector2(flip_x, 1.0))
		draw_texture_rect_region(_grimm_tex, Rect2(-disp_w * 0.5, -DISP_H, disp_w, DISP_H), src)
		draw_set_transform(Vector2.ZERO)
	else:
		# Procedural fallback
		draw_set_transform(Vector2(x, y), 0.0, Vector2(1.6, 1.6))
		_draw_ellipse(Vector2(0, 40), 20, 5, Color(0, 0, 0, 0.5))
		draw_rect(Rect2(-8, 25, 6, 15), Color("#1a1208"))
		draw_rect(Rect2(2, 25, 6, 15), Color("#1a1208"))
		var tilt := 0.0
		if pstate == "striking": tilt = sin(t / 250.0 * PI) * 0.3
		if pstate == "hit":      tilt = -0.3 + sin(t / 200.0 * PI * 4.0) * 0.1
		draw_set_transform(Vector2(x, y), tilt, Vector2(1.6, 1.6))
		var cloak := PackedVector2Array([Vector2(-15,-30),Vector2(-12,25),Vector2(12,25),Vector2(15,-30)])
		draw_colored_polygon(cloak, Color("#2a1f12"))
		_draw_ellipse(Vector2(0, -32), 10, 12, Color("#1a1208"))
		_draw_ellipse(Vector2(2, -32), 6, 7, Color("#0a0a0a"))
		draw_circle(Vector2(4, -32), 1.2, Color("#FAEEDA"))
		var sword_col := Color("#C0C0C0")
		if pstate == "striking":
			var reach := (t/150.0)*40.0 if t < 150.0 else 40.0-(t-150.0)/100.0*40.0
			draw_line(Vector2(8,-20), Vector2(8+reach,-15), sword_col, 3)
		elif pstate == "parrying":
			draw_line(Vector2(6,-26), Vector2(20,-2), sword_col, 3)
			draw_arc(Vector2(13,-15), 18, 0, TAU, 24,
				Color(C_GLOW.r,C_GLOW.g,C_GLOW.b,0.7+sin(t/50.0)*0.3), 1)
		elif blocking:
			draw_line(Vector2(-8,-10), Vector2(18,-12), sword_col, 3)
			draw_arc(Vector2(5,-12), 22, -PI/2.0, PI/2.0, 12,
				Color(C_BLUE.r,C_BLUE.g,C_BLUE.b,0.5), 1.5)
		else:
			draw_line(Vector2(8,-20), Vector2(14,2), sword_col, 3)
			draw_rect(Rect2(7,-22,4,3), Color("#3a2a14"))
		draw_set_transform(Vector2.ZERO)

func _draw_wesen_combat(wid: String, x: float, y: float, wstate: String, t: float, move) -> void:
	var sway := 0.0; var lunge := 0.0
	if wstate == "windup" and move:
		var progress: float = min(1.0, t / float(move["windup"]))
		sway = -sin(progress*PI)*0.15
		if progress > 0.85: lunge = -((progress-0.85)/0.15)*20.0
	elif wstate == "recover": sway = 0.1
	elif wstate == "stunned": sway = sin(t/100.0)*0.2
	draw_set_transform(Vector2(x+lunge,y), sway)
	match wid:
		"blutbad":        _draw_blutbad(wstate)
		"jagerbar":       _draw_medieval_sprite(_jagerbar_med_tex, 140.0, wstate)
		"fuchsbau":       _draw_medieval_sprite(_fuchsbau_med_tex, 140.0, wstate)
		"skalengeck":     _draw_medieval_sprite(_skalengeck_tex, 140.0, wstate)
		"lausenschlange": _draw_medieval_sprite(_lausenschlange_tex, 140.0, wstate)
		"spinnetod":      _draw_medieval_sprite(_spinnetod_tex, 141.0, wstate)
		"hexenbiest":     _draw_hexenbiest(wstate)
		_:                _draw_blutbad(wstate)
	draw_set_transform(Vector2.ZERO)

func _draw_blutbad(wstate: String) -> void:
	if _blutbad_tex:
		# blutbud_sprite.png — 4 rows × 8 frames, FW=128
		# Row 0 (y=0,   h=160, skip=42): human form
		# Row 1 (y=160, h=128, skip=10): transform/stunned
		# Row 2 (y=288, h=130, skip=8):  beast idle
		# Row 3 (y=418, h=141, skip=6):  beast attack
		const FW     := 128.0
		const DISP_H := 100.0
		const N      := 8

		var row_y:     float
		var row_h:     float
		var skip:      float
		var frame_idx: int
		match wstate:
			"windup":
				row_y = 418.0; row_h = 141.0; skip = 6.0
				var progress := 0.0
				if c.get("enemy_move") != null:
					progress = min(1.0, c["enemy_state_time"] / float(c["enemy_move"]["windup"]))
				frame_idx = clamp(int(progress * N), 0, N - 1)
			"stunned":
				row_y = 160.0; row_h = 128.0; skip = 10.0
				frame_idx = int(_elapsed_ms / 200.0) % N
			_:
				row_y = 288.0; row_h = 130.0; skip = 8.0
				frame_idx = int(_elapsed_ms / 150.0) % N

		var disp_w := FW / row_h * DISP_H
		var src    := Rect2(float(frame_idx) * FW, row_y + skip, FW, row_h - skip)
		_draw_ellipse(Vector2(0, 28), disp_w * 0.35, 5.0, Color(0, 0, 0, 0.45))
		# Negative width flips sprite left (facing Grimm at x=180)
		draw_texture_rect_region(_blutbad_tex, Rect2(disp_w * 0.5, -DISP_H + 28.0, -disp_w, DISP_H), src)
		return

	# Procedural fallback
	var fc := Color("#1a1208")
	_draw_ellipse(Vector2(0,-5), 40, 30, fc)
	_draw_ellipse(Vector2(-35,-25), 22, 20, fc)
	var ears := [Vector2(-45,-40),Vector2(-42,-58),Vector2(-36,-44)]
	draw_colored_polygon(PackedVector2Array(ears), fc)
	var ears2 := [Vector2(-32,-44),Vector2(-26,-58),Vector2(-24,-42)]
	draw_colored_polygon(PackedVector2Array(ears2), fc)
	draw_rect(Rect2(-25,18,7,18), fc); draw_rect(Rect2(-10,18,7,18), fc)
	draw_rect(Rect2(5,18,7,18), fc);   draw_rect(Rect2(20,18,7,18), fc)
	draw_colored_polygon(PackedVector2Array([Vector2(38,-10), Vector2(55,-22), Vector2(48,2)]), fc)
	draw_circle(Vector2(-42,-26), 3, Color("#D85A30"))
	draw_circle(Vector2(-30,-26), 3, Color("#D85A30"))
	if wstate == "windup":
		_draw_ellipse(Vector2(-48,-18), 10, 5, Color("#5a0808"))
		for i in 3: draw_rect(Rect2(-54+i*8,-22,2,5), Color.WHITE)
	else:
		for i in 3: draw_rect(Rect2(-50+i*8,-19,2,4), Color.WHITE)

# Generic drawer for 1024-wide medieval sheets: 4 rows × 8 frames × 128px wide.
# row_h: height of each row (559/4≈140 for standard sheets, 141 for 565-tall ones).
# Row layout assumed: 0=human/idle, 1=stunned, 2=beast idle, 3=attack.
func _draw_medieval_sprite(tex: Texture2D, row_h: float, wstate: String) -> void:
	if not tex:
		_draw_blutbad(wstate)
		return
	const FW     := 128.0
	const DISP_H := 100.0
	const N      := 8
	var row_y: float
	var frame_idx: int
	match wstate:
		"windup":
			row_y = row_h * 3.0
			var progress := 0.0
			if c.get("enemy_move") != null:
				progress = min(1.0, c["enemy_state_time"] / float(c["enemy_move"]["windup"]))
			frame_idx = clamp(int(progress * N), 0, N - 1)
		"stunned":
			row_y = row_h
			frame_idx = int(_elapsed_ms / 200.0) % N
		_:
			row_y = row_h * 2.0
			frame_idx = int(_elapsed_ms / 150.0) % N
	var disp_w := FW / row_h * DISP_H
	var src    := Rect2(float(frame_idx) * FW, row_y, FW, row_h)
	_draw_ellipse(Vector2(0, 28), disp_w * 0.35, 5.0, Color(0, 0, 0, 0.45))
	draw_texture_rect_region(tex, Rect2(disp_w * 0.5, -DISP_H + 28.0, -disp_w, DISP_H), src)

# Hexenbiest sheet (1024×529 after top-label crop).
# Detected row borders at y=0,129,262,396 — each row starts 1px after its border.
func _draw_hexenbiest(wstate: String) -> void:
	if not _hexenbiest_tex:
		_draw_blutbad(wstate)
		return
	const FW     := 128.0
	const DISP_H := 95.0
	const N      := 8
	# [row_start, row_content_h] pairs — skip the 1px dark border on each row
	var rows := [[1.0, 128.0], [130.0, 132.0], [263.0, 133.0], [397.0, 132.0]]
	var row_idx: int
	var frame_idx: int
	match wstate:
		"windup":
			row_idx = 2
			var progress := 0.0
			if c.get("enemy_move") != null:
				progress = min(1.0, c["enemy_state_time"] / float(c["enemy_move"]["windup"]))
			frame_idx = clamp(int(progress * N), 0, N - 1)
		"stunned":
			row_idx = 1
			frame_idx = int(_elapsed_ms / 200.0) % N
		_:
			row_idx = 0
			frame_idx = int(_elapsed_ms / 150.0) % N
	var row_y: float  = rows[row_idx][0]
	var row_h: float  = rows[row_idx][1]
	var disp_w := FW / row_h * DISP_H
	var src    := Rect2(float(frame_idx) * FW, row_y, FW, row_h)
	_draw_ellipse(Vector2(0, 28), disp_w * 0.35, 5.0, Color(0, 0, 0, 0.45))
	draw_texture_rect_region(_hexenbiest_tex, Rect2(disp_w * 0.5, -DISP_H + 28.0, -disp_w, DISP_H), src)

func _draw_jagerbar(wstate: String) -> void:
	var fc := Color("#412402")
	_draw_ellipse(Vector2(0,-5), 48, 36, fc)
	_draw_ellipse(Vector2(-42,-32), 26, 22, fc)
	draw_circle(Vector2(-55,-50), 6, fc)
	draw_circle(Vector2(-32,-50), 6, fc)
	_draw_ellipse(Vector2(-58,-28), 10, 8, Color("#5F5E5A"))
	draw_circle(Vector2(-62,-30), 2.5, Color.BLACK)
	draw_rect(Rect2(-26,20,9,20), fc); draw_rect(Rect2(-10,20,9,20), fc)
	draw_rect(Rect2(10,20,9,20), fc);  draw_rect(Rect2(26,20,9,20), fc)
	if wstate == "windup":
		for f in 4:
			var fx := -26.0 + f*17.0
			for i in 3: _draw_ellipse(Vector2(fx+i*2.5,42), 1.5, 3.5, Color("#1a1208"))
	# Eyes (bear-brown, almost human)
	draw_circle(Vector2(-48,-34), 3, Color("#FAEEDA"))
	draw_circle(Vector2(-38,-34), 3, Color("#FAEEDA"))
	_draw_ellipse(Vector2(-48,-34), 1.8, 1.8, fc)
	_draw_ellipse(Vector2(-38,-34), 1.8, 1.8, fc)
	draw_circle(Vector2(-48,-34), 0.8, Color.BLACK)
	draw_circle(Vector2(-38,-34), 0.8, Color.BLACK)

func _draw_fuchsbau(wstate: String) -> void:
	var fc := Color("#854F0B")
	_draw_ellipse(Vector2(0,-5), 32, 25, fc)
	_draw_ellipse(Vector2(-28,-22), 18, 16, fc)
	var ear1 := PackedVector2Array([Vector2(-38,-36),Vector2(-36,-52),Vector2(-30,-38)])
	draw_colored_polygon(ear1, fc)
	var ear2 := PackedVector2Array([Vector2(-26,-38),Vector2(-20,-52),Vector2(-18,-36)])
	draw_colored_polygon(ear2, fc)
	draw_rect(Rect2(-20,15,6,15), fc); draw_rect(Rect2(-8,15,6,15), fc)
	draw_rect(Rect2(4,15,6,15), fc);   draw_rect(Rect2(16,15,6,15), fc)
	# Tail
	var tail_pts := PackedVector2Array()
	for i in 13:
		var tt := float(i)/12.0
		tail_pts.append((1-tt)*(1-tt)*Vector2(30,-5)+2*(1-tt)*tt*Vector2(50,-30)+tt*tt*Vector2(40,0))
	draw_colored_polygon(tail_pts, fc)
	draw_circle(Vector2(50,-30), 3, Color.WHITE)
	# Eyes
	draw_circle(Vector2(-33,-24), 2.5, Color("#FAC775"))
	draw_circle(Vector2(-23,-24), 2.5, Color("#FAC775"))
	draw_circle(Vector2(-33,-24), 1, Color.BLACK)
	draw_circle(Vector2(-23,-24), 1, Color.BLACK)

# ─── drawing helpers ─────────────────────────────────────────────────────────
func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 25:
		var a := float(i)/24.0*TAU
		pts.append(center + Vector2(cos(a)*rx, sin(a)*ry))
	draw_colored_polygon(pts, color)
