extends Node2D

var possibleStates = ["grass", "forest", "water", "sand"]
var textures = {"grass" : "GrassTile.png", "forest" : "Forest.png", "water" : "Water.png", "sand" : "Sand.png"}
var rules = {"grass" : ["grass", "sand", "forest"], "forest" : ["grass", "forest"], "sand" : ["grass", "sand", "water"], "water" : ["sand", "water"]}
var entropy = 4
var spr
var lbl
var mask
var red
var spr_mng
var selected = false
var collapsed = false
var targeted = false
var passed = false
var pos = Vector2(0,0)

func _ready():
	spr = get_node("Sprite")
	lbl = get_node("Label")
	mask = get_node("Mask")
	spr_mng = get_node("SmallSpriteManager")
	red = get_node("Sprite2")

func render_tile():
	entropy = possibleStates.size()
	passed = false
	if targeted:
		red.visible = true
	else:
		red.visible = false
	if not collapsed:
		#cull tiles that do not exist in the possibleStates array
		#state will still be null here
		if not possibleStates.has("grass"):
			spr_mng.get_node("SmallGrass").visible = false
		else:
			spr_mng.get_node("SmallGrass").visible = true
		if not possibleStates.has("forest"):
			spr_mng.get_node("SmallForest").visible = false
		else:
			spr_mng.get_node("SmallForest").visible = true
		if not possibleStates.has("sand"):
			spr_mng.get_node("SmallSand").visible = false
		else: 
			spr_mng.get_node("SmallSand").visible = true
		if not possibleStates.has("water"):
			spr_mng.get_node("SmallWater").visible = false
		else:
			spr_mng.get_node("SmallWater").visible = true
	else:
		#we have collapsed
		spr_mng.get_node("SmallGrass").visible = false
		spr_mng.get_node("SmallForest").visible = false
		spr_mng.get_node("SmallSand").visible = false
		spr_mng.get_node("SmallWater").visible = false
		spr.texture = load("res://assets/tiles/" + textures[possibleStates[0]])
		lbl.text = ""
	targeted = false
