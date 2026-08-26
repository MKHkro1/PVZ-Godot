extends Plant000Base
class_name Plant050CustomPlant
## 原创植物空白骨架（占位名 CustomPlant，可全局改名）
## 使用说明：
## 1. 把你画的部件图替换 Body/BodyCorrect 下各 Sprite2D 的 texture（Stem/Head/Leaf_left/Leaf_right）
## 2. 按部件实际大小调整 position/scale，节点原点 = 旋转轴心
## 3. 在 AnimationPlayer 的 Idle（循环）里 K 摇摆帧；Attack 里 K 攻击动作
##    （Attack 动画已预置 Method 轨道：0.5s 处调 AttackComponent._shoot_bullet 发射子弹，
##     可拖动该关键帧到抬手瞬间；不需要攻击就把 AttackComponent 节点删掉）
## 4. 改完节点名后若动画轨道断链，用 addons/anim_player_refactor 批量重命名修复

@onready var attack_component: AttackComponentBulletBase = $AttackComponent


## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(attack_component.owner_update_speed)
