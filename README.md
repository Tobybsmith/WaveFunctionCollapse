# WaveFunctionCollapse
This is a very simple implementation of the Wave Function Collapse algorithm in Godot. There are 4 tile in the map, the the rules for those tiles are:
- Grass: Grass can border Grass, Sand, and Forest tiles. Grass cannot border Water tiles
- Forest: Forest can border Grass and Forest. Forest cannot border Grass or Water
- Sand: Sand can border Grass, Sand, and Water. Sand cannot border Forest
- Water: Water can border Sand and Water. Water cannot border Grass or Forest

# Todo
- The function sometimes reaches a contradictory state
- Directional borders (Grass can touch snow but only on the negative y direction)
