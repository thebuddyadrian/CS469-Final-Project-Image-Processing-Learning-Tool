extends Control

@onready var algorithm_manager: PanelContainer = $AlgorithmManager # UI for managing and modifying different shaders
@onready var multi_shader_image: SubViewportContainer = %MultiShaderImage # An image container that allows you to apply multiple shaders and reorder them
@onready var file_dialog: FileDialog = $FileDialog
@onready var algorithm_name: Label = $TabContainer/Description/AlgorithmName
@onready var description: Label = $TabContainer/Description/Description
@onready var number_of_filters: OptionButton = %NumberOfFilters
@onready var your_image: SubViewportContainer = %YourImage
@onready var target_image: SubViewportContainer = %TargetImage
@onready var free_play_ui: Control = $FreePlayUI
@onready var match_the_filters_ui: Control = $MatchTheFiltersUI
@onready var output: Label = $MatchTheFiltersUI/Output


# MATCH: An image will be shown with some filters applied. Find the settings to match those shaders
enum CHALLENGE_TYPE {MATCH, FIX}

var challenge_enabled = false
var current_challenge_filters = {} # A dictionary containing the filters needed to complete the challenge
var submitted_filters = {} # A dictionary containing the filters 

func _ready() -> void:
	algorithm_manager.algorithm_added.connect(multi_shader_image.add_shader)
	algorithm_manager.algorithm_removed.connect(multi_shader_image.remove_shader)
	algorithm_manager.algorithm_moved_up.connect(multi_shader_image.move_shader_up)
	algorithm_manager.algorithm_moved_down.connect(multi_shader_image.move_shader_down)
	algorithm_manager.algorithm_parameter_changed.connect(multi_shader_image.change_shader_parameter)
	algorithm_manager.algorithm_toggled.connect(multi_shader_image.set_shader_visible)
	algorithm_manager.algorithm_selected.connect(_on_algorithm_selected)

	algorithm_manager.algorithm_added.connect(your_image.add_shader)
	algorithm_manager.algorithm_removed.connect(your_image.remove_shader)
	algorithm_manager.algorithm_moved_up.connect(your_image.move_shader_up)
	algorithm_manager.algorithm_moved_down.connect(your_image.move_shader_down)
	algorithm_manager.algorithm_parameter_changed.connect(your_image.change_shader_parameter)
	algorithm_manager.algorithm_toggled.connect(your_image.set_shader_visible)
	algorithm_manager.algorithm_selected.connect(_on_algorithm_selected)


func _on_choose_image_pressed() -> void:
	file_dialog.show()


func _on_file_dialog_file_selected(path:String) -> void:
	multi_shader_image.choose_image(load(path))


func _on_algorithm_selected(_index, shader_name):
	algorithm_name.text = shader_name.replace("_", " ").capitalize()
	description.text = Global.algorithms[shader_name].get("description", "")


func _on_start_match_filters_pressed() -> void:
	algorithm_manager.remove_all_algorithms()
	var num_filters = number_of_filters.selected + 1
	print("Num Filters: %s" % num_filters)
	var shader_array: Array[Dictionary] = []
	
	match_the_filters_ui.show()
	free_play_ui.hide()
	
	var allowed_algorithms = Global.algorithms.keys()
	# Exclude certain algorithms
	allowed_algorithms.erase("highboost_filtering")
	allowed_algorithms.erase("thresholding_rgb")
	allowed_algorithms.erase("convolution")
	allowed_algorithms.erase("contrast_stretching")
	
	for i in range(num_filters):
		var shader = allowed_algorithms.pick_random()
		allowed_algorithms.erase(shader)
		var shader_dict = {}
		shader_dict["shader"] = shader
		shader_dict["params"] = {}
		for j in range(Global.algorithms[shader]["parameters"].size()):
			var param_name: String = Global.algorithms[shader]["parameters"][j]["param"]
			var min_value = Global.algorithms[shader]["parameters"][j]["min_value"]
			var max_value = Global.algorithms[shader]["parameters"][j]["max_value"]
			var default_value = Global.algorithms[shader]["parameters"][j]["default_value"]
			var value: float = randf_range(min_value, max_value)
			
			# Exceptions for certain algorithms
			if shader == "noise" and param_name == "seed":
				value = 0.0
			if shader == "brightness" and param_name.begins_with("skew"):
				value = 0.0
			if shader == "contrast" and param_name.begins_with("skew"):
				value = 1.0
			
			shader_dict["params"][param_name] = value
		shader_array.append(shader_dict)
	target_image.load_shaders_from_dict_array(shader_array)


func _on_quit_pressed() -> void:
	match_the_filters_ui.hide()
	free_play_ui.show()


func _on_show_answer_pressed() -> void:
	var dict_array = target_image.get_shaders_as_dict_array()
	var answer_string = ""
	var index: int = 0
	
	
	for dict in dict_array:
		print(dict)
		index += 1
		answer_string += "Filter %s: %s\n" % [index , dict["shader"]]
		for param in dict["params"]:
			answer_string += "- %s: %s\n" % [param, dict["params"][param]]
	
	output.text = answer_string
		

func _on_submit_pressed() -> void:
	# SCORING WIP
	pass # Replace with function body.


func _on_restart_pressed() -> void:
	_on_start_match_filters_pressed()
