extends Button

func _ready():
	AudioManager.play_menu_music()

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")
