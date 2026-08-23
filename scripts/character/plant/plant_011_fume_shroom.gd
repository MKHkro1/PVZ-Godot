extends Plant000Base
class_name Plant011FumeShroom

@onready var attack_component: AttackComponentBulletBase = $AttackComponent
@onready var bullet_fx: Node2D = %Bullet_FX
var all_bullet_fx :Array[GPUParticles2D]

func ready_norm():
	super()
	for p in bullet_fx.get_children():
		all_bullet_fx.append(p)

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(attack_component.owner_update_speed)


func _start_shoot():
	for gpu_particles_2d in all_bullet_fx:
		gpu_particles_2d.emitting = true

func _end_shoot():
	#print("结束")
	for gpu_particles_2d in all_bullet_fx:
		gpu_particles_2d.emitting = false

