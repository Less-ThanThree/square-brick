extends Area2D

signal area_enter(zone)

var parent

func _ready():
	parent = get_parent().get_parent().get_parent()
	area_entered.connect(self._on_area_entered)
	area_enter.connect(parent._on_area_entered)

func _on_area_entered(area: Area2D):
	if parent.is_set:
		if area.is_in_group("build"):
			emit_signal("area_enter", "build")
#func _on_area_entered(other_area: Area2D):
	#if other_area.is_in_group("build"):
		#print(parent.left_side_isnide)
		#print("BUILD", other_area.name)
