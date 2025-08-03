extends VBoxContainer

@onready var track_piece_scene = preload("res://track_piece_option.tscn")
@onready var start_flag_piece_scene = preload("res://start_flag_piece.tscn")
@onready var grid_container: GridContainer = $ScrollContainer/MarginContainer/GridContainer

const INITIAL_TRACK_PIECE_COUNT = 15

# Generate menu options using scene-based approach
func generate_menu_options():
    # Clear existing options
    clear_menu()
    
    # Generate track piece options
    for i in INITIAL_TRACK_PIECE_COUNT:
        create_track_piece_option()
    
    # Add start flag option
    create_start_flag_option()

func create_track_piece_option():
    var track_piece_container = track_piece_scene.instantiate()
    grid_container.add_child(track_piece_container)
    var track_piece = track_piece_container.get_node("TrackPiece/TrackPieceControl")
    track_piece.setup_random_piece()

# Create a track piece option with specific configuration
func create_specific_track_piece_option(piece_type: TrackPiece.TrackPieceType, terrain_type: TrackPiece.TerrainType, rotation: int = 0):
    var track_piece_container = track_piece_scene.instantiate()
    grid_container.add_child(track_piece_container)
    var track_piece = track_piece_container.get_node("TrackPiece/TrackPieceControl")
    track_piece.setup_piece(piece_type, terrain_type, rotation)

func create_start_flag_option():
    var start_flag_container = start_flag_piece_scene.instantiate()
    grid_container.add_child(start_flag_container)
    var start_flag_piece = start_flag_container.get_node("StartFlagControl")
    start_flag_piece.setup_start_flag_piece()

func clear_menu():
    for child in grid_container.get_children():
        child.queue_free()
