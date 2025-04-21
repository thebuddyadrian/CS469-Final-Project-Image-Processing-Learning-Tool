extends Control

const AlgorithmSlider = preload("res://scenes/algorithm_slider/algorithm_slider.tscn")

@onready var image_viewport: SubViewport = $ImageViewportContainer/ImageViewport
@onready var texture_rect: TextureRect = $ImageViewportContainer/ImageViewport/TextureRect
@onready var algorithm_container: VBoxContainer = $AlgorithmContainer
@onready var algorithms_dropdown: OptionButton = $AlgorithmContainer/AddAlgorithm/AlgorithmsDropdown

var active_slider: Node = null # The slider currently modifying the image

# Define algorithms and their settings
var algorithms = {
	"gaussian_blur": {
		"num_params": 1,
		"parameters": [{
			"param": "sigma", # Which param will be changed by the slider
			"min_value": 0.0, # Min value for the slider
			"max_value": 8.0, # Max value for the slider
			"default_value": 0.0, # Default value for the slider
		}]
	},
	"contrast": {
		"num_params": 1,
		"parameters": [{
			"param": "multiplier",
			"min_value": 0.0,
			"max_value": 3.0,
			"default_value": 1.0,
		}]
	},
	"noise": {
		"num_params": 1,
		"parameters": [{
			"param": "noise_intensity",
			"min_value": 0.0,
			"max_value": 1.0,
			"default_value": 0.0,
		}]
	},
	"brightness": {
		"num_params": 4,
		"parameters": [{
			"param": "brightness_mult",
			"min_value": 0.0,
			"max_value": 5.0,
			"default_value": 1.0,
			},
			{
			"param": "skew_red",
			"min_value": 0.0,
			"max_value": 5.0,
			"default_value": 1.0,
			},
			{
			"param": "skew_green",
			"min_value": 0.0,
			"max_value": 5.0,
			"default_value": 1.0,
			},
			{
			"param": "skew_blue",
			"min_value": 0.0,
			"max_value": 5.0,
			"default_value": 1.0,
			}]
	},
	"thresholding": {
		"num_params": 3,
		"parameters": [{
			"param": "red_threshold",
			"min_value": 0.0,
			"max_value": 100.0,
			"default_value": 50.0
		},
		{
			"param": "green_threshold",
			"min_value": 0.0,
			"max_value": 100.0,
			"default_value": 50.0
		},
		{
			"param": "blue_threshold",
			"min_value": 0.0,
			"max_value": 100.0,
			"default_value": 50.0
		}]
	},
	"image_negative": {
		"num_params": 1,
		"parameters": [{
			"param": "placeholder",
			"min_value": 0.0,
			"max_value": 1.0,
			"default_value": 0.0
		}]
	},
	"log_transform": {
		"num_params": 1,
		"parameters": [{
			"param": "scaling_constant",
			"min_value": 0.0,
			"max_value": 2.0,
			"default_value": 1.0
		}]
	},
	"power_law": {
		"num_params": 2,
		"parameters": [{
			"param": "gamma",
			"min_value": 0.01,
			"max_value": 5.00,
			"default_value": 1.0
		},
		{
			"param": "scaling_constant",
			"min_value": 0.0,
			"max_value": 2.0,
			"default_value": 1.0
		}]
	},
	"contrast_stretching": {
		"num_params": 4,
		"parameters": [{
			"param": "input_lower_bound",
			"min_value": 0.00,
			"max_value": 255.00,
			"default_value": 0
		},
		{
			"param": "input_upper_bound",
			"min_value": 0.00,
			"max_value": 255.00,
			"default_value": 255
		},
		{
			"param": "output_lower_bound",
			"min_value": 0.00,
			"max_value": 255.00,
			"default_value": 0.00
		},
		{
			"param": "output_upper_bound",
			"min_value": 0.00,
			"max_value": 255.00,
			"default_value": 255.0
		}]
	}
}

