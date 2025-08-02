extends VBoxContainer

@onready var track_piece_scene = preload("res://track_piece.tscn")
@onready var grid_container: GridContainer = $ScrollContainer/MarginContainer/GridContainer

const INITIAL_TRACK_PIECE_COUNT = 10

func _ready():
  generate_track_piece_options()

func generate_track_piece_options():
  # Call track piece scene to generate track pieces in a grid layout
  for i in INITIAL_TRACK_PIECE_COUNT:
    var track_piece = track_piece_scene.instantiate()
    
    # Make sure pieces are clickable/draggable
    track_piece.mouse_filter = Control.MOUSE_FILTER_PASS
    
    grid_container.add_child(track_piece)
    track_piece.setup_random_piece()
    
    # Connect signals for drag and drop functionality (to be implemented later)
    # track_piece.gui_input.connect(_on_track_piece_input.bind(track_piece))