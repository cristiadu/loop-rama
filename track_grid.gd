extends Control
class_name TrackGrid

const GRID_SIZE = 16

@onready var track_grid: Control = $TrackGrid
@onready var grid_overlay: GridOverlay = $TrackGrid/GridOverlay

# Track pieces that have been placed
var placed_pieces: Array[Dictionary] = []
var start_flag_placed: bool = false

func _ready():
    # Setup game logic only - layout is handled by scene
    setup_drop_functionality()
    # Add to group so track pieces can find this grid
    add_to_group("track_grid")

func setup_drop_functionality():
    # Enable drop functionality for game logic
    mouse_filter = Control.MOUSE_FILTER_PASS
    
    # Ensure the track area can receive drops
    if track_grid:
        track_grid.mouse_filter = Control.MOUSE_FILTER_PASS
    
    # Connect mouse signals for overlay management
    mouse_exited.connect(_on_mouse_exited)

# Check if data can be dropped here
func _can_drop_data(drop_position: Vector2, data) -> bool:
    # Accept any track piece or start flag data
    if not data is Dictionary:
        _hide_overlay()
        return false
    
    var piece_type = data.get("type", "")
    if piece_type != "track_piece" and piece_type != "start_flag_piece":
        _hide_overlay()
        return false
    
    # Get piece info and calculate grid position
    var piece_info = data.get("piece_info", {})
    if piece_info.is_empty():
        _hide_overlay()
        return false
    
    # Show overlay if not already showing
    if grid_overlay and not grid_overlay.is_showing_overlay:
        grid_overlay.show_overlay_with_drag_data(data)
    
    # Calculate grid position from drop position, centered on the piece
    var grid_pos = _calculate_grid_position(drop_position, piece_info)
    
    # Check if piece fits within grid bounds (including its full size)
    var fits_in_grid = _piece_fits_in_grid(grid_pos, piece_info)
    var has_space = _has_space_for_piece(grid_pos, piece_info)
    var start_flag_ok = true
    
    # Special check for start flag - only one allowed
    if piece_type == "start_flag_piece" and start_flag_placed:
        start_flag_ok = false
    
    var can_drop = fits_in_grid and has_space and start_flag_ok
    
    # Update overlay preview position
    if grid_overlay:
        grid_overlay.update_preview_position(grid_pos, can_drop)
    
    return can_drop

# Handle data being dropped
func _drop_data(drop_position: Vector2, data):
    # Hide overlay when drop happens
    _hide_overlay()
    
    var piece_type = data.get("type", "")
    var piece_info = data.get("piece_info", {})
    
    # Validate piece info
    if piece_info.is_empty():
        return
    
    # Calculate grid position and snap to grid, centered on the piece
    var grid_pos = _calculate_grid_position(drop_position, piece_info)
    var snap_position = Vector2(grid_pos.x * GRID_SIZE, grid_pos.y * GRID_SIZE)
    
    # Get the original track piece control from the dragged data
    var track_piece_control = data.get("track_piece_control")
    if track_piece_control == null:
        return
    
    # Create a new TrackPiece instance for the grid (with rotation buttons)
    var track_piece_scene = preload("res://track_piece.tscn")
    var new_track_piece_container = track_piece_scene.instantiate()
    var new_track_piece_control = new_track_piece_container.get_node("TrackPieceContainer/TrackPieceControl")
    
    # Set up the new piece with the same configuration as the original
    new_track_piece_control.setup_piece(
        track_piece_control.piece_type,
        track_piece_control.terrain_type,
        track_piece_control.current_rotation
    )
    
    # Add to grid and position
    track_grid.add_child(new_track_piece_container)
    new_track_piece_container.position = snap_position
    
    # Remove the original from menu (since drag was successful)
    var original_container = data.get("original_node")
    if original_container and original_container.get_parent():
        original_container.get_parent().remove_child(original_container)
        original_container.queue_free()
    
    # Disable drag for placed pieces but allow rotation button interaction
    if new_track_piece_control.has_method("disable_drag_only"):
        new_track_piece_control.disable_drag_only()
    else:
        # Fallback: set mouse filter but this might block rotation buttons
        new_track_piece_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    # Use the new track piece control for further operations
    track_piece_control = new_track_piece_control
    
    # Track the placed piece with grid information using actual dimensions
    var width_units = piece_info.get("width_units", 1)
    var height_units = piece_info.get("height_units", 1)
    
    # Use sprite-based dimensions from the piece if available (accounts for rotation)
    if track_piece_control.has_method("get_rotated_size"):
        var rotated_size = track_piece_control.get_rotated_size()
        width_units = rotated_size.x
        height_units = rotated_size.y
    
    var placed_piece_data = {
        "node": new_track_piece_container,
        "track_piece_control": track_piece_control,
        "grid_position": grid_pos,
        "pixel_position": snap_position,
        "piece_info": piece_info,
        "type": piece_type,
        "width_units": width_units,
        "height_units": height_units
    }
    placed_pieces.append(placed_piece_data)
    
    # Update start flag tracking
    if piece_type == "start_flag_piece":
        start_flag_placed = true
    
    pass

