extends Control
class_name StartMenuRoot

@onready var dialog: Dialog = $Dialog
@export var bgm:AudioStream
@onready var user: User = $User


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Cloud/AnimationPlayer.play("Idle")
	$BG_Right/Leaf/AnimationPlayer.play("Idle")
	$AnimationPlayer.play("Idle")

	SoundManager.setup_ui_start_menu_sound(self)
	SoundManager.play_bgm(bgm)

	Global.time_scale = 1.0
	Engine.time_scale = Global.time_scale

	## 入场动画(延迟到布局完成后播放)
	call_deferred("_play_entrance_anim")


## 入场动画:菜单分组从右侧依次滑入,木牌落下,版本号淡入
func _play_entrance_anim() -> void:
	var delay := 0.05
	for path in ["BG_Right/Menu", "BG_Right/Flower", "BG_Right/Item", "BG_Right/Option", "BG_Right/CustomButton"]:
		var ctrl: Control = get_node(NodePath(path))
		_slide_in_from_right(ctrl, delay)
		delay += 0.07
	_drop_in_from_top($WoodSign, 0.1)
	_fade_in($BG_Right/Version, 0.55)


## 控件从右侧偏移处滑入并淡入
func _slide_in_from_right(ctrl: Control, delay: float, offset_x := 60.0, duration := 0.45) -> void:
	var final_pos: Vector2 = ctrl.position
	ctrl.position = final_pos + Vector2(offset_x, 0)
	ctrl.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_property(ctrl, "position", final_pos, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ctrl, "modulate:a", 1.0, duration * 0.7)

## 控件从上方落下(回弹)
func _drop_in_from_top(ctrl: Control, delay: float, offset_y := 180.0) -> void:
	var final_pos: Vector2 = ctrl.position
	ctrl.position = final_pos - Vector2(0, offset_y)
	ctrl.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_property(ctrl, "position", final_pos, 0.6)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ctrl, "modulate:a", 1.0, 0.25)

## 控件淡入
func _fade_in(ctrl: CanvasItem, delay: float, duration := 0.4) -> void:
	ctrl.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_property(ctrl, "modulate:a", 1.0, duration)

## 花园需要浇水
var garden_need_water:=true

## 功能未实现
func _unrealized():
	dialog.appear_dialog()

## 开始游戏(冒险模式选关)
func _on_button_1_pressed() -> void:
	Global.game_para = null
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.ChooseLevelAdventure])


## 迷你游戏
func _on_button_2_pressed() -> void:
	Global.game_para = null
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.ChooseLevelMiniGame])

## 解密模式
func _on_button_3_pressed() -> void:
	Global.game_para = null
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.ChooseLevelPuzzle])

## 生存模式
func _on_button_4_pressed() -> void:
	Global.game_para = null
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.ChooseLevelSurvival])

## 自定义关卡
func _on_custom_button_pressed() -> void:
	Global.game_para = null
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.ChooseLevelCustom])

#region 选项
func _on_option_button_1_pressed() -> void:
	$StartMenuOptionDialog.appear_menu()


func _on_option_button_2_pressed() -> void:
	$Dialog_Help.appear_dialog()

## 退出游戏
func _on_option_button_3_pressed() -> void:
	get_tree().quit()


func _on_full_screen_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
#endregion


## 花园
func _on_item_button_1_pressed() -> void:
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.Garden])

## 图鉴
func _on_item_button_2_pressed() -> void:
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.Almanac])

## 商店
func _on_item_button_3_pressed() -> void:
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.Store])

## 点击用户更新时
func _on_button_update_user_pressed() -> void:
	user.visible = true


