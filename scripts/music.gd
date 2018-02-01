extends Node

var oaml
var enableMusic = true

func _ready():
	oaml = oamlGodotModule.new()
	oaml.Init("oaml.defs")

func playTrack(name):
	if (enableMusic == false):
		return
	oaml.PlayTrack(name)

func stopPlaying():
	oaml.StopPlaying()

func setLayerGain(layer, gain):
	oaml.SetLayerGain(layer, gain)

func getStatus():
	return oaml.GetPlayingInfo()

func isPlaying():
	return oaml.IsPlaying()

func setMainLoopCondition(value):
	oaml.SetMainLoopCondition(value)

