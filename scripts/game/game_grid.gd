class_name GameBoard
extends Control

signal swap_completed(valid: bool)

@export_group("Board Settings")
@export var rows: int = 9
@export var columns: int = 9

@export_group("Piece Settings")
@export var piece_size: Vector2 = Vector2(64, 64)
@export var horizontal_spacing: float = 12.0
@export var vertical_spacing: float = 13.0

@export var min_drag_distance: float = 40.0

var grid: Array[Array] = []
var is_swapping: bool = false

var drag_start_row: int = -1
var drag_start_col: int = -1
var drag_start_pos: Vector2 = Vector2.ZERO
var dragged_piece: Piece = null

@onready var match_detector: MatchDetector = $MatchDetector
@onready var fx_layer: FXLayer = $FxLayer

func _ready():
	initialize_board()

# ---------------------------------------------------------------------------
# Inicialización
# ---------------------------------------------------------------------------

func initialize_board() -> void:
	clear_board()
	grid.resize(rows)
	for row in rows:
		grid[row] = []
		grid[row].resize(columns)
	generate_initial_pieces()
	update_board_size()
	call_deferred("_resolve_initial_matches")

func _resolve_initial_matches() -> void:
	var matches = match_detector.check_and_emit(grid, rows, columns)
	if matches.size() > 0:
		await process_matches(matches)

func clear_board() -> void:
	for child in get_children():
		if child is Piece:
			child.queue_free()
	grid.clear()

func generate_initial_pieces() -> void:
	for row in rows:
		for col in columns:
			create_piece_at(row, col)

func create_piece_at(row: int, col: int) -> Piece:
	var piece = Piece.new()
	var random_type = Piece.PieceType.values()[randi() % Piece.PieceType.size()]

	piece.custom_minimum_size = piece_size
	piece.size = piece_size
	piece.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(piece)
	piece.setup(random_type)
	position_piece(piece, row, col)

	grid[row][col] = piece
	return piece

func position_piece(piece: Piece, row: int, col: int) -> void:
	piece.position = get_screen_pos(row, col)

func update_board_size() -> void:
	var total_width = columns * piece_size.x + (columns - 1) * horizontal_spacing
	var total_height = rows * piece_size.y + (rows - 1) * vertical_spacing
	custom_minimum_size = Vector2(total_width, total_height)

# ---------------------------------------------------------------------------
# Utilidades de grid
# ---------------------------------------------------------------------------

func get_piece_at(row: int, col: int) -> Piece:
	if is_valid_position(row, col):
		return grid[row][col]
	return null

func is_valid_position(row: int, col: int) -> bool:
	return row >= 0 and row < rows and col >= 0 and col < columns

func get_screen_pos(row: int, col: int) -> Vector2:
	return Vector2(
		col * (piece_size.x + horizontal_spacing),
		row * (piece_size.y + vertical_spacing)
	)

func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	var col = int(screen_pos.x / (piece_size.x + horizontal_spacing))
	var row = int(screen_pos.y / (piece_size.y + vertical_spacing))

	if is_valid_position(row, col):
		var local_x = screen_pos.x - col * (piece_size.x + horizontal_spacing)
		var local_y = screen_pos.y - row * (piece_size.y + vertical_spacing)
		if local_x >= 0 and local_x <= piece_size.x and local_y >= 0 and local_y <= piece_size.y:
			return Vector2i(col, row)

	return Vector2i(-1, -1)

func get_all_positions_of_type(type: Piece.PieceType) -> Array:
	var positions = []
	for row in rows:
		for col in columns:
			var piece = get_piece_at(row, col)
			if piece and piece.get_type() == type:
				positions.append({"row": row, "col": col})
	return positions

# ---------------------------------------------------------------------------
# Input / Drag
# ---------------------------------------------------------------------------

func _gui_input(event: InputEvent) -> void:
	if is_swapping:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			on_drag_start(event.position)
		else:
			on_drag_end(event.position)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		on_dragging(event.position)
	elif event is InputEventScreenTouch:
		if event.pressed:
			on_drag_start(event.position)
		else:
			on_drag_end(event.position)
	elif event is InputEventScreenDrag:
		on_dragging(event.position)

