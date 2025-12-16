extends Control

# -- Configuration --
@export var plate_spacing: float = 60.0
@export var max_plates: int = 5
@export var sushi_scale: float = 0.5

# -- Internal State --
var collected_items: Array[Sprite2D] = []

# Add a single item (used for Player Collection)
func add_sushi_to_counter(texture: Texture2D):
	var new_plate = _create_plate(texture)
	add_child(new_plate)
	collected_items.append(new_plate)
	
	if collected_items.size() > max_plates:
		var old = collected_items.pop_front()
		old.queue_free()
	
	_recenter_items()

# Set multiple items at once (used for the Target Order display)
func set_target_order(textures: Array):
	clear_display() # Wipe existing
	for tex in textures:
		var new_plate = _create_plate(tex)
		add_child(new_plate)
		collected_items.append(new_plate)
	_recenter_items()

# Helper to create the sprite
func _create_plate(texture: Texture2D) -> Sprite2D:
	var p = Sprite2D.new()
	p.texture = texture
	p.scale = Vector2(sushi_scale, sushi_scale)
	return p

# Remove all items (used when Player fails or finishes an order)
func clear_display():
	for item in collected_items:
		item.queue_free()
	collected_items.clear()

func _recenter_items():
	if collected_items.is_empty():
		return
	
	var total_stack_width = (collected_items.size() - 1) * plate_spacing
	var center_of_container = size.x / 2.0
	var center_y = size.y / 2.0
	var start_x = center_of_container - (total_stack_width / 2.0)
	
	for i in range(collected_items.size()):
		var item = collected_items[i]
		var target_pos = Vector2(start_x + (i * plate_spacing), center_y)
		
		# Simple Tween for smooth movement
		var tween = create_tween()
		tween.tween_property(item, "position", target_pos, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_recenter_items()