# Calculate grid position from screen position, centered on the piece
func _calculate_grid_position(screen_pos: Vector2, piece_info: Dictionary = {}) -> Vector2i:
    # Convert screen position directly to grid coordinates within the track area
    var local_pos = screen_pos - global_position - track_grid.position
    
    # Get piece dimensions for centering
    var width_units = piece_info.get("width_units", 1)
    var height_units = piece_info.get("height_units", 1)
    
    # Calculate grid coordinates and center the piece on the mouse cursor
    var grid_x = int((local_pos.x - (width_units * GRID_SIZE) / 2.0) / GRID_SIZE)
    var grid_y = int((local_pos.y - (height_units * GRID_SIZE) / 2.0) / GRID_SIZE)
    
    return Vector2i(grid_x, grid_y)

# Check if piece fits completely within grid bounds
func _piece_fits_in_grid(grid_pos: Vector2i, piece_info: Dictionary) -> bool:
    # Use the exact same dimensions that the preview system uses
    var width_units = piece_info.get("width_units", 1)
    var height_units = piece_info.get("height_units", 1)
    
    # Get grid dimensions
    var grid_rect = track_grid.get_rect()
    var max_x = int(grid_rect.size.x / GRID_SIZE)
    var max_y = int(grid_rect.size.y / GRID_SIZE)
    
    # Check if starting position is valid
    if grid_pos.x < 0 or grid_pos.y < 0:
        return false
    
    # Check if piece extends beyond grid boundaries
    if (grid_pos.x + width_units) > max_x or (grid_pos.y + height_units) > max_y:
        return false
    
    return true

# Check if there's space for the piece at the given position
func _has_space_for_piece(grid_pos: Vector2i, piece_info: Dictionary) -> bool:
    # Use the exact same dimensions that the preview system uses
    var width_units = piece_info.get("width_units", 1)
    var height_units = piece_info.get("height_units", 1)
    
    # Prevent overlapping but allow adjacent placement
    for placed_piece in placed_pieces:
        var placed_pos = placed_piece.get("grid_position", Vector2i(0, 0))
        
        # Use actual dimensions from the placed piece if available
        var placed_width = placed_piece.get("width_units", 1)
        var placed_height = placed_piece.get("height_units", 1)
        
        # Get the track piece control for dimension calculations
        var track_piece_control = placed_piece.get("track_piece_control")
        if track_piece_control and track_piece_control.has_method("get_rotated_size"):
            # Use the sprite-based dimensions, not control dimensions which may include button padding
            var rotated_size = track_piece_control.get_rotated_size()
            placed_width = rotated_size.x
            placed_height = rotated_size.y
        
        # Check for actual rectangle overlap - prevent any overlapping but allow touching edges
        if _grid_rectangles_overlap(
            grid_pos, Vector2i(width_units, height_units),
            placed_pos, Vector2i(placed_width, placed_height)
        ):
            return false
    
    return true

