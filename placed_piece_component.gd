extends Control
class_name PlacedPieceComponent

@export var piece_type: String
@export var piece_terrain: String  
@export var piece_rotation: int = 0
@export var grid_position: Vector2i
@export var width_units: int = 1
@export var height_units: int = 1

@onready var piece_sprite: Sprite2D = $PieceSprite

var piece_info: Dictionary

func _ready():
    # Disable drag for placed pieces (game rule)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    # Setup piece info for game logic
    setup_piece_info()

func setup_piece_info():
    piece_info = {
        "type": piece_type,
        "terrain": piece_terrain,
        "rotation": piece_rotation,
        "width_units": width_units,
        "height_units": height_units
    }

func configure_piece(type: String, terrain: String, rotation: int = 0):
    piece_type = type
    piece_terrain = terrain  
    piece_rotation = rotation
    
    # Set dimensions based on piece type
    match piece_type:
        "STRAIGHT":
            width_units = 1
            height_units = 2
        "CURVE", "S_SHAPED":
            width_units = 2
            height_units = 2
        _:
            width_units = 1
            height_units = 1
    
    setup_piece_info()

func get_piece_data() -> Dictionary:
    return {
        "node": self,
        "grid_position": grid_position,
        "piece_info": piece_info,
        "type": piece_type,
        "width_units": width_units,
        "height_units": height_units
    }
