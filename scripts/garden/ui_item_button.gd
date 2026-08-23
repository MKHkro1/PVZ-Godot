extends TextureButton
class_name UiItemButton


## 当前ui物品按钮信号，发送参数带本体
signal ui_item_button_signal
@onready var item_texture: TextureRect = $ItemTexture


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	item_texture.visible = false
	ui_item_button_signal.emit()
