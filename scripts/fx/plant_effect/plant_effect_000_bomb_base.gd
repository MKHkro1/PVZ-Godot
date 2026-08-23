extends Node2D
class_name BombEffectBase

## 爆炸特效
func activate_bomb_effect():

	visible = true
	if self.is_inside_tree():
		if get_tree().current_scene is MainGameManager:
			#GlobalUtils.child_node_change_parent(self, Global.main_game.bombs)
			reparent(Global.main_game.bombs)
