extends CharacterBody3D

var speed : float = 5.0
const JUMP_VELOCITY : float = 4.5

var mouse_speed = 0.003

var health : int = 100
var kills : int = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head : Node3D = $head
@onready var camera : Camera3D = $head/Camera3D

@onready var head_collision : ShapeCast3D = $head_collision

#
@onready var anim_player : AnimationPlayer = $AnimationPlayer
# for walking(and sprinting) and crouching
@onready var anim_player2 : AnimationPlayer = $AnimationPlayer2

@onready var health_bar := get_parent().get_node("CanvasLayer/HUD/health_bar")
@onready var bullet_label : Label = get_parent().get_node("CanvasLayer/HUD/bullet_label")
@onready var sprint_bar : ProgressBar = get_parent().get_node("CanvasLayer/HUD/sprint_bar")
@onready var sprint_regen : Timer = $"sprint/sprint_regen"
@onready var sprint_drain : Timer = $sprint/sprint_drain

var crouching = false

# speed for sprinting
var max_speed = 8.0
# speed for walking
var default_speed = 5.0
# speed for crouching
var min_speed = 3.0

# amount of sprint left controls
var sprint_max = 20
var sprint_left = sprint_max

enum weapons {
	MELEE,
	MAIN,
	SECONDARY
}

var weapon_refs : Dictionary

var weapon = weapons.MAIN

var can_shoot = true

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	weapon_refs = {
		"MELEE": $head/Camera3D/hand/hammer,
		"MAIN": $head/Camera3D/hand/ak47,
		"SECONDARY": $head/Camera3D/hand/pistol
	}
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var material = $MeshInstance3D.get_active_material(0)
	
	material.albedo_color = Color.from_hsv(randf_range(0, 1), 1, 1)
	
	camera.current = true
	
	weapon_refs["MELEE"].player_id = get_multiplayer_authority()
	weapon_refs["MAIN"].player_id = get_multiplayer_authority()
	weapon_refs["SECONDARY"].player_id = get_multiplayer_authority()
	
func _input(event):
	if not is_multiplayer_authority(): return
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_speed)
			camera.rotate_x(-event.relative.y * mouse_speed)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-20), deg_to_rad(59))
	
	# animations and sprint control
	var input_dir = Input.get_vector("left", "right", "foward", "back")
	if event.is_action_pressed("crouch") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_crouch()
	
	if input_dir != Vector2.ZERO:
		if not crouching:
			if !anim_player2.is_playing():
				anim_player2.play("walk")
			if event.is_action_pressed("sprint"):
				anim_player2.speed_scale = 1.6
				if sprint_left:
					speed = max_speed
					sprint_regen.stop()
					sprint_drain.start()
					
			if event.is_action_released("sprint"):
				anim_player2.speed_scale = 1
				speed = default_speed
				sprint_drain.stop()
				sprint_regen.start()
		else:
			if !anim_player2.is_playing():
				anim_player2.play("crouch_walk")
	else:
		if not crouching:
			anim_player2.play("RESET")
		else:
			anim_player2.pause()
	
	if event.is_action_pressed("weapon1") and weapon != weapons.MELEE:
		_raise_weapon(weapons.MELEE)
	if event.is_action_pressed("weapon2") and weapon != weapons.MAIN:
		_raise_weapon(weapons.MAIN)
	if event.is_action_pressed("weapon3") and weapon != weapons.SECONDARY:
		_raise_weapon(weapons.SECONDARY)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	sprint_left = clamp(sprint_left, 0, sprint_max)
	sprint_bar.value = sprint_left
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !crouching:
		velocity.y = JUMP_VELOCITY
		

	var input_dir = Input.get_vector("left", "right", "foward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

#if is_on_floor():
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
#else:
#	velocity.x = lerp(velocity.x, direction.x, delta * 0.7)
#	velocity.z = lerp(velocity.z, direction.z, delta * 0.7)

	
	move_and_slide()
	
	health_bar.value = health
	
	if sprint_left < sprint_max:
		sprint_bar.show()
	else:
		sprint_bar.hide()
	var m
	# switching
	match weapon:
		weapons.MELEE:
			weapon_refs["MELEE"]._switch_to.rpc()
			weapon_refs["MAIN"]._switch_away.rpc()
			weapon_refs["SECONDARY"]._switch_away.rpc()
			m = weapon_refs["MELEE"]
		weapons.MAIN:
			weapon_refs["MAIN"]._switch_to.rpc()
			weapon_refs["SECONDARY"]._switch_away.rpc()
			weapon_refs["MELEE"]._switch_away.rpc()
			m = weapon_refs["MAIN"]
		weapons.SECONDARY:
			weapon_refs["SECONDARY"]._switch_to.rpc()
			weapon_refs["MAIN"]._switch_away.rpc()
			weapon_refs["MELEE"]._switch_away.rpc()
			m = weapon_refs["SECONDARY"]
	
	if m.type == "gun":
		bullet_label.text = str(m.current_bullets) + " / " + str(m.total_bullets)
	else:
		bullet_label.text = ""
	
	# firing and reloading
	if Input.is_action_pressed("function1") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if m.type == "gun":
			if can_shoot:
				m._function1()
		elif m.type == "melee":
			m._function1.rpc()
		
	if Input.is_action_just_pressed("reload") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if m.type == "gun":
			m._reload.rpc()

func _on_sprint_regen_timeout():
	sprint_left += 1
	if sprint_left == sprint_max:
		sprint_regen.stop()

func _on_sprint_drain_timeout():
	sprint_left -= 1
	if sprint_left == 0:
		speed = default_speed
		sprint_drain.stop()
		
func _crouch():
	if crouching == true:
		if head_collision.is_colliding() == false:
			$collision_crouch.disabled = true
			$collision_full.disabled = false
			anim_player.play_backwards("crouch")
			speed = default_speed
	else:
		$collision_crouch.disabled = false
		$collision_full.disabled = true
		anim_player.play("crouch")
		speed = min_speed

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "crouch":
		crouching = not crouching

func _raise_weapon(new_weapon):
	can_shoot = false
	anim_player.play("switch")
	await get_tree().create_timer(0.5).timeout
	anim_player.play_backwards("switch")
	weapon = new_weapon
	can_shoot = true

@rpc("any_peer")
func _receive_damage(damage):
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id != get_multiplayer_authority():
		health -= damage
		if health <= 0:
			get_tree().root.get_node("main").get_node(str(peer_id))._add_kill.rpc_id(peer_id)
			health = 100
			position = Vector3.ZERO
			weapon_refs["MAIN"]._reset()
			weapon_refs["SECONDARY"]._reset()

@rpc("any_peer")
func _add_kill():
	kills += 1
	get_tree().root.get_node("main/CanvasLayer/HUD/kills_label").text = "Kills: " + str(kills)
