# Procedural FPS Template (from "Creature of Chaos")

## What is this?
This is an example project for building an roguelike fps game using my [my fps library](https://github.com/sklt-plt/coch-base-pub), in a "template" form. Compatible with Godot 3.5. Contains scenes and example setup for most of elements of the game to work. Consider supplied art public domain.

You can check out actual game on [Steam](https://store.steampowered.com/app/1912460/The_Creature_of_Chaos/) and [Itch.io](https://pkcat.itch.io/the-creature-of-chaos)

## Setting Up:
 1. Download Godot 3.5 or similar
 2. Download / clone this repository contents to empty folder
 3. Download [my fps library](https://github.com/sklt-plt/coch-base-pub)
    a. using git: `git submodule update --init --recursive`
    b. or manually into "Base" subfolder
 3. Open Godot. On Project Manager screen click "Import" then open "project.godot" file
 4. Optionally create new folder or duplicate "default" content pack

## About Content Packs:
 Project was designed with loading swappable "content pack" folders. Think Quake's mission packs, or Doom's WADs. These are subfolders under "content" directory. By design classes from "Base" folder (such as MapGenerator) will try to load assets from there. Currently used path is defined in Base/System/_Globals.gd as `content_pack_path`. This also means that defining file paths for Base classes should be done in format relative to `content_pack_path`.
 For example: for MapGenerator to load floor material from file "Content/example/floor.tres" you need to set
  - in _Globals.gd `content_pack_path = "res://Content/example"`
  and
  - in MapGenerator `floor_material_paths = ["/floor.tres"]`

## Currently included examples:
 - Player movement
 - "Revolver" and "Shotgun" weapons
 - Melee, Boomerang-throwing, Projectile-shooting and Sniper enemy
 - Resource and powerup pickups
 - Explosive barrels
 - Treasure chest
 - Randomizable "Furniture" objects 
 - HintBoard
 - Menus and HUD
 - Episode 1 and 2 campaign levels
 - Episode 1 boss
 - Arcade and Custom modes maps

## Missing / broken:
 - Episeode 1 custom map
 - Episode 2 arcade and custom map
 - Melee Enemy's attacks
 - Player's melee attack (kick)