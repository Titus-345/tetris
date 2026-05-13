extends TileMapLayer
@onready var increaseAnnouncement = $"../IncreaseLabel"
const HighScores = preload("res://Scripts/high_scores.gd")
var score = 0
var lines_cleared = 0
var last_shape = null

var das_delay = 0.2      # time before repeat starts
var das_interval = 0.05  # time between repeated moves
var das_timer = 0.0
var das_direction = 0    # -1 for left, 1 for right
var das_active = false

var das_down_timer = 0.0
var das_down_delay = 0.2
var das_down_interval = 0.05

var lock_timer = 0.0
var lock_delay = 0.5  # seconds to allow movement after touching ground
var locking = false

func drawTheTetrisBorder():
		for x in 10:
			set_cell(Vector2i(-5+x,10), 7, Vector2i(2,0)) #bottom wall
			set_cell(Vector2i(-5+x,-11), 7, Vector2i(2,0)) #top wall
		for x in 21:
			set_cell(Vector2i(-6,10-x), 7, Vector2i(4,0)) #left wall
			set_cell(Vector2i(5,10-x), 7, Vector2i(4,0))  #right wall

#the corners
		set_cell(Vector2i(-6,10), 7, Vector2i(0,1)) # bottom left
		set_cell(Vector2i(5,10), 7, Vector2i(1,1)) # bottom right
		set_cell(Vector2i(-6,-11), 7, Vector2i(0,0)) # top left
		set_cell(Vector2i(5,-11), 7, Vector2i(1,0)) # top right
const emptyCellEquivalence = Vector2i(-1,-1)
var gravTimer = 1
var gravTimerStart = .75

func _ready() -> void:
	MyAudioPlayer.stop()
	MyAudioPlayer.stream = preload("res://Tetris_Asset_Pack/music/Type B.mp3")
	MyAudioPlayer.play()

	#DRAW THE BORDER OF THE GAME
	drawTheTetrisBorder()
var shapeInstanceCount = 0

var shapeBodyTracker: Dictionary[int, Array] = {
}

const iShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)]
const oShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]
const tShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(1,1)]
const jShape: Array[Vector2i] = [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,2)]
const lShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,2)]
const sShape: Array[Vector2i] = [Vector2i(0,1), Vector2i(1,1), Vector2i(1,0), Vector2i(2,0)]
const zShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)]
const possibleShapes = [iShape, oShape, tShape, jShape, lShape, sShape, zShape]
var once = 0

func flash_announcement():
	var tween = create_tween()
	tween.tween_property(increaseAnnouncement, "modulate:a", 1.0, 0.15)
	tween.tween_interval(1.0)
	tween.tween_property(increaseAnnouncement, "modulate:a", 0.0, 0.5)

var landed = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
var last_grav_timer_start = gravTimerStart


func _process(delta: float) -> void:
	if shapeInstanceCount != 0:
		var topped_out = shapeBodyTracker[shapeInstanceCount-1][0].y < -8 and isGrounded()
		print(str(topped_out))
		if score > 1000000 or topped_out: 
			HighScores.save_score(score, lines_cleared)
			get_tree().change_scene_to_file("res://Scenes/HighScores.tscn")
	
	var new_grav = gravTimerStart

	if score > 2000:
		new_grav = .15
	elif score > 1600:
		new_grav = .3
	elif score > 1400:
		new_grav = .4
	elif score > 1000:
		new_grav = .45
	elif score > 500:
		new_grav = .55
	elif score > 200:
		new_grav = .6

	if new_grav != last_grav_timer_start:
		last_grav_timer_start = new_grav
		gravTimerStart = new_grav
		flash_announcement()

	if once == 0:
		spawnRandom()
		once += 1

	if Input.is_action_just_pressed("Rotate"):
		rotatePiece()
	if Input.is_action_just_pressed("Drop"):
		hardDrop()

	checkInputAndTranslatePiece(delta)

	if isGrounded():
		if not locking:
			locking = true
			lock_timer = lock_delay
		else:
			lock_timer -= delta
			if lock_timer <= 0:
				locking = false
				clearRows()
				spawnRandom()
	else:
		locking = false

	if gravTimer > 0:
		gravTimer -= delta
	else:
		gravTimer = gravTimerStart
		applyGravity()

