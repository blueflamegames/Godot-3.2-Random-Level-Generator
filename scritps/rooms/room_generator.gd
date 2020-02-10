extends Spatial
class_name RoomsGenerator

const INTERVAL = 0.05

signal level_generated

onready var room_start_scn : PackedScene = preload("res://scenes/rooms/room_start.tscn")
onready var room_end_scn : PackedScene = preload("res://scenes/rooms/room_end.tscn")

# Room scene and chance of spawning
onready var rooms = [
	[preload("res://scenes/rooms/room_L.tscn"), 5],
	[preload("res://scenes/rooms/room_T.tscn"), 5]
]

export var iteration_range : Vector2 = Vector2(5, 15)

var available_doorways = []

var room_start : RoomStart
var room_end : RoomEnd
var placed_rooms = []

var thread = Thread.new()

func _ready():
#	thread.start(self, "generate_rooms")
	generate_rooms(null)

func generate_rooms(userdata):
	# Add start room
	room_start = room_start_scn.instance()
	add_child(room_start)
	room_start.global_transform.origin = global_transform.origin
	add_doorways_to_available_doorways(room_start)
	yield(get_tree().create_timer(INTERVAL), "timeout")
	
	# Add corridors
	randomize()
	var iterations = rand_range(int(iteration_range.x), int(iteration_range.y))
	for i in iterations:
		var current_room = get_rand_room().instance()
		add_child(current_room)
		var room_placed = false
		for adi in available_doorways.size():
			for cdi in current_room.doorways.size():
				position_room_at_doorway(current_room, current_room.doorways[cdi], available_doorways[adi])
				yield(get_tree().create_timer(INTERVAL), "timeout")
				if !check_room_overlap(current_room):
					room_placed = true
					placed_rooms.push_back(current_room)
					
					current_room.doorways[cdi].queue_free()
					current_room.doorways.remove(cdi)
					
					available_doorways[adi].queue_free()
					available_doorways.remove(adi)
					
					break
			if room_placed:
				add_doorways_to_available_doorways(current_room)
				break
		if !room_placed:
			current_room.queue_free()
	
	# Add end room
	room_end = room_end_scn.instance()
	add_child(room_end)
	room_end.global_transform.origin = global_transform.origin
	var room_placed = false
	for adi in available_doorways.size():
		position_room_at_doorway(room_end, room_end.doorways[0], available_doorways[adi])
		yield(get_tree().create_timer(INTERVAL), "timeout")
		if !check_room_overlap(room_end):
			room_placed = true
			room_end.doorways[0].queue_free()
			available_doorways[adi].queue_free()
			available_doorways.remove(adi)
			break
	if !room_placed:
		room_end.queue_free()
	
	# Generate navmesh 
#	var nav = get_node("navigation")
#	var navmesh_instance = nav.get_node("navigation_mesh_instance")
#	var navmesh = navmesh_instance.navmesh
#	NavigationMeshGenerator.clear(navmesh)
#	NavigationMeshGenerator.bake(navmesh, self)
#	nav.navmesh_add(navmesh, navmesh_instance.global_transform)
	
#	thread.wait_to_finish()
	emit_signal("level_generated")
	
func position_room_at_doorway(room : Room, room_doorway : Doorway, target_doorway : Doorway):
	if is_instance_valid(room_doorway) and is_instance_valid(target_doorway):
		# Reset room's position and rotation
		room.global_transform.origin = Vector3.ZERO
		room.rotation = Vector3.ZERO
		
		# Rotate the room
		var target_doorway_euler = target_doorway.global_transform.basis.get_euler()
		var room_doorway_euler = room_doorway.global_transform.basis.get_euler()
		var delta_angle = utils.delta_angle(room_doorway_euler.y, target_doorway_euler.y)
		var current_room_target_rotation : Quat = Quat(Vector3.UP, delta_angle)
		room.global_transform.basis = current_room_target_rotation.inverse()
		
		# Position the room
		var room_position_offset = room_doorway.global_transform.origin - room.global_transform.origin
		room.global_transform.origin = target_doorway.global_transform.origin - room_position_offset

func check_room_overlap(room : Room):
	return room.overlaps

func get_rand_room():
	var total = 0
	for i in rooms.size():
		total += rooms[i][1]
	var rand = randi() % total
	for i in rooms.size():
		var room = rooms[i]
		if rand < room[1]:
			return room[0]
		rand -= room[1]

func add_doorways_to_available_doorways(room : Room):
	for d in room.doorways:
		available_doorways.push_back(d)

func clear():
	placed_rooms = []
	available_doorways = []
	for n in get_children():
		n.queue_free()
