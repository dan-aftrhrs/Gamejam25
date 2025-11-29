extends Area2D
@export var speed: float = 400.0

func _process(delta: float) -> void:
	position.x += speed * delta * -1
