extends Control
class_name UIRemindWord

@onready var ready_plant: TextureRect = $Ready
@onready var set_plant: TextureRect = $Set
@onready var plant: TextureRect = $Plant
@onready var approaching: TextureRect = $Approaching
@onready var final_wave: TextureRect = $FinalWave
@onready var zombies_won: TextureRect = $ZombiesWon


## 准备放置植物
func ready_set_plant() -> void:
	visible = true
	SoundManager.play_other_SFX("readysetplant")
	for node in [ready_plant, set_plant, plant]:
		node.visible = true
		node.scale = Vector2(0.3, 0.3)
		node.modulate = Color(1, 1, 1, 0)
		var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.set_parallel(true)
		tween.tween_property(node, "scale", Vector2.ONE, 0.3)
		tween.tween_property(node, "modulate", Color.WHITE, 0.2)
		await get_tree().create_timer(0.6, false).timeout
		var fade_tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		fade_tween.tween_property(node, "modulate", Color(1, 1, 1, 0), 0.15)
		await fade_tween.finished
		node.visible = false
	visible = false


## 僵尸靠近
func zombie_approach(final:bool) -> void:
	visible = true
	SoundManager.play_other_SFX("hugewave")
	_show_fade_in(approaching)
	await get_tree().create_timer(4, false).timeout
	_show_fade_out(approaching)
	await get_tree().create_timer(2, false).timeout
	if final:
		SoundManager.play_other_SFX("finalwave")
		_show_fade_in(final_wave)
		await get_tree().create_timer(3, false).timeout
		_show_fade_out(final_wave)
	visible = false


## 僵尸获胜
func zombie_won_word_appear() -> void:
	visible = true
	zombies_won.visible = true
	zombies_won.scale = Vector2(0.3, 0.3)
	zombies_won.modulate = Color(1, 1, 1, 0)
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(zombies_won, "scale", Vector2.ONE, 0.4)
	tween.tween_property(zombies_won, "modulate", Color.WHITE, 0.3)


func _show_fade_in(node: TextureRect) -> void:
	node.visible = true
	node.modulate = Color(1, 1, 1, 0)
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", Color.WHITE, 0.3)


func _show_fade_out(node: TextureRect) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	node.visible = false
