extends Node2D

@onready var tracks_menu = $UI/MainUI/MainContent/Menu/MenuBackground/MenuContent/ItemMenuTabs/Tracks
@onready var cars_menu = $UI/MainUI/MainContent/Menu/MenuBackground/MenuContent/ItemMenuTabs/Cars
@onready var speedometer = $UI/MainUI/MainContent/Menu/MenuBackground/MenuContent/SpeedometerContainer/Speedometer

func _ready():
    start_game()

func start_game():
    tracks_menu.generate_menu_options()
    cars_menu.generate_car_options()

func end_game():
    pass

# Get selected car for race
func get_selected_car():
    return cars_menu.get_selected_car_data()

# Check if race can start (car and track ready)
func can_start_race() -> bool:
    return cars_menu.selected_car != null

# Update speedometer based on current car and terrain
func update_speedometer_display(current_speed: float, terrain_type: TrackPiece.TerrainType = TrackPiece.TerrainType.ROAD):
  if speedometer and cars_menu.selected_car != null:
    # Create a Car instance to use with speedometer
    var car_instance = Car.new()
    car_instance.setup_car(cars_menu.selected_car)
    speedometer.update_speedometer(car_instance, terrain_type, current_speed)
