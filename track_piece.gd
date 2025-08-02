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
    SNOW,
    ROAD,
    WET,
}

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
        TerrainType.SNOW: {"path": "res://assets/images/tracks/straight_snow.png", "width": 1, "height": 2},
        TerrainType.ROAD: {"path": "res://assets/images/tracks/straight_road.png", "width": 1, "height": 2},
        TerrainType.WET: {"path": "res://assets/images/tracks/straight_wet.png", "width": 1, "height": 2},
    },
    TrackPieceType.CURVE: {
        TerrainType.DIRT: {"path": "res://assets/images/tracks/curve_dirt.png", "width": 2, "height": 2},
        TerrainType.SNOW: {"path": "res://assets/images/tracks/curve_snow.png", "width": 2, "height": 2},
        TerrainType.ROAD: {"path": "res://assets/images/tracks/curve_road.png", "width": 2, "height": 2},
        TerrainType.WET: {"path": "res://assets/images/tracks/curve_wet.png", "width": 2, "height": 2},
    },
    TrackPieceType.S_SHAPED_ROAD: {
        TerrainType.DIRT: {"path": "res://assets/images/tracks/s_shaped_road_dirt.png", "width": 2, "height": 2},
        TerrainType.SNOW: {"path": "res://assets/images/tracks/s_shaped_road_snow.png", "width": 2, "height": 2},
        TerrainType.ROAD: {"path": "res://assets/images/tracks/s_shaped_road_road.png", "width": 2, "height": 2},
        TerrainType.WET: {"path": "res://assets/images/tracks/s_shaped_road_wet.png", "width": 2, "height": 2},
    },
}

@onready var track_piece_sprite: Sprite2D = $TrackPieceSprite

# Setup a random piece type and terrain.
func setup_random_piece():
  var piece_type = TrackPieceType.values()[randi() % TrackPieceType.size()]
  var terrain_type = TerrainType.values()[randi() % TerrainType.size()]
  setup_piece(piece_type, terrain_type)

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

# Helper methods for size calculations
func get_actual_width() -> int:
    return width_units * GRID_SIZE

func get_actual_height() -> int:
    return height_units * GRID_SIZE

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
    if texture_path.is_empty():
        return {}
    
    var rotated_size = get_rotated_size()
    return {
        "type": piece_type,
        "terrain": terrain_type,
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

func _ready():
    pass