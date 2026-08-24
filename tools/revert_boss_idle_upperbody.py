#!/usr/bin/env python3
"""Revert idle/enter: hide cockpit upperbody (body1) — only show when head lowers in anim."""
import re
from pathlib import Path

ANIM_DIR = Path(__file__).resolve().parent.parent / "animation/character/zombie/999_zombie_boss"


def patch_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if "Boss_body1:visible" not in text:
        return False
    text2, n = re.subn(
        r'(NodePath\("Boss_body1:visible"\).*?"values": \[)true, true(\])',
        r"\1false, false\2",
        text,
        count=1,
        flags=re.S,
    )
    if n:
        path.write_text(text2, encoding="utf-8")
        return True
    return False


def main() -> None:
    for name in ("Zombie_boss_idle.tres", "Zombie_boss_enter.tres"):
        p = ANIM_DIR / name
        if patch_file(p):
            print("reverted", p.name)
        else:
            print("skip", p.name)


if __name__ == "__main__":
    main()
