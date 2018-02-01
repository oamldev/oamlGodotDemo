extends Node2D

func _ready():
	print("Theme1")
	get_node("SamplePlayer2D").play("Theme1")
	pass

