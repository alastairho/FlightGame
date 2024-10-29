extends RigidBody3D

#Player Controls

var throttle = 0
var pitch = 0
var roll = 0
var aoa = 0

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

@export var aircraftMass: int

var maxAlt = 18288 #A max
var maxPossibleThrust = 160000 #T max
var seaLevelStartThrust = 97861 #T highstart
var seaLevelEndThrust = 146791 #T highend
var maxAltStartThrust = 4448 #T lowstart 
var maxAltEndThrust = 31138 #T lowend
var seaLevelMaxThrustMach = 0.9 # M tmax
var maxAltMaxThrustMach = 1.8 #M tlastmax
var machEffect = 2

var aileronRatio
var stallAOA
var ClMax
var noLiftAOA
var CdStart
var CdStall
var zCdStart
var xCdStart
var liftCoefficent

var surfaceAreaTopSum
var surfaceAreaFrontSum
var surfaceAreaSide
var surfaceAreaWingTopSum := 0.00

var rollLiftPercent
@export var aircraftRollRadius: float
@export var aircraftPitchRadius: float

var pitchLiftPercent

#Physics Calculations
func _ready():
	mass = aircraftMass
	var aircraftCharacteristics = $AeroSurfaces.aircraftCharacteristics
	var bodyProperties = $AeroSurfaces.bodyProperties
	var wingProperties = $AeroSurfaces.wingProperties
	var stabilProperties = $AeroSurfaces.stabilProperties
	stallAOA = aircraftCharacteristics[0]
	ClMax = aircraftCharacteristics[1]
	noLiftAOA = aircraftCharacteristics[2]
	CdStart = aircraftCharacteristics[3]
	CdStall = aircraftCharacteristics[4]
	zCdStart = aircraftCharacteristics[5]
	xCdStart = aircraftCharacteristics[6]
	surfaceAreaTopSum = aircraftCharacteristics[7]
	surfaceAreaFrontSum = aircraftCharacteristics[8]
	surfaceAreaSide = aircraftCharacteristics[9]
	rollLiftPercent = aircraftCharacteristics[10]
	pitchLiftPercent = aircraftCharacteristics[11]

	for wings in wingProperties:
		surfaceAreaWingTopSum += wings[3]	#Wing top area
	for stabilizers in stabilProperties:
		surfaceAreaWingTopSum += stabilizers[3]
		
