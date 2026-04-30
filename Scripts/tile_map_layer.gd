extends TileMapLayer

func drawTheTetrisBorder():
		for x in 10:
			set_cell(Vector2(-5+x,10), 7, Vector2(2,0)) #bottom wall
			set_cell(Vector2(-5+x,-10), 7, Vector2(2,0)) #top wall
		for x in 20:
			set_cell(Vector2(-6,10-x), 7, Vector2(4,0)) #left wall
			set_cell(Vector2(5,10-x), 7, Vector2(4,0))  #right wall

#the corners
		set_cell(Vector2(-6,10), 7, Vector2(0,1)) # bottom left
		set_cell(Vector2(5,10), 7, Vector2(1,1)) # bottom right
		set_cell(Vector2(-6,-10), 7, Vector2(0,0)) # top left
		set_cell(Vector2(5,-10), 7, Vector2(1,0)) # top right
func _ready() -> void:
	#DRAW THE BORDER OF THE GAME
	drawTheTetrisBorder()

var shapeInstanceCount = 0
var shapeBodyTracker: Dictionary[int, Array] = {
}

const iShape: Array[Vector2] = [Vector2(0,0), Vector2(1,0), Vector2(2,0)]
const oShape: Array[Vector2] = [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]
const tShape: Array[Vector2] = [Vector2(0,0), Vector2(1,0), Vector2(2,0), Vector2(1,1)]
const jShape: Array[Vector2] = [Vector2(1,0), Vector2(1,1), Vector2(1,2), Vector2(0,2)]
const lShape: Array[Vector2] = [Vector2(0,0), Vector2(0,1), Vector2(0,2), Vector2(1,2)]
const sShape: Array[Vector2] = [Vector2(0,1), Vector2(1,1), Vector2(1,0), Vector2(2,0)]
const zShape: Array[Vector2] = [Vector2(0,1), Vector2(1,1), Vector2(1,1), Vector2(2,1)]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shapeInstanceCount <= 2:
		makeTetromino(sShape, Vector2(0,-4))
		makeTetromino(jShape, Vector2(0,0))
		makeTetromino(tShape, Vector2(0,4))
		print(shapeBodyTracker[2])
	
	
func makeTetromino(shape: Array, location: Vector2, color: String = "red" ):
	for n in shape.size():
		set_cell(Vector2(shape[n].x+location.x, shape[n].y+location.y), 5, Vector2(0,0))
	shapeBodyTracker[shapeInstanceCount] = shape
	shapeInstanceCount += 1
