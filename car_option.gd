extends Button
class_name CarOption

@onready var car_container = $MarginContainer/HBoxContainer/CarImageContainer/CarContainer
@onready var car_name_label = $MarginContainer/HBoxContainer/InfoVBox/CarName

# Speed star references
@onready var speed_star1 = $MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar1
@onready var speed_star2 = $MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar2
@onready var speed_star3 = $MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar3
@onready var speed_star4 = $MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar4
@onready var speed_star5 = $MarginContainer/HBoxContainer/InfoVBox/SpeedContainer/SpeedStars/SpeedStar5

# Traction star references
@onready var traction_star1 = $MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar1
@onready var traction_star2 = $MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar2
@onready var traction_star3 = $MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar3
@onready var traction_star4 = $MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar4
@onready var traction_star5 = $MarginContainer/HBoxContainer/InfoVBox/TractionContainer/TractionStars/TractionStar5

# Car scene reference
const CAR_SCENE = preload("res://car.tscn")

# Style reference from scene
@export var selected_style: StyleBoxFlat

var car_type: CarsMenu.CarType
var car_data: Dictionary
var car_instance: Car
var is_selected: bool = false

signal car_option_selected(car_type: CarsMenu.CarType)

func setup_car_option(type: CarsMenu.CarType, data: Dictionary):
  car_type = type
  car_data = data
  
  # Create car instance
  car_instance = CAR_SCENE.instantiate()
  car_instance.setup_car(type, data)
  car_instance.scale = Vector2(1.6, 1.6)  # Scale appropriately for menu
  car_container.add_child(car_instance)
  
  # Set car name
  car_name_label.text = data.name
  
  # Update speed stars
  update_speed_stars(data.potency)
  
  # Update traction stars
  update_traction_stars(data.traction)

func update_speed_stars(rating: int):
  var speed_stars = [speed_star1, speed_star2, speed_star3, speed_star4, speed_star5]
  for i in range(5):
    var star = speed_stars[i]
    if i < rating:
      star.text = "★"
      star.modulate = Color.YELLOW
    else:
      star.text = "☆"
      star.modulate = Color.GRAY

func update_traction_stars(rating: int):
  var traction_stars = [traction_star1, traction_star2, traction_star3, traction_star4, traction_star5]
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
