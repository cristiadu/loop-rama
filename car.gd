extends Node2D
class_name Car

enum CarType {
  BLUE_RACER,
  GREEN_BEAST,
  PINK_LIGHTNING,
  RED_STORM
}

# Car options with stats
static var car_configs: Dictionary

static func _static_init():
  car_configs = {}
  
  # Blue Racer
  var blue_data = CarData.new()
  blue_data.name = "Blue Racer"
  blue_data.texture_path = "res://assets/images/cars/blue.png"
  blue_data.potency = 3  # Speed (1-5 stars)
  blue_data.traction = 4  # Stability (1-5 stars)
  car_configs[CarType.BLUE_RACER] = blue_data
  
  # Green Beast
  var green_data = CarData.new()
  green_data.name = "Green Beast"
  green_data.texture_path = "res://assets/images/cars/green.png"
  green_data.potency = 5  # High speed
  green_data.traction = 2  # Low stability
  car_configs[CarType.GREEN_BEAST] = green_data
  
  # Pink Lightning
  var pink_data = CarData.new()
  pink_data.name = "Pink Lightning"
  pink_data.texture_path = "res://assets/images/cars/pink.png"
  pink_data.potency = 4  # Good speed
  pink_data.traction = 3  # Medium stability
  car_configs[CarType.PINK_LIGHTNING] = pink_data
  
  # Red Storm
  var red_data = CarData.new()
  red_data.name = "Red Storm"
  red_data.texture_path = "res://assets/images/cars/red.png"
  red_data.potency = 2  # Lower speed
  red_data.traction = 5  # High stability
  car_configs[CarType.RED_STORM] = red_data

class CarData:
  var name: String
  var texture_path: String
  var potency: int
  var traction: int

class EffectiveStats:
  var speed: float
  var base_speed: float
  var stability: float
  var base_stability: float

var car_type: CarType
var car_data: CarData

func setup_car(type: CarType):
  car_type = type
  car_data = Car.car_configs[car_type]
  
  # Get the car sprite node directly
  var car_sprite = $CarSprite
  
  # Load and set the car texture
  var texture = load(car_data.texture_path)
  car_sprite.texture = texture
  
  # Scale appropriately for the context
  car_sprite.scale = Vector2(1, 1)

  return car_data

func get_car_name() -> String:
  return car_data.name

func get_speed() -> int:
  return car_data.potency

func get_traction() -> int:
  return car_data.traction

# Calculate car performance on different terrain types
func get_terrain_performance(terrain_type: TrackPiece.TerrainType) -> EffectiveStats:
  var base_speed = get_speed()
  var base_stability = get_traction()
  
  # Terrain modifiers (speed_modifier, stability_modifier)
  var modifier = TrackPiece.terrain_modifiers[terrain_type]
  
  var effective_stats = EffectiveStats.new()
  effective_stats.speed = base_speed * modifier.speed
  effective_stats.stability = base_stability * modifier.stability
  effective_stats.base_speed = base_speed
  effective_stats.base_stability = base_stability
  return effective_stats
