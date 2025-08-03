extends Control

func _draw():
	var grid_size = 16
	var grid_color = Color.WHITE
	grid_color.a = 0.6
	
	# Draw vertical lines every 16 pixels
	var x = 0
	while x <= size.x:
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 2.0)
		x += grid_size
	
	# Draw horizontal lines every 16 pixels  
	var y = 0
	while y <= size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 2.0)
		y += grid_size