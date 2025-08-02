extends Node2D
class_name Car

var car_type: CarsMenu.CarType
var car_data: Dictionary

func setup_car(type: CarsMenu.CarType, data: Dictionary):
  car_type = type
  car_data = data
  
  # Get the car sprite node directly
  var car_sprite = $CarSprite
  
  # Load and set the car texture
  var texture = load(data.texture_path)
  car_sprite.texture = texture
  
  # Scale appropriately for the context
  car_sprite.scale = Vector2(1.5, 1.5)

func get_car_name() -> String:
  return car_data.get("name", "Unknown Car")

func get_speed() -> int:
  return car_data.get("potency", 1)

func get_traction() -> int:
  return car_data.get("traction", 1)
