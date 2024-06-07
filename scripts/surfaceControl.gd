extends Node3D
var surfaces

# Called when the node enters the scene tree for the first time.
func _ready():
	surfaces = get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for i in surfaces:
		var pos = surfaces[i].get_global_position()
		var aileronRatio = surfaces[i].get("aileronRatio")
		var stallAOA = surfaces[i].get("stallAOA")
		var ClMax = surfaces[i].get("ClMax")
		var noLiftAOA = surfaces[i].get("noLiftAOA")
		var CdStart = surfaces[i].get("CdStart")
		var CdStall = surfaces[i].get("CdStall")
