extends Node2D

const TILE_SIZE = 16
const COLS = 10
const ROWS = 20
const ORIGIN_X = -5
const ORIGIN_Y = -10

func _ready() -> void:
	var cam = get_viewport().get_camera_2d()
	var zoom = cam.zoom.x if cam else 1.0
	var cam_offset = get_viewport().get_canvas_transform().origin

	material = ShaderMaterial.new()
	material.shader = load("res://grid.gdshader")
	material.set_shader_parameter("tile_size", TILE_SIZE * zoom)
	material.set_shader_parameter("offset", cam_offset)
	material.set_shader_parameter("grid_color", Color(0.0, 0.0, 0.0, 0.2))

func _draw() -> void:
	var top_left = Vector2(ORIGIN_X * TILE_SIZE, ORIGIN_Y * TILE_SIZE)
	draw_rect(Rect2(top_left, Vector2(COLS * TILE_SIZE, ROWS * TILE_SIZE)), Color(0, 0, 0, 0))
