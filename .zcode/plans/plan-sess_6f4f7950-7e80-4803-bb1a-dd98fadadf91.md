## 锤子工具 UI 方案

### 需求
- 在手套右边新增锤子工具框
- 点击后秒杀小范围内所有僵尸
- 对僵王博士造成5000点伤害
- 冷却60秒，快捷键 H

### 实现步骤

**1. 创建 `UIHammer` 脚本** (`scripts/ui/card/hammer_in_ui.gd`)
- 参照 `UIGlove` 的冷却系统模式
- 60秒冷却，ProgressBar 遮罩
- 点击/快捷键时推事件 `"main_game_click_hammer"`

**2. 修改 `MainGame00Base.tscn`**
- ShovelContainer 宽度从 140 → 210（新增 70px 给锤子）
- 新增 `UIHammer` 节点（offset_left=140, offset_right=210），结构同 UIGlove
- 子节点：Hammer 图标（用 `hammer_1.png`）、ProgressBar、Button、Label("H")
- 连接 Button.pressed 信号

**3. 修改 `tool_container.gd`**
- `TOOL_WIDTH` 从 140 → 210

**4. 修改 `card_manager.gd`**
- 新增 `var is_hammer := true`
- `init_card_manager` 中从 `game_para.is_hammer` 初始化
- 显示/隐藏逻辑中加入 `ui_hammer.visible`

**5. 修改 `card_slot_root.gd`**
- 新增 `@onready var ui_hammer`
- 新增快捷键 `ShortcutKeys_H` → `ui_hammer._on_button_pressed()`

**6. 新增锤子攻击逻辑** (`scripts/ui/card/hammer_in_ui.gd` 中)
- 点击后获取所有僵尸，对每个僵尸调用 `be_attacked_hammer(99999)` 秒杀
- 对僵王博士（ZombossBoss）调用 `be_attacked_bullet(5000, ..., false, false)`
- 播放锤击音效
- 自动进入冷却

**7. 输入映射**
- 在 `project.godot` 中添加 `ShortcutKeys_H` 输入映射（KEY_H）