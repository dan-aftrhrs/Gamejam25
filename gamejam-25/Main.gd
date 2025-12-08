extends Node2D

@onready var chopsticks: Node = $Chopsticks # Path to your Chopsticks node

func _ready():
	if chopsticks:
		chopsticks.sushi_selected.connect(on_sushi_selected)
	else:
		print("ERROR: Chopsticks node not found in Main scene!")

func on_sushi_selected(sushi_instance: CharacterBody2D):
	print("Main received selection for sushi: ", sushi_instance.name)
	# This is where you'd add scoring, update the order list, etc.
	sushi_instance.queue_free() # Still remove it for now
