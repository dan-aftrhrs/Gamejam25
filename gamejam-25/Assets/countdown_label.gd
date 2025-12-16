extends RichTextLabel

@onready var timer = $"20SecondTimer"


func _process(_delta):
	if timer.time_left:
		var time_left = timer.time_left
		var seconds = floor(fmod(time_left,60))
		text = ("%02d" % [seconds])
	else:
		text = "Ready"
