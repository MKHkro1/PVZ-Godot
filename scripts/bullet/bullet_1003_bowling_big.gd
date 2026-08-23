extends BulletLinear000Base
class_name Bullet1003BowlingBig

@onready var body_correct: Node2D = $Body/BodyCorrect

## 旋转速度
var rotation_speed = 5.0


func _physics_process(delta: float) -> void:
	super(delta)
	body_correct.rotation += rotation_speed * delta

## 对敌人造成伤害
func _attack_enemy(enemy:Character000Base):
	## 攻击敌人
	enemy.be_attack_to_death(trigger_be_attack_sfx)
