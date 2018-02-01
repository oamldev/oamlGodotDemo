extends AnimationPlayer

onready var plr = get_node("../../")

func _on_AnimationPlayer_finished():
	if (plr.alive == false):
		return
	
	if (plr.attacking):
		plr.attacking = false

