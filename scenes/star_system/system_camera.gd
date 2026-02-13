extends Camera3D

## Free-look dev camera: WASD movement, right-click drag to rotate, scroll to zoom.

const MOVE_SPEED: float = 100.0
const FAST_MOVE_MULTIPLIER: float = 3.0
const MOUSE_SENSITIVITY: float = 0.003
const ZOOM_STEP: float = 20.0
const MIN_DISTANCE: float = 10.0

var _rotation_x: float = 0.0  # Pitch
var _rotation_y: float = 0.0  # Yaw
var _is_rotating: bool = false


func _ready() -> void:
	# Start position: elevated, looking toward origin
	position = Vector3(0.0, 300.0, 600.0)
	look_at(Vector3.ZERO)
	# Extract initial rotation from look_at
	_rotation_x = rotation.x
	_rotation_y = rotation.y


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			_is_rotating = mb.pressed
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _is_rotating else Input.MOUSE_MODE_VISIBLE
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			position += -basis.z * ZOOM_STEP
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			position += basis.z * ZOOM_STEP

	if event is InputEventMouseMotion and _is_rotating:
		var motion := event as InputEventMouseMotion
		_rotation_y -= motion.relative.x * MOUSE_SENSITIVITY
		_rotation_x -= motion.relative.y * MOUSE_SENSITIVITY
		_rotation_x = clamp(_rotation_x, -PI / 2.0, PI / 2.0)
		rotation = Vector3(_rotation_x, _rotation_y, 0.0)


func _process(delta: float) -> void:
	var direction := Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		direction -= basis.z
	if Input.is_key_pressed(KEY_S):
		direction += basis.z
	if Input.is_key_pressed(KEY_A):
		direction -= basis.x
	if Input.is_key_pressed(KEY_D):
		direction += basis.x
	if Input.is_key_pressed(KEY_Q):
		direction -= basis.y
	if Input.is_key_pressed(KEY_E):
		direction += basis.y

	var speed := MOVE_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= FAST_MOVE_MULTIPLIER

	if direction.length_squared() > 0.0:
		direction = direction.normalized()
		position += direction * speed * delta
