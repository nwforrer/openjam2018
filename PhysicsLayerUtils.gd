extends Node

var layer_name_to_bit = {}

func _ready():
	for i in range(1, 21):
		var layer_name = ProjectSettings.get_setting(str("layer_names/2d_physics/layer_", i))
		
		if layer_name:
			layer_name_to_bit[layer_name] = pow(2, i-1)

func layer_bit_for_name(layer):
	if layer_name_to_bit.has(layer):
		return layer_name_to_bit[layer]
	else:
		print("ERROR: physics layer %s not found" % layer)
		return 0
	
func obj_on_layer(obj, layer):
	var layer_bit = layer_bit_for_name(layer)
	return obj.collision_layer & int(layer_bit)