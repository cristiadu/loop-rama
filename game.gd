extends Node2D

@onready var tracks_menu = $UI/MainUI/MainContent/Menu/ItemMenuTabs/TracksMenu

func _ready():
    start_game()

func start_game():
  tracks_menu.generate_track_piece_options()

func end_game():
    pass
