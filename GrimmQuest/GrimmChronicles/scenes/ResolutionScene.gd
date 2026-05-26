extends Control

const C_BG    := Color("#100c08")
const C_CREAM := Color("#FAEEDA")
const C_DARK  := Color("#1a1208")
const C_BLOOD := Color("#993C1D")
const C_GREEN := Color("#0F6E56")
const C_GOLD  := Color("#BA7517")
const C_AMBER := Color("#c8820a")
const C_PARCH := Color("#F5E9CC")

func _ready() -> void:
	var r := GameState.result
	if r.is_empty():
		SceneNav.go_investigation()
		return
	_build_ui(r)

func _build_ui(r: Dictionary) -> void:
	var outcome: String = r.get("outcome", "wrong")

	# ── Background ──────────────────────────────────────────────────────────
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# ── Outer border panel ─────────────────────────────────────────────────
	var border_col: Color
	match outcome:
		"full":    border_col = C_GOLD
		"partial": border_col = C_AMBER
		_:         border_col = C_BLOOD

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 80; panel.offset_right = -80
	panel.offset_top  = 30; panel.offset_bottom = -30
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.07, 0.04, 1.0)
	sb.border_color = border_col
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(0)
	sb.content_margin_left = 32; sb.content_margin_right = 32
	sb.content_margin_top  = 20; sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", sb)
	add_child(panel)

	# Outer column: scrollable content area + pinned button row
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 0)
	panel.add_child(outer)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(col)

	# ── Eyebrow ─────────────────────────────────────────────────────────────
	var wesen_name: String = r.get("wesen_name", "Unknown")
	var eyebrow_text: String
	match outcome:
		"full":    eyebrow_text = "Case resolved"
		"partial": eyebrow_text = "Partial resolution"
		_:         eyebrow_text = "Wrong accusation"
	_add_label(col, eyebrow_text.to_upper(), 11, border_col)

	# ── Wesen name header ───────────────────────────────────────────────────
	_add_label(col, wesen_name, 26, C_CREAM)

	# ── Separator ───────────────────────────────────────────────────────────
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(border_col, 0.4))
	col.add_child(sep)

	# ── Narration paragraphs ────────────────────────────────────────────────
	var contract: String = GameState.player.get("contract", "")
	var wid: String = r.get("wesen_id", "")
	var wesen_data: Dictionary = Data.WESEN.get(wid, {})

	var para1: String
	var para2: String
	var para3: String

	match outcome:
		"full":
			para1 = wesen_data.get("signs", "The signs were there from the beginning.")
			para2 = wesen_data.get("weakness", "You came prepared.")
			para3 = "The threat is ended. Aunt Marie's book grows heavier by one entry."
		"partial":
			para1 = wesen_data.get("signs", "The creature matched the signs.")
			para2 = "The means you chose did not hold. It broke free."
			para3 = "It is gone — for now. You were right about the creature, wrong about the remedy. It will kill again."
		_:
			var true_wesen: Dictionary = Data.WESEN.get(wid, {})
			para1 = "You wake on the road, stitched by some kind hand."
			para2 = "The true killer was a %s. %s" % [true_wesen.get("name","unknown"), true_wesen.get("signs","")]
			para3 = "The innocent you accused wants nothing to do with you. The killer is still out there."

	_add_label(col, para1, 13, Color(C_CREAM, 0.75))
	_add_label(col, para2, 13, Color(C_CREAM, 0.75))
	_add_label(col, para3, 13, Color(C_CREAM, 0.9))

	# ── Correct answer reveal (partial/wrong) ───────────────────────────────
	if outcome != "full":
		var correct_items: Array = wesen_data.get("weakness_items", [])
		var reveal_text := "The correct means: " + " or ".join(correct_items)
		_add_label(col, reveal_text, 12, Color(border_col, 0.9))

	# ── Wesen unlock notification ───────────────────────────────────────────
	if r.get("new_wesen_unlocked", false):
		_add_label(col, "★  New diary entry unlocked: " + wesen_name, 12, C_GOLD)

	# ── Gold card ───────────────────────────────────────────────────────────
	var gold_delta: int = r.get("gold", 0)
	var gold_label := "%+d gold" % gold_delta
	var gold_col := C_GREEN if gold_delta > 0 else C_BLOOD
	_add_stat_row(col, "Gold earned", gold_label, gold_col)

	# ── Pinned footer — always visible ────────────────────────────────────────
	var sep2 := HSeparator.new()
	sep2.add_theme_color_override("color", Color(C_CREAM, 0.1))
	outer.add_child(sep2)

	var btn := _make_btn("Return to the waystation  →")
	btn.pressed.connect(func():
		GameState.result = {}
		GameState.scene = "hub"
		SceneNav.go_investigation())
	outer.add_child(btn)

func _add_label(parent: Control, text: String, size: int, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	parent.add_child(lbl)

func _add_stat_row(parent: Control, label: String, value: String, val_color: Color) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var lbl := Label.new()
	lbl.text = label.to_upper()
	lbl.add_theme_color_override("font_color", Color(C_CREAM, 0.45))
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.custom_minimum_size = Vector2(140, 0)
	row.add_child(lbl)
	var val := Label.new()
	val.text = value
	val.add_theme_color_override("font_color", val_color)
	val.add_theme_font_size_override("font_size", 18)
	row.add_child(val)
	parent.add_child(row)

func _make_btn(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.add_theme_font_size_override("font_size", 14)
	btn.custom_minimum_size = Vector2(300, 40)
	var sb_n := StyleBoxFlat.new(); var sb_h := StyleBoxFlat.new()
	sb_n.bg_color = Color("#3a2a14"); sb_h.bg_color = Color("#1a1208")
	sb_n.set_corner_radius_all(0); sb_h.set_corner_radius_all(0)
	sb_n.content_margin_left=16; sb_n.content_margin_right=16
	sb_n.content_margin_top=10;  sb_n.content_margin_bottom=10
	sb_h.content_margin_left=16; sb_h.content_margin_right=16
	sb_h.content_margin_top=10;  sb_h.content_margin_bottom=10
	btn.add_theme_stylebox_override("normal", sb_n)
	btn.add_theme_stylebox_override("hover",  sb_h)
	btn.add_theme_stylebox_override("pressed",sb_h)
	btn.add_theme_color_override("font_color", C_CREAM)
	return btn
