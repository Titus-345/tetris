extends Node2D

func _ready():
	var screen = get_viewport_rect().size
	var font = load("res://nintendo-nes-font.ttf")

	var canvas = CanvasLayer.new()
	add_child(canvas)

	var btn = Button.new()
	btn.text = "QUIT"
	btn.custom_minimum_size = Vector2(100, 36)
	btn.focus_mode = Control.FOCUS_NONE
	btn.position = Vector2(screen.x - 120, 16)

	var sn = StyleBoxFlat.new()
	sn.bg_color = Color(0.04, 0.04, 0.12)
	sn.border_color = Color(0.0, 0.95, 0.95)
	sn.set_border_width_all(2)
	sn.set_corner_radius_all(0)
	sn.content_margin_left = 10
	sn.content_margin_right = 10

	var sh = StyleBoxFlat.new()
	sh.bg_color = Color(0.0, 0.95, 0.95, 0.15)
	sh.border_color = Color(0.0, 0.95, 0.95)
	sh.set_border_width_all(2)
	sh.set_corner_radius_all(0)
	sh.content_margin_left = 10
	sh.content_margin_right = 10

	var sp = StyleBoxFlat.new()
	sp.bg_color = Color(0.0, 0.95, 0.95, 0.30)
	sp.border_color = Color(1.0, 1.0, 1.0)
	sp.set_border_width_all(2)
	sp.set_corner_radius_all(0)
	sp.content_margin_left = 10
	sp.content_margin_right = 10

	btn.add_theme_stylebox_override("normal",  sn)
	btn.add_theme_stylebox_override("hover",   sh)
	btn.add_theme_stylebox_override("pressed", sp)
	btn.add_theme_stylebox_override("focus",   sn)
	btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color",         Color(0.0, 0.95, 0.95))
	btn.add_theme_color_override("font_hover_color",   Color(1.0, 1.0, 1.0))
	btn.add_theme_color_override("font_pressed_color", Color(0.04, 0.04, 0.12))

	btn.pressed.connect(func(): get_tree().quit())
	canvas.add_child(btn)
