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
		"param": "sigma", # Which param will be changed by the slider
		"min_value": 0.0, # Min value for the slider
		"max_value": 8.0, # Max value for the slider
		"default_value": 0.0, # Default value for the slider
	},
	"contrast": {
		"param": "multiplier",
		"min_value": 0.0,
		"max_value": 3.0,
		"default_value": 1.0,
	},
	"noise": {
		"param": "noise_intensity",
		"min_value": 0.0,
		"max_value": 1.0,
		"default_value": 0.0,
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
	var slider = AlgorithmSlider.instantiate()
	# print("Selected item: %s, %s" % [algorithms_dropdown.selected, shader_name])
	slider.shader = shader_name
	slider.name = shader_name # Name the node the same as the shader name so it can be accessed later
	algorithm_container.add_child(slider)
	algorithm_container.move_child(slider, -2)
	slider.value_slider.min_value = algorithms[shader_name]["min_value"]
	slider.value_slider.max_value = algorithms[shader_name]["max_value"]
	slider.value_slider.value = algorithms[shader_name]["default_value"]
	slider.connect("changed", _on_algorithm_slider_changed)
	slider.connect("remove", _on_algorithm_remove)
	slider.connect("move_up", _on_algorithm_move_up)
	slider.connect("move_down", _on_algorithm_move_down)
	_instance_shader_filter(shader_name)
	slider.changed.emit(slider.shader, slider.value_slider.value) # Make sure the image responds to the default value



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
	


func _on_algorithm_slider_changed(shader_name, value):
	var color_rect: ColorRect = image_viewport.get_node(shader_name + "/ColorRect")
	var shader_material: ShaderMaterial = color_rect.material
	if shader_material:
		var param_name = algorithms[shader_name]["param"]
		shader_material.set_shader_parameter(param_name, value)


func _on_algorithm_remove(shader_name):
	var back_buffer_copy = image_viewport.get_node(shader_name)
	back_buffer_copy.queue_free()
	var slider = algorithm_container.get_node(shader_name)
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