# Initialize algorithm dropdown
func _ready() -> void:
	for algorithm in algorithms.keys():
		algorithms_dropdown.add_item(algorithm)


# Adds a slider for the shader as well as a ColorRect filter
func _on_add_button_pressed() -> void:
	var shader_name = algorithms_dropdown.get_item_text(algorithms_dropdown.selected)
	if algorithm_container.has_node(shader_name):
		return # If algorithm already exists, dont re-add
	
	var num_params = algorithms[shader_name]["num_params"]
	var parent_shader = shader_name
		
	for i in range(num_params):
		var slider = AlgorithmSlider.instantiate()
		# print("Selected item: %s, %s" % [algorithms_dropdown.selected, shader_name])
		slider.shader = shader_name
		slider.name = shader_name + '_' + str(i) # Name the node the same as the shader name so it can be accessed later
		algorithm_container.add_child(slider)
		algorithm_container.move_child(slider, -2)
		slider.value_slider.min_value = algorithms[shader_name]["parameters"][i]["min_value"]
		slider.value_slider.max_value = algorithms[shader_name]["parameters"][i]["max_value"]
		slider.value_slider.value = algorithms[shader_name]["parameters"][i]["default_value"]
		slider.ID = i
		slider.algorithm_name.text = algorithms[shader_name]["parameters"][i]["param"]
		slider.connect("changed", _on_algorithm_slider_changed)
		slider.connect("remove", _on_algorithm_remove)
		slider.connect("move_up", _on_algorithm_move_up)
		slider.connect("move_down", _on_algorithm_move_down)
		slider.changed.emit(slider.shader, i) # Make sure the image responds to the default value
	_instance_shader_filter(shader_name)


func _instance_shader_filter(shader_name: String) -> void:
	# A back buffer copy is needed to allow multiple shaders to stack
	var back_buffer_copy := BackBufferCopy.new()
	back_buffer_copy.rect.size = texture_rect.size
	back_buffer_copy.rect.position = Vector2.ZERO
	back_buffer_copy.name = shader_name # Name the node the same as the shader name so it can be accessed later
	image_viewport.add_child(back_buffer_copy)
	
	var color_rect := ColorRect.new()
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://shaders/" + shader_name + ".gdshader")
	color_rect.material = shader_material
	color_rect.name = "ColorRect"
	back_buffer_copy.add_child(color_rect)
	color_rect.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	


func _on_algorithm_slider_changed(shader_name, value, i):
	var color_rect: ColorRect = image_viewport.get_node(shader_name + "/ColorRect")
	var shader_material: ShaderMaterial = color_rect.material
	if shader_material:
		var param_name = algorithms[shader_name]["parameters"][i]["param"]
		shader_material.set_shader_parameter(param_name, value)


func _on_algorithm_remove(shader_name):
	var num_params = algorithms[shader_name]["num_params"]
	
	var back_buffer_copy = image_viewport.get_node(shader_name)
	back_buffer_copy.queue_free()
	
	for i in range(num_params):
		var node_id = shader_name + '_' + str(i)
		
		var slider = algorithm_container.get_node(node_id)
		slider.queue_free()


func _on_algorithm_move_up(shader_name):
	var back_buffer_copy = image_viewport.get_node(shader_name)
	# Don't go up if node is already highest (before image viewport)
	if back_buffer_copy.get_index() == 1:
		return
	image_viewport.move_child(back_buffer_copy, max(back_buffer_copy.get_index() - 1, 0))
	var slider = algorithm_container.get_node(shader_name)
	algorithm_container.move_child(slider, max(slider.get_index() - 1, 0))


func _on_algorithm_move_down(shader_name):
	var back_buffer_copy = image_viewport.get_node(shader_name)
	# Dont go down if node is already last
	if back_buffer_copy.get_index() == image_viewport.get_child_count() - 1:
		return
	image_viewport.move_child(back_buffer_copy, back_buffer_copy.get_index() + 1)
	var slider = algorithm_container.get_node(shader_name)
	algorithm_container.move_child(slider, slider.get_index() + 1)
