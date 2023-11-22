extends Node3D
var cube_direction_vectors = [
	Vector3(+1, -1, 0), Vector3(+1, 0, -1), Vector3(0, +1, -1), 
	Vector3(-1, +1, 0), Vector3(-1, 0, +1), Vector3(0, -1, +1) ]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		if Input.is_key_pressed(KEY_ESCAPE):
			get_tree().quit()
			


func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var camera = find_child("Camera3D") # Replace with the actual path to your Camera3D node

		# Get the ray from the camera through the mouse click position
		var ray_origin = camera.project_ray_origin(event.position)
		var ray_direction = camera.project_ray_normal(event.position)

		# Perform a ray cast to find the intersection point in the world
		var space_state = get_world_3d().direct_space_state
		var perams = PhysicsRayQueryParameters3D.new()
		perams.from = ray_origin
		perams.to = ray_origin + ray_direction * 100
		var intersection = space_state.intersect_ray(perams)  

		# Check if there was an intersection
		if intersection:
			var intersection_point = intersection.position
			#print("Mouse Click at world coordinates: ", intersection_point)
			# if tile, print tile.height_level
			var obj = intersection.collider
			obj = obj.get_parent_node_3d()
			if "pos" in obj :
				print("Tile Cord: ",obj.pos)
				print("Height Level: ", obj.height_level, " Height Zone: ", obj.height_zone)
				print("Contents: ", obj.contents)
				print("Biome: ", obj.Biome)
				
				var neighbors = []

				# add our neighbors, mark where we need walls
				for direction in cube_direction_vectors:
					var neighbor_pos = obj.pos + direction
					if neighbor_pos in $MapNode.map_data.keys():
						var neighbor_tile = $MapNode.map_data[neighbor_pos]
						if neighbor_tile.height_level < obj.height_level:
							neighbors.append(1)
						else: neighbors.append(0)
					else: neighbors.append(1)
					# if tile is touching even amount of lower tiles it will be pointy top, 
					# else it will be flat top
					
				print("Neighbors: ", neighbors)

