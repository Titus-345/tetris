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

var shapesMade = {
	0: [],
	1: []
}

var iShape: Array[Vector2] = [Vector2(0,0), Vector2(1,0), Vector2(2,0)]
var oShape: Array[Vector2] = [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	makeTetromino(iShape, Vector2(0,0))
	
	
	
func makeTetromino(shape: Array, location: Vector2, color: String = "red" ):
	for n in shape.size():
		set_cell(shape[n], 5, Vector2(0,0))
		print(n)
