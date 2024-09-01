extends Node3D

@export_group("Aircraft Characteristics")

@export var stallAOA := 0

@export var ClMax := 0.00
@export var noLiftAOA := 0

@export var CdStart := 0.00
@export var CdStall := 0.00

@export var zCdStart := 0.00

@export var xCdStart := 0.00

@export var rollLiftPercent := 0.00
@export var pitchLiftPercent := 0.00

var surfaceAreaTopSum := 0.00
var surfaceAreaFrontSum := 0.00
var surfaceAreaSide := 0.00

var aircraftCharacteristics = []
var bodyProperties = []
var wingProperties = []
var stabilProperties = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var surfaces = get_child_count()
	for i in range(surfaces):
		var surfaceType = get_child(i).surfaceType
		var aileronRatio = get_child(i).aileronRatio
		var surfacex = get_child(i).get_scale().x
		var surfacey = get_child(i).get_scale().y
		var surfacez = get_child(i).get_scale().z
		var surfaceAreaTop = surfacex * surfacez
		var surfaceAreaFront =  surfacey * surfacex
		
		var surfacePos = get_child(i).get_global_position()
		surfaceAreaTopSum += surfaceAreaTop
		surfaceAreaFrontSum += surfaceAreaFront
		if surfaceType == "Body":
			bodyProperties.append([surfacex, surfacey, surfacez, surfaceAreaTop, surfaceAreaFront, surfacePos])
			surfaceAreaSide = surfacez * surfacey
		elif surfaceType == "Wing":
			wingProperties.append([surfacex, surfacey, surfacez, surfaceAreaTop, surfaceAreaFront, aileronRatio, surfacePos])
		elif surfaceType == "hzStabilizer":
			stabilProperties.append([surfacex, surfacey, surfacez, surfaceAreaTop, surfaceAreaFront, aileronRatio, surfacePos])
	
	aircraftCharacteristics = [stallAOA , ClMax, noLiftAOA, CdStart, CdStall, zCdStart, xCdStart, surfaceAreaTopSum, surfaceAreaFrontSum, surfaceAreaSide, rollLiftPercent, pitchLiftPercent]

