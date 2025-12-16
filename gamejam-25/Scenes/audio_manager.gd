extends Node

@onready var music_player = $MusicPlayer

# --- DRAG YOUR AUDIO FILES HERE IN INSPECTOR ---
@export var menu_music: AudioStream # For Start & End screens
@export var game_music: AudioStream # For Main game

# Play the Menu Music (Start/End)
func play_menu_music():
	if music_player.stream == menu_music and music_player.playing:
		return # Already playing, don't restart it
	
	music_player.stream = menu_music
	music_player.play()

# Play the Game Music (Main)
func play_game_music():
	if music_player.stream == game_music and music_player.playing:
		return
		
	music_player.stream = game_music
	music_player.play()

# Stop music (Optional)
func stop_music():
	music_player.stop()
