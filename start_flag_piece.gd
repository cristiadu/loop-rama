extends Control
class_name StartFlagPiece

const GRID_SIZE = 16

# Start flag specific properties
var width_units: int = 1  # Width in grid units (16px each)
var height_units: int = 2 # Height in grid units (16px each)
var current_rotation: int = 0 # Rotation in degrees (must be multiple of 90)

@onready var start_flag_sprite: Sprite2D = $StartFlagSprite

# Initialize the start flag piece
func setup_start_flag_piece():
    _apply_rotation()
    _update_size()

# Return actual width accounting for rotation
func get_actual_width() -> int:
    var rotated_size = get_rotated_size()
    return rotated_size.x * GRID_SIZE

# Return actual height accounting for rotation
func get_actual_height() -> int:
    var rotated_size = get_rotated_size()
    return rotated_size.y * GRID_SIZE

# Return size considering current rotation
func get_rotated_size() -> Vector2i:
    if current_rotation % 180 == 0:
        return Vector2i(width_units, height_units)
    else:
        return Vector2i(height_units, width_units)



# Apply rotation to the sprite
func _apply_rotation():
    # Normalize rotation to 0-359 range
    current_rotation = current_rotation % 360
    if current_rotation < 0:
        current_rotation += 360
    
    # Apply rotation to sprite
    start_flag_sprite.rotation_degrees = current_rotation

# Update the control size based on piece dimensions and rotation
func _update_size():
    var rotated_size = get_rotated_size()
    var actual_width = rotated_size.x * GRID_SIZE
    var actual_height = rotated_size.y * GRID_SIZE
    
    # Set the control size
    custom_minimum_size = Vector2(actual_width, actual_height)
    size = Vector2(actual_width, actual_height)
    
    # Center the sprite within the control bounds
    if start_flag_sprite:
        start_flag_sprite.position = Vector2(actual_width / 2.0, actual_height / 2.0)

# Rotate the piece by 90 degrees
func rotate_piece():
    current_rotation += 90
    _apply_rotation()
    _update_size()

# Set specific rotation
func set_piece_rotation(degrees: int):
    current_rotation = degrees
    _apply_rotation()
    _update_size()

# Get current piece info
func get_piece_info() -> Dictionary:
    var rotated_size = get_rotated_size()
    return {
        "type": "START_FLAG",
        "width_units": rotated_size.x,
        "height_units": rotated_size.y,
        "actual_width": rotated_size.x * GRID_SIZE,
        "actual_height": rotated_size.y * GRID_SIZE,
        "rotation": current_rotation
    }

# Different dropping behavior - start flags can only be placed once per track
func can_be_dropped_at_position(_position: Vector2) -> bool:
    # TODO: Implement specific dropping logic for start flags
    # For example, check if there's already a start flag on the track
    # or ensure it's placed at valid start positions only
    return true

# Handle specific start flag dropping behavior
func handle_drop(_drop_position: Vector2):
    # TODO: Implement start flag specific drop handling
    # This could include:
    # - Checking for existing start flags
    # - Validating the drop position
    # - Setting up race starting logic
    pass

# Drag and drop functionality
func _ready():
    # Enable input but only drag when clicking on sprite
    mouse_filter = Control.MOUSE_FILTER_PASS
    
    # Ensure sprite is properly centered from the start
    setup_start_flag_piece()

var drag_allowed: bool = false

func _gui_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        # Check if click is within sprite bounds
        var sprite_rect = Rect2(start_flag_sprite.position - start_flag_sprite.texture.get_size()/2, start_flag_sprite.texture.get_size())
        if sprite_rect.has_point(event.position):
            drag_allowed = true
        else:
            drag_allowed = false

func _get_drag_data(_position):
    if not drag_allowed:
        return null
    
    # Create drag data with piece information
    var drag_data = {
        "type": "start_flag_piece",
        "piece_info": get_piece_info(),
        "original_node": self
    }
    
    # Use a duplicate of this piece as the drag preview so it looks like moving the original
    var preview = duplicate()
    set_drag_preview(preview)
    
    # Hide the original during drag
    visible = false
    
    return drag_data

# Handle drag cancellation (when drag is dropped outside valid area)
func _notification(what):
    if what == NOTIFICATION_DRAG_END:
        # Restore visibility if drag was cancelled
        visible = true