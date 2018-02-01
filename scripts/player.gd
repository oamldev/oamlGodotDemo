extends KinematicBody2D

const SCALE = 4
const GRAVITY = 500.0*SCALE # Pixels/second
const DAMAGE_THROWBACK = 8000*SCALE
const VERTICAL_DAMAGE_THROWBACK = 6000*SCALE
const FLOOR_NORMAL = Vector2(0, -1)

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 300*SCALE
const WALK_MIN_SPEED = 10*SCALE
const WALK_MAX_SPEED = 100*SCALE
const STOP_FORCE = 1300*SCALE
const STOP_FORCE_HIT = 200*SCALE
const JUMP_SPEED = 150*SCALE
const JUMP_MAX_AIRBORNE_TIME = 0.2
const DASH_SPEED = 250*SCALE
const DASH_TIME = 0.05
const HIT_COUNTER_TIME = 30
const HEALTH_DEFAULT = 5
const HEALTHMAX_DEFAULT = 5

const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

onready var sprite = get_node("Sprite")
onready var statusText = get_node("CanvasLayer/Status")
onready var damageArea = get_node("DamageArea")
onready var samplePlayer = get_node("SamplePlayer")
onready var animPlayer = get_node("Sprite/AnimationPlayer")

var alive = true
var invulnerable = false
var healthPoints
var healthMax
var inMenu = false

var manaPoints = 10
var manaMax = 10

var anim = "Idle"
var velocity = Vector2()
var on_air_time = 100
var prevJump = false
var prevLeft = false
var prevRight = false
var prevDash = false
var dashTime = 0
var dashing = false
var jumping = false
var doubleJump = false
var facingright = true
var attacking = false
var lava_hit = false
var spike_hit = false
var hit_counter = 0
var insideDoor = false

func death():
	pass

func setInsideDoor(option):
	insideDoor = option

func toggleMenu():
	inMenu = !inMenu
	get_node("CanvasLayer/Menu/Menu").enable(inMenu)

func die():
	alive = false

func _ready():
	set_process_input(true)
	set_physics_process(true)

func _input(event):
	var cancel = event.is_action_pressed("ui_cancel")
	if (cancel):
		toggleMenu()

func _physics_process(delta):
	statusText.set_text(music.getStatus())

	if (inMenu):
		return

	if (hit_counter > 0):
		hit_counter = hit_counter - 1
		if ((hit_counter % 5) == 0):
			sprite.set_modulate(Color(1, 1, 1))
		else:
			sprite.set_modulate(Color(1, 0, 0))

	if (alive == false):
		if (hit_counter == 0):
			toggleMenu()
		return

	var walk_left = Input.is_action_pressed("ui_left")
	var walk_right = Input.is_action_pressed("ui_right")
	var jump = Input.is_action_pressed("ui_up")

	if (jump and insideDoor):
		finishLevel()
		jump = false
		return

	velocity.y+= delta*GRAVITY
	velocity = move_and_slide(velocity, FLOOR_NORMAL, 0.0, 8)

	var target_speed = 0
	if (walk_left):
		target_speed+= -1
		facingright = false
	if (walk_right):
		target_speed+= 1
		facingright = true

	target_speed*= WALK_FORCE
	velocity.x = lerp(velocity.x, target_speed, 0.2)

	var scale = sprite.get_scale()
	if (facingright == true and scale.x == -1):
		sprite.set_scale(Vector2(1,1))
	elif (facingright == false and scale.x == 1):
		sprite.set_scale(Vector2(-1,1))

	if (is_on_floor()):
		on_air_time = 0

	############
	# Jump code
	#
	if (jumping and on_air_time == 0):
		# If we're not on air then we're not jumping
		jumping = false
		doubleJump = false

	if (jumping and jump and not prevJump and not doubleJump):
		# Jump was triggered again before reaching floor, do a double jump
		velocity.y = -JUMP_SPEED
		doubleJump = true
#		samplePlayer.play("Jump")

	if (on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prevJump and not jumping):
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true
#		samplePlayer.play("Jump")

	on_air_time += delta
	prevLeft = walk_left
	prevRight = walk_right
	prevJump = jump

	############
	# Music code
	#
	var pos = get_position()
	var pctComplete = pos.x / 900.0
	if (pctComplete > 1.0):
		pctComplete = 1.0
	var val = 0.1 + pctComplete * 1.5
	music.setLayerGain("Arp", val)

	if (pos.x < 300.0):
		music.setMainLoopCondition(0) # Area1
	elif (pos.x < 750.0):
		music.setMainLoopCondition(1) # Area2
	else:
		music.setMainLoopCondition(2) # Area3

	if (alive == false):
		anim = "Death"
	elif (attacking):
		anim = "Attack"
	elif (jumping):
		anim = "Jump"
	elif (velocity.x < 0.1 or velocity.x > 0.1):
		anim = "Walk"
	else:
		anim = "Idle"
	if (animPlayer.get_current_animation() != anim):
		animPlayer.play(anim)

