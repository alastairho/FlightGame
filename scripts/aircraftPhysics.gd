extends RigidBody3D

@export var centerWeightPercent = 0.80
@export var wingWeightPercent = 0.20

@export var maxThrust = 120000 #Newtons
var throttle = 0
var pitch = 0
var roll = 0
var speed = 0

var throttleSens = 0.01
var rollSens = 0.01
var pitchSens = 0.01

func _player_input():
	if Input.is_action_pressed("ThrottleUp"):
		throttle += throttleSens
	if Input.is_action_pressed("ThrottleDown"):
		throttle -= throttleSens
	if throttle < 0:
		throttle = 0
	elif throttle > 1:
		throttle = 1
		
	if Input.is_action_pressed("PitchUp"):
		pitch += pitchSens
	if Input.is_action_pressed("PitchDown"):
		pitch -= pitchSens
		
	if Input.is_action_pressed("RollAnticlockwise"):
		roll += rollSens
	if Input.is_action_pressed("RollClockwise"):
		roll -= rollSens
		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_player_input()
	var thrustForce = -basis.z*throttle*maxThrust
	var velocityVector = Vector3(get_linear_velocity())
	var speed = sqrt(velocityVector.x**2+velocityVector.y**2+velocityVector.z**2)
	apply_central_force(thrustForce)
	print(throttle)
	print(speed)
