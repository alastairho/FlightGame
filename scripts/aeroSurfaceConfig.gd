extends Node3D

@onready var wing = %ASWing
@onready var aileron = %ASAileron

@export_enum("Horizontal", "Vertical") var surfaceAxis = 0

@export_group("Body")
@export var skinFriction = 0

@export_group("Airfoil")
@export var aileronRatio = 0
@export var stallAOA = 0

@export var ClMax = 0
@export var noLiftAOA = 0

@export var CdStart = 0
@export var CdStall = 0
