# Minecraft in Godot Alpha 3 (Unstable branch)
## Alpha 3 goals
- More optimized rendering system (Pre 4)
- Lighting system (Pre 4)
- caves (saving for alpha 4)
- loads of new building blocks (~)
- doors (pre 14)
- add entities (Pig - Pre 8, Sheep - Saving for Alpha 4)
- add mobs (Zombie-pre 11, Skeleton-pre 12, Creeper)
- add bow with camera that moves with cursor to extent (saving for alpha 4)
- organize worlds from date modified (pre 12)
- water (saving for alpha 4)
- Saplings (pre 11)
- Wheat (saving for alpha 4)
- chest (pre 11)
- water acts like water (saving for alpha 4)
- redstone (release tbd)

BUG THAT NEED FIXING
- block rendering engine seems to be held together with duct tape and not as optimized as it could be

### Alpha 3 pre 2
- Begun work on lighting system, practically broken in every way imaginable
### Alpha 3 pre 4
- Finished lighting system, it now works as intended
- Put lighting system on separate thread for better optimization
- made block rendering more optimized
### Alpha 3 pre 5
- Begun work on save system
### Alpha 3 pre 6
- Finished one world save system.
### Alpha 3 pre 7
- Added ladders
- bug fixes
### Alpha 3 pre 8
- Added pig entity
- Made a system for adding more entities easier in the future
- Added day cycle
- Added damage system to allow weapons to damage entities that allow so
### Alpha 3 pre 9
- Added menu screen
- Working on new save system
### Alpha 3 pre 10-11
- Added zombies
- Reworked hunger system to be more like Minecraft
- Added raw and cooked porkchops
- Finished save system basics
- Added saplings
- Added ability to swim in water
- Fixed world loading chunks at 0 even when the player is not there when loading in a world
- Fixed right clicking anywhere in the inventory also clicking the results from crafting
- Fixed world not loading before light starts updating 
- Fixed entities not saving
- Fixed furnace using fuel item even if it is smelting after loading it 
### Alpha 3 pre 12
- Made worlds organized from date modified
- Water system (WIP)
- Skeletons
### Alpha 3 pre 13
- Added breaking, walking, and placement sounds
- Added menu music
- Added clicking sounds to buttons
- Reworked block data into json files
- Removed water system
### Alpha 3 pre 14
-Added Doors