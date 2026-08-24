#!/usr/bin/env python3
"""Patch boss idle/enter anims: show upperbody (body1) in cockpit during idle."""
import re
from pathlib import Path

ANIM_DIR = Path(__file__).resolve().parent.parent / "animation/character/zombie/999_zombie_boss"
UPPER = "res://assets/reanim/Zombie_boss_upperbody.jpg"
# head_idle 首帧 cockpit 位置
BODY1_POS = "Vector2(527.80, 156.10)"


def patch_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if "Boss_body1:visible" not in text:
        return False
    changed = False

    # 确保有 upperbody 资源引用
    if UPPER not in text:
        ids = [int(m.group(1)) for m in re.finditer(r'id="(\d+)_fuck"', text)]
        next_id = (max(ids) + 1) if ids else 20
        insert = f'[ext_resource type="Texture2D" path="{UPPER}" id="{next_id}_fuck"]\n\n'
        text = text.replace("\n[resource]\n", f"\n{insert}[resource]\n", 1)
        upper_id = f'ExtResource("{next_id}_fuck")'
        changed = True
    else:
        m = re.search(rf'\[ext_resource[^\]]*path="{re.escape(UPPER)}"[^\]]*id="([^"]+)"', text)
        upper_id = f'ExtResource("{m.group(1)}")' if m else 'ExtResource("13_fuck")'

    # body1 visible -> true
    text2, n = re.subn(
        r'(NodePath\("Boss_body1:visible"\).*?"values": \[)false, false(\])',
        r"\1true, true\2",
        text,
        count=1,
        flags=re.S,
    )
    if n:
        text = text2
        changed = True

    # body1 texture
    text2, n = re.subn(
        r'(NodePath\("Boss_body1:texture"\).*?"values": \[)null, null(\])',
        rf"\1{upper_id}, {upper_id}\2",
        text,
        count=1,
        flags=re.S,
    )
    if n:
        text = text2
        changed = True

    # body1 position constant (idle/enter 只需单帧)
    if "Boss_body1:position" in text:
        text2, n = re.subn(
            r'(NodePath\("Boss_body1:position"\).*?"values": \[)[^\]]+(\])',
            rf"\1{BODY1_POS}, {BODY1_POS}\2",
            text,
            count=1,
            flags=re.S,
        )
        if n:
            text = text2
            changed = True

    if changed:
        path.write_text(text, encoding="utf-8")
    return changed


def main() -> None:
    for name in ("Zombie_boss_idle.tres", "Zombie_boss_enter.tres"):
        p = ANIM_DIR / name
        if patch_file(p):
            print("patched", p.name)
        else:
            print("skip", p.name)


if __name__ == "__main__":
    main()
