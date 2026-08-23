extends Plant000Base
class_name Plant028Blover

## 三叶草吹的时间
@export var blover_time:float = 2.0

var is_blow_away_once:=false

func ready_norm():
	super()
	await get_tree().create_timer(blover_time).timeout
	hp_component.Hp_loss_death()

## 吹散迷雾
func blow_away_fog():
	if is_blow_away_once:
		return
	is_blow_away_once = true
	if is_instance_valid(Global.main_game.background_manager.fog):
		Global.main_game.background_manager.fog.be_flow_away()

	EventBus.push_event("blover_blow_away_in_sky_zombie")

