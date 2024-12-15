extends Area2D

func _ready():
	self.connect("area_entered", _on_area_entered)

func _on_area_entered(other_area: Area2D):
	if other_area.is_in_group("build"):
		print("BUILD", other_area.name)
