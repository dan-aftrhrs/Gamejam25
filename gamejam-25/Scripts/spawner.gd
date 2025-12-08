extends Node

@export_range(0.1, 5.0, 0.1) var spawn_interval: float = 1.0 # Time between spawns
@export_range(50, 500, 10) var sushi_speed: float = 100.0
@export var sushi_scenes: Array[PackedScene] = [] # Drag em here

@export var left_spawn_point: Marker2D
@export var right_spawn_point: Marker2D

var spawn_timer: Timer

var sushi_types_to_spawn_left: Array = [] # For even distribution
var sushi_types_to_spawn_right: Array = [] # For even distribution

func _ready():
	_reset_sushi_queues()

	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	spawn_timer.start()

func on_spawn_timer_timeout():
	_spawn_sushi_in_lane(left_spawn_point, Vector2.RIGHT, true) # Spawns from left, moves right, flipped
	_spawn_sushi_in_lane(right_spawn_point, Vector2.LEFT, false) # Spawns from right, moves left, not flipped

func _spawn_sushi_in_lane(spawn_point: Marker2D, direction: Vector2, flip_h: bool):
	var sushi_scene_to_spawn: PackedScene = null
	if direction == Vector2.RIGHT: # Left lane, moving right
		if sushi_types_to_spawn_left.is_empty():
			_reset_sushi_queues()
		sushi_scene_to_spawn = sushi_types_to_spawn_left.pop_front()
	else: # Right lane, moving left
		if sushi_types_to_spawn_right.is_empty():
			_reset_sushi_queues()
		sushi_scene_to_spawn = sushi_types_to_spawn_right.pop_front()

	var sushi_instance = sushi_scene_to_spawn.instantiate()
	# Add to parent node (Main) delayed
	get_parent().add_child.call_deferred(sushi_instance)

	call_deferred("_setup_sushi_initial_state", sushi_instance, spawn_point, direction, flip_h)


func _setup_sushi_initial_state(sushi_instance: CharacterBody2D, spawn_point: Marker2D, direction: Vector2, flip_h: bool):
	# Ensure the instance is valid and in the tree before setting properties
	if not is_instance_valid(sushi_instance) or not sushi_instance.is_inside_tree():
		print("WARNING: Sushi instance not valid or not in tree when setting up initial state.")
		return

	sushi_instance.global_position = spawn_point.global_position

	if sushi_instance.has_method("set_movement_data"):
		sushi_instance.set_movement_data(direction, sushi_speed, flip_h)
	else:
		print("WARNING: Sushi instance does not have 'set_movement_data' method. Manual movement needed.")


func _reset_sushi_queues():
	sushi_types_to_spawn_left = sushi_scenes.duplicate()
	sushi_types_to_spawn_left.shuffle()
	sushi_types_to_spawn_right = sushi_scenes.duplicate()
	sushi_types_to_spawn_right.shuffle()
