extends Node2D

@export var top_row_y_pos: float = 832.0   # Y-position for the top row
@export var bottom_row_y_pos: float = 1024.0 # Y-position for the bottom row
@export_range(0.1, 50.0, 0.1) var move_speed: float = 25.0 # Speed at which chopsticks move between rows

@export var chopstick_sprite: Sprite2D # Reference to your chopsticks sprite
@onready var animated_sprite_2d = $AnimatedSprite2D # Get the AnimatedSprite2D node

var target_y_pos: float # The Y position the chopsticks are currently moving towards
var current_row: int = 0 # 0 for top, 1 for bottom

signal sushi_selected(sushi_instance: CharacterBody2D) # Signal emitted when sushi is selected

func _ready():
	# Set initial position to the top row
	global_position = Vector2(global_position.x, top_row_y_pos)
	target_y_pos = top_row_y_pos
	current_row = 0
	animated_sprite_2d.play("Idle") # Play Idle animation initially

func _process(delta):
	# Move chopsticks smoothly towards the target Y position
	global_position.y = lerp(global_position.y, target_y_pos, delta * move_speed)

func _input(event):
	if event.is_action_pressed("move_chopsticks"):
		toggle_chopstick_row()
	elif event.is_action_pressed("select_sushi"):
		attempt_select_sushi()
		animated_sprite_2d.play("Pick") # Play Pick animation when select_sushi is pressed
	elif event.is_action_released("select_sushi"):
		animated_sprite_2d.play("Idle") # Play Idle animation when select_sushi is released

func toggle_chopstick_row():
	if current_row == 0:
		target_y_pos = bottom_row_y_pos
		current_row = 1
	else:
		target_y_pos = top_row_y_pos
		current_row = 0

func attempt_select_sushi():
	# Find all children of the main scene that are sushi instances
	var main_node = get_parent() # Assuming Chopsticks is child of Main
	if not main_node: return

	for child in main_node.get_children():
		if child is CharacterBody2D and child.has_method("set_movement_data"): # It's a sushi
			# Simple overlap check: Is the sushi roughly at the chopstick's Y-level
			# and within a reasonable X-range for selection?
			if abs(child.global_position.y - global_position.y) < 20: # Within 20 pixels vertically
				# This X-range might need tuning based on your chopstick sprite and sushi size
				if abs(child.global_position.x - global_position.x) < 50: # Within 50 pixels horizontally
					print("Selected sushi!")
					emit_signal("sushi_selected", child)
					child.queue_free() # Remove selected sushi for now (will change later)
					return # Only select one sushi per button press
