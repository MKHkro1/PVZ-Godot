extends Control
## 铲子/手套栏: 跟随卡槽容器右缘定位, 避免被卡槽内容遮挡

const TOOL_WIDTH := 140.0

@onready var _card_slot_container: Control = %CardSlotContainer


func _ready() -> void:
	if is_instance_valid(_card_slot_container):
		_card_slot_container.resized.connect(_sync_to_card_slot)
		_card_slot_container.child_order_changed.connect(_sync_to_card_slot)
	call_deferred("_sync_to_card_slot")


func _sync_to_card_slot() -> void:
	if not is_instance_valid(_card_slot_container):
		return
	position = Vector2(_card_slot_container.position.x + _card_slot_container.size.x, 0.0)
	z_index = 10
