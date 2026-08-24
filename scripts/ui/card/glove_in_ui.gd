extends TextureRect
class_name UIGlove

const COOL_TIME := 10.0

@onready var glove_icon: TextureRect = $Glove
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
	if not Global.glove_no_cooldown and _is_cooling:
		SoundManager.play_other_SFX("buzzer")
		return
	glove_icon.visible = false
	EventBus.push_event("main_game_click_glove")

func ui_glove_appear() -> void:
	if not _is_cooling:
		glove_icon.visible = true

func start_cooldown() -> void:
	if Global.glove_no_cooldown:
		return
	_is_cooling = true
	_cool_timer = COOL_TIME
	cool_mask.visible = true
	cool_mask.value = COOL_TIME
	glove_icon.visible = false

func is_on_cooldown() -> bool:
	return not Global.glove_no_cooldown and _is_cooling

func _end_cooldown() -> void:
	_is_cooling = false
	cool_mask.visible = false
	glove_icon.visible = true
