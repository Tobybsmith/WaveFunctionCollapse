extends Node2D

var tile = load("res://scenes/tiles/Tile.tscn")
const rules = {"grass" : ["grass", "sand", "forest"], "forest" : ["grass", "forest"], "sand" : ["grass", "sand", "water"], "water" : ["sand", "water"]}
var t
var world
var ties = []
var currentTilePos
const HEIGHT = 20
const WIDTH = 20
var count = 0
var complete
var busted = false

#TODO
#edge adjacency
#why crash when big


func _ready():
	randomize()
	world = make_2d_array(HEIGHT, WIDTH)
	for i in HEIGHT:
		for j in WIDTH:
			var current_tile = tile.instance()
			self.add_child(current_tile)
			current_tile.global_position = Vector2(i * 32 + 16 + 300, j * 32 + 16 + 100)
			#have to instance these at some point to make actual tiles
			world[j][i] = current_tile
			current_tile.pos = Vector2(j,i)
	while not complete:
		collapse()

#func _physics_process(delta):
#	if busted:
#		reset()
#		busted = false;
#	if count % 1 == 0:
#		count = 0;
#		collapse()
#	if complete:
#		return
#	count += 1

func reset():
	print("RESET")
	world.clear()
	world = make_2d_array(HEIGHT, WIDTH)
	for i in HEIGHT:
		for j in WIDTH:
			var current_tile = tile.instance()
			self.add_child(current_tile)
			current_tile.global_position = Vector2(i * 32 + 16 + 300, j * 32 + 16 + 100)
			#have to instance these at some point to make actual tiles
			world[j][i] = current_tile
			current_tile.pos = Vector2(j,i)

func collapse():
	count += 1
	#to start, look for the tile with the lowest entropy value
	#if there is a tie, then pick randomly from the tied values
	var max_e  = INF;
	var lowest
	var e = 0
	var currentTile
	#gets the lowest entropy tile in the board, or a random one if there is a tie
	for i in HEIGHT:
		for j in WIDTH:
			e = world[j][i].entropy
			if e < max_e and e > 1:
				#new low found
				lowest = world[j][i]
				max_e = e
				ties.clear()
			elif e == max_e and e > 1:
				ties.push_back(world[j][i])
			elif e < max_e and e <= 1:
				#print("SUS")
				pass
			#only other condition is that e > max_e
	#now we either have a lowest entropy tile, or a set of ties for lowest entropy
	
#	for i in HEIGHT:
#		for j in WIDTH:
#			if world[j][i].entropy > 1:
#				print("G1")
	
	if ties.size() > 0:
		#we have a tie
		currentTile = ties[randi()%ties.size()]
		currentTile.possibleStates = [currentTile.possibleStates[randi()%currentTile.possibleStates.size()]]
		currentTile.collapsed = true
		#collapses one tile
	else:
		#we have one tile with a lowest entropy value and this represents out in point
		currentTile = lowest
		if currentTile == null and get_avaliable_tiles().size() > 0:
			currentTile = get_avaliable_tiles()[randi()%get_avaliable_tiles().size()]
		if currentTile == null:
			complete = true
			return
		#somehow possibleStates can be 0
		if currentTile.possibleStates.size() == 0:
			busted = true
			return
		currentTile.possibleStates = [currentTile.possibleStates[randi()%currentTile.possibleStates.size()]]
		currentTile.collapsed = true
	#now we have one collapsed tile and we need to look for the lowest  
	#i think we have to do this with recursion
	
	#steps:
	#1 pick the neighbor with the lowest entropy (random on ties)
	#2 modify its rules with a get_new_rules() function to tell it what states it is not allowed
	#2.5 mark that tile as passed so we do not go back to it
	#3 then pick the neighbor with the lowest entropy (random on ties) (repeat 1)
	#4 repeat
	
#	print(currentTile.pos)
	if currentTile.collapsed:
		currentTile.targeted = true
	#ripple doesnt change enough neighbors
	ripple(currentTile)
	ties.clear()
	#end of function
	for i in HEIGHT:
		for j in WIDTH:
			world[j][i].render_tile()

func ripple(origin):
	#steps:
	#1 pick the neighbor with the lowest entropy (random on ties)
	#2 modify its rules with a get_new_rules() function to tell it what states it is not allowed
	#2.5 mark that tile as passed so we do not go back to it
	#3 then pick the neighbor with the lowest entropy (random on ties) (repeat 1)
	#4 repeat
	
	var neighbors = get_neighbors(origin)
	
	if origin.passed == true:
		return
	
	#ripple affects previously touched tiles
	origin.passed = true
	
	#this is good
	if not origin.collapsed:
		origin.possibleStates = get_rules_from_solved(origin)
	
	for n in neighbors: 
		#if n.entropy <= origin.entropy:
		ripple(n)


