extends Control

@onready var final_score_label = $FinalScoreLabel
@onready var restart_button = $FinalScoreLabel/RestartButton

func _ready():
	# --- PLAY MENU MUSIC ---
	AudioManager.play_menu_music()
	
	# Display the score
	final_score_label.text = "Final Score: " + str(Global.final_score)
	
	# Connect the button
	restart_button.pressed.connect(_on_restart_pressed)

func _on_restart_pressed():
	Global.final_score = 0
	get_tree().change_scene_to_file("res://Main.tscn")
