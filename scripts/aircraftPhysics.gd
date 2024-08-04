extends RigidBody3D

#Player Controls

var throttle = 0
var pitch = 0
var roll = 0

func _player_input():
	const THROTTLESENS = 0.01
	const ROLLSENS = 0.02
	const PITCHSENS = 0.02
	const RETURNSENS = 0.01
	
	if Input.is_action_pressed("ThrottleUp"):
		throttle += THROTTLESENS
	if Input.is_action_pressed("ThrottleDown"):
		throttle -= THROTTLESENS
		
	throttle = clamp(throttle,0,1.0)
		
	if Input.is_action_pressed("PitchUp"):
		pitch += PITCHSENS
	else:
		if pitch > 0:
			pitch -= RETURNSENS
	if Input.is_action_pressed("PitchDown"):
		pitch -= PITCHSENS
	else:
		if pitch < 0:
			pitch += RETURNSENS
			
	pitch = clamp(pitch,-1.0,1.0)
		
	if Input.is_action_pressed("RollAnticlockwise"):
		roll += ROLLSENS
	else:
		if roll > 0:
			roll -= RETURNSENS
	if Input.is_action_pressed("RollClockwise"):
		roll -= ROLLSENS
	else:
		if roll < 0:
			roll += RETURNSENS
			
	roll = clamp(roll,-1.0,1.0)
	

#Airplane Properties
var wingProperties: Array = []

var centerWeightPercent = 0.80
var wingWeightPercent = 0.20

var maxAlt = 18288 #A max
var maxPossibleThrust = 160000 #T max
var seaLevelStartThrust = 97861 #T highstart
var seaLevelEndThrust = 146791 #T highend
var maxAltStartThrust = 4448 #T lowstart 
var maxAltEndThrust = 31138 #T lowend
var seaLevelMaxThrustMach = 0.9 # M tmax
var maxAltMaxThrustMach = 1.8 #M tlastmax

var positionOffset
var aileronRatio
var stallAOA
var ClMax
var noLiftAOA
var CdStart
var CdStall
var zCdStart
var zCdStall
var liftCoefficent
var surfaceAreaTopSum
var surfaceAreaFrontSum
var surfaceAreaWingTopSum

var liftRatio = 0.50
#wingProperties.append([surfaceAreaTop, surfaceAreaFront, aileronRatio, surfacePos])
#aircraftCharacteristics = [stallAOA , ClMax, noLiftAOA, CdStart, CdStall, surfaceAreaTopSum, surfaceAreaFrontSum]

#Physics Calculations
func _ready():
	var aircraftCharacteristics = $AeroSurfaces.aircraftCharacteristics
	var wingProperties = $AeroSurfaces.wingProperties
	stallAOA = aircraftCharacteristics[0]
	ClMax = aircraftCharacteristics[1]
	noLiftAOA = aircraftCharacteristics[2]
	CdStart = aircraftCharacteristics[3]
	CdStall = aircraftCharacteristics[4]
	zCdStart = aircraftCharacteristics[5]
	zCdStall = aircraftCharacteristics[6]
	surfaceAreaTopSum = aircraftCharacteristics[7]
	surfaceAreaFrontSum = aircraftCharacteristics[8]
	surfaceAreaWingTopSum = aircraftCharacteristics[9]
	


