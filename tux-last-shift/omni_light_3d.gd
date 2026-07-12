extends OmniLight3D

# Tốc độ đổi màu (số càng lớn thì đổi càng nhanh)
@export var speed: float = 0.5 

var hue: float = 0.0

func _process(delta):
	# Tăng dần giá trị hue
	hue += delta * speed
	
	# Nếu hue > 1 thì reset về 0 để lặp lại
	if hue > 1.0:
		hue = 0.0
	
	# Chuyển đổi từ hệ màu HSV sang RGB
	# H (hue): giá trị từ 0-1 (màu sắc)
	# S (saturation): 1.0 là màu đậm nhất
	# V (value): 1.0 là độ sáng cao nhất
	light_color = Color.from_hsv(hue, 1.0, 1.0)
