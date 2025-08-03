extends Button

@onready var game = get_node("../../../../..")

# Demo state for cycling through terrains
var demo_terrain_index = 0
var demo_terrains = [
  TrackPiece.TerrainType.ROAD,
  TrackPiece.TerrainType.DIRT, 
  TrackPiece.TerrainType.SAND,
  TrackPiece.TerrainType.WET,
  TrackPiece.TerrainType.SNOW
]

func _ready():
    # Connect the button press signal
    pressed.connect(_on_pressed)

func _on_pressed():
    # Check if car is selected
    if not game.can_start_race():
        print("Please select a car before starting the race!")
        return
    
    var selected_car = game.get_selected_car()
    print("Starting race with car: ", selected_car.name)
    print("Car stats - Speed: ", selected_car.potency, " Traction: ", selected_car.traction)
    
    # Demo: Cycle through different terrain types to test speedometer
    var current_terrain = demo_terrains[demo_terrain_index]
    var terrain_name = TrackPiece.TerrainType.keys()[current_terrain]
    print("Testing speedometer on terrain: ", terrain_name)
    
    game.update_speedometer_display(80.0, current_terrain)
    
    # Cycle to next terrain for next button press
    demo_terrain_index = (demo_terrain_index + 1) % demo_terrains.size()
    
    # TODO: Start the actual race with the selected car
    # This is where you would load the race scene and pass the car data
