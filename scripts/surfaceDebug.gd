@tool
extends Node3D

var wing
var aileron
var aileronRatio := 0.00


func _ready():
	wing = $ASWing
	aileron = $ASAileron
	aileronRatio = get_parent().aileronRatio

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _surfaceVisualiser():
	#Change position and scale of wing/aileron depending on aileron ratio
	aileron.set_scale(Vector3(1,1,aileronRatio))
	aileron.set_position(Vector3(0,0,(1-aileronRatio)/2))
	wing.set_scale(Vector3(1,1,1-aileronRatio))
	wing.set_position(Vector3(0,0,-aileronRatio/2))

func _process(delta):
	if Engine.is_editor_hint():
		# Code to execute in editor.
		_surfaceVisualiser()


	if not Engine.is_editor_hint():
		# Code to execute in game. Should add a debug button to hide Aero surface.
		_surfaceVisualiser()
		#self.visible = false

	# Code to execute both in editor and in game.
