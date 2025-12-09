extends Control

# -- Configuration --
@export var plate_spacing: float = 60.0 # Distance between plates
@export var max_plates: int = 5         # Max sushi shown
@export var sushi_scale: float = 0.5    # 1.0 is original size, 0.5 is half size

# -- Internal State --
var collected_items: Array[Sprite2D] = []

func add_sushi_to_counter(texture: Texture2D):
	# 1. Create the sprite
	var new_plate = Sprite2D.new()
	new_plate.texture = texture
	
	# 2. Apply the size change
	new_plate.scale = Vector2(sushi_scale, sushi_scale)
	
	# 3. Add to scene and array
	add_child(new_plate)
	collected_items.append(new_plate)
	
	# Optional: Remove oldest if we exceed max display
	if collected_items.size() > max_plates:
		var old = collected_items.pop_front()
		old.queue_free()
	
	_recenter_items()

func _recenter_items():
	if collected_items.is_empty():
		return
		
	# 1. Calculate the total width of the 'stack' of sushi
	var total_stack_width = (collected_items.size() - 1) * plate_spacing
	
	# 2. Find the center of this UI Control
	var center_of_container = size.x / 2.0
	var center_y = size.y / 2.0
	
	# 3. Calculate where the first plate should start to make the whole stack centered
	var start_x = center_of_container - (total_stack_width / 2.0)
	
	# 4. Reposition all items
	for i in range(collected_items.size()):
		var item = collected_items[i]
		
		# Calculate position: Start Point + (Index * Spacing)
		var target_pos = Vector2(start_x + (i * plate_spacing), center_y)
		
		# Animate
		var tween = create_tween()
		tween.tween_property(item, "position", target_pos, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

# Optional: Ensure items recenter if the screen/window is resized
func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_recenter_items()
