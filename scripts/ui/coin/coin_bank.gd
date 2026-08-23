extends Control
class_name CoinBankLabel

## 是否自动隐藏
@export var auto_hide := true
@onready var label_coin_value: Label = $TextureRect/LabelCoinValue
@onready var timer_auto_hide: Timer = $TimerAutoHide
@onready var marker_2d_coin_target: Marker2D = $Marker2DCoinTarget

func _ready() -> void:
	update_label()


## 金币数字跳动动画
var _tween_coin_punch: Tween

func update_label():
	visible = true
	label_coin_value.text = "$" + GlobalUtils.format_number_with_commas(Global.coin_value)
	_punch_coin_counter()
	if auto_hide:
		if is_instance_valid(Global.main_game) and Global.main_game.main_game_progress == MainGameManager.E_MainGameProgress.RE_CHOOSE_CARD:
			visible = false
		else:
			timer_auto_hide.start()


func _punch_coin_counter() -> void:
	if not is_instance_valid(label_coin_value) or not label_coin_value.is_inside_tree():
		return
	if _tween_coin_punch and _tween_coin_punch.is_valid():
		_tween_coin_punch.kill()
	label_coin_value.pivot_offset = label_coin_value.size / 2.0
	label_coin_value.scale = Vector2(1.25, 1.25)
	_tween_coin_punch = create_tween()
	_tween_coin_punch.tween_property(label_coin_value, "scale", Vector2.ONE, 0.18)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_timer_auto_hide_timeout() -> void:
	visible = false
