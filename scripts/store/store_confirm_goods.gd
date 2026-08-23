extends Control
class_name ConfirmGoods
## 确认是否购买商品

@onready var pvz_button_yes: PVZButtonBase = $Panel/HBoxContainer/PVZButtonYes
@onready var pvz_button_no: PVZButtonBase = $Panel/HBoxContainer/PVZButtonNo

## 当前商品节点
var curr_goods_node:Goods

func _ready() -> void:
	pvz_button_yes.pressed.connect(_on_pvz_button_yes_pressed)
	pvz_button_no.pressed.connect(_on_pvz_button_no_pressed)


## 出现该界面确认购买商品
func appear_canvas_layer(curr_goods:Goods):
	print(curr_goods.name)
	curr_goods_node = curr_goods
	visible = true


## 确认购买
func _on_pvz_button_yes_pressed() -> void:
	curr_goods_node.comfirm_get_this_goods()
	curr_goods_node = null
	visible = false

## 取消购买
func _on_pvz_button_no_pressed() -> void:
	curr_goods_node = null
	visible = false
