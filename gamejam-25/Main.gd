extends Node2D

# --- NODES IN SCENE ---
@onready var chopsticks: Node = $Chopsticks
@onready var player_display: Control = $CounterDisplay
@onready var score_label: Label = $ScoreLabel 
@onready var start_label: Label = $StartLabel # The big "3-2-1" label
@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer # Used for Beeps, Success, and Fail sounds
@onready var game_timer: Timer = $"Countdown_label/20SecondTimer"

# --- EXPORTED VARIABLES (Assign these in Inspector) ---
@export var order_display: Control 
@export var spawner_node: Node # Drag your "Spawner" node here

# Audio Files
@export var success_sound: AudioStream
@export var fail_sound: AudioStream

# Sushi Textures
@export var maki_counter_img: Texture2D
@export var nigiri_counter_img: Texture2D
@export var tomago_counter_img: Texture2D
@export var wasabi_counter_img: Texture2D
@export var ebi_counter_img: Texture2D

# --- INTERNAL VARIABLES ---
var sushi_map = {}
var sushi_keys = ["Maki", "Nigiri", "Tomago", "Wasabi", "Ebi"]
var current_order: Array = [] 
var player_progress_index: int = 0 
var score: int = 0

func _ready():
	# 1. Setup Audio
	AudioManager.play_game_music()
	
	# 2. Setup Connections
	if chopsticks:
		chopsticks.sushi_selected.connect(on_sushi_selected)
	else:
		print("ERROR: Chopsticks node not found!")
	
	game_timer.timeout.connect(_on_game_timer_timeout)

	# 3. Build the Map
	sushi_map = {
		"Maki": maki_counter_img,
		"Nigiri": nigiri_counter_img,
		"Tomago": tomago_counter_img,
		"Wasabi": wasabi_counter_img,
		"Ebi": ebi_counter_img
	}
	
	# 4. Initialize UI
	update_score_ui()
	generate_new_order()
	
	# 5. Start the Intro Sequence
	run_start_countdown()

# --- COUNTDOWN SEQUENCE ---
func run_start_countdown():
	start_label.visible = true
	
	# "3"
	start_label.text = "1"
	sfx_player.play() # Uses the sound currently assigned to the player (or previous one)
	# Note: Ideally, set a default beep in the inspector or load it here if needed
	await get_tree().create_timer(1.0).timeout
	
	# "2"
	start_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	
	# "1"
	start_label.text = "3"
	await get_tree().create_timer(1.0).timeout
	
	# "GO!"
	start_label.text = "Lets GO!"
	
	await get_tree().create_timer(0.5).timeout
	start_label.visible = false
	
	# Start the game systems
	if spawner_node:
		spawner_node.start_game_spawning()
	else:
		print("ERROR: Spawner Node not assigned in Inspector!")
	
	game_timer.start()

# --- GAME LOGIC ---
func generate_new_order():
	current_order.clear()
	player_progress_index = 0
	
	# Create 4 random items
	for i in range(4):
		current_order.append(sushi_keys.pick_random())
	
	# Update the Top Display
	if order_display:
		var texture_list = []
		for type in current_order:
			texture_list.append(sushi_map[type])
		order_display.set_target_order(texture_list)
	
	# Clear Bottom Display
	player_display.clear_display()

func on_sushi_selected(sushi_instance: CharacterBody2D):
	var selected_type = sushi_instance.sushi_type
	
	# Safety check
	if not sushi_map.has(selected_type):
		sushi_instance.queue_free()
		return

	var expected_type = current_order[player_progress_index]
	
	if selected_type == expected_type:
		# --- CORRECT ---
		_play_sfx(success_sound)
		player_display.add_sushi_to_counter(sushi_map[selected_type])
		player_progress_index += 1
		
		if player_progress_index >= 4:
			complete_order_success()
	else:
		# --- WRONG ---
		fail_order()

	sushi_instance.queue_free()

func complete_order_success():
	score += 20
	update_score_ui()
	generate_new_order()

func fail_order():
	_play_sfx(fail_sound)
	score -= 5
	print("ORDER FAILED! Score: ", score)
	update_score_ui()
	player_progress_index = 0
	player_display.clear_display()

# --- UI & END GAME ---
func update_score_ui():
	if score_label:
		score_label.text = "Score: " + str(score)

func _on_game_timer_timeout():
	print("Time is up!")
	Global.final_score = score
	get_tree().change_scene_to_file("res://Scenes/EndScreen.tscn")

# --- AUDIO HELPER ---
func _play_sfx(stream: AudioStream):
	if stream:
		sfx_player.stream = stream
		sfx_player.play()
	else:
		print("Warning: SFX requested but no AudioStream assigned in Inspector.")
