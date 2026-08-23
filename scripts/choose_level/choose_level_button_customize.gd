extends ChooseLevelButton
class_name ChooseLevelButtonCustomize

@onready var label: Label = $TextureButton/Label
var level_name:String

func init_choose_level_button_customize(new_level_data_game_para:ResourceLevelData, curr_level_name:String):
	curr_level_data_game_para = new_level_data_game_para
	level_name = curr_level_name

func _ready() -> void:
	super()
	label.text = level_name
