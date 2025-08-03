extends Control
class_name TrackPiece

const GRID_SIZE = 16

enum TrackPieceType {
    STRAIGHT,
    CURVE,
    S_SHAPED_ROAD,
}

enum TerrainType {
    DIRT,
    SAND,
    SNOW,
    ROAD,
    WET,
}

class TerrainModifier:
  var speed: float
  var stability: float
  
  func _init(speed_modifier: float, stability_modifier: float):
    speed = speed_modifier
    stability = stability_modifier

# Direct piece data fields
var piece_type: TrackPieceType
var terrain_type: TerrainType
var texture_path: String
var width_units: int  # Width in grid units (16px each)
var height_units: int # Height in grid units (16px each)
var current_rotation: int = 0 # Rotation in degrees (must be multiple of 90)

# Predefined track piece configurations
static var track_piece_configs: Dictionary = {
    TrackPieceType.STRAIGHT: {
        TerrainType.DIRT: {"path": "res://assets/images/tracks/straight_dirt.png", "width": 1, "height": 2},
        TerrainType.SAND: {"path": "res://assets/images/tracks/straight_sand.png", "width": 1, "height": 2},
        TerrainType.SNOW: {"path": "res://assets/images/tracks/straight_snow.png", "width": 1, "height": 2},
        TerrainType.ROAD: {"path": "res://assets/images/tracks/straight_road.png", "width": 1, "height": 2},
        TerrainType.WET: {"path": "res://assets/images/tracks/straight_wet.png", "width": 1, "height": 2},
    },
    TrackPieceType.CURVE: {
        TerrainType.DIRT: {"path": "res://assets/images/tracks/curve_dirt.png", "width": 2, "height": 2},
        TerrainType.SAND: {"path": "res://assets/images/tracks/curve_sand.png", "width": 2, "height": 2},
        TerrainType.SNOW: {"path": "res://assets/images/tracks/curve_snow.png", "width": 2, "height": 2},
        TerrainType.ROAD: {"path": "res://assets/images/tracks/curve_road.png", "width": 2, "height": 2},
        TerrainType.WET: {"path": "res://assets/images/tracks/curve_wet.png", "width": 2, "height": 2},
    },
    TrackPieceType.S_SHAPED_ROAD: {
        TerrainType.DIRT: {"path": "res://assets/images/tracks/s_dirt.png", "width": 4, "height": 4},
        TerrainType.SAND: {"path": "res://assets/images/tracks/s_sand.png", "width": 4, "height": 4},
        TerrainType.SNOW: {"path": "res://assets/images/tracks/s_snow.png", "width": 4, "height": 4},
        TerrainType.ROAD: {"path": "res://assets/images/tracks/s_road.png", "width": 4, "height": 4},
        TerrainType.WET: {"path": "res://assets/images/tracks/s_wet.png", "width": 4, "height": 4},
    },
}

# Terrain modifiers (speed_modifier, stability_modifier)
static var terrain_modifiers = {
  TerrainType.ROAD: TerrainModifier.new(1.0, 1.0),      # Best performance
  TerrainType.DIRT: TerrainModifier.new(0.8, 0.9),      # Slight reduction
  TerrainType.SAND: TerrainModifier.new(0.6, 0.7),      # Moderate reduction
  TerrainType.WET: TerrainModifier.new(0.7, 0.6),       # Slippery
  TerrainType.SNOW: TerrainModifier.new(0.5, 0.5)       # Challenging
}

@onready var track_piece_sprite: Sprite2D = $TrackPieceSprite

# Setup a random piece type and terrain.
func setup_random_piece():
  var random_piece_type = TrackPieceType.values()[randi() % TrackPieceType.size()]
  var random_terrain_type = TerrainType.values()[randi() % TerrainType.size()]
  setup_piece(random_piece_type, random_terrain_type)

