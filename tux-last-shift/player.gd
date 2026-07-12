extends CharacterBody3D

# Tốc độ đi bình thường khi bấm W/A/S/D
@export var walk_speed: float = 5.0

# Tốc độ chạy khi giữ Shift
@export var sprint_speed: float = 8.0

# Lực nhảy khi bấm Space
@export var jump_velocity: float = 4.5

# Độ nhạy chuột, số càng lớn xoay càng nhanh
@export var mouse_sensitivity: float = 0.002

# Camera3D phải là node con trực tiếp của CharacterBody3D
@onready var camera: Camera3D = $Camera3D

# Lấy trọng lực mặc định từ Project Settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Lưu góc nhìn lên/xuống của camera
var camera_pitch: float = 0.0


func _ready() -> void:
	# Khóa chuột vào giữa màn hình để dùng chuột xoay camera
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Di chuyển chuột để xoay camera
	if event is InputEventMouseMotion:
		# Chuột trái/phải: xoay cả thân player theo trục Y
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Chuột lên/xuống: xoay riêng Camera3D theo trục X
		camera_pitch -= event.relative.y * mouse_sensitivity

		# Giới hạn góc nhìn để camera không bị lộn ngược
		camera_pitch = clamp(camera_pitch, deg_to_rad(-89.0), deg_to_rad(89.0))

		camera.rotation.x = camera_pitch

	# Bấm Esc để thả chuột ra khỏi cửa sổ game
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	# Nếu player không đứng trên sàn thì bị trọng lực kéo xuống
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Input: jump = Space
	# Chỉ cho nhảy khi đang đứng trên sàn
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Input: sprint = Shift
	# Giữ Shift thì chạy nhanh hơn
	var current_speed := walk_speed
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	# Input Map:
	# left    = A
	# right   = D
	# forward = W
	# back    = S
	#
	# A tạo x = -1
	# D tạo x =  1
	# W tạo y = -1
	# S tạo y =  1
	var input_dir := Input.get_vector("left", "right", "forward", "back")

	# Đổi input 2D từ WASD thành hướng di chuyển 3D
	# input_dir.x dùng cho trái/phải
	# input_dir.y dùng cho tiến/lùi
	#
	# transform.basis giúp player di chuyển theo hướng đang nhìn
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	# Nếu đang bấm WASD thì di chuyển
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	# Nếu không bấm WASD thì giảm tốc về 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed)
		velocity.z = move_toward(velocity.z, 0.0, current_speed)

	# Di chuyển CharacterBody3D bằng velocity
	move_and_slide()
