extends Label
class_name LabelZombieSum

func _ready() -> void:
	EventBus.subscribe("main_game_progress_update", _on_main_game_progress_update)

func _on_main_game_progress_update(main_game_progress :MainGameManager.E_MainGameProgress):
	if main_game_progress == MainGameManager.E_MainGameProgress.CHOOSE_CARD or main_game_progress == MainGameManager.E_MainGameProgress.RE_CHOOSE_CARD:
		visible = false
	else:
		visible = true