# Initialize the track piece with type and terrain
func setup_piece(type: TrackPieceType, terrain: TerrainType, initial_rotation: int = 0):
    if not track_piece_configs.has(type):
        push_error("Track piece type not found: " + str(type))
        return false
    
    if not track_piece_configs[type].has(terrain):
        push_error("Terrain type not found for piece type " + str(type) + ": " + str(terrain))
        return false
    
    var config = track_piece_configs[type][terrain]
    piece_type = type
    terrain_type = terrain
    texture_path = config.path
    width_units = config.width
    height_units = config.height
    current_rotation = initial_rotation
    
    # Validate rotation (must be multiple of 90)
    if current_rotation % 90 != 0:
        push_warning("Rotation must be multiple of 90 degrees, rounding to nearest")
        current_rotation = round(current_rotation / 90.0) * 90
    
    _load_texture()
    _apply_rotation()
    _update_size()
    return true

# Helper methods for size calculations accounting for rotation
func get_actual_width() -> int:
    var rotated_size = get_rotated_size()
    return rotated_size.x * GRID_SIZE

func get_actual_height() -> int:
    var rotated_size = get_rotated_size()
    return rotated_size.y * GRID_SIZE

func get_rotated_size() -> Vector2i:
    # Return size considering current rotation
    if current_rotation % 180 == 0:
        return Vector2i(width_units, height_units)
    else:
        return Vector2i(height_units, width_units)

# Load texture from file path
func _load_texture():
    if texture_path.is_empty():
        return
    
    # Ensure sprite exists before trying to set texture
    if not track_piece_sprite:
        track_piece_sprite = get_node("TrackPieceSprite")
    
    if not track_piece_sprite:
        push_error("TrackPieceSprite node not found")
        return
    
    var texture = load(texture_path) as Texture2D
    if texture:
        track_piece_sprite.texture = texture
    else:
        push_error("Failed to load texture: " + texture_path)

# Apply rotation to the sprite
func _apply_rotation():
    # Normalize rotation to 0-359 range
    current_rotation = current_rotation % 360
    if current_rotation < 0:
        current_rotation += 360
    
    # Ensure sprite exists before trying to set rotation
    if not track_piece_sprite:
        track_piece_sprite = get_node("TrackPieceSprite")
    
    if track_piece_sprite:
        # Apply rotation to sprite
        track_piece_sprite.rotation_degrees = current_rotation

# Update the control size based on piece dimensions and rotation
func _update_size():
    var rotated_size = get_rotated_size()
    var actual_width = rotated_size.x * GRID_SIZE
    var actual_height = rotated_size.y * GRID_SIZE
    
    # Set the control size
    custom_minimum_size = Vector2(actual_width, actual_height)
    size = Vector2(actual_width, actual_height)
    
    # Ensure sprite exists before trying to position it
    if not track_piece_sprite:
        track_piece_sprite = get_node("TrackPieceSprite")
    
    # Center the sprite within the control bounds
    if track_piece_sprite:
        track_piece_sprite.position = Vector2(actual_width / 2.0, actual_height / 2.0)
    
    # Reposition rotation buttons if they exist and are visible
    var rotation_buttons = _get_rotation_buttons()
    if rotation_buttons and rotation_buttons.visible:
        call_deferred("_position_rotation_buttons", rotation_buttons)

# Rotate the piece by 90 degrees
func rotate_piece(direction: String = "RIGHT"):
    if direction == "LEFT":
        current_rotation -= 90
    else:  # RIGHT or default
        current_rotation += 90
    _apply_rotation()
    _update_size()
    
    # Reposition rotation buttons after size change
    var rotation_buttons = _get_rotation_buttons()
    if rotation_buttons and rotation_buttons.visible:
        call_deferred("_position_rotation_buttons", rotation_buttons)

# Set specific rotation
func set_piece_rotation(degrees: int):
    current_rotation = degrees
    _apply_rotation()
    _update_size()
    
    # Reposition rotation buttons after size change
    var rotation_buttons = _get_rotation_buttons()
    if rotation_buttons and rotation_buttons.visible:
        call_deferred("_position_rotation_buttons", rotation_buttons)

