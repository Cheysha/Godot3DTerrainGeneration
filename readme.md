# 3D Godot Project 

This is a fork of the og version, trying to make it more like a 3d links awakening, rather than a platformer
fun with procedural generation and creative programming

Project generates a 3d map made out of hexagons

## TODO:
	
### Short Term:
- re-implement the player
	
### Mid Term:
- add more variation to the small items

### Long Term:
- figure out more things i want to generate, and maybe ways to streaamline the process
- long term plan

## Notes

the idea is to place a hexagon tile at every point at the grid, using a noise map to place height
<img src="https://github.com/Cheysha/3dgodotProj/blob/main/doc/start.png" width="250" height="250">

the height levels are than quanitized and assignes properties based of the quanitized_height, details are added based on tile type and value of biome_map at that point
<img src="https://github.com/Cheysha/3dgodotProj/blob/main/doc/lg.png" width="250" height="250">


