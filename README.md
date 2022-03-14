# Procedural FPS Template ("Creature of Chaos" Source)

## What is this?
This is source code of my game in a "template" form, version from 14-03-2022. Compatible with Godot 3.x  Contains all files needed for modding and running out of box. Art assets have been replaced with amazing programmer art.

You can check out actual game on [Steam](https://store.steampowered.com/app/1912460/The_Creature_of_Chaos/) and [Itch.io](https://pkcat.itch.io/the-creature-of-chaos)

## Setting Up:
 1. Download Godot 3.4 or similar
 2. Download / clone this repository contents to empty folder
 3. Open Godot. On Project Manager screen click "Import" then open "project.godot" file
 4. Optionally create new folder or duplicate "default" content pack

## About Content Packs:
 Project was designed with loading swappable "content pack" folders. Think Quake's mission packs, or Doom's WADs. These are subfolders under "content" directory. By design classes from "Base" folder (such as MapGenerator) will try to load assets from there. Currently used path is defined in Base/System/_Globals.gd as `content_pack_path`. This also means that defining file paths for Base classes should be done in format relative to `content_pack_path`.
 For example: for MapGenerator to load floor material from file "Content/example/floor.tres" you need to set
  - in _Globals.gd `content_pack_path = "res://Content/example"`
  and
  - in MapGenerator `floor_material_paths = ["/floor.tres"]`

## Stuff included:
### Player:
 - KinematicActor: pushable kinematic node depending on external forces (getting pushed by damage, standing on platform, etc). Common handling for Player and Enemies
 - First person player movement: running, walking, jumping, crouching, swimming, climbing ladders, mouse look, teleporting on command and when player falls out of map
 - PlayerResources: keeping track of player's variables, taking and giving resources, resource limits and upgrades, optional time-limit tracking
 - PlayerStats: keeping track of player score and stats (time taken, number of kills, treasures, etc)
 - Player hud displaying resources and score
 - PlayerAnimations: misc effects like "gun bobbing"
 - GunBase: customizable "hitscan" gun script: shooting, reloading, magazines, aiming (toggle / hold), handling hands and gun animations, automatic / semiautomatic modes
 - GunController: handle player gun switching
 - PlayerStartingEquipment: ensure player has minimal amount of resources / equipment when level starts
### Map Generator:
 - MapGenerator: manage sub-generators flow and generation settings
 - RoomsDataGenerator: generate high-level map design (room relations, sizes, difficulty, side-paths, treasures, interior type)
 - RoomWallsGenerator: generate wall meshes and corridors to adjacent rooms
 - RandomWalksInteriorGenerator: generate "corridor" rooms connecting exits and some dead-ends, differentiate floor tiles between main and sub paths
 - ArenaGenerator: generate "arena" rooms containing random obstacles and open design
 - Prefab Rooms: allows use of manually prefabricated room interiors, with optional procedural enemy and item placement
 - EntityGroupsGenerator: place enemies and items on designated tiles
 - GeneratorOverrides: randomize MapGenerator's variables or use provided by OverridesUI
 - OverridesUI: allow player manually set some MapGenerator's variables

### Interactable Objects:
 - Explosive Barrels (pushable by player and enemies)
 - Keys and Locked Doors
 - Resource Pickup Object: define resource to be given to player
 - Powerup Object: define resource to be powered up on interact
 - TreasureChest: Spawn random resource powerup or gun powerup (if player owns it)
 - Interactable: base class for all things requiring pressing "Interact" key
 - "Water" and "Ladder" triggers
 - ObjectCache: define objects to be loaded on start + have cached shaders on level load 
### Menus:
 - Pause / Game Over Menu
 - Options Menu: graphics settings (window / fullscreen display, resolution scale, vsync, antialiasing mode, sharpening strength, toggling dynamic shadows, toggling ambient occlusion, setting player's field-of-view), audio (master / music / sfx volume), controls (customizing keybinding for most in-game functions)
 - Saving and loading: player's progress, player's settings, player's controls, player's "custom map" mode settings
### Enemies:
 - KinematicEnemy: customizable AI state machine script; movement depending on if player is in line-of-sight, 3 movement options (standing, wandering, chasing player), attacking using selected means (melee / projectiles / 'boomerangs'), playing sfx, spawning 'gibs', giving player resources on defeat
 - Projectile types: collision-based, area-of-effect based, enemy spawning
 - AIManager: handling time-slicing of enemies AI
 - "Drone" enemies: flying along 3DCurves and shooting projectiles
 - "DroneBoss" enemy: behavior for stationary enemy with Drone children, showing health on player's hud
 - Hurtbox skeleton: handling hitbox-based damage
### Misc:
 - Basic modding support (see "About 'ContentPacks'")
 - EpisodeManager: track and handle level transition
 - Initializer: loads globals from ContentPacks
 - Globals: apply and keep user settings and progress
 - FontCache: keep font references for resizing 
 - Music Controller: play music and handle transitions (time-based / crossfade)
 - SoundtrackShuffle: change songs randomly on level transition
 - HittableMaterial: define effect on hit to be spawned when shooting objects
