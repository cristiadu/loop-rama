extends Control
class_name GridOverlay

# RTS-style grid overlay system for track pieces
# 
# This overlay provides visual feedback during drag operations:
# - Shows grid lines only when dragging pieces over the grid
# - Displays a light blue preview of where pieces would be positioned
# - Automatically hides when drag ends or mouse exits the grid
# 
# Replaces the always-visible grid lines for a cleaner, more intuitive interface

const GRID_SIZE = 16

# Style configuration - set in scene file
@export var grid_line_color: Color
@export var grid_line_opacity: float
@export var grid_line_width: float
@export var preview_fill_color: Color
@export var preview_fill_opacity: float
@export var preview_border_color: Color
@export var preview_border_opacity: float
@export var preview_border_width: float

var is_showing_overlay: bool = false
var current_drag_data = null
var preview_position: Vector2i = Vector2i(-1, -1)

func _ready():
	# Initially hidden
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw():
	if not is_showing_overlay or not current_drag_data:
		return
	
	# Draw grid lines with light opacity
	_draw_grid_lines()
	
	# Draw preview overlay for piece position
	if preview_position != Vector2i(-1, -1):
		_draw_piece_preview()

func _draw_grid_lines():
	var grid_color = grid_line_color
	grid_color.a = grid_line_opacity
	
	# Draw vertical lines every 16 pixels
	var x = 0
	while x <= size.x:
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, grid_line_width)
		x += GRID_SIZE
	
	# Draw horizontal lines every 16 pixels  
	var y = 0
	while y <= size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, grid_line_width)
		y += GRID_SIZE

func _draw_piece_preview():
	if not current_drag_data:
		return
		
	var piece_info = current_drag_data.get("piece_info", {})
	if piece_info.is_empty():
		return
	
	var width_units = piece_info.get("width_units", 1)
	var height_units = piece_info.get("height_units", 1)
	
	# Calculate pixel position and size
	var pixel_pos = Vector2(preview_position.x * GRID_SIZE, preview_position.y * GRID_SIZE)
	var pixel_size = Vector2(width_units * GRID_SIZE, height_units * GRID_SIZE)
	
	# Draw semi-transparent fill overlay
	var fill_color = preview_fill_color
	fill_color.a = preview_fill_opacity
	draw_rect(Rect2(pixel_pos, pixel_size), fill_color)
	
	# Draw border around the preview area
	var border_color = preview_border_color
	border_color.a = preview_border_opacity
	draw_rect(Rect2(pixel_pos, pixel_size), border_color, false, preview_border_width)

func show_overlay_with_drag_data(drag_data):
	current_drag_data = drag_data
	is_showing_overlay = true
	visible = true
	queue_redraw()

func hide_overlay():
	current_drag_data = null
	is_showing_overlay = false
	visible = false
	preview_position = Vector2i(-1, -1)
	queue_redraw()

func update_preview_position(grid_pos: Vector2i, can_drop: bool):
	if can_drop:
		preview_position = grid_pos
	else:
		preview_position = Vector2i(-1, -1)
	queue_redraw()

# Calculate grid position from screen position (relative to this overlay)
# Note: This matches the calculation in TrackGrid._calculate_grid_position
func calculate_grid_position(screen_pos: Vector2) -> Vector2i:
	var local_pos = screen_pos
	var grid_x = int(local_pos.x / GRID_SIZE)
	var grid_y = int(local_pos.y / GRID_SIZE)
	return Vector2i(grid_x, grid_y)