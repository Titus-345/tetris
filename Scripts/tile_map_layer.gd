extends TileMapLayer

func drawTheTetrisBorder():
		for x in 10:
			set_cell(Vector2i(-5+x,10), 7, Vector2i(2,0)) #bottom wall
			set_cell(Vector2i(-5+x,-10), 7, Vector2i(2,0)) #top wall
		for x in 20:
			set_cell(Vector2i(-6,10-x), 7, Vector2i(4,0)) #left wall
			set_cell(Vector2i(5,10-x), 7, Vector2i(4,0))  #right wall

#the corners
		set_cell(Vector2i(-6,10), 7, Vector2i(0,1)) # bottom left
		set_cell(Vector2i(5,10), 7, Vector2i(1,1)) # bottom right
		set_cell(Vector2i(-6,-10), 7, Vector2i(0,0)) # top left
		set_cell(Vector2i(5,-10), 7, Vector2i(1,0)) # top right
const emptyCellEquivalence = Vector2i(-1,-1)
var gravTimer = 1

func _ready() -> void:
	#DRAW THE BORDER OF THE GAME
	drawTheTetrisBorder()
	
var shapeInstanceCount = 0
var shapeBodyTracker: Dictionary[int, Array] = {
}

const iShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]
const oShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]
const tShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(1,1)]
const jShape: Array[Vector2i] = [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,2)]
const lShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,2)]
const sShape: Array[Vector2i] = [Vector2i(0,1), Vector2i(1,1), Vector2i(1,0), Vector2i(2,0)]
const zShape: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)]
const possibleShapes = [iShape, oShape, tShape, jShape, lShape, sShape, zShape]
var once = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if once == 0:
		spawnRandom()
		once += 1
	
	
	if gravTimer > 0:
		gravTimer -= delta
	else:
		gravTimer = 1
		applyGravity()
	if 0 == isGrounded():
		checkInputAndTranslatePiece()
	else:
		await get_tree().create_timer(1.5).timeout
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
	var randomX = randi_range(-5,2)
	makeTetromino(possibleShapes.pick_random(), Vector2i(randomX,-9), randi_range(0,6))
func applyGravity():
	for n in shapeInstanceCount:
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
			var color = get_cell_source_id(shapeBodyTracker[n][0])
			for vector in shapeBodyTracker[n].size():
				erase_cell(shapeBodyTracker[n][vector])
			for vector in shapeBodyTracker[n].size():
				set_cell(Vector2i(shapeBodyTracker[n][vector].x, shapeBodyTracker[n][vector].y+1), color, Vector2i(0,0))
				shapeBodyTracker[n][vector].y += 1
				#print(vector)
func checkInputAndTranslatePiece():
	if Input.is_action_just_pressed("Left"):
		var unsafe = false
		for cellNumber in shapeBodyTracker[shapeInstanceCount-1].size():
			if get_cell_atlas_coords(Vector2i(shapeBodyTracker[shapeInstanceCount-1][cellNumber].x-1,shapeBodyTracker[shapeInstanceCount-1][cellNumber].y)) != emptyCellEquivalence:
				if not Vector2i(shapeBodyTracker[shapeInstanceCount-1][cellNumber].x-1,shapeBodyTracker[shapeInstanceCount-1][cellNumber].y) in shapeBodyTracker[shapeInstanceCount-1]:
					unsafe = true
		var color = get_cell_source_id(shapeBodyTracker[shapeInstanceCount-1][0])
		if !unsafe:
			for vector in shapeBodyTracker[shapeInstanceCount-1].size():
				erase_cell(shapeBodyTracker[shapeInstanceCount-1][vector])
			for vector in shapeBodyTracker[shapeInstanceCount-1].size():
				set_cell(Vector2i(shapeBodyTracker[shapeInstanceCount-1][vector].x-1, shapeBodyTracker[shapeInstanceCount-1][vector].y), color, Vector2i(0,0))
				shapeBodyTracker[shapeInstanceCount-1][vector].x -= 1
	if Input.is_action_just_pressed("Right"):
		var unsafe = false
		for cellNumber in shapeBodyTracker[shapeInstanceCount-1].size():
			if get_cell_atlas_coords(Vector2i(shapeBodyTracker[shapeInstanceCount-1][cellNumber].x+1,shapeBodyTracker[shapeInstanceCount-1][cellNumber].y)) != emptyCellEquivalence:
				if not Vector2i(shapeBodyTracker[shapeInstanceCount-1][cellNumber].x+1,shapeBodyTracker[shapeInstanceCount-1][cellNumber].y) in shapeBodyTracker[shapeInstanceCount-1]:
					unsafe = true
		var color = get_cell_source_id(shapeBodyTracker[shapeInstanceCount-1][0])
		if !unsafe:
			for vector in shapeBodyTracker[shapeInstanceCount-1].size():
				erase_cell(shapeBodyTracker[shapeInstanceCount-1][vector])
			for vector in shapeBodyTracker[shapeInstanceCount-1].size():
				set_cell(Vector2i(shapeBodyTracker[shapeInstanceCount-1][vector].x+1, shapeBodyTracker[shapeInstanceCount-1][vector].y), color, Vector2i(0,0))
				shapeBodyTracker[shapeInstanceCount-1][vector].x += 1
func isGrounded() -> float:
		var smthBelow: float = 0
		#print("----------------") #to distinguish different shapes in terminal
		for i in shapeBodyTracker[shapeInstanceCount-1].size():
			if (get_cell_atlas_coords(Vector2i(shapeBodyTracker[shapeInstanceCount-1][i].x, shapeBodyTracker[shapeInstanceCount-1][i].y+1)) != emptyCellEquivalence): #is cell below shape tiles != empty?
				if not Vector2i(shapeBodyTracker[shapeInstanceCount-1][i].x, shapeBodyTracker[shapeInstanceCount-1][i].y+1) in shapeBodyTracker[shapeInstanceCount-1]: #and its not my own dang tile check????
					#print("It's full with another shape's tile!! at cell below -> " + str(shapeBodyTracker[shapeInstanceCount-1][i]))
					smthBelow = true
				else:
					pass#print("the spots below the lowest tiles associated with the shape are empty!!")
		if smthBelow:
				return 1
		else:
				return 0
