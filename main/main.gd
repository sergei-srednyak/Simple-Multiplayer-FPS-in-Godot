extends Node

@onready var main_menu : PanelContainer = $CanvasLayer/main_menu
@onready var address_entry : LineEdit = $CanvasLayer/main_menu/MarginContainer/VBoxContainer/address_entry
@onready var quit : Button = $CanvasLayer/main_menu/MarginContainer/VBoxContainer/quit

@onready var fps_counter : Label = $CanvasLayer/fps_counter

@onready var pause_menu : ColorRect = $CanvasLayer/pause_menu

const Player = preload("res://player/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

var game_started = false

func _ready():
	quit.pressed.connect(get_tree().quit)

func _process(delta):
	var frames_per_sec = "%.2f" % (1.0 / delta)
	fps_counter.text = "FPS: "+frames_per_sec
	
func _unhandled_input(event):
	if event.is_action_pressed("exit") and game_started:
		pause_menu._pause()

func _on_host_button_pressed():
	main_menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	get_node("CanvasLayer/HUD").show()
	get_node("CanvasLayer/controls").hide()
	#upnp_setup()
	game_started = true
	fps_counter.show()

func _on_join_button_pressed():
	main_menu.hide()
	enet_peer.create_client("localhost", PORT)
	#enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	get_node("CanvasLayer/controls").hide()
	get_node("CanvasLayer/HUD").show()
	game_started = true
	fps_counter.show()
	
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
