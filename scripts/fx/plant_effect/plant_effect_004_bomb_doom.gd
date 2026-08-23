extends BombEffectBase
class_name BombEffectDoom

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate_bomb_effect():
	super()
	EventBus.push_event("canvas_layer_effect_once", [CanvasLayerEffect.E_CanvasLayerEffectType.Doom])

	animation_player.play("idle")
	await animation_player.animation_finished
	queue_free()
