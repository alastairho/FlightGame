@tool
extends Node3D

@onready var wing = %ASWing
@onready var aileron = %ASAileron

@export_group("Body")
@export var skinFriction = 0

@export_group("Airfoil")
@export var aileronRatio = 0.00
@export var stallAOA = 0
var surfaceScale = 0

@export var ClMax = 0.00
@export var noLiftAOA = 0

@export var CdStart = 0.00
@export var CdStall = 0.00


func _surfaceVisualiser():
	#Change position and scale of wing/aileron depending on aileron ratio
	surfaceScale = Vector3(get_scale())
	aileron.set_scale(Vector3(surfaceScale.x,surfaceScale.y,surfaceScale.z*aileronRatio))
	aileron.set_position(Vector3(0,0,(surfaceScale.z-aileronRatio)/2))
	wing.set_scale(Vector3(surfaceScale.x,surfaceScale.y,surfaceScale.z-surfaceScale.z*aileronRatio))
	wing.set_position(Vector3(0,0,-aileronRatio/2))


func _surfaceVectorVisualiser():
	pass


func _process(delta):
	if Engine.is_editor_hint():
		# Code to execute in editor.
		_surfaceVisualiser()
		
		
	if not Engine.is_editor_hint():
		# Code to execute in game.
		_surfaceVisualiser()

	# Code to execute both in editor and in game.
