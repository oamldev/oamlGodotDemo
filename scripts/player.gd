extends KinematicBody2D

const SCALE = 4
const GRAVITY = 500.0*SCALE # Pixels/second
const DAMAGE_THROWBACK = 8000*SCALE
const VERTICAL_DAMAGE_THROWBACK = 6000*SCALE

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
	set_fixed_process(true)

func _input(event):
	var cancel = event.is_action_pressed("ui_cancel")
	if (cancel):
		toggleMenu()

func _fixed_process(delta):
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

	var force = Vector2(0, GRAVITY)
	var stop = true
	
	if (walk_left):
		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
			facingright = false
	elif (walk_right):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
			facingright = true

	var scale = sprite.get_scale()
	if (facingright == true and scale.x == -1):
		sprite.set_scale(Vector2(1,1))
	elif (facingright == false and scale.x == 1):
		sprite.set_scale(Vector2(-1,1))

	if (stop):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		if (hit_counter == 0):
			vlen -= STOP_FORCE*delta
		else:
			vlen -= STOP_FORCE_HIT*delta
		if (vlen < 0):
			vlen = 0
		
		velocity.x = vlen*vsign
	
	# Integrate forces to velocity
	velocity += force*delta
	
	# Integrate velocity into motion and move
	var motion = velocity*delta
	
	# Move and consume motion
	motion = move(motion)
	
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		# Ran against something, is it the floor? Get normal
		var n = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			# If angle to the "up" vectors is < angle tolerance
			# char is on floor
			on_air_time = 0
			floor_velocity = get_collider_velocity()
		
		if (on_air_time == 0 and force.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			# Since this formula will always slide the character around, 
			# a special case must be considered to to stop it from moving 
			# if standing on an inclined floor. Conditions are:
			# 1) Standing on floor (on_air_time == 0)
			# 2) Did not move more than one pixel (get_travel().length() < SLIDE_STOP_MIN_TRAVEL)
			# 3) Not moving horizontally (abs(velocity.x) < SLIDE_STOP_VELOCITY)
			# 4) Collider is not moving
			
			revert_motion()
			velocity.y = 0.0
		else:
			# For every other case of motion, our motion was interrupted.
			# Try to complete the motion by "sliding" by the normal
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			# Then move again
			move(motion)

	if (floor_velocity != Vector2()):
		# If floor moves, move with floor
		move(floor_velocity*delta)

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
		samplePlayer.play("Jump")
		animPlayer.play("Jump")

	if (on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prevJump and not jumping):
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true
		samplePlayer.play("Jump")
		animPlayer.play("Jump")

	on_air_time += delta
	prevLeft = walk_left
	prevRight = walk_right
	prevJump = jump

	############
	# Music code
	#
	var pos = get_pos()
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

