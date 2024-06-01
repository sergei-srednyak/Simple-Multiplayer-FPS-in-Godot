extends CenterContainer

@export var radius : float = 1
@export var color : Color = Color.WHITE

func _ready():
	queue_redraw()

func _draw():
	draw_circle(Vector2(0,0),radius,color)
