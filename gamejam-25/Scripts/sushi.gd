extends CharacterBody2D

# Add this identifier
@export var sushi_type: String = "salmon" 

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0

@onready var sushi_sprite: Sprite2D = $Sprite2D
@export var visual_width_override: float = 0.0

func _physics_process(delta):
	if direction != Vector2.ZERO and speed > 0:
		position += direction * speed * delta

func set_movement_data(move_direction: Vector2, move_speed: float, flip_h_sprite: bool = false):
	direction = move_direction
	speed = move_speed
	if sushi_sprite:
		sushi_sprite.flip_h = flip_h_sprite

func get_effective_width() -> float:
	if visual_width_override > 0:
		return visual_width_override
	if sushi_sprite and sushi_sprite.texture:
		return sushi_sprite.texture.get_width() * sushi_sprite.scale.x
	return 50.0
