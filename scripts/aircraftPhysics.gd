extends RigidBody3D

@export var centerWeightPercent = 0.80
@export var wingWeightPercent = 0.20
@export var totalWeight = 11000 #Kilograms

var throttle = 0
@export var maxThrust = 120000 #Newtons

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
