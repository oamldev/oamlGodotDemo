extends Node2D

onready var rootNode = get_node("..")

var options = []
var selected = 0
var numopts
var value = 0
var status = 0
var count = 0



func _ready():
	var count = get_child_count()
	numopts = count
	var i = 0
	while (count > 0):
		var opt = get_child(i)
		options.append(opt)
		count-= 1
		i+= 1

func enable(option):
	set_process_input(option)
	set_physics_process(option)
	if (option):
		get_node("..").show()
	else:
		get_node("..").hide()


func _input(event):
	var up = event.is_action_pressed("ui_up")
	var down = event.is_action_pressed("ui_down")
	var accept = event.is_action_pressed("ui_accept")

	if (down):
		var node = options[selected]
		node.modulate.a = 1
		status = 0
		count = 0
		selected+= 1
		if (selected > numopts-1):
			selected = numopts-1

	if (up):
		var node = options[selected]
		node.modulate.a = 1
		status = 0
		count = 0
		selected-= 1
		if (selected < 0):
			selected = 0

	if (accept):
		var option = options[selected]
		if (option.get_name() == "Resume"):
			get_node("../../../").toggleMenu()
		elif (option.get_name() == "MainMenu"):
			get_tree().change_scene("res://mainmenu.scn")
		elif (option.get_name() == "Exit"):
			get_tree().quit()


func _physics_process(delta):
	var node = options[selected]
	if (status == 0):
		value-= 0.02
		if (value <= 0.0):
			status = 1
	else:
		value+= 0.02
		if (value >= 1.0):
			status = 0

	node.modulate.a = value