func spawnAfterDelay(delta):
	await get_tree().create_timer(gravTimerStart+.2).timeout
	spawnRandom()
	
func makeTetromino(shape: Array, location: Vector2i, color: int = 5):
	match shape:
		iShape:
			color = 0
		oShape:
			color = 1
		tShape:
			color = 2
		jShape:
			color = 3
		lShape:
			color = 4
		sShape:
			color = 5
		zShape:
			color = 6
	
	
	var sourceAtlasCoords = Vector2i(0,0)
	shapeBodyTracker[shapeInstanceCount] = []
	shapeBodyTracker[shapeInstanceCount].resize(shape.size())
	for n in shape.size():
		set_cell(Vector2i(shape[n].x+location.x, shape[n].y+location.y), color, sourceAtlasCoords)
		shapeBodyTracker[shapeInstanceCount][n] = Vector2i(shape[n].x+location.x, shape[n].y+location.y)
	shapeInstanceCount += 1
func spawnRandom():
	var randomX = randi_range(-5, 1)
	var newShape = possibleShapes.pick_random()
	while newShape == last_shape:
		newShape = possibleShapes.pick_random()
	last_shape = newShape
	makeTetromino(newShape, Vector2i(randomX, -9), randi_range(0, 6))
func applyGravity(): 
	var n = shapeInstanceCount - 1
	var unsafe = false
	#print("----------------") #to distinguish different shapes in terminal
	for i in shapeBodyTracker[n].size():
		if (get_cell_atlas_coords(Vector2i(shapeBodyTracker[n][i].x, shapeBodyTracker[n][i].y+1)) != emptyCellEquivalence): #is cell below shape tiles != empty?
			if not Vector2i(shapeBodyTracker[n][i].x, shapeBodyTracker[n][i].y+1) in shapeBodyTracker[n]: #and its not my own dang tile check????
				#print("It's full with another shape's tile!! at cell below -> " + str(shapeBodyTracker[n][i]))
				unsafe = true
		else:
			pass #print("the spots below the lowest tiles associated with the shape are empty!!")
	if unsafe == false:
		if shapeBodyTracker[n]:
			var color = get_cell_source_id(shapeBodyTracker[n][0])
			for vector in shapeBodyTracker[n].size():
				erase_cell(shapeBodyTracker[n][vector])
			for vector in shapeBodyTracker[n].size():
				set_cell(Vector2i(shapeBodyTracker[n][vector].x, shapeBodyTracker[n][vector].y+1), color, Vector2i(0,0))
				shapeBodyTracker[n][vector].y += 1
				#print(vector)
func checkInputAndTranslatePiece(delta: float):
	if Input.is_action_just_pressed("Left"):
		translatePiece(-1)
		das_direction = -1
		das_timer = das_delay
		das_active = false
	elif Input.is_action_just_pressed("Right"):
		translatePiece(1)
		das_direction = 1
		das_timer = das_delay
		das_active = false

	if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		das_timer -= delta
		if das_timer <= 0:
			das_active = true
			das_timer = das_interval
			translatePiece(das_direction)
	else:
		das_timer = 0.0
		das_active = false
		
	if Input.is_action_just_pressed("Down"):
		softDrop()
		das_down_timer = das_down_delay
	elif Input.is_action_pressed("Down"):
		das_down_timer -= delta
		if das_down_timer <= 0:
			das_down_timer = das_down_interval
			softDrop()

func translatePiece(dir: int):
	var unsafe = false
	for cellNumber in shapeBodyTracker[shapeInstanceCount-1].size():
		if get_cell_atlas_coords(Vector2i(shapeBodyTracker[shapeInstanceCount-1][cellNumber].x+dir, shapeBodyTracker[shapeInstanceCount-1][cellNumber].y)) != emptyCellEquivalence:
			if not Vector2i(shapeBodyTracker[shapeInstanceCount-1][cellNumber].x+dir, shapeBodyTracker[shapeInstanceCount-1][cellNumber].y) in shapeBodyTracker[shapeInstanceCount-1]:
				unsafe = true
	if !unsafe:
		var color = get_cell_source_id(shapeBodyTracker[shapeInstanceCount-1][0])
		for vector in shapeBodyTracker[shapeInstanceCount-1].size():
			erase_cell(shapeBodyTracker[shapeInstanceCount-1][vector])
		for vector in shapeBodyTracker[shapeInstanceCount-1].size():
			set_cell(Vector2i(shapeBodyTracker[shapeInstanceCount-1][vector].x+dir, shapeBodyTracker[shapeInstanceCount-1][vector].y), color, Vector2i(0,0))
			shapeBodyTracker[shapeInstanceCount-1][vector].x += dir
