extends Control
class_name StartFlagPiece

const GRID_SIZE = 16

# Start flag specific properties
var width_units: int = 1  # Width in grid units (16px each)
var height_units: int = 1 # Height in grid units (16px each) - start flag is 1x1
# Start flags don't rotate

@onready var start_flag_sprite: Sprite2D = $StartFlagSprite

# Initialize the start flag piece
func setup_start_flag_piece():
    _update_size()

# Return actual width accounting for rotation
func get_actual_width() -> int:
    var rotated_size = get_rotated_size()
    return rotated_size.x * GRID_SIZE

# Return actual height accounting for rotation
func get_actual_height() -> int:
    var rotated_size = get_rotated_size()
    return rotated_size.y * GRID_SIZE

# Return size (start flags don't rotate)
func get_rotated_size() -> Vector2i:
    return Vector2i(width_units, height_units)



# Start flags don't rotate, so no rotation logic needed

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

# Start flags don't rotate

# Get current piece info
func get_piece_info() -> Dictionary:
    return {
        "type": "START_FLAG",
        "width_units": width_units,
        "height_units": height_units,
        "actual_width": width_units * GRID_SIZE,
        "actual_height": height_units * GRID_SIZE
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
var is_placed_on_grid: bool = false
var is_selected: bool = false
var associated_car: Car = null  # Reference to the car placed with this start flag

func _gui_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        # If piece is placed on grid, handle selection instead of drag
        if is_placed_on_grid:
            drag_allowed = false
            _toggle_selection()
            return
            
        # Check if click is within sprite bounds for dragging
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

# Toggle selection state of the piece
func _toggle_selection():
    is_selected = !is_selected
    
    if is_selected:
        # Visual feedback for selection (optional)
        modulate = Color(1.2, 1.2, 1.2, 1.0)  # Slightly brighter
        # Deselect other pieces (tell the grid to handle this)
        _notify_grid_of_selection()
    else:
        modulate = Color(1.0, 1.0, 1.0, 1.0)  # Normal color

# Deselect this piece (called by grid when another piece is selected)
func deselect():
    is_selected = false
    modulate = Color(1.0, 1.0, 1.0, 1.0)  # Normal color

# Notify grid of selection for deselecting other pieces
func _notify_grid_of_selection():
    var grid = get_tree().get_first_node_in_group("track_grid")
    if grid and grid.has_method("on_piece_selected"):
        grid.on_piece_selected(self)

# Disable drag functionality when placed on grid
func disable_drag_only():
    is_placed_on_grid = true
    # Keep mouse filter as PASS so selection can still work
    mouse_filter = Control.MOUSE_FILTER_PASS

# Set the associated car for this start flag
func set_associated_car(car: Car):
    associated_car = car

# Get the associated car
func get_associated_car() -> Car:
    return associated_car

# Remove the associated car
func remove_associated_car():
    if associated_car:
        associated_car.queue_free()
        associated_car = null
