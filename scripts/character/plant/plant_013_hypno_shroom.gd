extends Plant000Base
class_name Plant013HypnoShroom


## 被僵尸啃食一次特殊效果,魅惑\大蒜
func _be_zombie_eat_once_special(attack_zombie:Zombie000Base):
	hypno_zombie(attack_zombie)

## 魅惑僵尸
func hypno_zombie(zombie:Zombie000Base):
	if not is_sleeping:
		SoundManager.play_character_SFX("MindControlled")
		zombie.be_hypno()
		character_death()

