extends PanelContainer

# Child node for editing the parameters of an algorithm (shader)
const AlgorithmEditor = preload("res://scenes/algorithm_editor/algorithm_editor.tscn")

@onready var algorithms_dropdown: OptionButton = %AlgorithmsDropdown
@onready var algorithm_editors: VBoxContainer = %AlgorithmEditors

# The currently selected AlgorithmEditor node
var currently_selected

signal algorithm_added(shader_name)
signal algorithm_removed(index)
signal algorithm_toggled(index, toggled_on)
signal algorithm_selected(index, shader_name)
signal algorithm_parameter_changed(index, parameter, value)
signal algorithm_moved_up(index)
signal algorithm_moved_down(index)



# Initialize algorithm dropdown
func _ready() -> void:
	for algorithm in Global.algorithms.keys():
		algorithms_dropdown.add_item(algorithm.capitalize())


# Adds a slider for the shader as well as a Co `	lorRect filter
func _on_add_button_pressed() -> void:
	# Index 0 is the placeholder "Select Algorithm" text
	if algorithms_dropdown.selected == 0:
		return
	# Since we add the algorithms to the dropdown in the same order they are defined in Global.gd, we can grab their name from the dictionary keys
	var shader_name = Global.algorithms.keys()[algorithms_dropdown.selected - 1]
	var algorithm_editor = AlgorithmEditor.instantiate()
	algorithm_editor.shader = shader_name
	algorithm_editor.remove.connect(_on_algorithm_remove.bind(algorithm_editor))
	algorithm_editor.move_down.connect(_on_algorithm_move_down.bind(algorithm_editor))
	algorithm_editor.move_up.connect(_on_algorithm_move_up.bind(algorithm_editor))
	algorithm_editor.parameter_changed.connect(_on_algorithm_parameter_changed.bind(algorithm_editor))
	algorithm_editor.toggle.connect(_on_algorithm_toggle.bind(algorithm_editor))
	algorithm_editor.select.connect(_on_algorithm_select.bind(algorithm_editor))
	algorithm_added.emit(shader_name)
	algorithm_editors.add_child(algorithm_editor)


# When the child AlgorithmEditor requests to be removed
func _on_algorithm_remove(algorithm_editor: Node) -> void:
	algorithm_editor.queue_free()
	algorithm_removed.emit(algorithm_editor.get_index())


# When the child AlgorithmEditor is toggled on or off
func _on_algorithm_toggle(toggled_on: bool, algorithm_editor: Node) -> void:
	algorithm_toggled.emit(algorithm_editor.get_index(), toggled_on)


# When an Algorithm requests to be moved up
func _on_algorithm_move_up(algorithm_editor: Node):
	# Don't go up if node is already first
	if algorithm_editor.get_index() == 0:
		return
	# Emits the index BEFORE being moved, this is to allow the moving of algorithms to be synced to the MultiShaderImage
	algorithm_moved_up.emit(algorithm_editor.get_index())
	algorithm_editors.move_child(algorithm_editor, algorithm_editor.get_index() - 1)
	

# When an Algorithm requests to be moved down
func _on_algorithm_move_down(algorithm_editor: Node):
	# Don't go up if node is already last
	if algorithm_editor.get_index() == algorithm_editors.get_child_count() - 1:
		return
	# Emits the index BEFORE being moved, this is to allow the moving of algorithms to be synced to the MultiShaderImage
	algorithm_moved_down.emit(algorithm_editor.get_index())
	algorithm_editors.move_child(algorithm_editor, algorithm_editor.get_index() + 1)


# When an Algorithm changes one of its parameter sliders
func _on_algorithm_parameter_changed(parameter, value, algorithm_editor):
	algorithm_parameter_changed.emit(algorithm_editor.get_index(), parameter, value)


# When an algorithm is clicked and requests to be marked as selected
func _on_algorithm_select(algorithm_editor):
	if currently_selected:
		currently_selected.selected = false
	algorithm_editor.selected = true
	currently_selected = algorithm_editor
	algorithm_selected.emit(algorithm_editor.get_index(), algorithm_editor.shader)


func get_shader_name(index) -> ShaderMaterial:
	return algorithm_editors.get_child(index).shader


func remove_all_algorithms():
	for algorithm in algorithm_editors.get_children():
		_on_algorithm_remove(algorithm)