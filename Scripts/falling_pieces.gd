extends Node2D

const TETROMINOES = [
	[[0,0],[1,0],[2,0],[3,0]],   # I
	[[0,0],[0,1],[1,1],[2,1]],   # J
	[[2,0],[0,1],[1,1],[2,1]],   # L
	[[0,0],[1,0],[0,1],[1,1]],   # O
	[[1,0],[2,0],[0,1],[1,1]],   # S
	[[0,0],[1,0],[2,0],[1,1]],   # T
	[[0,0],[1,0],[1,1],[2,1]],   # Z
]

const COLORS = [
	Color(0.0, 0.9, 0.9, 0.5),  # cyan   I
	Color(0.0, 0.3, 1.0, 0.5),  # blue   J
	Color(1.0, 0.6, 0.0, 0.5),  # orange L
	Color(1.0, 0.9, 0.0, 0.5),  # yellow O
	Color(0.0, 0.8, 0.2, 0.5),  # green  S
	Color(0.8, 0.0, 0.9, 0.5),  # purple T
	Color(0.9, 0.1, 0.1, 0.5),  # red    Z
]

const BLOCK_SIZE = 30
const SPAWN_INTERVAL = 0.6
const FALL_SPEED_MIN = 60.0
const FALL_SPEED_MAX = 140.0

var _timer: float = 0.0
var _pieces: Array = []
var _screen_size: Vector2

func _ready():
	_screen_size = get_viewport_rect().size

func _process(delta: float):
	_timer += delta
	if _timer >= SPAWN_INTERVAL:
		_timer = 0.0
		_spawn_piece()

	for piece in _pieces:
		piece["pos"].y += piece["speed"] * delta
		piece["angle"] += piece["rotation_speed"] * delta

	_pieces = _pieces.filter(func(p): return p["pos"].y < _screen_size.y + 200)
	queue_redraw()

func _spawn_piece():
	var idx   = randi() % TETROMINOES.size()
	var cells = TETROMINOES[idx]
	var col   = COLORS[idx]
	var speed = randf_range(FALL_SPEED_MIN, FALL_SPEED_MAX)
	var rot   = randf_range(-0.4, 0.4)
	var x     = randf_range(0, _screen_size.x)

	_pieces.append({
		"cells": cells,
		"color": col,
		"pos":   Vector2(x, -BLOCK_SIZE * 4),
		"speed": speed,
		"rotation_speed": rot,
		"angle": 0.0
	})

func _draw():
	for piece in _pieces:
		for cell in piece["cells"]:
			var local = Vector2(cell[0] * BLOCK_SIZE, cell[1] * BLOCK_SIZE)
			var cx = 1.5 * BLOCK_SIZE
			var cy = 1.5 * BLOCK_SIZE
			local = (local - Vector2(cx, cy)).rotated(piece["angle"]) + Vector2(cx, cy)
			var rect = Rect2(piece["pos"] + local, Vector2(BLOCK_SIZE - 2, BLOCK_SIZE - 2))
			draw_rect(rect, piece["color"], true)
			draw_rect(rect, piece["color"].lightened(0.4), false)
