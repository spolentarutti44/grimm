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

	var outcome: String = r.get("outcome", "")
	var eyebrow := ""; var title := ""
	match outcome:
		"full":    eyebrow = "Case closed";            title = "The diary closes on a solved entry"
		"partial": eyebrow = "Incomplete resolution";  title = "It escapes — but named"
		"wrong":   eyebrow = "Wrong accusation";       title = "You wake to a road that did not finish you"
		_:         eyebrow = "The investigation ends"; title = "Back to the waystation"

	_add_label(col, eyebrow.to_upper(), 11, C_GOLD)
	_add_label(col, title, 22, C_CREAM)
	_add_label(col, r.get("narration", ""), 14, Color(C_CREAM, 0.8))

	if r.get("new_wesen_unlocked", false):
		_add_label(col, "★  New diary entry unlocked: " + r.get("wesen_name", ""), 12, C_GOLD)

	# Gold card
	var gold: int = r.get("gold", 0)
	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 10)
	col.add_child(grid)
	_add_stat_card(grid, "Gold", ("%+d" % gold if gold != 0 else "0"),
		C_GREEN if gold > 0 else C_BLOOD if gold < 0 else C_CREAM)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(C_CREAM, 0.15))
	col.add_child(sep)

	var back_btn := _make_btn("Return to the waystation  →")
	back_btn.pressed.connect(func():
		GameState.result = {}
		SceneNav.go_investigation())
	col.add_child(back_btn)

func _add_label(parent: Control, text: String, size: int, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	parent.add_child(lbl)

func _add_stat_card(parent: Control, label: String, value: String, val_color: Color) -> void:
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(120, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.09, 0.06, 1.0)
	sb.set_corner_radius_all(8)
	sb.content_margin_left=12; sb.content_margin_right=12
	sb.content_margin_top=8;   sb.content_margin_bottom=8
	card.add_theme_stylebox_override("panel", sb)
	_add_label(card, label.to_upper(), 10, Color(C_CREAM, 0.5))
	_add_label(card, value, 20, val_color)
	parent.add_child(card)

func _make_btn(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.add_theme_font_size_override("font_size", 14)
	btn.custom_minimum_size = Vector2(280, 38)
	var sb_n := StyleBoxFlat.new(); var sb_h := StyleBoxFlat.new()
	sb_n.bg_color = Color("#3a2a14"); sb_h.bg_color = Color("#1a1208")
	sb_n.set_corner_radius_all(6);   sb_h.set_corner_radius_all(6)
	sb_n.content_margin_left=14; sb_n.content_margin_right=14
	sb_n.content_margin_top=9;   sb_n.content_margin_bottom=9
	sb_h.content_margin_left=14; sb_h.content_margin_right=14
	sb_h.content_margin_top=9;   sb_h.content_margin_bottom=9
	btn.add_theme_stylebox_override("normal", sb_n)
	btn.add_theme_stylebox_override("hover",  sb_h)
	btn.add_theme_stylebox_override("pressed",sb_h)
	btn.add_theme_color_override("font_color", C_CREAM)
	return btn
