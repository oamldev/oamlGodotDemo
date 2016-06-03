extends Node2D


func resizeWindowed():
	var baseWidth = 256.0
	var baseHeight = 128.0
	var scale = 4
	var minWidth = baseWidth*scale

	var windowSize = OS.get_window_size()
	var scrSize = OS.get_screen_size()
	var maxWidth = floor(scrSize.x / baseWidth) * baseWidth

	var newX = clamp(floor(windowSize.x / baseWidth) * baseWidth, minWidth, maxWidth)
	var newY = int(newX * (baseHeight / baseWidth))
	var winSize = Vector2(newX, newY)

	OS.set_window_size(winSize)
	OS.set_window_position(scrSize*0.5 - winSize*0.5)

func resize():
	var fullscreen = false
	if (Globals.has("fullscreen")):
		fullscreen = Globals.get("fullscreen")

	if (OS.is_window_fullscreen() != fullscreen):
		OS.set_window_fullscreen(fullscreen)

	if (not fullscreen):
		resizeWindowed()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _ready():
	get_tree().connect("screen_resized", self, "resize")
	if (music.isPlaying() == false):
		music.playTrack("Theme")

	if (Globals.has("Init") == false):
		Globals.set("Init", 1)
		resize()
