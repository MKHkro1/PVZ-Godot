extends AnimComponentBase
class_name AnimComponentBobsled

@onready var animation_player: AnimationPlayer = $"../Body/AnimationPlayer"
@onready var all_sub_bobsled_anim_player = [
	$"../Body2/AnimationPlayer",
	$"../Body4/AnimationPlayer",
	$"../Body3/AnimationPlayer"
]

func _ready() -> void:
	## ready中获取动画角色原始速度
	animation_origin_speed = animation_player.speed_scale
	animation_player.animation_finished.connect(_on_animation_finished)

## 更新动画速度(根据速度倍率)
func owner_update_speed(speed_factor_product:float):
	animation_player.speed_scale = animation_origin_speed * speed_factor_product
	for sub_bobsled_anim_player in all_sub_bobsled_anim_player:
		sub_bobsled_anim_player.speed_scale = animation_origin_speed * speed_factor_product

## 更新动画速度(动画播放速度)
func update_anim_speed_scale(speed_scale:float):
	animation_player.speed_scale = speed_scale
	for sub_bobsled_anim_player in all_sub_bobsled_anim_player:
		sub_bobsled_anim_player.speed_scale = speed_scale

## 停止动画
func stop_anim():
	animation_player.pause()
	for sub_bobsled_anim_player in all_sub_bobsled_anim_player:
		sub_bobsled_anim_player.pause()

