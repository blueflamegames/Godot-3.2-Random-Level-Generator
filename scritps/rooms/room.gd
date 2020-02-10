extends Spatial
class_name Room

var doorways = []
var bounds : Area
var overlaps : bool = false

func _ready():
	doorways = get_node("mesh/doorways").get_children()
	bounds = get_node("mesh/bounds")
#	bounds.connect("area_entered", self, "_on_area_entered")

#func _on_area_entered(area):
#	overlaps = true

func _process(delta):
	if bounds.get_overlapping_areas().size() > 0:
		overlaps = true
	else:
		overlaps = false
