@tool
extends Node3D

@export_group("Airfoil")
@export_enum("Body","Wing","hzStabilizer") var surfaceType: String = "Body"
@export var aileronRatio := 0.00
