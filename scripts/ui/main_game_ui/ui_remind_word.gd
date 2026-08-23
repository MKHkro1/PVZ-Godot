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
		await get_tree().create_timer(0.6, false).timeout  # 等待 1 秒
		node.visible = false
	visible = false


## 僵尸靠近
func zombie_approach(final:bool) -> void:
	visible = true
	SoundManager.play_other_SFX("hugewave")
	approaching.visible = true
	await get_tree().create_timer(4, false).timeout  # 等待 4 秒
	approaching.visible = false
	await get_tree().create_timer(2, false).timeout  # 等待 2 秒
	if final:
		# SFX 最后一波红字音效
		SoundManager.play_other_SFX("finalwave")
		final_wave.visible = true
		await get_tree().create_timer(3, false).timeout  # 等待 3 秒
		final_wave.visible = false

	visible = false

## 僵尸获胜
func zombie_won_word_appear() -> void:

	visible = true
	zombies_won.visible = true
	#await get_tree().create_timer(0.8).timeout  # 等待 1 秒
	#zombies_won.visible = false
	#visible = false
