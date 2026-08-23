extends Zombie000Base
class_name Zombie020Yeti

## 雪人润的概率,每次移动\攻击开始动画时判断
@export_range(0,1,0.01) var probability_run:float=0.2
## 是否已经润了
var is_run_end:=false

func ready_norm():
	super()
	if Global.main_game.p_yeti_run != -1:
		probability_run = Global.main_game.p_yeti_run

## 判断是否逃跑
func judge_is_run():
	## 如果已经逃跑，判断是否离开当前视野
	if is_run_end:
		if global_position.x > 900:
			character_death_disappear()

		return
	var p = randf()
	#print("逃跑概率:",p, "阈值:", probability_run)
	if p < probability_run:
		update_direction_x_root(-1)
		is_run_end = true

