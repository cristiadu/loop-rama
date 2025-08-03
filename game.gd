extends Node2D

@onready var tracks_menu = $UI/MainUI/MainContent/Menu/MenuBackground/MenuContent/ItemMenuTabs/Tracks
@onready var cars_menu = $UI/MainUI/MainContent/Menu/MenuBackground/MenuContent/ItemMenuTabs/Cars
@onready var speedometer = $UI/MainUI/MainContent/Menu/MenuBackground/MenuContent/SpeedometerContainer/Speedometer
@onready var selected_car_label = $UI/MainUI/SelectedCarDisplay/SelectedCarLabel
@onready var selected_car_name = $UI/MainUI/SelectedCarDisplay/SelectedCarName
@onready var selected_car_sprite_container = $UI/MainUI/SelectedCarDisplay/SelectedCarSprite

var current_car_sprite: Car

func _ready():
    # Add to group so other nodes can find this game node
    add_to_group("game")
    start_game()

func start_game():
    tracks_menu.generate_menu_options()
    cars_menu.generate_car_options()
    
    # Connect to car selection signal
    cars_menu.car_selected.connect(_on_car_selected)
    
    # Initialize the selected car display
    update_selected_car_display()

func end_game():
    pass

# Get selected car for race
func get_selected_car():
    return cars_menu.get_selected_car_data()

# Check if race can start (car and track ready)
func can_start_race() -> bool:
    return cars_menu.selected_car != null

# Handle car selection change
func _on_car_selected(car_type: Car.CarType):
    update_selected_car_display()

# Update the selected car display in the grass area
func update_selected_car_display():
    if selected_car_name and cars_menu.selected_car != null:
        # Update car name text only
        var car_name = Car.car_configs[cars_menu.selected_car].name
        selected_car_name.text = car_name
        
        # Update car sprite
        update_selected_car_sprite()

# Update the car sprite display
func update_selected_car_sprite():
    # Clear existing sprite
    if current_car_sprite:
        current_car_sprite.queue_free()
        current_car_sprite = null
    
    # Create new car sprite
    const CAR_SCENE = preload("res://car.tscn")
    current_car_sprite = CAR_SCENE.instantiate()
    current_car_sprite.setup_car(cars_menu.selected_car)
    current_car_sprite.scale = Vector2(1.5, 1.5)  # Bigger size for better visibility
    current_car_sprite.position = Vector2(30, 30)  # Center in the 60x60 container
    selected_car_sprite_container.add_child(current_car_sprite)

# Update speedometer based on current car and terrain
func update_speedometer_display(current_speed: float, terrain_type: TrackPiece.TerrainType = TrackPiece.TerrainType.ROAD):
  if speedometer and cars_menu.selected_car != null:
    # Create a Car instance to use with speedometer
    var car_instance = Car.new()
    car_instance.setup_car(cars_menu.selected_car)
    speedometer.update_speedometer(car_instance, terrain_type, current_speed)
