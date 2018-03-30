extends Node

var oaml
var enableMusic = true

func _ready():
	oaml = oamlGodotModule.new()
	oaml.init("oaml.defs")

func play_track(name):
	if (enableMusic == false):
		return
	oaml.play_track(name)

func stop_playing():
	oaml.stop_playing()

func set_layer_gain(layer, gain):
	oaml.set_layer_gain(layer, gain)

func get_status():
	return oaml.get_playing_info()

func is_playing():
	return oaml.is_playing()

func set_main_loop_condition(value):
	oaml.set_main_loop_condition(value)

