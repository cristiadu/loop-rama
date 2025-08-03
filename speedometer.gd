extends Control

enum SpeedState {
	LOSING_SPEED,
	KEEPING_SPEED,
	GAINING_SPEED
}

@onready var speedometer_sprite: Sprite2D = $SpeedometerSprite
@onready var speed_label: Label = $SpeedLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_speed: float = 0.0
var current_state: SpeedState = SpeedState.KEEPING_SPEED

func _ready():
	# Initialize the speedometer
	set_speed_state(SpeedState.KEEPING_SPEED)
	update_speed_display(0)

func set_speed_state(new_state: SpeedState):
	if current_state == new_state:
		return
		
	current_state = new_state
	
	match current_state:
		SpeedState.LOSING_SPEED:
			animation_player.play("losing_speed")
		SpeedState.KEEPING_SPEED:
			animation_player.play("keeping_speed")
		SpeedState.GAINING_SPEED:
			animation_player.play("gaining_speed")

func update_speed_display(speed: float):
	current_speed = speed
	speed_label.text = str(int(speed))

func calculate_speed_state(car: Car, terrain_type: TrackPiece.TerrainType) -> SpeedState:
	# Use the existing car system to get terrain performance
	var effective_stats = car.get_terrain_performance(terrain_type)
	
	# Calculate performance ratios compared to base stats
	var speed_ratio = effective_stats.speed / effective_stats.base_speed
	var stability_ratio = effective_stats.stability / effective_stats.base_stability
	
	# Determine speed state based on terrain performance
	# Road terrain (1.0, 1.0) = neutral/keeping speed
	# Better than road = gaining speed
	# Worse than road = losing speed
	
	var performance_factor = (speed_ratio + stability_ratio) / 2.0
	
	if performance_factor > 1.0:
		return SpeedState.GAINING_SPEED
	elif performance_factor < 0.8:  # Significant performance loss
		return SpeedState.LOSING_SPEED
	else:
		return SpeedState.KEEPING_SPEED

# Public interface for external systems
func update_speedometer(car: Car, terrain_type: TrackPiece.TerrainType, new_speed: float):
	var new_state = calculate_speed_state(car, terrain_type)
	set_speed_state(new_state)
	update_speed_display(new_speed)

# Debug function to test different car/terrain combinations
func demo_terrain_effects():
	print("\n=== Speedometer Terrain Effects Demo ===")
	
	var car_types = [Car.CarType.BLUE_RACER, Car.CarType.GREEN_BEAST, Car.CarType.RED_STORM]
	var terrain_types = [TrackPiece.TerrainType.ROAD, TrackPiece.TerrainType.SAND, TrackPiece.TerrainType.SNOW]
	
	for car_type in car_types:
		var car = Car.new()
		car.setup_car(car_type)
		print("\n", car.get_car_name(), " (Speed:", car.get_speed(), " Traction:", car.get_traction(), ")")
		
		for terrain_type in terrain_types:
			var state = calculate_speed_state(car, terrain_type)
			var effective_stats = car.get_terrain_performance(terrain_type)
			var terrain_name = TrackPiece.TerrainType.keys()[terrain_type]
			print("  ", terrain_name, ": ", SpeedState.keys()[state], " (Effective Speed:", effective_stats.speed, " Stability:", effective_stats.stability, ")")