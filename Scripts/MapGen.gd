extends Node3D

@export var Width = 25
@export var Height = 20
@export var noise : FastNoiseLite#= FastNoiseLite.new()
@export var moisture_map : FastNoiseLite
@export var high_freq_map : FastNoiseLite

var map_data : Dictionary
var cube_direction_vectors = [
	Vector3(+1, -1, 0), Vector3(+1, 0, -1), Vector3(0, +1, -1), 
	Vector3(-1, +1, 0), Vector3(-1, 0, +1), Vector3(0, -1, +1) ]

func _ready():
	generate_map()
	
func _process(delta):
	if Input.is_key_pressed(KEY_R):
		for child in self.get_children():
			remove_child(child)
		map_data.clear()
		generate_map()
	
func generate_map():
	var water_tile = preload("res://Premade/Tiles/hex_water_gltf.tscn")
	var sand_tile = preload("res://Premade/Tiles/hex_sand_gltf.tscn")
	var grass_tile = preload("res://Premade/Tiles/hex_forest_gltf.tscn")
	var rock_tile = preload("res://Premade/Tiles/hex_rock_gltf.tscn")
	#var shape = preload("res://Premade/Tiles/comps/collision_shape_3d.tscn")
	var rand = randi_range(0, 1000)
	var total_steps = 4
	var tile_total_counts = {"water":0,"sand":0,"grass":0,"rock":0} 

	# Random Offsets
	#noise.offset = Vector3(rand, rand, rand)
	#moisture_map.offset = Vector3(rand, rand, rand)
	var image = noise.get_image(Width, Height)
	var moisture_image = moisture_map.get_image(Width, Height)

	for y in range(Height):
		for x in range(Width):
			var noise_value = image.get_pixel(x, y).v
			noise_value *= .8 # too many mountains by default
			var moisture_value = moisture_image.get_pixel(x, y).v
			var quanitized_noise = quantize_noise(noise_value, total_steps)
			var random_offset = randf_range(0.15, 0.23)
			var height_margin = random_offset * quanitized_noise
			var tile_scene : PackedScene
			var height_zone : int
			var biome : String = ""

			# Check the value of q and instantiate the appropriate tile
			if quanitized_noise <= 0:
				tile_scene = water_tile
				height_zone = 1
				height_margin = 0
				tile_total_counts["water"] += 1
			elif quanitized_noise <= 1:
				tile_scene = sand_tile
				height_zone = 2
				tile_total_counts["sand"] +=1
			elif quanitized_noise <= 2:
				tile_scene = grass_tile
				height_zone = 3
				if moisture_value <= .5:
					biome = "Forest"
				tile_total_counts["grass"] +=1
			else:
				tile_scene = rock_tile
				height_zone = 4
				tile_total_counts["rock"] +=1
			
			# get tile instance ready	
			var instantiated_tile :StaticBody3D  = tile_scene.instantiate()
			instantiated_tile.height_level = quanitized_noise
			instantiated_tile.height_zone = height_zone
			instantiated_tile.Biome = biome
			
			# this changes distrubutions on heights based on level, eg. beach close to water, mountain up high
			var smoothing_factor = .5
			if height_zone == 1 || height_zone == 2: 
				smoothing_factor = smoothing_factor * .5 
			if height_zone == 3: 
				smoothing_factor = smoothing_factor * .8 
			if height_zone == 4:
				smoothing_factor = smoothing_factor * 2 
				
			# translate the tile, scale the mesh, and generate a new shape from the scaled mesh, dont scale collider unevenly
			var translation = Vector3(x * 2, 0, y * 1.74) #1.74 is the spacing for hexagons to lineup, need func
			if y % 2 == 0: 
				translation.x += 1 # half of tile size
			instantiated_tile.translate(translation)
			instantiated_tile.get_child(0).set_scale(Vector3(1, quanitized_noise * smoothing_factor + 1 , 1))
			instantiated_tile.get_child(1).set_scale(Vector3(1, quanitized_noise * smoothing_factor + 1 , 1)) # shopuld scale a collider, 

			# POS in our map
			var q = x - (y + (y % 2)) / 2
			var r = y
			var s = -q-r
			var pos = Vector3(q, r, s) 
			instantiated_tile.pos = pos
			map_data[pos] = instantiated_tile 

			add_child(instantiated_tile)
			set_editable_instance(instantiated_tile,true)

	# Print out the tile counts
	print("--------------------------------------")

	print(tile_total_counts)

	
	# Post processing
	#add_forest()
	#add_houses()
	#dd_small_items()
	add_walls()
	
	
func quantize_noise(value, num_values = 4):
	var step = 1.0 / num_values
	return int(value / step)

	
	var tile = map_data[Vector3(position)]
	var i = 0
	for direction in cube_direction_vectors:
		if map_data.has(Vector3(position + direction)):
			var target_tile = map_data[Vector3(position + direction)]
			if target_tile.height_zone == tile.height_zone : #magic!
				tile.neighbors[i] = 1
		i += 1

