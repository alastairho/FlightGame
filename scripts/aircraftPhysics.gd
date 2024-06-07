extends RigidBody3D

@export var centerWeightPercent = 0.80
@export var wingWeightPercent = 0.20

@export var maxThrust = 120000 #Newtons
var throttle = 0
var pitch = 0
var roll = 0

var throttleSens = 0.01
var rollSens = 0.02
var pitchSens = 0.02
var returnSens = 0.01

var zDragCoefficent = 0.015
var aeroSurfaces
var positionOffset
var aileronRatio
var stallAOA
var ClMax
var noLiftAOA
var CdStart
var CdStall
var liftCoefficent
var CdRate
var dragCoefficent
var surfaceArea

func _player_input():
	if Input.is_action_pressed("ThrottleUp"):
		throttle += throttleSens
	if Input.is_action_pressed("ThrottleDown"):
		throttle -= throttleSens
		
	throttle = clamp(throttle,0,1)
		
	if Input.is_action_pressed("PitchUp"):
		pitch += pitchSens
	else:
		if pitch > 0:
			pitch -= returnSens
	if Input.is_action_pressed("PitchDown"):
		pitch -= pitchSens
	else:
		if pitch < 0:
			pitch += returnSens
			
	pitch = clamp(pitch,-1,1)
		
	if Input.is_action_pressed("RollAnticlockwise"):
		roll += rollSens
	else:
		if roll > 0:
			roll -= returnSens
	if Input.is_action_pressed("RollClockwise"):
		roll -= rollSens
	else:
		if roll < 0:
			roll += returnSens
			
	roll = clamp(roll,-1,1)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	aeroSurfaces = $AeroSurfaces.get_child_count()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_player_input()
	var velocityVector = Vector3(get_linear_velocity())
	
	var altitude = int(self.global_transform.origin.y)
	var speed = sqrt(velocityVector.x**2+velocityVector.y**2+velocityVector.z**2)
	var aoa = 0
	var airDensity = 1.21+(-1.07e-4)*altitude+(2.57e-9)*altitude**2
	
	var thrustForce = -basis.z*throttle*maxThrust
	var zDragForce = basis.z*(zDragCoefficent*airDensity*(velocityVector.z**2)/2)*9.132 #Wing leading edge area
	
	var liftForce
	var yDragForce
	var liftForceSum = Vector3()
	var yDragForceSum = Vector3()
	
	
	
	for i in range(aeroSurfaces):
		positionOffset = self.get_global_position()-$AeroSurfaces.get_child(i).get_global_position()
		surfaceArea = $AeroSurfaces.get_child(i).get_scale().x * $AeroSurfaces.get_child(i).get_scale().z
		aileronRatio = $AeroSurfaces.get_child(i).aileronRatio
		stallAOA = $AeroSurfaces.get_child(i).stallAOA
		ClMax = $AeroSurfaces.get_child(i).ClMax
		noLiftAOA = $AeroSurfaces.get_child(i).noLiftAOA
		CdStart = $AeroSurfaces.get_child(i).CdStart
		CdStall = $AeroSurfaces.get_child(i).CdStall
		
		if aoa <= stallAOA and aoa >= -stallAOA:
			liftCoefficent = (ClMax/stallAOA)*aoa
		elif aoa > stallAOA or aoa < -stallAOA:
			liftCoefficent = -(((ClMax*(aoa-(2*stallAOA)+noLiftAOA))*(aoa-noLiftAOA))/((stallAOA**2)-(2*noLiftAOA*stallAOA)+(noLiftAOA**2)))
		elif aoa < 0:
			liftCoefficent *= -1
		else:
			liftCoefficent = 0
		
		liftForce = basis.y*((liftCoefficent*airDensity*(velocityVector.z**2))/2)*surfaceArea
		
		CdRate = (CdStall-CdStart)/stallAOA 
		dragCoefficent = CdRate*aoa**2+CdStart
		yDragForce = -basis.y*((zDragCoefficent*airDensity*(velocityVector.y**2))/2)*surfaceArea
		
		liftForceSum += liftForce
		yDragForceSum += yDragForce
	
	prints("Cl: " +str(liftCoefficent , " Cd: " +str(dragCoefficent)))
	
	var zResultantForce = thrustForce + zDragForce
	var yResultantForce = liftForceSum + yDragForceSum
	
	apply_central_force(zResultantForce + yResultantForce)
	get_node("UI/Statistics/HBoxContainer/StatLabel").text = "N/A" + "\n" + str(altitude) + "\n" + str(int(speed)) + "\n" + str(int(velocityVector.y))
	get_node("UI/Controls/HBoxContainer2/ControlLabel").text = str(throttle) + "\n" + str(pitch) + "\n" + str(roll)
