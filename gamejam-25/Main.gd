extends Node2D

@onready var chopsticks: Node = $Chopsticks
@onready var counter_display: Control = $CounterDisplay # Make sure to link this in editor

# Drag your "Counter" specific images here in the Inspector
@export var maki_counter_img: Texture2D
@export var nigiri_counter_img: Texture2D
@export var tomago_counter_img: Texture2D
@export var wasabi_counter_img: Texture2D

# Map strings to textures
var sushi_map = {}

func _ready():
	if chopsticks:
		chopsticks.sushi_selected.connect(on_sushi_selected)
	else:
		print("ERROR: Chopsticks node not found!")
	
	# Initialize the map
	# Make sure keys match the 'sushi_type' you set in Step 1
	sushi_map = {
		"Maki": maki_counter_img,
		"Nigiri": nigiri_counter_img,
		"Tomago": tomago_counter_img,
		"Wasabi": wasabi_counter_img
	}

func on_sushi_selected(sushi_instance: CharacterBody2D):
	print("Main received selection for: ", sushi_instance.sushi_type)
	
	# Check if we have a counter image for this type
	if sushi_map.has(sushi_instance.sushi_type):
		var texture_to_show = sushi_map[sushi_instance.sushi_type]
		counter_display.add_sushi_to_counter(texture_to_show)
	else:
		print("Warning: No counter image found for type: ", sushi_instance.sushi_type)

	sushi_instance.queue_free()
