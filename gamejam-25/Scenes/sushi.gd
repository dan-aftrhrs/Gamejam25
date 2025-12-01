extends Area2D
@export var speed: float = 400.0
@export var move_direction: Vector2 = Vector2.LEFT
@export var type: String = ""

func _process(delta: float) -> void:
	position.x += speed * delta * move_direction.x
