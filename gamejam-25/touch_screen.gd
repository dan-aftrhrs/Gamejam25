extends Control

# Distance in pixels before a touch is considered a swipe
@export var swipe_threshold: float = 50.0

var touch_start_pos: Vector2 = Vector2.ZERO
var is_swiped: bool = false

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch Started
			touch_start_pos = event.position
			is_swiped = false
		else:
			# Touch Released
			if not is_swiped:
				# It was a Tap
				trigger_input_a()

	elif event is InputEventScreenDrag:
		if not is_swiped:
			var drag_distance = event.position.distance_to(touch_start_pos)
			if drag_distance > swipe_threshold:
				# It was a Swipe
				is_swiped = true
				trigger_input_b()

func trigger_input_a():
	print("Input A (Tap) triggered")
	var ev = InputEventAction.new()
	ev.action = "select_sushi"
	ev.pressed = true
	Input.parse_input_event(ev) # Tells the engine the button was pushed
	
	# We must also "release" it, otherwise the game thinks it's held down forever
	await get_tree().create_timer(0.1).timeout
	
	var rel = InputEventAction.new()
	rel.action = "select_sushi"
	rel.pressed = false
	Input.parse_input_event(rel) # Tells the engine the button was released

func trigger_input_b():
	print("Input B (Swipe) triggered")
	var ev = InputEventAction.new()
	ev.action = "move_chopsticks"
	ev.pressed = true
	Input.parse_input_event(ev)
	
	await get_tree().create_timer(0.1).timeout
	
	var rel = InputEventAction.new()
	rel.action = "move_chopsticks"
	rel.pressed = false
	Input.parse_input_event(rel)
