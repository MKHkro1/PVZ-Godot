extends Node2D
class_name ItemBase

@onready var body: Node2D = $Body
var item_button:UiItemButton
var is_activate := false
##INFO:安卓适配 使用时鼠标点击后等待状态
var is_mouse_button_pressed_wait := false

var is_clone := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	is_activate = false

func _process(_delta):
	if is_activate and not is_mouse_button_pressed_wait:
		global_position = get_global_mouse_position()


func use_it():
	pass

## 克隆自己
func clone_self():
	var parent = get_parent()
	if parent:
		var clone:ItemBase = duplicate(4)
		parent.add_child(clone)
		clone.global_position = global_position
		clone.body.visible = true
		return clone

## 鼠标点击ui图标按钮，激活该物品
func activete_it():
	visible = true
	is_activate = true
	body.visible = true

## 取消激活
func deactivate_it(is_play_sfx:=true):
	item_button.item_texture.visible = true
	visible = false
	is_activate = false

	global_position = Vector2(0,0)
	if is_play_sfx:
		SoundManager.play_other_SFX("tap2")
