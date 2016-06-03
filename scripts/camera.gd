extends Camera2D

const REF_HEIGHT = 128

var zoom = 1 #LESS is MORE

func _ready():
    set_process(true)
    pass

func _process(delta):
    var screen = get_tree().get_root().get_rect().size
    var width = screen.x
    var height = screen.y
    var ratio = width / height
    var zoom = (REF_HEIGHT * ratio / width) * self.zoom
    set_zoom( Vector2(zoom, zoom) )
