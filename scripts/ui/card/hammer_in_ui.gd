extends TextureRect
class_name UIHammer

const COOL_TIME := 60.0

@onready var hammer_icon: TextureRect = $Hammer
@onready var cool_mask: ProgressBar = $ProgressBar

var _is_cooling := false
var _cool_timer := 0.0


func _ready() -> void:
	cool_mask.max_value = COOL_TIME
	cool_mask.value = 0
	cool_mask.visible = false


func _process(delta: float) -> void:
	if not _is_cooling:
		return
	_cool_timer -= delta
	cool_mask.value = _cool_timer
	if _cool_timer <= 0.0:
		_end_cooldown()


func _on_button_pressed() -> void:
	if _is_cooling:
		SoundManager.play_other_SFX("buzzer")
		return
	if not _can_use():
		return
	hammer_icon.visible = false
	EventBus.push_event("main_game_click_hammer")


func _can_use() -> bool:
	if not is_instance_valid(Global.main_game):
		return false
	var progress: int = Global.main_game.main_game_progress
	return progress == MainGameManager.E_MainGameProgress.PREPARE \
		or progress == MainGameManager.E_MainGameProgress.MAIN_GAME


func start_cooldown() -> void:
	_is_cooling = true
	_cool_timer = COOL_TIME
	cool_mask.visible = true
	cool_mask.value = COOL_TIME


func is_on_cooldown() -> bool:
	return _is_cooling


func _end_cooldown() -> void:
	_is_cooling = false
	cool_mask.visible = false
	hammer_icon.visible = true
