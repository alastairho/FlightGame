extends Node3D

@onready var forceVisualX = %VectorX
@onready var forceVisualY = %VectorY
@onready var forceVisualZ = %VectorZ

# Called when the node enters the scene tree for the first time.
func _ready():
	forceVisualX.set_scale(Vector3(0,1,1))
	forceVisualY.set_scale(Vector3(1,0,1))
	forceVisualZ.set_scale(Vector3(1,1,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
