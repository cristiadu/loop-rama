extends VBoxContainer

# Car data structure
class_name CarsMenu

enum CarType {
  BLUE_RACER,
  GREEN_BEAST,
  PINK_LIGHTNING,
  RED_STORM
}

# Car configuration with stats
var car_configs = {
  CarType.BLUE_RACER: {
    "name": "Blue Racer",
    "texture_path": "res://assets/images/cars/blue.png",
    "potency": 3,  # Speed (1-5 stars)
    "traction": 4  # Stability (1-5 stars)
  },
  CarType.GREEN_BEAST: {
    "name": "Green Beast", 
    "texture_path": "res://assets/images/cars/green.png",
    "potency": 5,  # High speed
    "traction": 2  # Low stability  
  },
  CarType.PINK_LIGHTNING: {
    "name": "Pink Lightning",
    "texture_path": "res://assets/images/cars/pink.png", 
    "potency": 4,  # Good speed
    "traction": 3  # Medium stability
  },
  CarType.RED_STORM: {
    "name": "Red Storm",
    "texture_path": "res://assets/images/cars/red.png",
    "potency": 2,  # Lower speed
    "traction": 5  # High stability
  }
}

# References to car option nodes in the scene
@onready var blue_racer_option: CarOption = $ScrollContainer/MarginContainer/CarsVBox/BlueRacerOption
@onready var green_beast_option: CarOption = $ScrollContainer/MarginContainer/CarsVBox/GreenBeastOption
@onready var pink_lightning_option: CarOption = $ScrollContainer/MarginContainer/CarsVBox/PinkLightningOption
@onready var red_storm_option: CarOption = $ScrollContainer/MarginContainer/CarsVBox/RedStormOption

# Selected car tracking
var selected_car: CarType = CarType.BLUE_RACER
var car_options: Array[CarOption] = []

# Signal for when car selection changes
signal car_selected(car_type: CarType)

func _ready():
  initialize_car_options()

func initialize_car_options():
  # Setup car options array
  car_options = [
    blue_racer_option,
    green_beast_option, 
    pink_lightning_option,
    red_storm_option
  ]
  
  # Initialize each car option with its data
  var car_types = CarType.values()
  for i in range(car_options.size()):
    var car_option = car_options[i]
    var car_type = car_types[i]
    var config = car_configs[car_type]
    
    # Setup the car option with data
    car_option.setup_car_option(car_type, config)
    
    # Connect the signal
    car_option.car_option_selected.connect(_on_car_selected)
  
  # Select first car by default
  update_selection_display()

func _on_car_selected(car_type: CarType):
  selected_car = car_type
  update_selection_display()
  car_selected.emit(car_type)
  print("Selected car: ", car_configs[car_type].name)

func update_selection_display():
  for car_option in car_options:
    var is_selected = car_option.car_type == selected_car
    car_option.set_selected(is_selected)

# Get current selected car data
func get_selected_car_data() -> Dictionary:
  return car_configs[selected_car]

# Get selected car instance for track placement
func get_selected_car_instance() -> Car:
  for car_option in car_options:
    if car_option.car_type == selected_car:
      return car_option.get_car_instance()
  return null

# Calculate car performance on different terrain types
func get_terrain_performance(terrain_type) -> Dictionary:
  var car_data = get_selected_car_data()
  var base_speed = car_data.potency
  var base_stability = car_data.traction
  
  # Terrain modifiers (speed_modifier, stability_modifier)
  var terrain_modifiers = {
    "ROAD": {"speed": 1.0, "stability": 1.0},      # Best performance
    "DIRT": {"speed": 0.8, "stability": 0.9},      # Slight reduction
    "SAND": {"speed": 0.6, "stability": 0.7},      # Moderate reduction
    "WET": {"speed": 0.7, "stability": 0.6},       # Slippery
    "SNOW": {"speed": 0.5, "stability": 0.5}       # Challenging
  }
  
  var modifier = terrain_modifiers.get(str(terrain_type), {"speed": 1.0, "stability": 1.0})
  
  return {
    "effective_speed": base_speed * modifier.speed,
    "effective_stability": base_stability * modifier.stability,
    "base_speed": base_speed,
    "base_stability": base_stability
  }
