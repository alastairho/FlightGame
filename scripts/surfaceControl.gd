extends Node3D

@export_group("Aircraft Characteristics")

@export var stallAOA := 0

@export var ClMax := 0.00
@export var noLiftAOA := 0

@export var CdStart := 0.00
@export var CdStall := 0.00

@export var zCdStart := 0.00
@export var zCdStall := 0.00

var surfaceAreaTopSum := 0.00
var surfaceAreaFrontSum := 0.00
var surfaceAreaWingTopSum := 0.00

var aircraftCharacteristics = []
var wingProperties = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var surfaces = get_child_count()
	for i in range(surfaces):
		var surfaceAreaTop = get_child(i).get_scale().x * get_child(i).get_scale().z
		var surfaceAreaFront =  get_child(i).get_scale().y * get_child(i).get_scale().x
		var aileronRatio = get_child(i).aileronRatio
		var surfacePos = get_child(i).get_global_position()
		surfaceAreaTopSum += surfaceAreaTop
		surfaceAreaFrontSum += surfaceAreaFront
		if aileronRatio == 0:
			surfaceAreaWingTopSum += surfaceAreaTop
		else:
			wingProperties.append([surfaceAreaTop, surfaceAreaFront, aileronRatio, surfacePos])
	
	aircraftCharacteristics = [stallAOA , ClMax, noLiftAOA, CdStart, CdStall, zCdStart, zCdStall, surfaceAreaTopSum, surfaceAreaFrontSum, surfaceAreaWingTopSum]

