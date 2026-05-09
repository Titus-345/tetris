extends Node2D

const C_BG     = Color(0.04, 0.04, 0.12)
const C_GRID   = Color(0.10, 0.10, 0.28)
const C_CYAN   = Color(0.0,  0.95, 0.95)
const C_YELLOW = Color(1.0,  0.92, 0.0)
const C_DIM    = Color(0.35, 0.35, 0.55)
const C_WHITE  = Color(1.0,  1.0,  1.0)

const SAVE_PATH   = "user://highscores.dat"
const MAX_SCORES  = 10

var _screen: Vector2

func _ready():
	_screen = get_viewport_rect().size
	_build_ui()

func _build_ui():
	# background
	var bg = ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = _screen
	add_child(bg)

	# main vbox
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.custom_minimum_size = Vector2(420, 0)
	add_child(vbox)

	# title
	var title = Label.new()
	title.text = "HIGH SCORES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(420, 0)
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", C_YELLOW)
	title.add_theme_constant_override("outline_size", 3)
	title.add_theme_color_override("font_outline_color", Color(0.4, 0.35, 0.0))
	vbox.add_child(title)

	# divider spacer
	var sp1 = Control.new()
	sp1.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(sp1)

	# header row
	var header = _make_row("RANK", "SCORE", "LINES", C_DIM, 16)
	vbox.add_child(header)

	var div = ColorRect.new()
	div.color = C_DIM
	div.custom_minimum_size = Vector2(420, 1)
	vbox.add_child(div)

	var sp2 = Control.new()
	sp2.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(sp2)

	# scores
	var scores = load_scores()
	if scores.is_empty():
		var empty = Label.new()
		empty.text = "No scores yet. Play a game!"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size", 16)
		empty.add_theme_color_override("font_color", C_DIM)
		vbox.add_child(empty)
	else:
		for i in scores.size():
			var entry = scores[i]
			var col = C_YELLOW if i == 0 else C_WHITE
			if i >= 3:
				col = C_DIM
			var row = _make_row(
				"#" + str(i + 1),
				str(entry["score"]),
				str(entry["lines"]),
				col,
				20
			)
			vbox.add_child(row)

	# spacer before button
	var sp3 = Control.new()
	sp3.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(sp3)

	# back button
	var btn = Button.new()
	btn.text = "◀  BACK TO MENU"
	btn.custom_minimum_size = Vector2(300, 54)
	btn.focus_mode = Control.FOCUS_NONE

	var sn = StyleBoxFlat.new()
	sn.bg_color = Color(C_CYAN.r, C_CYAN.g, C_CYAN.b, 0.08)
	sn.border_color = C_CYAN
	sn.set_border_width_all(2)
	sn.set_corner_radius_all(4)
	sn.content_margin_left = 20
	sn.content_margin_right = 20

	var sh = StyleBoxFlat.new()
	sh.bg_color = Color(C_CYAN.r, C_CYAN.g, C_CYAN.b, 0.22)
	sh.border_color = C_CYAN
	sh.set_border_width_all(2)
	sh.set_corner_radius_all(4)
	sh.content_margin_left = 20
	sh.content_margin_right = 20

	btn.add_theme_stylebox_override("normal", sn)
	btn.add_theme_stylebox_override("hover",  sh)
	btn.add_theme_stylebox_override("focus",  sn)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color",       C_CYAN)
	btn.add_theme_color_override("font_hover_color", C_CYAN.lightened(0.3))
	btn.pressed.connect(_on_back_pressed)

	var btn_center = CenterContainer.new()
	btn_center.custom_minimum_size = Vector2(420, 0)
	btn_center.add_child(btn)
	vbox.add_child(btn_center)

	# center the whole vbox
	await get_tree().process_frame
	vbox.position = Vector2(
		(_screen.x - vbox.size.x) / 2.0,
		(_screen.y - vbox.size.y) / 2.0
	)

func _make_row(rank: String, score: String, lines: String, col: Color, size: int) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(420, 0)

	var lbl_rank = Label.new()
	lbl_rank.text = rank
	lbl_rank.custom_minimum_size = Vector2(80, 0)
	lbl_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_rank.add_theme_font_size_override("font_size", size)
	lbl_rank.add_theme_color_override("font_color", col)

	var lbl_score = Label.new()
	lbl_score.text = score
	lbl_score.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_score.add_theme_font_size_override("font_size", size)
	lbl_score.add_theme_color_override("font_color", col)

	var lbl_lines = Label.new()
	lbl_lines.text = lines
	lbl_lines.custom_minimum_size = Vector2(100, 0)
	lbl_lines.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_lines.add_theme_font_size_override("font_size", size)
	lbl_lines.add_theme_color_override("font_color", col)

	row.add_child(lbl_rank)
	row.add_child(lbl_score)
	row.add_child(lbl_lines)
	return row

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

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# ── save / load ──────────────────────────────────────────────

static func save_score(new_score: int, new_lines: int):
	var scores = load_scores()
	scores.append({"score": new_score, "lines": new_lines})
	scores.sort_custom(func(a, b): return a["score"] > b["score"])
	if scores.size() > MAX_SCORES:
		scores.resize(MAX_SCORES)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(scores)
		file.close()

static func load_scores() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		return data
	return []
