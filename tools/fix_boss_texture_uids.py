#!/usr/bin/env python3
"""Fix Zomboss upperbody/neck: png paths must not reference jpg UIDs."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
UID_FIXES = {
    "Zombie_boss_upperbody.png": ("uid://618utgrqroib", "uid://byk72kpagmolj"),
    "Zombie_boss_neck.png": ("uid://ddr888opwsyx3", "uid://cqf17otqmcif5"),
}
PATH_FIXES = {
    "Zombie_boss_upperbody.jpg": "Zombie_boss_upperbody.png",
    "Zombie_boss_neck.jpg": "Zombie_boss_neck.png",
}

TARGET_DIRS = [
    ROOT / "scenes" / "character" / "zombie",
    ROOT / "animation" / "character" / "zombie" / "999_zombie_boss",
]


def patch_text(text: str) -> tuple[str, bool]:
    changed = False
    for old, new in PATH_FIXES.items():
        if old in text:
            text = text.replace(old, new)
            changed = True
    for _name, (wrong, right) in UID_FIXES.items():
        if wrong in text:
            text = text.replace(wrong, right)
            changed = True
    return text, changed


def main() -> None:
    count = 0
    for d in TARGET_DIRS:
        for path in d.rglob("*"):
            if path.suffix not in {".tscn", ".tres"}:
                continue
            raw = path.read_text(encoding="utf-8")
            new, ok = patch_text(raw)
            if ok:
                path.write_text(new, encoding="utf-8")
                print("patched", path.relative_to(ROOT))
                count += 1
    print("done,", count, "files")


if __name__ == "__main__":
    main()
