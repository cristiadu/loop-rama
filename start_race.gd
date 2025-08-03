extends Button

@onready var game = get_node("../../../../..")

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
    
    # TODO: Start the actual race with the selected car
    # This is where you would load the race scene and pass the car data
