extends Node2D

@export var top_row_y_pos: float = 832.0
@export var bottom_row_y_pos: float = 1024.0
@export_range(0.1, 10.0, 0.1) var move_speed: float = 5.0

@export var chopstick_sprite: Sprite2D
@onready var chopstick_detection_area: Area2D = $ChopstickDetectionArea # Get reference to the Area2D

var target_y_pos: float
var current_row: int = 0 # 0 for top, 1 for bottom

# Store currently overlapping sushi to pick from
var overlapping_sushi: Array[CharacterBody2D] = []

signal sushi_selected(sushi_instance: CharacterBody2D) # Signal emitted when sushi is selected

func _ready():
	if not chopstick_sprite:
		print("WARNING: Chopstick Sprite not assigned in Inspector!")
	if not chopstick_detection_area:
		print("ERROR: ChopstickDetectionArea not found as child of Chopsticks!")
		set_process(false)
		return

	# Connect signals from the Area2D for BODY detection
	chopstick_detection_area.body_entered.connect(_on_chopstick_detection_area_body_entered)
	chopstick_detection_area.body_exited.connect(_on_chopstick_detection_area_body_exited)

	# Set initial position to the top row
	global_position = Vector2(global_position.x, top_row_y_pos)
	target_y_pos = top_row_y_pos
	current_row = 0

func _process(delta):
	# Move chopsticks smoothly towards the target Y position
	global_position.y = lerp(global_position.y, target_y_pos, delta * move_speed)

func _input(event):
	if event.is_action_pressed("move_chopsticks"):
		toggle_chopstick_row()
	elif event.is_action_pressed("select_sushi"):
		attempt_select_sushi()

func toggle_chopstick_row():
	if current_row == 0:
		target_y_pos = bottom_row_y_pos
		current_row = 1
	else:
		target_y_pos = top_row_y_pos
		current_row = 0

func attempt_select_sushi():
	# Clean up any invalid (freed) sushi from the overlapping list first
	overlapping_sushi = overlapping_sushi.filter(func(s): return is_instance_valid(s))

	if overlapping_sushi.is_empty():
		print("No sushi overlapping chopsticks to select.")
		return

	# From the overlapping sushi, find the one closest to the center of the chopsticks' X position
	var closest_sushi: CharacterBody2D = null
	var min_distance_x: float = INF # Infinity

	for sushi in overlapping_sushi:
		# We already filtered for valid instances, so no need for is_instance_valid(sushi) here
		var distance = abs(sushi.global_position.x - global_position.x)
		if distance < min_distance_x:
			min_distance_x = distance
			closest_sushi = sushi

	if closest_sushi:
		print("Selected sushi (via Area2D/Body): ", closest_sushi.name)
		emit_signal("sushi_selected", closest_sushi)
		# The sushi will be freed by the Main script after signal connection
		overlapping_sushi.erase(closest_sushi) # Remove from our tracking list
	else:
		print("No valid sushi found in overlapping_sushi to select.")


# --- Signal handlers for Area2D (BODY detection) ---

func _on_chopstick_detection_area_body_entered(body: CharacterBody2D): # Changed from 'area' to 'body'
	# Check if the entered body is a sushi by checking its script method
	if body.has_method("set_movement_data"): # Simple check for sushi
		if not overlapping_sushi.has(body):
			overlapping_sushi.append(body)
			#print("Sushi entered detection area: ", body.name)

func _on_chopstick_detection_area_body_exited(body: CharacterBody2D): # Changed from 'area' to 'body'
	# Check if the exited body is a sushi
	if body.has_method("set_movement_data"):
		if overlapping_sushi.has(body):
			overlapping_sushi.erase(body)
			#print("Sushi exited detection area: ", body.name)
