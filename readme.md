# 3D Godot Project 

The Idea of this project was to  procedurally generated terrain from free assets found on itch.io, in Godot 


## Notes
the idea is to create an image filled with noise, and use that image to set tile position, and determine tile height, eg: pixels w/ 0 = low; pixels w/ 1 = high;
<img src="https://github.com/Cheysha/3dgodotProj/blob/main/doc/start.png" width="250" height="250">

the height levels are than quanitized and assignes properties based of the quanitized_height, additional algorithims can be ran to add detail 
<img src="https://github.com/Cheysha/3dgodotProj/blob/main/doc/lg.png" width="250" height="250">

for example, we can make another noise map of identacle size and use the values of that map to place things like houses / trees / rocks. due to the way these items are distibuted, the detail map should be high frequency
<img original>

OR, you could you a low frequency map to place a biome and place detail based on biome AND height conditions
<img forest_biome>

a cool thing from zelda games i likes were the walls on ledges. we can generate walls. By thesting the neighbors of the hexagon and seeing how many are on a lower quanitized_height level, we can see where we need to generate walls; side note, it is easier to use a cubed coordinate system for this. q, r, s
<img walls> 

there are more details into making things look more map like, but its a good start,

now if things are going to be gamey, wee need a sense of scale, kinda liked this,but it didnt really work, 
<img scale>

jumping foward, this is the scale i decided i liked, different hight levels have different offsets to make them look more natural, eg: beach clcose to water;
<img height>


side note, the stair algorithim i worth mentioning, every continous cluster on cells on the same hight will need a staircase leading down to the lower level (with execptions). so select a random tile on the edge and make it a staircase, there are 2 different types of stairs, depending on how many faces are touching tiles of the same height.  
<img mockup>

