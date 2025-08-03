extends Control
class_name HandButton

@onready var hand_sprite: Sprite2D = $HandButtonSprite

var original_modulate: Color
var original_position: Vector2
var is_pressing: bool = false
var shake_timer: float = 0.0
var shake_intensity: float = 3.0

func _ready():
	# Store the original color and position
	original_modulate = hand_sprite.modulate
	original_position = hand_sprite.position

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			if event.pressed and not is_pressing:
				_on_button_pressed()
			elif not event.pressed and is_pressing:
				_on_button_released()

func _process(delta):
	if is_pressing:
		# Create shake effect
		shake_timer += delta * 50.0  # Speed of shake
		var shake_x = sin(shake_timer) * shake_intensity
		var shake_y = cos(shake_timer * 1.2) * shake_intensity
		hand_sprite.position = original_position + Vector2(shake_x, shake_y)

func _on_button_pressed():
	is_pressing = true
	# Add red tint
	hand_sprite.modulate = Color(1.3, 0.8, 0.8, 1.0)  # Reddish tint

func _on_button_released():
	is_pressing = false
	# Return to original color and position
	hand_sprite.modulate = original_modulate
	hand_sprite.position = original_position
	shake_timer = 0.0