var lift
var aoaSens = 2
func _physics_process(delta):
	_player_input()
	var globalVelocityVector = Vector3(get_linear_velocity())
	var velocityVector : Vector3
	velocityVector.x = transform.basis.x.dot(globalVelocityVector.normalized())*globalVelocityVector.length()
	velocityVector.y = transform.basis.y.dot(globalVelocityVector.normalized())*globalVelocityVector.length()
	velocityVector.z = transform.basis.z.dot(globalVelocityVector.normalized())*globalVelocityVector.length()
	
	var altitude = int(global_transform.origin.y)
	var speed = sqrt(velocityVector.x**2+velocityVector.y**2+velocityVector.z**2)
	var speedMach = speed/343
	var airDensity
	if altitude < 20800: #Limit of the model
		airDensity = 1.21+(-1.07e-4)*altitude+(2.57e-9)*altitude**2
	else:
		airDensity = 0
	
	#Gravity
	var gravityForce
	if altitude > 5:
		gravityForce = Vector3(0,mass*-9.81,0)
	else:
		gravityForce = Vector3(0,0,0)
	
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
		 
	elif speedMach > seaLevelMaxThrustMach+maxThrustMachDepAlt:
		maxThrust = (-seaLevelEndThrust-lowestThrustDepAlt)*((speedMach-seaLevelMaxThrustMach-lowestThrustDepAlt)**2)+(maxPossibleThrust*(1-altitudeRatio))
		
	else:
		maxThrust = 0
		
	if maxThrust < 0:
		maxThrust = 0
		
	var thrustForce = -basis.z*(powerOutput*maxThrust)
	
	#Lift
	if aoa <= stallAOA and aoa >= -stallAOA:
		liftCoefficent = (((ClMax/stallAOA)/(speedMach+1)**machEffect)/(speedMach+1))*aoa
	elif aoa > stallAOA:
		liftCoefficent = -((((ClMax/(speedMach+1)**machEffect)*(aoa-(2*stallAOA)+noLiftAOA))*(aoa-noLiftAOA))/((stallAOA**2)-(2*noLiftAOA*stallAOA)+(noLiftAOA**2)))
	elif aoa < -stallAOA:
		liftCoefficent = ((((ClMax/(speedMach+1)**machEffect)*(-aoa-(2*stallAOA)+noLiftAOA))*(-aoa-noLiftAOA))/((stallAOA**2)-(2*noLiftAOA*stallAOA)+(noLiftAOA**2)))
	
	if aoa >= noLiftAOA or aoa <= -noLiftAOA:
		liftCoefficent = 0
	
	
	lift = (liftCoefficent*(airDensity*(velocityVector.z**2))/2)*surfaceAreaWingTopSum
	var liftForce = basis.y*lift
	
	#Drag
	var CdRate = (CdStall-CdStart)/(stallAOA**2)
	var dragCoefficent = (CdRate/(speedMach+1)**machEffect)*(aoa**2)+CdStart
	var yDragForce = -basis.y*((dragCoefficent*(airDensity*(globalVelocityVector.z**2))/2)*surfaceAreaFrontSum)
	
	var zDragCoefficent = zCdStart
	var zDragForce = basis.z*((zDragCoefficent*(airDensity*(velocityVector.y**2))/2)*(surfaceAreaTopSum))
	
	var xDragCoefficent = xCdStart
	var xDragForce : Vector3
	if velocityVector.x < 0:
		xDragForce = basis.x*((xDragCoefficent*(airDensity*(velocityVector.x**2))/2)*(surfaceAreaSide))
	elif velocityVector.x > 0:
		xDragForce = -basis.x*((xDragCoefficent*(airDensity*(velocityVector.x**2))/2)*(surfaceAreaSide))
	else:
		xDragForce = Vector3(0,0,0)
	
	#Roll
	var rollLift = abs(roll)*25000
	var rollTorque: Vector3
	if roll > 0:
		rollTorque = basis.z*rollLift*aircraftRollRadius
	elif roll < 0:
		rollTorque = -basis.z*rollLift*aircraftRollRadius
	
	'''
	My Previous idea of the model
	if roll != 0:
		var rollLift = abs(roll)*rollLiftPercent*lift
		var radRolled = (rollLift*aircraftRollRadius*delta**2)/rollMomentOfInertia
		var angleRolled = rad_to_deg(radRolled)
		if roll < 0:
			angleRolled *= -1
	'''
	#Pitch
	var pitchLift : float
	pitchLift = abs(pitch)*15000
	var pitchTorque: Vector3
	if pitch > 0:
		pitchTorque = basis.x*pitchLift*aircraftPitchRadius
	elif pitch < 0:
		pitchTorque = -basis.x*pitchLift*aircraftPitchRadius
	
	#Apply Forces and Info
	var zResultantForce = thrustForce + zDragForce
	var yResultantForce = liftForce + yDragForce + gravityForce
	var force = zResultantForce + yResultantForce + xDragForce
	var torque = rollTorque + pitchTorque
	
	aoa = rad_to_deg(acos(globalVelocityVector.normalized().dot(-basis.z.normalized())))
	
	apply_central_force(force)
	apply_torque(torque)
	get_node("UI/Statistics/HBoxContainer/StatLabel").text = str(aoa) + "\n" + str(altitude) + "\n" + str(int(speed)) + "\n" + str(speedMach) + "\n" + str(int(globalVelocityVector.y))
	get_node("UI/Controls/HBoxContainer2/ControlLabel").text = str(throttle) + "\n" + str(pitch) + "\n" + str(roll)
	
	#Debug
	#print("z: " + str(zResultantForce) + " y: "+ str(yResultantForce))
	#print("Cl: " +str(liftCoefficent) , " Cd: " +str(dragCoefficent) , " Thrust Force: " + str(thrustForce) ,  " Lift Force: " +str(liftForce), " Drag Force: " +str(xDragForce), " Force: " +str(force))
	#print(str(thrustForce," ",maxThrust, " "))
	#print(str(rollTorque," ",liftForce, " "))
	#print(str(velocityVector," ",aoa, " ", 	velocityVector.normalized().dot(-basis.z.normalized())))