#this is only called on uncollapsed nodes
#we only want to change higher-entropy tiles
#if a tile we are looking at has lower entropy than the current tile, do not update
func get_rules_from_solved(origin):
	var neighbors = get_neighbors(origin)
	var temp = {"grass" : 0, "forest" : 0, "sand" : 0, "water" : 0}
	var new_rules : Array
	var arr : Array
	var collapsed_neighbor_rules = ["grass", "forest", "sand", "water"]
	var return_collapsed = false
	var collapsed_arr : Array
	var neighbor_arr : Array
	var col = false
	var neb = false
	
	#get intersection of all the neighbor rules
	for n in neighbors:
		if n.collapsed:
			#if n is collapsed, then add n's rules to the new_rules
			#collapsed neighbor rules will become the intersection of collapsed_neighbor_rules with rules[n.possibleStates[0]]
			#intersection returns duplicates so we need to cull them
			collapsed_arr.push_back(rules[n.possibleStates[0]])
			col = true
	if col:
		#gets intersection of all the collapsed rules to figure out what the tile should be
		collapsed_neighbor_rules = multiple_intersection(collapsed_arr)
	
	for n in neighbors:
		if not n.collapsed:
			for state in n.possibleStates:
				neighbor_arr += rules[state]
	
#	collapsed_neighbor_rules.remove("grass")
#	collapsed_neighbor_rules.remove("sand")
#	collapsed_neighbor_rules.remove("forest")
#	collapsed_neighbor_rules.remove("water")
	
	for r in collapsed_neighbor_rules:
		temp[r] = 1
		#will set the temp
	for k in temp.keys():
		if temp[k] == 1:
			arr.push_back(k)
	
	#print("Position: " + str(origin.pos) + " Possible States After Rule Change: " + str(origin.possibleStates) + " " + str(arr))
	#there might be duplicates here somehow
	
#	if arr.size() > origin.possibleStates.size():
#		return origin.possibleStates
#	if arr.size() == 0:
#		print(origin.possibleStates)
	return arr

func get_lowest_local_entropy_tile(origin):
	#should look at the 4 cardinal neighbors of a tile
	var lowest_entropy = INF
	var lowest_pos
	var entropies = []
	var lowest_ties = []
	entropies = get_neighbors(origin)
	#find the lowest entropy in the set
	for i in range(entropies.size()):
		if entropies[i].entropy < lowest_entropy and entropies[i].passed == false:
			lowest_entropy = entropies[i].entropy
			lowest_pos = i
			lowest_ties.clear()
		elif entropies[i].entropy == lowest_entropy or entropies[i].passed == true:
			lowest_ties.push_back(entropies[i])
		#return the lowest, or a rando in the case of a tie
	if lowest_ties.size() == 0:
		return entropies[lowest_pos]
	else:
		return lowest_ties[randi()%lowest_ties.size()]

func get_lowest_entropy_tile():
	var lowest_entropy = INF
	var target
	var local_ties = []
	for i in HEIGHT:
		for j in WIDTH:
			#w/o world[i][j].passed = false its more random
			if world[j][i].entropy < lowest_entropy and world[i][j].passed == false:
				target = world[j][i]
				lowest_entropy = target.entropy
				local_ties.clear()
			elif world[j][i].entropy == lowest_entropy and world[i][j].passed == false:
				local_ties.push_back(world[j][i])
	if local_ties.size() > 0:
		return local_ties[randi()%local_ties.size()]
	return target

func make_2d_array(i, j):
	var arr = []
	for a in j:
		arr.append([])
		for b in i:
			arr[a].append(null)
	return arr

func intersection(a1, a2):
	var arr : Array
	if a1.size() > a2.size():
		for element in a2:
			if a1.has(element):
				arr.push_back(element)
	else:
		for element in a1:
			if a2.has(element):
				arr.push_back(element)
	return arr

func multiple_intersection(list_of_arrays):
	var final = list_of_arrays[0]
	for arr in list_of_arrays:
		final = intersection(arr, final)
	return final

func get_avaliable_tiles():
	var arr : Array
	for i in HEIGHT:
		for j in WIDTH:
			if world[j][i].collapsed != true:
				arr.push_back(world[j][i])
	return arr

func get_neighbors(origin):
	var neighbors = []
	if(origin.pos.x + 1 <= HEIGHT - 1):
		neighbors.push_back(world[origin.pos.x + 1][origin.pos.y])
	if(origin.pos.y - 1 >= 0):
		neighbors.push_back(world[origin.pos.x][origin.pos.y - 1])
	if(origin.pos.y + 1 <= WIDTH - 1):
		neighbors.push_back(world[origin.pos.x][origin.pos.y + 1])
	if(origin.pos.x - 1 >= 0):
		neighbors.push_back(world[origin.pos.x - 1][origin.pos.y])
	return neighbors
