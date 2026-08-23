extends Node
## 游戏物品管理器
class_name GameItemManager

## 放置在背景的游戏物品
@onready var game_items_in_bg: Node2D = %GameItemsInBg
@onready var canvas_layer_temp: CanvasLayer = %CanvasLayerTemp

enum E_GameItemType {
	WallnutBowlingStripe,	## 保龄球红线
	Hammer					## 锤子
}
var all_game_items:Dictionary[E_GameItemType, Node]

## 保龄球红线
var WALLNUT_BOWLING_STRIPE = load("res://scenes/item/game_scenes_item/mini_game_items/wallnut_bowling_stripe.tscn")
## 锤子
var HAMMER = load("res://scenes/item/game_scenes_item/mini_game_items/hammer.tscn")

## 初始化小游戏的不同物品
func init_game_item_manager(game_para:ResourceLevelData):
	if game_para.is_bowling_stripe:
		var wallnut_bowling_stripe:WallnutBowlingStripe = WALLNUT_BOWLING_STRIPE.instantiate()
		game_items_in_bg.add_child(wallnut_bowling_stripe)
		wallnut_bowling_stripe.init_item(game_para.plant_cell_col_j, game_para.plant_cell_can_use)
		all_game_items[E_GameItemType.WallnutBowlingStripe] = wallnut_bowling_stripe

	if game_para.is_hammer:
		var hammer = HAMMER.instantiate()
		canvas_layer_temp.add_child(hammer)
		all_game_items[E_GameItemType.Hammer] = hammer
