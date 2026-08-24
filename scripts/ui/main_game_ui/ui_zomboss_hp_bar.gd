extends Control
class_name ZombossHpBar
## 僵王战右下角血量条

var _boss: ZombossBoss

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var hp_label: Label = $HpLabel


func bind_boss(boss: ZombossBoss) -> void:
	_boss = boss
	visible = true
	_update()


func _process(_delta: float) -> void:
	if _boss == null or not is_instance_valid(_boss):
		visible = false
		return
	_update()


func _update() -> void:
	if _boss.is_dead:
		visible = false
		return
	var pct := _boss.curr_hp / ZombossBoss.HP_MAX * 100.0
	texture_progress_bar.value = pct
	hp_label.text = str(int(_boss.curr_hp))
