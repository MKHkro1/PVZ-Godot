extends Control
class_name MainGameRain


func _ready() -> void:
	if is_instance_valid(Global.main_game):
		SoundManager.play_rain_SFX()

func _exit_tree() -> void:
	SoundManager.stop_rain_SFX()