# Check if two grid rectangles overlap (battleship-style collision)
func _grid_rectangles_overlap(pos1: Vector2i, size1: Vector2i, pos2: Vector2i, size2: Vector2i) -> bool:
    # Rectangle 1: from pos1 to (pos1 + size1 - 1)
    # Rectangle 2: from pos2 to (pos2 + size2 - 1)
    
    var r1_left = pos1.x
    var r1_right = pos1.x + size1.x - 1
    var r1_top = pos1.y  
    var r1_bottom = pos1.y + size1.y - 1
    
    var r2_left = pos2.x
    var r2_right = pos2.x + size2.x - 1
    var r2_top = pos2.y
    var r2_bottom = pos2.y + size2.y - 1
    
    # Check if rectangles DON'T overlap, then negate
    var no_overlap = (r1_right < r2_left or r2_right < r1_left or 
                     r1_bottom < r2_top or r2_bottom < r1_top)
    
    return not no_overlap

# Check if two rectangles overlap
func _rectangles_overlap(pos1: Vector2i, size1: Vector2i, pos2: Vector2i, size2: Vector2i) -> bool:
    return not (pos1.x >= pos2.x + size2.x or 
                pos2.x >= pos1.x + size1.x or 
                pos1.y >= pos2.y + size2.y or 
                pos2.y >= pos1.y + size1.y)

# Move piece from menu to track at specified grid position
func move_piece_to_track(piece_node: Control, grid_pos: Vector2i):
    # Remove from current parent (menu)
    var current_parent = piece_node.get_parent()
    if current_parent:
        current_parent.remove_child(piece_node)
    
    # Add to track grid
    track_grid.add_child(piece_node)
    
    # Position using grid coordinates with actual piece dimensions
    var pixel_pos = Vector2(grid_pos.x * GRID_SIZE, grid_pos.y * GRID_SIZE)
    
    # Position the piece at grid-aligned coordinates
    piece_node.position = pixel_pos
    
    # Disable drag for placed pieces but allow rotation button interaction
    if piece_node.has_method("disable_drag_only"):
        piece_node.disable_drag_only()
    else:
        # Fallback: disable interaction completely
        piece_node.mouse_filter = Control.MOUSE_FILTER_IGNORE



# Remove a piece from the track (if needed for editing)
func remove_piece(piece_node: Control):
    for i in range(placed_pieces.size()):
        if placed_pieces[i].node == piece_node:
            var piece_data = placed_pieces[i]
            
            # Update start flag tracking
            if piece_data.type == "start_flag_piece":
                start_flag_placed = false
            
            # Remove from tracking
            placed_pieces.remove_at(i)
            
            # Remove from scene
            piece_node.queue_free()
            break

# Get all placed pieces
func get_placed_pieces() -> Array[Dictionary]:
    return placed_pieces

# Handle piece selection - deselect all other pieces
func on_piece_selected(selected_piece):
    for placed_piece in placed_pieces:
        var track_piece_control = placed_piece.get("track_piece_control")
        if track_piece_control and track_piece_control != selected_piece and track_piece_control.has_method("deselect"):
            track_piece_control.deselect()

# Check if track has required pieces for racing
func is_track_ready_for_race() -> bool:
    # Basic validation - need at least a start flag
    return start_flag_placed

# Hide the grid overlay
func _hide_overlay():
    if grid_overlay:
        grid_overlay.hide_overlay()

# Handle when drag enters the grid area
func _notification(what):
    if what == NOTIFICATION_DRAG_END:
        # Hide overlay when drag ends (either dropped or cancelled)
        _hide_overlay()

# Hide overlay when mouse exits grid during drag
func _on_mouse_exited():
    # Only hide if we're currently showing overlay (during a drag)
    if grid_overlay and grid_overlay.is_showing_overlay:
        _hide_overlay()
