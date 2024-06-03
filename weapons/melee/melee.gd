extends Node3D

@export var type : String = ""

@export var damage : int = 0

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var hitbox : Area3D = $hitbox

var player_id : int

@rpc("call_local")
func _function1():
	if not anim_player.is_playing():
		anim_player.play("attack")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		for body in hitbox.get_overlapping_bodies():
			if body.has_method("_receive_damage"):
				body._receive_damage.rpc(damage)
		anim_player.play("back")

@rpc("call_local")
func _switch_away():
	hide()

@rpc("call_local")
func _switch_to():
	show()
