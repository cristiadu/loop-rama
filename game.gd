extends Node2D

@onready var tracks_menu = $UI/MainUI/MainContent/Menu/ItemMenuTabs/TracksMenu
@onready var cars_menu = $UI/MainUI/MainContent/Menu/ItemMenuTabs/CarsMenu

func _ready():
    start_game()

func start_game():
    tracks_menu.generate_track_piece_options()
    cars_menu.generate_car_options()

func end_game():
    pass

# Get selected car for race
func get_selected_car():
    return cars_menu.get_selected_car_data()

# Check if race can start (car and track ready)
func can_start_race() -> bool:
    return cars_menu.selected_car != null
