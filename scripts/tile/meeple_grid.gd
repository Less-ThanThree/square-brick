extends GridContainer

@onready var panel_meeple = preload("res://components/tile_component/meeple.tscn")

var count_grid = self.columns * 3
var tile_resource: Resource

func _ready() -> void:
	var parent = get_parent()
	
	parent.connect("show_meeple_advice", _on_show_meeple_advice)
	load_meeple_grid()
	tile_resource = parent.get_tile_resource()

func load_meeple_grid():
	for i in range(count_grid):
		var meeple_tile = panel_meeple.instantiate()
		#meeple_set.connect(meeple_tile._on_meeple_set)
		add_child(meeple_tile)

func _on_show_meeple_advice():
	var meeple_advice_pos = tile_resource.meeple_position
	for pos in meeple_advice_pos:
		var index = meeple_advice_pos[pos].y * self.columns + meeple_advice_pos[pos].x
		var meeple_panel = get_child(index)
		meeple_panel._on_meeple_set()
