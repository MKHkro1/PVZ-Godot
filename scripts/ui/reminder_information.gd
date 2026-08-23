extends CanvasLayer
class_name ReminderInformation
## 是否消失
@export var is_fade := true
## 每句话存在时间
@export var exist_time :float= 5

@onready var label: Label = $Panel/Label


func _init_info(info_texts:Array[String], time:float= 5):
	exist_time = time
	for info_text in info_texts:

		label.text = info_text
		await get_tree().create_timer(exist_time).timeout

	queue_free()
