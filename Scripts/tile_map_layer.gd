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
var timer = 1

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
	else:
		timer = 1
		if shapeInstanceCount <= 2:
			makeTetromino(zShape, Vector2i(0,-3))
			print(shapeBodyTracker[0])
		applyGravity()
	
func makeTetromino(shape: Array, location: Vector2i, color: String = "red" ):
	shapeBodyTracker[shapeInstanceCount] = []
	shapeBodyTracker[shapeInstanceCount].resize(shape.size())
	for n in shape.size():
		set_cell(Vector2i(shape[n].x+location.x, shape[n].y+location.y), 5, Vector2i(0,0))
		shapeBodyTracker[shapeInstanceCount][n] = Vector2i(shape[n].x+location.x, shape[n].y+location.y)
	shapeInstanceCount += 1

func applyGravity():
	var unsafe = true
	for n in shapeInstanceCount:
		for i in shapeBodyTracker[n].size():
			if (get_cell_atlas_coords(Vector2i(shapeBodyTracker[n][i].x, shapeBodyTracker[n][i].y+1)) != emptyCellEquivalence): #is cell below shape tiles != empty?
				if not Vector2i(shapeBodyTracker[n][i].x, shapeBodyTracker[n][i].y+1) in shapeBodyTracker[n]: #and its not my own dang tile check????
					print("It's full with another shape's tile!! at cell below -> " + str(shapeBodyTracker[n][i]))
					print(Vector2i(shapeBodyTracker[n][i].x, shapeBodyTracker[n][i].y+1))
					print(shapeBodyTracker[n])
			else:
				print("the spots below the lowest tiles associated with the shape are empty!! move it on down")
	
