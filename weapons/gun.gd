extends Node3D

@export var auto_reload : bool = false
@export var damage : int = 0
@export var total_bullets : int = 0
@export var magazine_size : int = 0

var current_bullets : int
var default_bullets : int = 0

@export var bullet_speed : int
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var raycast : RayCast3D = $RayCast3D
var bullet = preload("res://weapons/bullet/bullet.tscn")

@onready var muzzle_flash : GPUParticles3D = $muzzle_flash

var player_id : int = -1

func _ready():
	current_bullets = magazine_size
	default_bullets = total_bullets
	
func _process(_delta):
	if current_bullets == 0 and auto_reload:
		_reload()

func _function1():
	if !anim_player.is_playing() and current_bullets != 0:
		_fire_effects.rpc()
		_fire_bullet.rpc()

@rpc("call_local")
func _reload():
	if !anim_player.is_playing() and current_bullets != magazine_size:
		anim_player.play("reload")

@rpc("call_local")
func _fire_effects():
	anim_player.stop()
	anim_player.play("fire")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

@rpc("call_local")
func _fire_bullet():
	var shot = bullet.instantiate()
	shot.speed = bullet_speed
	shot.damage = damage
	shot.position = raycast.global_position
	shot.transform.basis = raycast.global_transform.basis
	if player_id != -1:
		shot.player_id = player_id
	get_tree().root.add_child(shot)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fire":
		current_bullets -= 1
	elif anim_name == "reload":
		if not total_bullets <= 0 and not total_bullets < (magazine_size - current_bullets):
			total_bullets = total_bullets - (magazine_size - current_bullets)
			current_bullets = magazine_size

func _reset():
	current_bullets = magazine_size
	total_bullets = default_bullets

# animations to show other players
@rpc("call_local")
func _switch_away():
	hide()

@rpc("call_local")
func _switch_to():
	show()
