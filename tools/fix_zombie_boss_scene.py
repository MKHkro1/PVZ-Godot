#!/usr/bin/env python3
"""Rebuild lean Zombie_boss.tscn — external animations only, no embedded Animation blob."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "all_reanim" / "Zombie_boss.tscn"
DST = ROOT / "scenes" / "character" / "zombie" / "Zombie_boss.tscn"
ANIM_SRC_DIR = ROOT / "assets" / "all_reanim"
ANIM_DST_DIR = ROOT / "animation" / "character" / "zombie" / "999_zombie_boss"
BOSS_SCRIPT = "res://scripts/character/zombie/zombie_boss.gd"
UID = "uid://ceq71xsqf5iyg"


def fix_resource_paths(text: str) -> str:
    text = re.sub(r"D:\\Web\\PVZ-Godot\\", "res://", text)
    text = text.replace("\\", "/")
    text = re.sub(r"assets/reanimZombie_boss_", "assets/reanim/Zombie_boss_", text)
    text = re.sub(
        r"animation/character/zombie/999_zombie_bossZombie_boss_",
        "animation/character/zombie/999_zombie_boss/Zombie_boss_",
        text,
    )
    # 上半身 / 颈部统一用带 alpha 的 png(勿用 jpg, 透明区会变白)
    text = text.replace(
        "assets/reanim/Zombie_boss_upperbody.jpg",
        "assets/reanim/Zombie_boss_upperbody.png",
    )
    text = text.replace(
        "assets/reanim/Zombie_boss_neck.jpg",
        "assets/reanim/Zombie_boss_neck.png",
    )
    text = text.replace("uid://618utgrqroib", "uid://byk72kpagmolj")
    text = text.replace("uid://ddr888opwsyx3", "uid://cqf17otqmcif5")
    return text


def copy_animations() -> None:
    ANIM_DST_DIR.mkdir(parents=True, exist_ok=True)
    for src in ANIM_SRC_DIR.glob("Zombie_boss_*.tres"):
        dst = ANIM_DST_DIR / src.name
        dst.write_text(fix_resource_paths(src.read_text(encoding="utf-8")), encoding="utf-8")


def slim_scene_from(src_text: str) -> str:
    lines = fix_resource_paths(src_text).splitlines()

    ext_lines: list[str] = []
    lib_lines: list[str] = []
    node_lines: list[str] = []
    section = "ext"

    for line in lines:
        if line.startswith(";"):
            continue
        if line.startswith("[gd_scene"):
            ext_lines.append(
                f"[gd_scene load_steps=PLACEHOLDER format=3 uid=\"{UID}\"]"
            )
            continue
        if line.startswith("[ext_resource"):
            ext_lines.append(line)
            continue
        if line.startswith("[sub_resource type=\"AnimationLibrary\""):
            if "AnimationLibrary_fuck" in line:
                section = "skip_lib_fuck"
                continue
            section = "lib"
            lib_lines.append(line)
            continue
        if line.startswith("[sub_resource type=\"Animation\""):
            section = "skip_anim"
            continue
        if line.startswith("[node "):
            if line.startswith("[node name=\"AnimLib\""):
                section = "skip_animlib_node"
                continue
            section = "node"
            node_lines.append(line)
            continue

        if section == "ext":
            if not line.strip():
                continue
            if line.startswith("[sub_resource") or line.startswith("[node "):
                continue
        elif section == "lib":
            lib_lines.append(line)
        elif section == "node":
            if line.startswith("[node name=\"AnimLib\""):
                section = "skip_animlib_node"
                continue
            node_lines.append(line)
        elif section == "skip_animlib_node":
            if line.startswith("[node "):
                if line.startswith("[node name=\"AnimLib\""):
                    continue
                section = "node"
                node_lines.append(line)
            continue
        # skip_anim, skip_lib_fuck: drop lines

    # Attach boss script to root node (skip duplicate root line from source)
    out_nodes: list[str] = []
    for line in node_lines:
        if line.startswith("[node name=\"ZombieBoss\"") or (
            line.startswith("[node name=\"Node2D\"") and "parent=" not in line
        ):
            out_nodes.append("[node name=\"ZombieBoss\" type=\"Node2D\"]")
            out_nodes.append("script = ExtResource(\"boss_script\")")
            continue
        out_nodes.append(line)

    if not any("boss_script" in l for l in ext_lines):
        insert_at = next(
            i for i, l in enumerate(ext_lines) if l.startswith("[ext_resource")
        )
        ext_lines.insert(
            insert_at,
            f"[ext_resource type=\"Script\" path=\"{BOSS_SCRIPT}\" id=\"boss_script\"]",
        )

    load_steps = (
        sum(1 for l in ext_lines if l.startswith("[ext_resource"))
        + sum(1 for l in lib_lines if l.startswith("[sub_resource"))
        + 1
    )
    ext_lines[0] = f"[gd_scene load_steps={load_steps} format=3 uid=\"{UID}\"]"

    parts = [ext_lines[0], "", *ext_lines[1:], "", *lib_lines, "", *out_nodes]
    return "\n".join(parts) + "\n"


def build_scene() -> None:
    raw = SRC.read_text(encoding="utf-8")
    DST.write_text(slim_scene_from(raw), encoding="utf-8")
    size_kb = DST.stat().st_size // 1024
    print(f"  scene: {DST} ({size_kb} KB)")


if __name__ == "__main__":
    print("Fixing Zombie_boss assets...")
    copy_animations()
    build_scene()
    print("Done.")
