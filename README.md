# Minecraft in Godot Alpha 3 (Unstable branch)
## Alpha 3 goals
- More optimized rendering system (Pre 4)
- Lighting system (Pre 4)
- caves
- loads of new building blocks (~)
- doors
- add entities (Pig - Pre 8, Sheep)
- add mobs (Zombie-pre 11, Skeleton, Creeper)
- add bow with camera that moves with cursor to extent
- organize worlds from date modified (pre 12)
- water
- Saplings (pre 11)
- Wheat
- chest (pre 11)
- water acts like water
- redstone (?)

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