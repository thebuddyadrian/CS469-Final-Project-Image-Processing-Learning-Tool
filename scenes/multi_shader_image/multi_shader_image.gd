@tool
extends SubViewportContainer

@export var canvas_size: Vector2 = Vector2(640, 360)
@onready var image_viewport: SubViewport = $ImageViewport
@onready var texture_rect: TextureRect = $ImageViewport/TextureRect
@onready var shader_holder: Control = $ImageViewport/ShaderHolder



func _ready() -> void:
	apply_canvas_size()


func _process(_delta):
	if Engine.is_editor_hint():
		apply_canvas_size()


# Make sure texture rect always fits within aspect ratio
# We could use the "Keep Aspect" option of TextureRect, but we want the actual control to be the same exact size of the image, that way filters can simply match the size of the control
func apply_canvas_size():
	size = canvas_size
	image_viewport.size = canvas_size
	
	var image_size: Vector2 = texture_rect.texture.get_size()
	var canvas_size_ratio: Vector2 = canvas_size / image_size # How many times bigger the canvas than the image
	var canvas_aspect_ratio = canvas_size.x/canvas_size.y
	var image_aspect_ratio = image_size.x/image_size.y

	if image_aspect_ratio <= canvas_aspect_ratio:
		texture_rect.size.y = canvas_size.y
		texture_rect.size.x = floor(image_size.x * canvas_size_ratio.y)

		texture_rect.position.y = 0
		texture_rect.position.x = floor((canvas_size.x - texture_rect.size.x) / 2)
	else:
		texture_rect.size.x = canvas_size.x
		texture_rect.size.y = floor(image_size.y * canvas_size_ratio.x)

		texture_rect.position.x = 0
		texture_rect.position.y = floor((canvas_size.y - texture_rect.size.y) / 2)


func add_shader(shader_name: String):
	# A back buffer copy is needed to allow multiple shaders to stack
	var back_buffer_copy := BackBufferCopy.new()
	# Copy the size of the texture rect, to make sure the filter only covers the actual image
	back_buffer_copy.rect.size = texture_rect.size
	back_buffer_copy.rect.position = texture_rect.position
	back_buffer_copy.name = shader_name
	back_buffer_copy.set_meta("shader", shader_name)
	shader_holder.add_child(back_buffer_copy, true)
	
	# Add a ColorRect which will filter the image (and other ColorRects) behind it
	var color_rect := ColorRect.new()
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://shaders/" + shader_name + ".gdshader")
	color_rect.material = shader_material
	color_rect.name = "ColorRect"
	color_rect.set_meta("shader", shader_name)
	back_buffer_copy.add_child(color_rect)
	color_rect.set_anchors_and_offsets_preset(PRESET_FULL_RECT)


# Remove shader at position
func remove_shader(idx: int):
	if shader_holder.get_child_count() <= idx:
		return
	shader_holder.get_child(idx).queue_free()


# Can be used to temporarily disable a shader
func set_shader_visible(idx: int, visible: bool):
	if shader_holder.get_child_count() <= idx:
		return
	shader_holder.get_child(idx).visible = visible


func get_shader_name(idx: int) -> String:
	return shader_holder.get_child(idx).get_meta("shader")


# Get the shader material at a specific index
func get_shader_material(idx: int) -> ShaderMaterial:
	var color_rect: ColorRect = shader_holder.get_child(idx).get_node("ColorRect")
	var shader_material: ShaderMaterial = color_rect.material
	return shader_material


func change_shader_parameter(index, parameter, value):
	get_shader_material(index).set_shader_parameter(parameter, value)


func move_shader_up(idx: int):
	var back_buffer_copy = shader_holder.get_child(idx)
	# Don't go up if node is already first
	if back_buffer_copy.get_index() == 0:
		return
	shader_holder.move_child(back_buffer_copy, idx - 1)


func move_shader_down(idx: int):
	var back_buffer_copy = shader_holder.get_child(idx)
	# Don't go up if node is already last
	if back_buffer_copy.get_index() == shader_holder.get_child_count() - 1:
		return
	shader_holder.move_child(back_buffer_copy, idx + 1)


func choose_image(texture: Texture):
	texture_rect.texture = texture

	apply_canvas_size()

	# Update all shaders to fit the new image
	for back_buffer_copy in shader_holder.get_children():
		back_buffer_copy.rect.size = texture_rect.size
		back_buffer_copy.rect.position = texture_rect.position
		back_buffer_copy.get_node("ColorRect").set_anchors_and_offsets_preset(PRESET_FULL_RECT)


func get_shaders_as_dict_array() -> Array[Dictionary]:
	var shaders: Array[Dictionary]
	for back_buffer_copy in shader_holder.get_children():
		var color_rect = back_buffer_copy.get_node("ColorRect") # Grab the ColorRect that applies the shader filter
		var shader_name = color_rect.get_meta("shader")
		var shader_dict = {} # To represent the shader data as a dictionary
		shader_dict["shader"] = shader_name
		shader_dict["params"] = {}
	
		for param in Global.algorithms[shader_name]["parameters"]:
			var param_name = param["param"]
			shader_dict["params"][param_name] = color_rect.material.get_shader_parameter(param_name)
			print("Got shader parameter for shader %s - %s:%s" % [shader_name, param_name, color_rect.get_instance_shader_parameter(param_name)])
		shaders.append(shader_dict)

	return shaders


func remove_all_shaders():
	for child in shader_holder.get_children():
		child.free()


func load_shaders_from_dict_array(dict_array: Array[Dictionary]):
	remove_all_shaders()
	for i in range(dict_array.size()):
		var shader_dict = dict_array[i]
		add_shader(shader_dict["shader"])
		for param in shader_dict["params"].keys():
			change_shader_parameter(i, param, shader_dict["params"][param])