# Get current piece info
func get_piece_info() -> Dictionary:
    if texture_path.is_empty():
        return {}
    
    var rotated_size = get_rotated_size()
    return {
        "type": TrackPieceType.keys()[piece_type],
        "terrain": TerrainType.keys()[terrain_type],
        "texture_path": texture_path,
        "width_units": rotated_size.x,
        "height_units": rotated_size.y,
        "actual_width": rotated_size.x * GRID_SIZE,
        "actual_height": rotated_size.y * GRID_SIZE,
        "rotation": current_rotation
    }

# Static method to get available piece configurations
static func get_available_configurations() -> Dictionary:
    return track_piece_configs

# Static method to check if a piece type/terrain combination exists
static func has_configuration(type: TrackPieceType, terrain: TerrainType) -> bool:
    return track_piece_configs.has(type) and track_piece_configs[type].has(terrain)

func get_terrain_modifiers() -> TerrainModifier:
    return terrain_modifiers[terrain_type]

# Drag and drop functionality
func _ready():
    # Enable input but only drag when clicking on sprite
    mouse_filter = Control.MOUSE_FILTER_PASS
    
    # Ensure sprite is properly centered if piece was set up before ready
    if not texture_path.is_empty():
        _update_size()
    
    # Connect rotation buttons for all pieces (menu and placed)
    call_deferred("_connect_rotation_buttons")

var drag_allowed: bool = false
var is_placed_on_grid: bool = false
var is_selected: bool = false
var just_placed: bool = false

func _gui_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        # If piece is placed on grid, handle selection instead of drag
        if is_placed_on_grid:
            drag_allowed = false
            _toggle_selection()
            return
            
        # For drag detection, use sprite bounds to match the visual track piece
        if track_piece_sprite and track_piece_sprite.texture:
            # Calculate the sprite area within the control (sprite is centered)
            var sprite_size = track_piece_sprite.texture.get_size()
            var sprite_rect = Rect2(track_piece_sprite.position - sprite_size/2, sprite_size)
            if sprite_rect.has_point(event.position):
                drag_allowed = true
                # For menu pieces, show rotation buttons when clicked
                if not is_placed_on_grid:
                    _toggle_selection()
            else:
                drag_allowed = false
        else:
            # Fallback: use sprite-based dimensions if texture not available
            var rotated_size = get_rotated_size()
            var sprite_area_size = Vector2(rotated_size.x * GRID_SIZE, rotated_size.y * GRID_SIZE)
            var sprite_rect = Rect2((size - sprite_area_size) / 2, sprite_area_size)
            if sprite_rect.has_point(event.position):
                drag_allowed = true
                if not is_placed_on_grid:
                    _toggle_selection()
            else:
                drag_allowed = false
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        # Right click to rotate (for both menu and placed pieces)
        rotate_piece("RIGHT")

var original_parent = null

func _get_drag_data(position):
    if not drag_allowed or is_placed_on_grid:
        return null
    
    # Store original parent to check later
    original_parent = get_parent()
    
    # Create drag data with piece information
    # For menu pieces, get the option container
    var container = get_parent().get_parent()  # The root container (TrackPieceOption)
    var drag_data = {
        "type": "track_piece",
        "piece_info": get_piece_info(),
        "original_node": container,
        "track_piece_control": self  # Keep reference to the script node
    }
    
    # Create a simple drag preview 
    var preview = Control.new()
    preview.size = Vector2(32, 32)  # Small fixed size
    
    if track_piece_sprite and track_piece_sprite.texture:
        var preview_sprite = Sprite2D.new()
        preview_sprite.texture = track_piece_sprite.texture
        preview_sprite.rotation_degrees = current_rotation
        preview_sprite.position = Vector2(16, 16)  # Center in the small control
        preview_sprite.modulate = Color(1, 1, 1, 0.8)
        preview.add_child(preview_sprite)
    
    set_drag_preview(preview)
    
    # Hide the entire container during drag (keep it in menu until successful drop)
    container.visible = false
    
    return drag_data