func on_drag_start(pos: Vector2) -> void:
	var grid_pos = screen_to_grid(pos)

	if grid_pos.x == -1:
		drag_start_row = -1
		drag_start_col = -1
		dragged_piece = null
		return

	drag_start_row = grid_pos.y
	drag_start_col = grid_pos.x
	drag_start_pos = pos
	dragged_piece = get_piece_at(drag_start_row, drag_start_col)

	if dragged_piece:
		var tween = create_tween()
		tween.tween_property(dragged_piece, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_BACK)
		dragged_piece.modulate = Color(1.3, 1.3, 1.3)

func on_dragging(pos: Vector2) -> void:
	if drag_start_row == -1 or not dragged_piece:
		return

	var drag_vector = pos - drag_start_pos
	if drag_vector.length() < min_drag_distance:
		return

	var target_row = drag_start_row
	var target_col = drag_start_col

	if abs(drag_vector.x) > abs(drag_vector.y):
		target_col += 1 if drag_vector.x > 0 else -1
	else:
		target_row += 1 if drag_vector.y > 0 else -1

	if is_valid_position(target_row, target_col):
		execute_swap(drag_start_row, drag_start_col, target_row, target_col)
		drag_start_row = -1
		drag_start_col = -1
		dragged_piece = null

func on_drag_end(_pos: Vector2) -> void:
	if dragged_piece:
		var tween = create_tween()
		tween.tween_property(dragged_piece, "scale", Vector2(1.0, 1.0), 0.1)
		dragged_piece.modulate = Color(1.0, 1.0, 1.0)

	drag_start_row = -1
	drag_start_col = -1
	dragged_piece = null

# ---------------------------------------------------------------------------
# Swap
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Swap
# ---------------------------------------------------------------------------

