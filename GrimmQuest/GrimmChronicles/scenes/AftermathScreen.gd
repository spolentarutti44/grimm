extends Control

const C_BG    := Color("#0a0a0a")
const C_CREAM := Color("#FAEEDA")
const C_DARK  := Color("#1a1208")
const C_BLOOD := Color("#993C1D")
const C_GREEN := Color("#0F6E56")
const C_GOLD  := Color("#BA7517")

func _ready() -> void:
	var r := GameState.result
	if r.is_empty():
		SceneNav.go_investigation()
		return
	_build_ui(r)

func _build_ui(r: Dictionary) -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.custom_minimum_size = Vector2(520, 0)
	col.position = Vector2(-260, -180)
	col.add_theme_constant_override("separation", 14)
	add_child(col)

	var outcome: String = r.get("outcome","")
	var eyebrow := ""
	var title   := ""
	match outcome:
		"killed":  eyebrow = "After the killing";  title = "The diary closes"
		"spared":  eyebrow = "After the mercy";    title = "The diary opens"
		"defeated":eyebrow = "After the run";      title = "You wake to a road that did not finish you"

	var ey := Label.new()
	ey.text = eyebrow.to_upper()
	ey.add_theme_color_override("font_color", C_GOLD)
	ey.add_theme_font_size_override("font_size", 11)
	col.add_child(ey)

	var tl := Label.new()
	tl.text = title
	tl.add_theme_color_override("font_color", C_CREAM)
	tl.add_theme_font_size_override("font_size", 22)
	tl.autowrap_mode = TextServer.AUTOWRAP_WORD
	col.add_child(tl)

	var narr := Label.new()
	narr.text = r.get("narration","")
	narr.add_theme_color_override("font_color", Color(C_CREAM.r,C_CREAM.g,C_CREAM.b,0.8))
	narr.add_theme_font_size_override("font_size", 14)
	narr.autowrap_mode = TextServer.AUTOWRAP_WORD
	col.add_child(narr)

	# Deduction result (not shown for random encounters)
	if not r.get("is_encounter", false):
		var deduct_lbl := Label.new()
		deduct_lbl.add_theme_font_size_override("font_size", 12)
		deduct_lbl.add_theme_color_override("font_color", Color(C_CREAM.r,C_CREAM.g,C_CREAM.b,0.6))
		if r.get("correct", false):
			deduct_lbl.text = "Your deduction was sound."
		elif outcome != "defeated":
			deduct_lbl.text = "You read the signs wrong."
			deduct_lbl.add_theme_color_override("font_color", C_BLOOD)
		col.add_child(deduct_lbl)

	# Stats grid
	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 10)
	col.add_child(grid)

	var gold: int = r.get("gold",0)
	var xp:   int = r.get("xp",0)
	_add_stat_card(grid, "Gold", ("%+d" % gold if gold != 0 else "0"),
		C_GREEN if gold > 0 else C_BLOOD if gold < 0 else C_CREAM)
	_add_stat_card(grid, "XP", "+%d" % xp, C_CREAM)
	if r.get("level_up", false):
		_add_stat_card(grid, "Level", "↑ %d" % GameState.player["level"], C_GREEN)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(C_CREAM.r,C_CREAM.g,C_CREAM.b,0.15))
	col.add_child(sep)

	var back_label := "Return to the investigation  →" if r.get("is_encounter", false) \
		else "Return to the waystation  →"
	var back_btn := _make_btn(back_label)
	back_btn.pressed.connect(func():
		GameState.result = {}
		SceneNav.go_investigation())
	col.add_child(back_btn)

func _add_stat_card(parent: Control, label: String, value: String, val_color: Color) -> void:
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(120, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12,0.09,0.06,1.0)
	sb.set_corner_radius_all(8)
	sb.content_margin_left=12; sb.content_margin_right=12
	sb.content_margin_top=8;   sb.content_margin_bottom=8
	card.add_theme_stylebox_override("panel", sb)

	var lbl := Label.new()
	lbl.text = label.to_upper()
	lbl.add_theme_color_override("font_color", Color(C_CREAM.r,C_CREAM.g,C_CREAM.b,0.5))
	lbl.add_theme_font_size_override("font_size", 10)
	card.add_child(lbl)

	var val := Label.new()
	val.text = value
	val.add_theme_color_override("font_color", val_color)
	val.add_theme_font_size_override("font_size", 20)
	card.add_child(val)

	parent.add_child(card)

func _make_btn(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.add_theme_font_size_override("font_size", 14)
	btn.custom_minimum_size = Vector2(280, 38)
	var sb_n := StyleBoxFlat.new()
	var sb_h := StyleBoxFlat.new()
	sb_n.bg_color = Color("#3a2a14"); sb_h.bg_color = Color("#1a1208")
	sb_n.set_corner_radius_all(6); sb_h.set_corner_radius_all(6)
	sb_n.content_margin_left=14; sb_n.content_margin_right=14
	sb_n.content_margin_top=9;   sb_n.content_margin_bottom=9
	sb_h.content_margin_left=14; sb_h.content_margin_right=14
	sb_h.content_margin_top=9;   sb_h.content_margin_bottom=9
	btn.add_theme_stylebox_override("normal", sb_n)
	btn.add_theme_stylebox_override("hover",  sb_h)
	btn.add_theme_stylebox_override("pressed",sb_h)
	btn.add_theme_color_override("font_color", C_CREAM)
	return btn
