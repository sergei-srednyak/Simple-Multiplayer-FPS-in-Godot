extends Node3D

var speed = 50
var damage = 0
@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var raycast : RayCast3D = $RayCast3D
@onready var particles : GPUParticles3D = $GPUParticles3D

var player_id = -1

func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	if raycast.is_colliding():
		var target = raycast.get_collider()
		
		if target.has_method("_receive_damage"):
			target._receive_damage.rpc(damage)#rpc_id(target.get_multiplayer_authority(), damage)
		mesh.visible = false
		particles.emitting = true
		queue_free()

func _on_timer_timeout():
	queue_free()
