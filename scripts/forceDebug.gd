extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var forceVisualX = %VectorX
	var forceVisualY = %VectorY
	var forceVisualZ = %VectorZ
	forceVisualX.set_scale(Vector3(0,1,1))
	forceVisualY.set_scale(Vector3(1,0,1))
	forceVisualZ.set_scale(Vector3(1,1,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
