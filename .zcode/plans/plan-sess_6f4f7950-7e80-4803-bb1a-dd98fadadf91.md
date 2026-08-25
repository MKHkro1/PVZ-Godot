## 游戏体验优化方案

基于全面的代码审查，以下优化按影响优先级排列，聚焦"小改动、大体验提升"：

---

### 1. 卡槽动画加缓动曲线
**文件:** `scripts/ui/card/card_slot/card_slot_norm/card_slot_norm.gd`
**问题:** `move_card_to`、`move_card_slot_candidate`、`move_card_slot_battle` 的 tween 全部使用默认线性插值，动画生硬机械
**修改:** 为所有 tween 添加 `set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)`，让卡片滑入更自然

---

### 2. "Ready / Set / Plant" 文字弹出动画
**文件:** `scripts/ui/main_game_ui/ui_remind_word.gd`
**问题:** 三个文字只是简单 toggle visible，没有缩放/淡入效果，缺少原版的弹跳感
**修改:** 每个文字出现时从 scale 0.3→1.0 弹出（TRANS_BACK, EASE_OUT），消失时缩小淡出

---

### 3. 对话框打开/关闭加过渡动画
**文件:** `scripts/ui/dialog.gd`
**问题:** 所有对话框直接 toggle visible，无任何过渡
**修改:** 打开时从 scale 0.8→1.0 + 淡入，关闭时 scale 1.0→0.9 + 淡出

---

### 4. 对话框确认面板居中 bug 修复
**文件:** `scripts/ui/dialog_confirm.gd`
**问题:** `_center_panel()` 第一行就是 `return`，居中逻辑是死代码
**修改:** 删除 `return`，修复面板居中计算（`panel_size` 应为 `panel_size / 2` 因为 anchor 中心对齐）

---

### 5. 旗帜进度条动画
**文件:** `scripts/ui/main_game_ui/ui_flag_progress_bar_flag.gd`
**问题:** 旗帜位置瞬间跳变，没有过渡
**修改:** 用 tween 平滑移动旗帜位置（0.3s, TRANS_BACK, EASE_OUT）

---

### 6. 游戏速度限制 clamp
**文件:** `scripts/manager/main_game_manager.gd`
**问题:** 注释说速度超过8会出bug，但没有实际 clamp
**修改:** 在 `test_time_scale` setter 中 `clampi(value, 1, 8)`

---

### 7. 倍速标签精度修复
**文件:** `scripts/ui/ui_main_game_menu/main_game_menu_option_dialog.gd`
**问题:** `str(Global.time_scale)` 显示 `1.3999999` 等浮点精度问题
**修改:** 使用 `snapped(0.1)` 或 `stepify` 保留一位小数

---

### 8. 僵尸数量标签实际显示数量
**文件:** `scripts/ui/main_game_ui/label_zombie_sum.gd`
**问题:** 标签只控制显示/隐藏，从不显示实际僵尸数量
**修改:** 订阅 `signal_curr_zombie_num_change` 事件，实时更新文本为 "当前僵尸数量：X"

---

### 共同原则
- 所有 tween 使用 `TRANS_CUBIC` 或 `TRANS_BACK` + `EASE_OUT`，保持一致的动画风格
- 不改动任何游戏逻辑，只改表现层
- 每个修改独立可测试