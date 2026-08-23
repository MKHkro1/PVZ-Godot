extends CanvasLayer
class_name CanvasLayerEffect
## 通过事件总线进行全屏光效展示

## 全屏光效种类
enum E_CanvasLayerEffectType{
	Ice,	## 冰冻
	Doom,	## 毁灭菇
}

@onready var all_panel_effect: Dictionary[E_CanvasLayerEffectType, Panel] = {
	E_CanvasLayerEffectType.Ice: $Panel_Ice,
	E_CanvasLayerEffectType.Doom: $Panel_Doom
}

var all_tween:Dictionary[E_CanvasLayerEffectType,Tween]
var all_ori_color:Dictionary[E_CanvasLayerEffectType,Color]

func _ready() -> void:
	for i in all_panel_effect.keys():
		all_ori_color[i] = all_panel_effect[i].modulate
	## 注册事件总线
	EventBus.subscribe("canvas_layer_effect_once", canvas_layer_effect_once)

## 发生一次全屏光效
func canvas_layer_effect_once(canvas_layer_effect_type:E_CanvasLayerEffectType, duration: float = 0.3):
	if all_tween.get(canvas_layer_effect_type):
		all_tween[canvas_layer_effect_type].kill()

	all_tween[canvas_layer_effect_type] = create_tween()  # 创建 Tween 实例
	visible = true
	all_tween[canvas_layer_effect_type].tween_property(all_panel_effect[canvas_layer_effect_type], "modulate", all_ori_color[canvas_layer_effect_type] + Color(0,0,0,0.3), duration * 0.5)
	all_tween[canvas_layer_effect_type].tween_property(all_panel_effect[canvas_layer_effect_type], "modulate", all_ori_color[canvas_layer_effect_type], duration * 0.5)

	await all_tween[canvas_layer_effect_type].finished
	visible = false
