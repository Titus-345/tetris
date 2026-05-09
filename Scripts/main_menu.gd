extends Node2D

const C_BG        = Color(0.04, 0.04, 0.12)
const C_GRID      = Color(0.10, 0.10, 0.28)
const C_CYAN      = Color(0.0,  0.95, 0.95)
const C_YELLOW    = Color(1.0,  0.92, 0.0)
const C_WHITE     = Color(1.0,  1.0,  1.0)
const C_DIM       = Color(0.35, 0.35, 0.55)

var _screen: Vector2
var _title_tween: Tween
var _vbox: VBoxContainer

func _ready():
	_screen = get_viewport_rect().size
	_build_ui()
	_animate_title()

func _build_ui():
	var bg = ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = _screen
	add_child(bg)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.custom_minimum_size = Vector2(320, 0)
	add_child(vbox)
	_vbox = vbox

	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "TETRIS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(320, 0)
	title.add_theme_font_size_override("font_size", 88)
	title.add_theme_color_override("font_color", C_CYAN)
	title.add_theme_constant_override("outline_size", 3)
	title.add_theme_color_override("font_outline_color", Color(0, 0.4, 0.4))
	vbox.add_child(title)

	var sub = Label.new()
	sub.text = "— PRESS PLAY TO START —"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", C_DIM)
	vbox.add_child(sub)

	var sp = Control.new()
	sp.custom_minimum_size = Vector2(0, 32)
	vbox.add_child(sp)

	_make_button(vbox, "▶  PLAY",        C_CYAN,   _on_play_pressed)
	_make_button(vbox, "★  HIGH SCORES", C_YELLOW, _on_highscores_pressed)
	_make_button(vbox, "⚙  SETTINGS",    C_WHITE,  _on_settings_pressed)
	_make_button(vbox, "✕  QUIT",        C_DIM,    _on_quit_pressed)

	var ver = Label.new()
	ver.text = "v1.0"
	ver.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	ver.position = Vector2(-60, -30)
	ver.add_theme_font_size_override("font_size", 11)
	ver.add_theme_color_override("font_color", C_DIM)
	add_child(ver)

	await get_tree().process_frame
	vbox.position = Vector2(
		(_screen.x - vbox.size.x) / 2.0,
		(_screen.y - vbox.size.y) / 2.0
	)

func _make_button(parent: Node, txt: String, col: Color, cb: Callable):
	var btn = Button.new()
	btn.text = txt
	btn.custom_minimum_size = Vector2(300, 54)
	btn.focus_mode = Control.FOCUS_NONE

	var sn = StyleBoxFlat.new()
	sn.bg_color = Color(col.r, col.g, col.b, 0.08)
	sn.border_color = col
	sn.set_border_width_all(2)
	sn.set_corner_radius_all(4)
	sn.content_margin_left = 20
	sn.content_margin_right = 20

	var sh = StyleBoxFlat.new()
	sh.bg_color = Color(col.r, col.g, col.b, 0.22)
	sh.border_color = col
	sh.set_border_width_all(2)
	sh.set_corner_radius_all(4)
	sh.content_margin_left = 20
	sh.content_margin_right = 20

	var sp2 = StyleBoxFlat.new()
	sp2.bg_color = Color(col.r, col.g, col.b, 0.40)
	sp2.border_color = col.lightened(0.3)
	sp2.set_border_width_all(2)
	sp2.set_corner_radius_all(4)
	sp2.content_margin_left = 20
	sp2.content_margin_right = 20

	btn.add_theme_stylebox_override("normal",  sn)
	btn.add_theme_stylebox_override("hover",   sh)
	btn.add_theme_stylebox_override("pressed", sp2)
	btn.add_theme_stylebox_override("focus",   sn)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color",         col)
	btn.add_theme_color_override("font_hover_color",   col.lightened(0.3))
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)

	btn.pressed.connect(cb)
	parent.add_child(btn)

func _draw():
	var s = get_viewport_rect().size
	var gs = 32

	for x in range(0, int(s.x) + gs, gs):
		draw_line(Vector2(x, 0), Vector2(x, s.y), C_GRID, 1.0)
	for y in range(0, int(s.y) + gs, gs):
		draw_line(Vector2(0, y), Vector2(s.x, y), C_GRID, 1.0)

	for y in range(0, int(s.y), 4):
		draw_line(Vector2(0, y), Vector2(s.x, y), Color(0, 0, 0, 0.18), 1.0)

	draw_rect(Rect2(0, s.y - 4, s.x, 4), C_CYAN)
	draw_rect(Rect2(0, 0, s.x, 4), C_CYAN)

func _animate_title():
	await get_tree().process_frame
	var title = find_child("TitleLabel")
	if not title:
		return
	_title_tween = create_tween().set_loops()
	_title_tween.tween_property(title, "modulate:a", 0.6, 0.9)
	_title_tween.tween_property(title, "modulate:a", 1.0, 0.9)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_highscores_pressed():
	get_tree().change_scene_to_file("res://Scenes/HighScores.tscn")

func _on_settings_pressed():
	pass

func _on_quit_pressed():
	get_tree().quit()
