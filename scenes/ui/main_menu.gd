extends Control

const SHIP_MODELS: Array[String] = [
	"res://assets/models/Spaceships/craft_speederA.glb",
	"res://assets/models/Spaceships/craft_speederB.glb",
	"res://assets/models/Spaceships/craft_racer.glb",
	"res://assets/models/Spaceships/craft_miner.glb",
]

const SHIP_NAMES: Array[String] = [
	"Speeder A",
	"Speeder B",
	"Racer",
	"Miner",
]

const BG_ORBIT_RADIUS: float = 1200.0
const BG_ORBIT_SPEED: float = 0.03
const BG_ORBIT_HEIGHT: float = 400.0
const SHIP_ROTATE_SPEED: float = 0.5

var _current_ship_index: int = 0
var _bg_camera: Camera3D
var _bg_angle: float = 0.0
var _ship_pivot: Node3D
var _ship_model: Node3D

@onready var bg_viewport: SubViewport = $BgViewportContainer/BgViewport
@onready var ship_viewport: SubViewport = $UILayer/ContentMargin/ContentHBox/ShipPanel/ShipVBox/ShipViewportContainer/ShipViewport
@onready var ship_name_label: Label = $UILayer/ContentMargin/ContentHBox/ShipPanel/ShipVBox/ShipNameLabel
@onready var seed_panel: PanelContainer = $UILayer/ContentMargin/ContentHBox/RightVBox/SeedPanel
@onready var current_seed_label: Label = $UILayer/ContentMargin/ContentHBox/RightVBox/SeedPanel/SeedMargin/SeedVBox/CurrentSeedLabel
@onready var seed_input: LineEdit = $UILayer/ContentMargin/ContentHBox/RightVBox/SeedPanel/SeedMargin/SeedVBox/SeedInputHBox/SeedInput
@onready var seed_footer_label: Label = $UILayer/SeedFooterLabel


func _ready() -> void:
	seed_panel.visible = false
	current_seed_label.text = "Current Seed: %d" % GameManager.universe_seed
	seed_footer_label.text = "SEED: %d" % GameManager.universe_seed
	ship_name_label.text = SHIP_NAMES[_current_ship_index]

	_setup_background()
	_setup_ship_preview()
	_load_ship_preview()


func _process(delta: float) -> void:
	# Orbit background camera
	if _bg_camera:
		_bg_angle += BG_ORBIT_SPEED * delta
		_bg_camera.position = Vector3(
			cos(_bg_angle) * BG_ORBIT_RADIUS,
			BG_ORBIT_HEIGHT,
			sin(_bg_angle) * BG_ORBIT_RADIUS
		)
		_bg_camera.look_at(Vector3.ZERO)

	# Rotate ship preview
	if _ship_pivot:
		_ship_pivot.rotate_y(SHIP_ROTATE_SPEED * delta)


func _setup_background() -> void:
	var star_system_scene: PackedScene = load("res://scenes/star_system/star_system.tscn")
	var star_system := star_system_scene.instantiate()
	bg_viewport.add_child(star_system)

	# Wait one frame for the star system to spawn its children (including spaceship)
	await get_tree().process_frame

	# Remove the spaceship so only the star system renders
	for child in star_system.get_children():
		if child.name == "Spaceship" or child.scene_file_path == "res://scenes/player/spaceship.tscn":
			child.queue_free()
			break
	# Also check for dynamically added spaceships
	for child in star_system.get_children():
		if child is Node3D and child.has_node("ThirdPersonCamera"):
			child.queue_free()
			break

	# Strip the SystemCamera's dev controls and use it as our orbit camera
	var system_cam: Camera3D = star_system.get_node_or_null("SystemCamera")
	if system_cam:
		system_cam.set_script(null)
		system_cam.current = true
		_bg_camera = system_cam


func _setup_ship_preview() -> void:
	# World environment with transparent background
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.6, 0.7, 1.0)
	env.ambient_light_energy = 0.8

	var world_env := WorldEnvironment.new()
	world_env.environment = env
	ship_viewport.add_child(world_env)

	# Dramatic directional light
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-30, -45, 0)
	light.light_energy = 1.5
	light.light_color = Color(0.9, 0.95, 1.0)
	light.shadow_enabled = true
	ship_viewport.add_child(light)

	# Fill light from the other side
	var fill_light := DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(-20, 135, 0)
	fill_light.light_energy = 0.4
	fill_light.light_color = Color(0.4, 0.5, 0.8)
	ship_viewport.add_child(fill_light)

	# Pivot for rotating the ship
	_ship_pivot = Node3D.new()
	ship_viewport.add_child(_ship_pivot)

	# Camera looking at origin
	var cam := Camera3D.new()
	cam.position = Vector3(0, 2, 10)
	cam.look_at(Vector3.ZERO)
	cam.current = true
	ship_viewport.add_child(cam)


func _load_ship_preview() -> void:
	# Remove old model
	if _ship_model:
		_ship_model.queue_free()
		_ship_model = null

	var model_scene: PackedScene = load(SHIP_MODELS[_current_ship_index])
	if not model_scene:
		return

	var model_instance := model_scene.instantiate()
	_ship_pivot.add_child(model_instance)
	model_instance.scale = Vector3(5, 5, 5)

	# Center model on visual bounds (same logic as spaceship.gd)
	var center := _get_visual_center(model_instance)
	model_instance.position = -center * model_instance.scale
	_ship_model = model_instance


func _get_visual_center(root: Node3D) -> Vector3:
	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(root, meshes)
	if meshes.is_empty():
		return Vector3.ZERO
	var combined := AABB()
	var first := true
	for mesh in meshes:
		var aabb := mesh.get_aabb()
		var xform := root.global_transform.affine_inverse() * mesh.global_transform
		for i in 8:
			var corner := aabb.position + aabb.size * Vector3(
				float(i & 1), float((i >> 1) & 1), float((i >> 2) & 1)
			)
			var p := xform * corner
			if first:
				combined = AABB(p, Vector3.ZERO)
				first = false
			else:
				combined = combined.expand(p)
	return combined.get_center()


func _collect_meshes(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		_collect_meshes(child, result)


# --- Signal handlers (existing functionality preserved) ---

func _on_new_game_button_pressed() -> void:
	GameManager.selected_ship_model = SHIP_MODELS[_current_ship_index]
	get_tree().change_scene_to_file("res://scenes/star_system/star_system.tscn")


func _on_config_seed_button_pressed() -> void:
	seed_panel.visible = !seed_panel.visible


func _on_apply_seed_button_pressed() -> void:
	var new_seed := seed_input.text.to_int()
	GameManager.set_universe_seed(new_seed)
	current_seed_label.text = "Current Seed: %d" % new_seed
	seed_footer_label.text = "SEED: %d" % new_seed


func _on_random_seed_button_pressed() -> void:
	var new_seed := randi()
	GameManager.set_universe_seed(new_seed)
	current_seed_label.text = "Current Seed: %d" % new_seed
	seed_input.text = str(new_seed)
	seed_footer_label.text = "SEED: %d" % new_seed


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_prev_ship_button_pressed() -> void:
	_current_ship_index = (_current_ship_index - 1 + SHIP_MODELS.size()) % SHIP_MODELS.size()
	ship_name_label.text = SHIP_NAMES[_current_ship_index]
	_load_ship_preview()


func _on_next_ship_button_pressed() -> void:
	_current_ship_index = (_current_ship_index + 1) % SHIP_MODELS.size()
	ship_name_label.text = SHIP_NAMES[_current_ship_index]
	_load_ship_preview()
