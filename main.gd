extends Control

const AlgorithmSlider = preload("res://scenes/algorithm_slider/algorithm_slider.tscn")

@onready var texture_rect: TextureRect = $ImageViewportContainer/ImageViewport/TextureRect
@onready var algorithm_container: VBoxContainer = $AlgorithmContainer
@onready var algorithms_dropdown: OptionButton = $AlgorithmContainer/AddAlgorithm/AlgorithmsDropdown

var active_slider: Node = null # The slider currently modifying the image

# List of algorithms, should match the filenames found in "res://shaders", but without .gdshader
var algorithms = ["contrast", "gaussian_blur"]

# Defines which params should be changed on each shader
var shader_params = {
	"gaussian_blur": "sigma",
	"contrast": "multiplier",
}


# Load all shaders found in "res://shaders"
func _ready() -> void:
	var dir = DirAccess.open("res://shaders")
	dir.list_dir_begin()
	var filename = dir.get_next()

	while filename != "":
		if filename.ends_with(".gdshader"):
			var filename_no_ext = filename.split(".")[0]
			algorithms_dropdown.add_item(filename_no_ext)
		filename = dir.get_next()


# Adds the shader as a slider
func _on_add_button_pressed() -> void:
	var slider = AlgorithmSlider.instantiate()
	var shader_name = algorithms_dropdown.get_item_text(algorithms_dropdown.selected)
	print("Selected item: %s, %s" % [algorithms_dropdown.selected, shader_name])
	slider.shader = shader_name
	algorithm_container.add_child(slider)
	algorithm_container.move_child(slider, -2)
	slider.connect("changed", _on_active_slider_changed)
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://shaders/" + shader_name + ".gdshader")
	texture_rect.material = shader_material


func _on_active_slider_changed(shader, value):
	var shader_material: ShaderMaterial = texture_rect.material
	if shader_material:
		var param_name = shader_params[shader]
		shader_material.set_shader_parameter(param_name, value)
		print("slider changed")
