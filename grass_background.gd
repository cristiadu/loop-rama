extends Sprite2D

# Set scale to fit exactly into 960x540
var target_width = 960.0
var target_height = 540.0

func _ready():
  var scale_x = target_width / texture.get_width()
  var scale_y = target_height / texture.get_height()
  scale = Vector2(scale_x, scale_y)
  
  # Center the background on the screen
  position = Vector2(target_width / 2, target_height / 2)
