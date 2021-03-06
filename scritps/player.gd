extends KinematicBody
class_name Player

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 4
const JUMP_SPEED = 6
const ACCEL = 6

var dir = Vector3()

const DEACCEL= 6
const MAX_SLOPE_ANGLE = 45

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

onready var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
onready var hud = get_node("canvas/hud")
onready var message = hud.get_node("message")
onready var restart_button = hud.get_node("restart")

func _ready():
	camera = get_node("helper/camera")
	rotation_helper = get_node("helper")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	restart_button.connect("pressed", main_scene, "restart")

func _physics_process(delta):
	process_input()
	process_movement(delta)

func process_input():
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()
	if Input.is_action_pressed("move_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1
	input_movement_vector = input_movement_vector.normalized()
	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("move_jump"):
			vel.y = JUMP_SPEED
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	vel.y += delta * GRAVITY
	var hvel = vel
	hvel.y = 0
	var target = dir
	target *= MAX_SPEED
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