# Disable drag functionality while keeping rotation buttons active
func disable_drag_only():
    is_placed_on_grid = true
    just_placed = true
    # Keep mouse filter as PASS so rotation buttons can still receive input
    mouse_filter = Control.MOUSE_FILTER_PASS
    
    # Show rotation buttons immediately after placement
    _show_rotation_buttons()
    
    # Auto-hide after a short delay unless selected
    var timer = get_tree().create_timer(3.0)  # 3 seconds
    timer.timeout.connect(_auto_hide_buttons)

# Toggle selection state of the piece
func _toggle_selection():
    is_selected = !is_selected
    just_placed = false  # Reset just_placed when manually selecting
    
    if is_selected:
        _show_rotation_buttons()
        # Deselect other pieces (tell the grid to handle this)
        _notify_grid_of_selection()
    else:
        _hide_rotation_buttons()

# Show rotation buttons
func _show_rotation_buttons():
    var rotation_buttons = _get_rotation_buttons()
    if rotation_buttons:
        rotation_buttons.visible = true
        # Position buttons after a frame to ensure size is set
        call_deferred("_position_rotation_buttons", rotation_buttons)

# Position rotation buttons dynamically based on piece size
func _position_rotation_buttons(rotation_buttons):
    if not rotation_buttons:
        return
    
    # Get the sprite to position relative to it
    if not track_piece_sprite:
        track_piece_sprite = get_node("TrackPieceSprite")
    
    if not track_piece_sprite or not track_piece_sprite.texture:
        return
    
    # Get sprite bounds (texture size)
    var texture_size = track_piece_sprite.texture.get_size()
    var sprite_pos = track_piece_sprite.position
    
    # Calculate sprite bounds (considering it's centered)
    var sprite_top_left = sprite_pos - texture_size / 2.0
    var sprite_top_right = Vector2(sprite_pos.x + texture_size.x / 2.0, sprite_pos.y - texture_size.y / 2.0)
    
    # Position buttons above the sprite, horizontally centered
    var button_width = 38
    var button_height = 20
    var vertical_spacing = 4  # Less spacing between sprite and buttons
    
    rotation_buttons.position = Vector2(sprite_pos.x - button_width / 2.0, sprite_top_left.y - button_height - vertical_spacing)
    rotation_buttons.size = Vector2(button_width, button_height)

# Hide rotation buttons
func _hide_rotation_buttons():
    var rotation_buttons = _get_rotation_buttons()
    if rotation_buttons:
        rotation_buttons.visible = false

# Get rotation buttons node
func _get_rotation_buttons():
    if has_node("RotationButtons"):
        return get_node("RotationButtons")
    return null

# Auto-hide buttons after delay if not selected (only for placed pieces)
func _auto_hide_buttons():
    if not is_selected and just_placed and is_placed_on_grid:
        _hide_rotation_buttons()
        just_placed = false

# Deselect this piece (called by grid when another piece is selected)
func deselect():
    is_selected = false
    just_placed = false
    _hide_rotation_buttons()

# Notify grid of selection for deselecting other pieces
func _notify_grid_of_selection():
    var grid = get_tree().get_first_node_in_group("track_grid")
    if grid and grid.has_method("on_piece_selected"):
        grid.on_piece_selected(self)

# Connect rotation buttons if they exist in the parent container
func _connect_rotation_buttons():
    # Connect rotation buttons for all pieces (menu and placed)
    if has_node("RotationButtons"):
        var rotation_buttons = get_node("RotationButtons")
        if rotation_buttons and rotation_buttons.has_method("set_track_piece"):
            rotation_buttons.set_track_piece(self)

# Handle drag cancellation (when drag is dropped outside valid area)
func _notification(what):
    if what == NOTIFICATION_DRAG_END:
        # Only show again if piece is still in original menu parent (drag was cancelled)
        var container = get_parent().get_parent()
        if container and get_parent() == original_parent:
            container.visible = true
