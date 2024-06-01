extends ColorRect

@onready var resume : Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/resume
@onready var quit : Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/quit
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready():
	quit.pressed.connect(get_tree().quit)
	resume.pressed.connect(_resume)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _resume():
	anim_player.play("unpause")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _pause():
	anim_player.play("pause")
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
