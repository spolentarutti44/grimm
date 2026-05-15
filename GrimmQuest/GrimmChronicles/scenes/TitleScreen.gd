extends Control

# Parchment palette
const C_BG      := Color("#0a0a0a")
const C_CREAM   := Color("#FAEEDA")
const C_DARK    := Color("#1a1208")
const C_BROWN   := Color("#3a2a14")
const C_BLOOD   := Color("#993C1D")
const C_GOLD    := Color("#BA7517")

func _ready() -> void:
	GameState.load_save()
	# If the player had already started, jump straight in
	if GameState.player.get("started", false):
		SceneNav.go_investigation()
		return
	_build_ui()

func _build_ui() -> void:
	# Dark canvas background
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Centred column
	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.custom_minimum_size = Vector2(480, 0)
	center.add_theme_constant_override("separation", 16)
	# Shift it slightly above absolute center
	center.position = Vector2(-240, -140)
	add_child(center)

	# Eye-brow label
	var eyebrow := Label.new()
	eyebrow.text = "A BOOK OF HUNTS"
	eyebrow.add_theme_color_override("font_color", C_GOLD)
	eyebrow.add_theme_font_size_override("font_size", 11)
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(eyebrow)

	# Title
	var title := Label.new()
	title.text = "The Grimm Chronicles"
	title.add_theme_color_override("font_color", C_CREAM)
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)

	# Tagline
	var tag := Label.new()
	tag.text = "A point-and-click mystery with action-timing duels.\nInvestigate. Deduce. Strike true."
	tag.add_theme_color_override("font_color", Color(0.98, 0.93, 0.85, 0.7))
	tag.add_theme_font_size_override("font_size", 13)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.autowrap_mode = TextServer.AUTOWRAP_WORD
	center.add_child(tag)

	# Divider
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(0.98, 0.93, 0.85, 0.15))
	center.add_child(sep)

	# Buttons row
	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_CENTER
	btns.add_theme_constant_override("separation", 12)
	center.add_child(btns)

	var has_save := FileAccess.file_exists(GameState.SAVE_PATH)

	var start_btn := _make_btn(("Continue" if has_save else "Begin the hunt"), true)
	start_btn.pressed.connect(_on_start)
	btns.add_child(start_btn)

	if has_save:
		var new_btn := _make_btn("New game", false)
		new_btn.pressed.connect(_on_new_game)
		btns.add_child(new_btn)

	# Controls hint
	var hint := Label.new()
	hint.text = "Investigation: Click / WASD + E to interact\nCombat: A/D dodge · J parry · K strike · Shift block"
	hint.add_theme_color_override("font_color", Color(0.98, 0.93, 0.85, 0.45))
	hint.add_theme_font_size_override("font_size", 11)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	center.add_child(hint)

func _make_btn(label: String, primary: bool) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.add_theme_font_size_override("font_size", 14)
	btn.custom_minimum_size = Vector2(160, 36)

	var sb_n := StyleBoxFlat.new()
	var sb_h := StyleBoxFlat.new()
	if primary:
		sb_n.bg_color = C_BLOOD
		sb_h.bg_color = Color("#712B13")
	else:
		sb_n.bg_color = C_BROWN
		sb_h.bg_color = Color("#2a1f12")
	sb_n.set_corner_radius_all(6)
	sb_h.set_corner_radius_all(6)
	sb_n.content_margin_left   = 12; sb_n.content_margin_right  = 12
	sb_n.content_margin_top    = 8;  sb_n.content_margin_bottom = 8
	sb_h.content_margin_left   = 12; sb_h.content_margin_right  = 12
	sb_h.content_margin_top    = 8;  sb_h.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", sb_n)
	btn.add_theme_stylebox_override("hover",  sb_h)
	btn.add_theme_stylebox_override("pressed",sb_h)
	btn.add_theme_color_override("font_color", C_CREAM)
	return btn

func _on_start() -> void:
	GameState.load_save()
	GameState.player["started"] = true
	GameState.save()
	SceneNav.go_investigation()

func _on_new_game() -> void:
	# Simple confirm via AcceptDialog
	var dlg := ConfirmationDialog.new()
	dlg.dialog_text = "Erase this diary and begin again?"
	dlg.confirmed.connect(_do_new_game)
	add_child(dlg)
	dlg.popup_centered()

func _do_new_game() -> void:
	GameState.reset()
	GameState.player["started"] = true
	GameState.save()
	SceneNav.go_investigation()
