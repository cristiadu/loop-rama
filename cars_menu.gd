extends VBoxContainer

# Car data structure
class_name CarsMenu

# Reference to the container where car options will be added
@onready var cars_vbox: VBoxContainer = $ScrollContainer/MarginContainer/CarsVBox

# Car option scene reference
const CAR_OPTION_SCENE = preload("res://car_option.tscn")

# Selected car tracking
var selected_car: Car.CarType = Car.CarType.BLUE_RACER
var car_options: Array[CarOption] = []

# Signal for when car selection changes
signal car_selected(car_type: Car.CarType)

func generate_car_options():
  # Clear any existing car options
  for child in cars_vbox.get_children():
    child.queue_free()
  car_options.clear()
  
  # Create car option instances dynamically
  var car_types = Car.CarType.values()
  for car_type in car_types:
    var car_option = create_car_option(car_type)
    cars_vbox.add_child(car_option)
    car_options.append(car_option)
  
  # Select first car by default
  update_selection_display()

func create_car_option(car_type: Car.CarType) -> CarOption:
  # Instantiate the car option scene
  var car_option = CAR_OPTION_SCENE.instantiate() as CarOption
  
  # Setup the car option with data
  car_option.setup_car_option(car_type)
  
  # Connect the signal
  car_option.car_option_selected.connect(_on_car_selected)
  
  return car_option

func _on_car_selected(car_type: Car.CarType):
  selected_car = car_type
  update_selection_display()
  car_selected.emit(car_type)
  print("Selected car: ", Car.car_configs[car_type].name)

func update_selection_display():
  for car_option in car_options:
    var is_selected = car_option.car_type == selected_car
    car_option.set_selected(is_selected)

func update_selected_car_label():
  if selected_car_label and Car.car_configs.has(selected_car):
    var car_name = Car.car_configs[selected_car].name
    selected_car_label.text = "Selected Car: " + car_name

# Get current selected car data
func get_selected_car_data() -> Car.CarData:
  for car_option in car_options:
    if car_option.car_type == selected_car:
      return car_option.car_data
  return null

# Get selected car instance for track placement
func get_selected_car_instance() -> Car:
  for car_option in car_options:
    if car_option.car_type == selected_car:
      return car_option.get_car_instance()
  return null

# Reload car options (useful for updates or changes)
func reload_car_options():
  generate_car_options()

# Clean up when the menu is destroyed
func _exit_tree():
  for car_option in car_options:
    if is_instance_valid(car_option):
      car_option.queue_free()
  car_options.clear()
