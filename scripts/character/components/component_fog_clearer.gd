extends ComponentNormBase
class_name FogClearerComponent

@onready var area_2d_fog_clear: Area2D = $Area2DFogClear

var fog_node:Fog

func _ready() -> void:
	super._ready()
	if is_instance_valid(Global.main_game):
		fog_node = Global.main_game.background_manager.fog
	if is_instance_valid(fog_node):
		fog_node.add_fog_clearer(area_2d_fog_clear)

## 植物死亡
func _exit_tree() -> void:
	if is_instance_valid(fog_node):
		fog_node.del_fog_clearer(area_2d_fog_clear)

