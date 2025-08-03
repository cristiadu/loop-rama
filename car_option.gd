extends Button
class_name CarOption

# Template scene for individual car options
# Dynamically instantiated by CarsMenu when needed

# Car scene reference
const CAR_SCENE = preload("res://car.tscn")

# Style reference from scene
@export var selected_style: StyleBoxFlat

var car_type: Car.CarType
var car_data: Car.CarData
var car_instance: Car
var is_selected: bool = false

signal car_option_selected(car_type: Car.CarType)

func setup_car_option(type: Car.CarType):
  car_type = type
  
  # Create car instance
  car_instance = CAR_SCENE.instantiate()
  car_data = car_instance.setup_car(type)
  car_instance.scale = Vector2(1.6, 1.6)  # Scale appropriately for menu
  
  # Get car container directly since @onready vars aren't ready yet
  var container = get_node("MarginContainer/HBoxContainer/CarImageContainer/CarContainer")
  container.add_child(car_instance)
  
  # Set car name
  var name_label = get_node("MarginContainer/HBoxContainer/InfoVBox/CarName")
  name_label.text = car_data.name
  
  # Update speed stars
  update_speed_stars(car_data.potency)
  
  # Update traction stars
  update_traction_stars(car_data.traction)

func update_speed_stars(rating: int):
  # Get speed stars directly since @onready vars aren't ready yet during setup
  var speed_stars = [
    get_node("MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar1"),
    get_node("MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar2"),
    get_node("MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar3"),
    get_node("MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar4"),
    get_node("MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar5")
  ]
  for i in range(5):
    var star = speed_stars[i]
    if i < rating:
      star.text = "★"
      star.modulate = Color.YELLOW
    else:
      star.text = "☆"
      star.modulate = Color.GRAY

func update_traction_stars(rating: int):
  # Get traction stars directly since @onready vars aren't ready yet during setup
  var traction_stars = [
    get_node("MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar1"),
    get_node("MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar2"),
    get_node("MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar3"),
    get_node("MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar4"),
    get_node("MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar5")
  ]
  for i in range(5):
    var star = traction_stars[i]
    if i < rating:
      star.text = "★"
      star.modulate = Color.CYAN
    else:
      star.text = "☆"
      star.modulate = Color.GRAY

func set_selected(selected: bool):
  is_selected = selected
  update_selection_appearance()

func update_selection_appearance():
  if is_selected:
    # Highlight selected car
    modulate = Color.LIGHT_BLUE
    # Use the selected style defined in scene
    add_theme_stylebox_override("normal", selected_style)
  else:
    # Normal appearance - revert to scene-defined style
    modulate = Color.WHITE
    remove_theme_stylebox_override("normal")

func _on_pressed():
  car_option_selected.emit(car_type)

func get_car_instance() -> Car:
  return car_instance

func _exit_tree():
  # Clean up car instance when option is destroyed
  if car_instance and is_instance_valid(car_instance):
    car_instance.queue_free()
