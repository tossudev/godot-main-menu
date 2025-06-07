extends Node2D

# Give each layer a speed on the x-axis. (pixels per second)
# Sorted from farthest to nearest, so ideally lower values to higher values.
const LAYER_SPEEDS: Array = [
	10.0,
	15.0,
	20.0,
	30.0
]
# Width of layer textuers, used for repeating textures infinitely.
const LAYER_WIDTH: int = 320
const LAYER_DIRECTION: int = -1

# Object references
var layer_nodes: Array = []


func _ready() -> void:
	_get_layer_nodes()


func _process(delta):
	_update_background_visuals(delta)


func _get_layer_nodes() -> void:
	# Get all layer node references
	for layer_node: Object in get_children():
		layer_nodes.append(layer_node)


func _update_background_visuals(delta: float) -> void:
	var layer_index: int = 0
	for layer_node: Object in layer_nodes:
		
		# Use list of speeds to determine move amount, change layer direction if necessary
		var amount_to_move: float = (
				LAYER_SPEEDS[layer_index] * delta) * LAYER_DIRECTION
		
		layer_node.position.x += amount_to_move
		
		if layer_node.position.x <= LAYER_WIDTH * LAYER_DIRECTION:
			layer_node.position.x = 0.0
		
		layer_index += 1
