extends Control

@onready var rotate_left_button: Button = $ButtonsContainer/RotateLeftButton
@onready var rotate_right_button: Button = $ButtonsContainer/RotateRightButton

var track_piece: TrackPiece

func _ready():
	rotate_left_button.pressed.connect(_on_rotate_left_pressed)
	rotate_right_button.pressed.connect(_on_rotate_right_pressed)

func set_track_piece(piece: TrackPiece):
	track_piece = piece

func _on_rotate_left_pressed():
	if track_piece:
		track_piece.rotate_piece("LEFT")

func _on_rotate_right_pressed():
	if track_piece:
		track_piece.rotate_piece("RIGHT")