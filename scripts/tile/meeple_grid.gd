extends GridContainer

@onready var panel_meeple = preload("res://components/tile_component/meeple.tscn")

var count_grid = self.columns * 3
var tile_resource: Resource
var parent

func _ready() -> void:
	parent = get_parent()
	
	parent.connect("show_meeple_advice", _on_show_meeple_advice)
	parent.connect("meeple_skip", _on_meeple_skip)
	load_meeple_grid()
	tile_resource = parent.get_tile_resource()

func load_meeple_grid():
	for i in range(count_grid):
		var meeple_tile = panel_meeple.instantiate()
		#meeple_set.connect(meeple_tile._on_meeple_set)
		add_child(meeple_tile)

func _on_show_meeple_advice():
	if !parent.is_set:
		var meeple_advice_pos = tile_resource.meeple_position[parent.side]
		for pos in meeple_advice_pos:
			var index = meeple_advice_pos[pos].y * self.columns + meeple_advice_pos[pos].x
			var meeple_panel = get_child(index)
			meeple_panel.connect("meeple_set", clear_meeple_advice)
			meeple_panel._on_meeple_set()

func clear_meeple_advice(node):
	var meeples = get_children()
	parent.is_set = true
	#parent.is_current = false
	for meeple in meeples:
		if meeple != node:
			meeple.clear_advice()
	if node != null:
		parent.is_meeple = true
		Player.decrease_meeple(1)
	Player.update_current_state(Player.STATE.CHOOSE_TILE)

func _on_meeple_skip():
	if !parent.is_meeple:
		clear_meeple_advice(null)