func add_houses():
	var p = preload("res://Premade/Decor/house.tscn")
	# go through all tiles on the map, and if the height_zone is 3, place a preload on it, y offset of 1
	for tile in map_data.values():
		# var rand = randi_range(0,10)  # Not used, consider removing
		var rand2 = randi_range(1, 6)

		if tile.height_zone != 3 || tile.contents:
			continue  # Skip to the next tile
		
		var valid_placement = true # nne
		
		# check the neighboring tiles within a radius of two tiles in each direction
		for q in range(-2, 3):
			for r in range(max(-2, -q - 2), min(3, -q + 3)):
				var neighbor_pos = tile.pos + Vector3(q, r, -q - r)
				
				if neighbor_pos not in map_data.keys(): # works but needs rewritten
					valid_placement = false
				
				if neighbor_pos in map_data.keys():
					var neighbor_tile = map_data[neighbor_pos]
					
					# Check if the neighbor tile has contents or has a different height zone
					if !Dictionary(neighbor_tile.contents).is_empty() || tile.height_zone != neighbor_tile.height_zone:
						valid_placement = false
						break
				else:
					# Neighbor tile is outside the map, consider how you want to handle this case
					continue
		
		# If all neighbors are valid, place a house
		if valid_placement:
			
			# raise the bordering tiles to the same height as the current
			for direction in cube_direction_vectors:
				var neighbor_pos = tile.pos + direction
				var neighbor_tile :Node3D  = map_data.get(neighbor_pos)
				neighbor_tile.height_level = tile.height_level
				
				var diff : float = neighbor_tile.position.y - tile.position.y
				neighbor_tile.translate(Vector3(0,-diff,0))
			'''
			var i = p.instantiate()
			i.translate(tile.position + Vector3(0, 1, 0))
			i.scale_object_local(Vector3(2,2,2,))
			match rand2:
				1: i.rotate(Vector3(0, 1, 0), 60)
				2: i.rotate(Vector3(0, 1, 0), 120)
				3: i.rotate(Vector3(0, 1, 0), 180)
				4: i.rotate(Vector3(0, 1, 0), 240)
				5: i.rotate(Vector3(0, 1, 0), 300)
				6: pass
			tile.contents["house"] = i
			add_child(i)
			'''
func add_forest():
	var p = preload("res://Premade/Decor/forest.tscn")

	for tile in map_data.values():
		
		var rand2 = randi_range(1,6)
		if tile.height_zone == 3 && tile.Biome == "Forest" && !tile.contents:
			var i = p.instantiate()
			i.translate(tile.position + Vector3(0,tile.height_zone,0))
			# rotate the forest based on rand2, to add variation
			match rand2:
				1:
					i.rotate(Vector3(0,1,0),60)
					pass
				2:
					i.rotate(Vector3(0,1,0),120)
					pass
				3:
					i.rotate(Vector3(0,1,0),180)
					pass
				4:
					i.rotate(Vector3(0,1,0),240)
					pass
				5:
					i.rotate(Vector3(0,1,0),360)
					pass
				6:
					pass
			
			tile.contents["forest"] = i
			#i.scale_object_local(Vector3(2,2,2))
			add_child(i)
func add_small_items(): 
	var img = high_freq_map.get_image(Width,Height)
	var stone = preload("res://Premade/Decor/detail_rocks_gltf.tscn")
	
	for tile in map_data.values():
		var col = tile.pos.x + (tile.pos.y + (int(tile.pos.y)&1)) / 2
		var row = tile.pos.y
		var noise_value = img.get_pixel(col,row).v
		var rand2 = randi_range(1,6)
		
		if tile.height_zone != 1 && noise_value >= .7 && !tile.contents:
			var i = stone.instantiate()
			i.translate(tile.position + Vector3(0, 1, 0))
			match rand2:
				1: i.rotate(Vector3(0, 1, 0), 60)
				2: i.rotate(Vector3(0, 1, 0), 120)
				3: i.rotate(Vector3(0, 1, 0), 180)
				4: i.rotate(Vector3(0, 1, 0), 240)
				5: i.rotate(Vector3(0, 1, 0), 300)
				6: pass
			tile.contents["stone"] = i
			add_child(i)
		
func add_walls():

	var total_walls = 0
	var wall = preload("res://Premade/Decor/overworld_wall.tscn")
	for tile in map_data.values():
		var neighbors = []

		# skip water tiles
		if tile.height_zone == 1:
			continue

		# add our neighbors, mark where we need walls
		for direction in cube_direction_vectors:
			var neighbor_pos = tile.pos + direction
			if neighbor_pos in map_data.keys():
				var neighbor_tile = map_data[neighbor_pos]
				if neighbor_tile.height_level < tile.height_level:
					# keeps walls of sand to water transitions, keep it beachy
					if (tile.height_level==1 && neighbor_tile.height_level ==0):
						neighbors.append(0)
						continue
					neighbors.append(1)
				else: neighbors.append(0)
			else: neighbors.append(1)
		
		# look at neighbors and add walls where needed
		var i = 0
		for neighbor in neighbors: # i = 0, ne, i = 1, e, i = 2, se, i = 3, sw, i = 4, w, i = 5, nw
			if neighbors[i] == 1:
				var wall_instance = wall.instantiate()
				#var y = tile.height_zone + .183 # magic offset
				var v = tile.get_child(0) as Node3D # get the scale of the first child.
				var y = v.scale.y + .183
				total_walls += 1
				match i: 
					0:
						wall_instance.translate(Vector3(.4,y,-.7))
						wall_instance.rotate_y(deg_to_rad(-60)) 
					1:
						wall_instance.translate(Vector3(.8,y,0))
						wall_instance.rotate_y(deg_to_rad(-120)) 
					2:	
						wall_instance.translate(Vector3(.4,y,.7))
						wall_instance.rotate(Vector3(0,1,0),deg_to_rad(180))
					3:
						wall_instance.translate(Vector3(-.4,y,.7))
						wall_instance.rotate(Vector3(0,1,0),deg_to_rad(120))
					4:
						wall_instance.translate(Vector3(-.78,y,0))
						wall_instance.rotate(Vector3(0,1,0),deg_to_rad(60))
					5:
						wall_instance.translate(Vector3(-.4,y,-.7))
						# no rotation needed for this case
						
				tile.add_child(wall_instance)
			i += 1

	print("Total walls: ", total_walls)