func _physics_process(delta):
	_player_input()
	var velocityVector = Vector3(get_linear_velocity())
	
	var altitude = int(global_transform.origin.y)
	var speed = sqrt(velocityVector.x**2+velocityVector.y**2+velocityVector.z**2)
	var speedMach = speed/343
	var aoa = 0
	var airDensity
	if altitude < 20800: #Limit of the model
		airDensity = 1.21+(-1.07e-4)*altitude+(2.57e-9)*altitude**2
	else:
		airDensity = 0
	
	#Thrust
	var powerOutput: float
	if throttle <= 0.77:
		powerOutput = (0.5*throttle)/0.77
	else:
		powerOutput = ((0.5*throttle)/0.23)-1.17
	
	var altitudeRatio = altitude/maxAlt
	var maxThrustMachDepAlt = (maxAltMaxThrustMach-seaLevelMaxThrustMach)*altitudeRatio
	var highestThrustDepAlt = (seaLevelStartThrust-maxAltStartThrust)*(1-altitudeRatio)
	var lowestThrustDepAlt = (seaLevelEndThrust-maxAltEndThrust)*(1-altitudeRatio)
	var maxThrust
	
	if speedMach <= seaLevelMaxThrustMach+maxThrustMachDepAlt and speedMach >= 0:
		maxThrust = ((maxPossibleThrust*(1-altitudeRatio)-highestThrustDepAlt)/(seaLevelMaxThrustMach+maxThrustMachDepAlt)*speedMach)+maxAltStartThrust+highestThrustDepAlt
		#print("line" + " " + str(maxThrust))
	elif speedMach > seaLevelMaxThrustMach+maxThrustMachDepAlt:
		maxThrust = (-seaLevelEndThrust-lowestThrustDepAlt)*((speedMach-seaLevelMaxThrustMach-lowestThrustDepAlt)**2)+(maxPossibleThrust*(1-altitude/maxAlt))
		#print("parabola" + " " + str(maxThrust))
	else:
		maxThrust = 0
		
	if maxThrust < 0:
		maxThrust = 0
		
	var thrustForce = -basis.z*(powerOutput*maxThrust)
	
	#Lift
	var clampedSpeedMach = clamp(speedMach,1,INF)
	
	if aoa <= stallAOA and aoa >= -stallAOA:
		liftCoefficent = ((ClMax/stallAOA)/clampedSpeedMach)*aoa
	elif aoa > stallAOA or aoa < -stallAOA:
		liftCoefficent = -((((ClMax/clampedSpeedMach)*(aoa-(2*stallAOA)+noLiftAOA))*(aoa-noLiftAOA))/((stallAOA**2)-(2*noLiftAOA*stallAOA)+(noLiftAOA**2)))
	elif aoa < 0:
		liftCoefficent *= -1
	else:
		liftCoefficent = 0
	
	var liftForce = basis.y*((liftCoefficent*(airDensity*(velocityVector.z**2))/2)*surfaceAreaWingTopSum)
	
	#Drag
	var CdRate = (CdStall-CdStart)/(stallAOA**2)
	var dragCoefficent = CdRate*(aoa**2)+CdStart
	var yDragForce = -basis.y*((dragCoefficent*(airDensity*(velocityVector.y**2))/2)*surfaceAreaTopSum)
	
	var zCdRate = (zCdStall-zCdStart)/(stallAOA**2)
	var zDragCoefficent = zCdRate*(aoa**2)+zCdStart
	var zDragForce = basis.z*((zDragCoefficent*(airDensity*(velocityVector.z**2))/2)*surfaceAreaFrontSum)
	
	#Roll
	liftRatio = 0.50 + roll/2
	
	#Pitch
	
	#Apply Forces and Info
	var zResultantForce = thrustForce + zDragForce
	var yResultantForce = liftForce + yDragForce
	
	apply_central_force(zResultantForce + yResultantForce)
	get_node("UI/Statistics/HBoxContainer/StatLabel").text = str(aoa) + "\n" + str(altitude) + "\n" + str(int(speed)) + "\n" + str(int(velocityVector.y)) + "\n" + str(speedMach)
	get_node("UI/Controls/HBoxContainer2/ControlLabel").text = str(throttle) + "\n" + str(pitch) + "\n" + str(roll)
	
	#Debug
	#print("z: " + str(zResultantForce) + " y: "+ str(yResultantForce))
	#print("Cl: " +str(liftCoefficent) , " Cd: " +str(dragCoefficent) , " Thrust Force: " + str(thrustForce) ,  " Lift Force: " +str(liftForce), " Drag Force: " +str(yDragForce))
	#print("lift ratio : " + str(liftRatio), " roll: " + str(roll))
	print(str(thrustForce," ",maxThrust, " "))