func execute_swap(row1: int, col1: int, row2: int, col2: int) -> void:
	is_swapping = true

	var piece1 = get_piece_at(row1, col1)
	var piece2 = get_piece_at(row2, col2)

	if not piece1 or not piece2:
		is_swapping = false
		return

	piece1.scale = Vector2(1.0, 1.0)
	piece1.modulate = Color(1.0, 1.0, 1.0)

	var tween1 = create_tween()
	var tween2 = create_tween()
	tween1.tween_property(piece1, "position", get_screen_pos(row2, col2), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween2.tween_property(piece2, "position", get_screen_pos(row1, col1), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	grid[row1][col1] = piece2
	grid[row2][col2] = piece1

	await tween1.finished

	# Caso especial: color_bomb se activa directamente al swapear
	# La pieza con la que se swapea define qué tipo se elimina
	if piece1.special_type == Piece.SpecialType.COLOR_BOMB or piece2.special_type == Piece.SpecialType.COLOR_BOMB:
		await _activate_color_bomb_swap(piece1, piece2, row1, col1, row2, col2)
		is_swapping = false
		return

	var matches = match_detector.check_and_emit(grid, rows, columns)

	if matches.size() > 0:
		emit_signal("swap_completed", true)
		await process_matches(matches, row1, col1, row2, col2)
	else:
		emit_signal("swap_completed", false)
		await revert_swap(row1, col1, row2, col2, piece1, piece2)

	is_swapping = false

func _activate_color_bomb_swap(piece1: Piece, piece2: Piece, row1: int, col1: int, row2: int, col2: int) -> void:
	# Determinar cuál es la color_bomb y cuál define el tipo a eliminar
	var bomb: Piece
	var target: Piece
	var bomb_row: int
	var bomb_col: int

	if piece1.special_type == Piece.SpecialType.COLOR_BOMB:
		bomb = piece1
		bomb_row = row2  # después del swap piece1 está en row2,col2
		bomb_col = col2
		target = piece2
	else:
		bomb = piece2
		bomb_row = row1
		bomb_col = col1
		target = piece1

	# Obtener todas las posiciones del tipo de la pieza target
	# COLOR_BOMB.activate() usa self.type para buscar, así que le asignamos
	# temporalmente el tipo del target
	bomb.type = target.get_type()
	var positions = bomb.activate(self, bomb_row, bomb_col)

	emit_signal("swap_completed", true)
	await remove_pieces(positions)
	await _fill_board()

	var new_matches = match_detector.check_and_emit(grid, rows, columns)
	if new_matches.size() > 0:
		await get_tree().create_timer(0.15).timeout
		await process_matches(new_matches)
	else:
		match_detector.check_has_moves(grid, rows, columns)

func revert_swap(row1: int, col1: int, row2: int, col2: int, piece1: Piece, piece2: Piece) -> void:
	var tween1 = create_tween()
	var tween2 = create_tween()
	tween1.tween_property(piece1, "position", get_screen_pos(row1, col1), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween2.tween_property(piece2, "position", get_screen_pos(row2, col2), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	grid[row1][col1] = piece1
	grid[row2][col2] = piece2

	await tween1.finished


func _trigger_fx_for_piece(piece: Piece, row: int, col: int) -> void:
	var pos = get_screen_pos(row, col) + piece_size / 2.0
	match piece.special_type:
		Piece.SpecialType.STRIPED_H:   fx_layer.play_striped_h(pos)
		Piece.SpecialType.STRIPED_V:   fx_layer.play_striped_v(pos)
		Piece.SpecialType.WRAPPED:     fx_layer.play_wrapped(pos)
		Piece.SpecialType.COLOR_BOMB:  fx_layer.play_color_bomb(pos)
# ---------------------------------------------------------------------------
# Procesamiento de matches
# ---------------------------------------------------------------------------

func process_matches(matches: Array, moved_row: int = -1, moved_col: int = -1, moved_row2: int = -1, moved_col2: int = -1) -> void:
	var pieces_to_remove = []
	var specials_to_create = []
	var seen_remove = {}
	var seen_special = {}

	matches.sort_custom(func(a, b): return a.size() > b.size())

	for match_group in matches:
		var special = match_detector.get_special_type_for_match(match_group)

		var spawn_pos: Vector2i = Vector2i(-1, -1)

		if special != Piece.SpecialType.NONE:
			if match_group.size() > 0 and match_group[0].get("is_tl", false):
				spawn_pos = match_group[0].get("intersection", Vector2i(-1, -1))
			else:
				spawn_pos = _find_moved_piece_in_group(match_group, moved_row, moved_col, moved_row2, moved_col2)
				if spawn_pos.x == -1:
					var center = match_group[match_group.size() / 2]
					spawn_pos = Vector2i(center.col, center.row)

			var center_key = str(spawn_pos.y) + "_" + str(spawn_pos.x)
			if not seen_special.has(center_key):
				seen_special[center_key] = true
				specials_to_create.append({
					"row": spawn_pos.y,
					"col": spawn_pos.x,
					"base_type": get_piece_at(spawn_pos.y, spawn_pos.x).get_type(),
					"special": special
				})
		for pos in match_group:
				var piece = get_piece_at(pos.row, pos.col)
				if not piece:
					continue

				# Disparar FX si esta pieza es especial y se está activando ahora
				if piece.special_type != Piece.SpecialType.NONE:
					_trigger_fx_for_piece(piece, pos.row, pos.col)

				var affected = piece.activate(self, pos.row, pos.col)
				for affected_pos in affected:
					var key = str(affected_pos.row) + "_" + str(affected_pos.col)
					if not seen_remove.has(key):
						seen_remove[key] = true
						pieces_to_remove.append(affected_pos)

	await remove_pieces(pieces_to_remove)

	for spec in specials_to_create:
		var piece = create_piece_at(spec.row, spec.col)
		piece.setup(spec.base_type)
		piece.special_type = spec.special
		piece.update_visual()

	await _fill_board()

	var new_matches = match_detector.check_and_emit(grid, rows, columns)
	if new_matches.size() > 0:
		await get_tree().create_timer(0.15).timeout
		await process_matches(new_matches)
	else:
		match_detector.check_has_moves(grid, rows, columns)

func _find_moved_piece_in_group(match_group: Array, r1: int, c1: int, r2: int, c2: int) -> Vector2i:
	for pos in match_group:
		if (pos.row == r1 and pos.col == c1) or (pos.row == r2 and pos.col == c2):
			return Vector2i(pos.col, pos.row)
	return Vector2i(-1, -1)

# ---------------------------------------------------------------------------
# Relleno
# ---------------------------------------------------------------------------

func _fill_board() -> void:
	await BoardFiller.drop_existing_pieces(self)
	await BoardFiller.spawn_new_pieces(self)

func remove_pieces(positions: Array) -> void:
	var unique = {}
	for pos in positions:
		var key = str(pos.row) + "_" + str(pos.col)
		unique[key] = pos

	var tweens = []
	for key in unique:
		var pos = unique[key]
		var piece = get_piece_at(pos.row, pos.col)
		if not piece:
			continue
		grid[pos.row][pos.col] = null
		var tween = create_tween()
		tween.tween_property(piece, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_callback(piece.queue_free)
		tweens.append(tween)

	if tweens.size() > 0:
		await tweens[tweens.size() - 1].finished