func rotatePiece():
	var piece = shapeBodyTracker[shapeInstanceCount - 1]
	
	# Skip rotation for O shape (2x2 square)
	if piece.size() == 4:
		var xs = []
		for c in piece:
			xs.append(c.x)
		var ys = []
		for c in piece:
			ys.append(c.y)
		if xs.max() - xs.min() == 1 and ys.max() - ys.min() == 1:
			return
	
	# Find the pivot (center cell of the active piece)
	var pivot = piece[1]
	
	var rotated = []
	for cell in piece:
		var relative = cell - pivot
		var newRelative = Vector2i(-relative.y, relative.x)
		rotated.append(pivot + newRelative)
	
	# Check if any rotated position is blocked
	for cell in rotated:
		if get_cell_atlas_coords(cell) != emptyCellEquivalence:
			if cell not in piece:
				return # Blocked, cancel rotation
	
	# Apply rotation
	var color = get_cell_source_id(piece[0])
	for cell in piece:
		erase_cell(cell)
	for i in piece.size():
		set_cell(rotated[i], color, Vector2i(0, 0))
		shapeBodyTracker[shapeInstanceCount - 1][i] = rotated[i]

func softDrop():
	gravTimer = 0.0
func hardDrop():
	while !isGrounded():
		var color = get_cell_source_id(shapeBodyTracker[shapeInstanceCount-1][0])
		for vector in shapeBodyTracker[shapeInstanceCount-1].size():
			erase_cell(shapeBodyTracker[shapeInstanceCount-1][vector])
		for vector in shapeBodyTracker[shapeInstanceCount-1].size():
			set_cell(Vector2i(shapeBodyTracker[shapeInstanceCount-1][vector].x, shapeBodyTracker[shapeInstanceCount-1][vector].y+1), color, Vector2i(0,0))
			shapeBodyTracker[shapeInstanceCount-1][vector].y += 1

func isGrounded() -> bool:
	for i in shapeBodyTracker[shapeInstanceCount - 1].size():
		var below = Vector2i(
			shapeBodyTracker[shapeInstanceCount - 1][i].x,
			shapeBodyTracker[shapeInstanceCount - 1][i].y + 1
		)

		if get_cell_atlas_coords(below) != emptyCellEquivalence:
			if below not in shapeBodyTracker[shapeInstanceCount - 1]:
				return true

	return false

func clearRows():
	var rows_cleared_this_turn = 0
	var row = 9
	while row >= -10:
		var full = true
		for col in range(-5, 5):
			if get_cell_atlas_coords(Vector2i(col, row)) == emptyCellEquivalence:
				full = false
				break
		
		if full:
			rows_cleared_this_turn += 1

			# flash white tile across the row
			for col in range(-5, 5):
				set_cell(Vector2i(col, row), 9, Vector2i(0, 0))
			
			await get_tree().create_timer(0.3).timeout

			# cache all colors before touching anything
			var colorCache: Dictionary = {}
			for n in shapeBodyTracker:
				for cell in shapeBodyTracker[n]:
					colorCache[cell] = get_cell_source_id(cell)

			# erase the full row
			for col in range(-5, 5):
				erase_cell(Vector2i(col, row))

			# erase all cells above the cleared row
			for n in shapeBodyTracker:
				for cell in shapeBodyTracker[n]:
					if cell.y < row:
						erase_cell(cell)

			# rebuild tracker and redraw
			for n in shapeBodyTracker:
				var newCells = []
				for cell in shapeBodyTracker[n]:
					if cell.y == row:
						pass
					elif cell.y < row:
						set_cell(Vector2i(cell.x, cell.y + 1), colorCache[cell], Vector2i(0, 0))
						newCells.append(Vector2i(cell.x, cell.y + 1))
					else:
						newCells.append(cell)
				shapeBodyTracker[n] = newCells
		else:
			row -= 1

	match rows_cleared_this_turn:
		1: score += 100
		2: score += 300
		3: score += 500
		4: score += 800
	lines_cleared += rows_cleared_this_turn
