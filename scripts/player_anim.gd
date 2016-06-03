extends AnimationPlayer

onready var plr = get_node("../../")
onready var sprite = get_node("../")

func _ready():
	set_process(true)

func _process(delta):
	if (plr.alive == false):
		if get_current_animation() != "Death":
			play("Death")
	elif (plr.attacking):
		if get_current_animation() != "Attack":
			play("Attack")
	elif (plr.jumping):
		return
	elif get_current_animation() == "Idle":
		if (plr.velocity.x != 0):
			play("Walk")
	elif get_current_animation() == "Walk":
		if (plr.velocity.x == 0):
			play("Idle")


func _on_AnimationPlayer_finished():
	if (plr.alive == false):
		return
	
	if (plr.attacking):
		plr.attacking = false
	
	if (plr.velocity.x == 0):
		play("Walk")
	else:
		play("Idle")
