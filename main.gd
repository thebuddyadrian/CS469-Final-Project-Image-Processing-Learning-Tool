extends Control

@onready var algorithm_manager: PanelContainer = $AlgorithmManager # UI for managing and modifying different shaders
@onready var multi_shader_image: SubViewportContainer = %MultiShaderImage # An image container that allows you to apply multiple shaders and reorder them
@onready var file_dialog: FileDialog = $FileDialog
@onready var internal_file_dialog: FileDialog = $InternalFileDialog
@onready var algorithm_name: Label = $TabContainer/Description/AlgorithmName
@onready var description: Label = $TabContainer/Description/Description
@onready var number_of_filters: OptionButton = %NumberOfFilters
@onready var your_image: SubViewportContainer = %YourImage
@onready var target_image: SubViewportContainer = %TargetImage
@onready var free_play_ui: Control = $FreePlayUI
@onready var match_the_filters_ui: Control = $MatchTheFiltersUI
@onready var output: TextEdit = $MatchTheFiltersUI/Output


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
	internal_file_dialog.show()


func _on_choose_custom_image_pressed() -> void:
	file_dialog.show()


func _on_file_dialog_file_selected(path:String) -> void:
	var image = Image.new()
	image.load(path)
	var texture = ImageTexture.create_from_image(image)
	multi_shader_image.choose_image(texture)
	your_image.choose_image(texture)
	target_image.choose_image(texture)


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
	$Notice.show()

func _on_quit_pressed() -> void:
	match_the_filters_ui.hide()
	free_play_ui.show()
	$Notice.hide()


func _on_show_answer_pressed() -> void:
	var dict_array = target_image.get_shaders_as_dict_array()
	var answer_string = ""
	var index: int = 0
	
	# Show all filters and parameter values
	for dict in dict_array:
		index += 1
		answer_string += "Filter %s: %s\n" % [index , dict["shader"]]
		for param in dict["params"]:
			answer_string += "- %s: %s\n" % [param, dict["params"][param]]
	
	output.text = answer_string
		

func _on_submit_pressed() -> void:
	var target_dict_array = target_image.get_shaders_as_dict_array()
	var your_dict_array = your_image.get_shaders_as_dict_array()
	var num_filters = your_dict_array.size()
	var total_score: float = 0.0 # Final score out of 100
	var output_string = ""

	for i in range(num_filters):
		if i >= target_dict_array.size():
			break

		var target_filter = target_dict_array[i]
		var your_filter = your_dict_array[i]
		output_string += "Filter %s: %s\n" % [i + 1, your_filter["shader"]]
		
		
		 # Wrong filter type = 0 score for this filter
		if target_filter["shader"] != your_filter["shader"]:
			output_string += "Incorrect Filter: +0%\n"
			continue

		var target_params = target_filter["params"]
		var your_params = your_filter["params"]
		var num_params = target_params.size()
		var max_score = 100.0 / num_filters
		
		
		if num_params == 0:
			output_string += "No Params, Full points: +%s\n\n" % max_score
			total_score += max_score
			continue

		var filter_score: float = 0.0

		for param_name in your_params.keys():
			output_string += "Param: %s\n" % param_name
			if your_params.has(param_name):
				var target_value = target_params[param_name]
				var your_value = your_params[param_name]

				var diff = abs(float(target_value) - float(your_value))
				var max_val = max(abs(float(target_value)), 0.0001) # Prevent division by 0
				var percent_diff = clamp(1.0 - (diff / max_val), 0.0, 1.0) # Closer = higher score
				output_string += "Accuracy: %s\n" % (percent_diff * 100)

				var param_score = percent_diff * (100.0 / num_filters / num_params)
				filter_score += param_score
				output_string += "Score For this param: %s\n" % param_score
			else:
				output_string += "Missing Param, No Points\n"
		
		output_string += "Score for this filter: %s\n\n" % filter_score
		
		total_score += filter_score
	output_string += "TOTAL SCORE: %s" % total_score
	$MatchTheFiltersUI/Output.text = output_string

func _on_restart_pressed() -> void:
	_on_start_match_filters_pressed()
