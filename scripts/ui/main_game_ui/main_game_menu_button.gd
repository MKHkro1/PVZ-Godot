extends PVZButtonBase
class_name MainGameMenuAppearButton
## 主游戏菜单出现按钮

func _ready() -> void:
	super._ready()
	button_down.connect(SoundManager.play_other_SFX.bind("gravebutton"))
