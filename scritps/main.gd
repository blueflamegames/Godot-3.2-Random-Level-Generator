extends Spatial

onready var player_scene = preload("res://scenes/player.tscn")
onready var room_generator = get_node("room_generator")

func _ready():
	room_generator.connect("level_generated", self, "_on_room_generated")

func _on_room_generated():
	get_node("camera").current = false
	var player = player_scene.instance()
	add_child(player)
	player.global_transform.origin = get_node("player_spawn").global_transform.origin
	player.get_node("helper/camera").current = true

func restart():
	get_tree().reload_current_scene()
