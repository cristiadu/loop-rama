extends VBoxContainer

@onready var track_piece_scene = preload("res://track_piece.tscn")

const INITIAL_TRACK_PIECE_COUNT = 10


func generate_track_piece_options():
  # Call track piece scene to generate a random track piece.
  for i in INITIAL_TRACK_PIECE_COUNT:
    var track_piece = track_piece_scene.instantiate()
    track_piece.setup_random_piece()
    add_child(track_piece)

func _ready():
  pass