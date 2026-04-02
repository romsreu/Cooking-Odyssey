class_name MatchDetector
extends Node

signal matches_found(matches: Array)
signal no_moves_available()

func check_and_emit(grid: Array, rows: int, columns: int) -> Array:
	var matches = _check_matches(grid, rows, columns)
	if matches.size() > 0:
		emit_signal("matches_found", matches)
	return matches

func check_has_moves(grid: Array, rows: int, columns: int) -> void:
	if not _has_valid_moves(grid, rows, columns):
		emit_signal("no_moves_available")

# ---------------------------------------------------------------------------
# Detección de matches
# ---------------------------------------------------------------------------

func _check_matches(grid: Array, rows: int, columns: int) -> Array:
	var h_groups = []
	var v_groups = []

	# Recolectar todos los grupos horizontales
	for row in rows:
		var col = 0
		while col < columns:
			var group = _expand_horizontal(grid, row, col, columns)
			if group.size() >= 3:
				h_groups.append(group)
				col += group.size()
			else:
				col += 1

	# Recolectar todos los grupos verticales
	for col in columns:
		var row = 0
		while row < rows:
			var group = _expand_vertical(grid, row, col, rows)
			if group.size() >= 3:
				v_groups.append(group)
				row += group.size()
			else:
				row += 1

	return _resolve_groups(h_groups, v_groups)

func _resolve_groups(h_groups: Array, v_groups: Array) -> Array:
	var matches = []
	var used_h = {}
	var used_v = {}

	for hi in h_groups.size():
		for vi in v_groups.size():
			var intersection = _find_intersection(h_groups[hi], v_groups[vi])
			if intersection.x != -1:
				# Fusionar los dos grupos en uno, deduplicando
				var merged = _merge_groups(h_groups[hi], v_groups[vi])
				merged[0]["is_tl"] = true  # marcar para get_special_type_for_match
				merged[0]["intersection"] = intersection  # celda de cruce
				matches.append(merged)
				used_h[hi] = true
				used_v[vi] = true

	# Agregar los grupos que no participaron en ninguna T/L
	for hi in h_groups.size():
		if not used_h.has(hi):
			matches.append(h_groups[hi])

	for vi in v_groups.size():
		if not used_v.has(vi):
			matches.append(v_groups[vi])

	return matches

func _find_intersection(group_a: Array, group_b: Array) -> Vector2i:
	for a in group_a:
		for b in group_b:
			if a.row == b.row and a.col == b.col:
				return Vector2i(a.col, a.row)
	return Vector2i(-1, -1)

func _merge_groups(group_a: Array, group_b: Array) -> Array:
	var merged = []
	var seen = {}
	for pos in group_a + group_b:
		var key = str(pos.row) + "_" + str(pos.col)
		if not seen.has(key):
			seen[key] = true
			merged.append(pos)
	return merged

func _expand_horizontal(grid: Array, row: int, start_col: int, columns: int) -> Array:
	var piece = _get_piece(grid, row, start_col)
	if not piece:
		return []

	var group = [{"row": row, "col": start_col}]
	var type = piece.get_type()

	for col in range(start_col + 1, columns):
		var current = _get_piece(grid, row, col)
		if current and current.get_type() == type:
			group.append({"row": row, "col": col})
		else:
			break

	return group

func _expand_vertical(grid: Array, start_row: int, col: int, rows: int) -> Array:
	var piece = _get_piece(grid, start_row, col)
	if not piece:
		return []

	var group = [{"row": start_row, "col": col}]
	var type = piece.get_type()

	for row in range(start_row + 1, rows):
		var current = _get_piece(grid, row, col)
		if current and current.get_type() == type:
			group.append({"row": row, "col": col})
		else:
			break

	return group

func get_special_type_for_match(match_group: Array) -> Piece.SpecialType:
	# T o L detectada en _resolve_groups
	if match_group.size() > 0 and match_group[0].get("is_tl", false):
		return Piece.SpecialType.WRAPPED

	var size = match_group.size()
	if size >= 5:
		return Piece.SpecialType.COLOR_BOMB
	if size == 4:
		var is_horizontal = match_group[0].row == match_group[1].row
		return Piece.SpecialType.STRIPED_H if is_horizontal else Piece.SpecialType.STRIPED_V
	return Piece.SpecialType.NONE

# ---------------------------------------------------------------------------
# Movimientos posibles
# ---------------------------------------------------------------------------

func _has_valid_moves(grid: Array, rows: int, columns: int) -> bool:
	for row in rows:
		for col in columns:
			if col + 1 < columns:
				_swap_in_grid(grid, row, col, row, col + 1)
				var found = _check_matches(grid, rows, columns).size() > 0
				_swap_in_grid(grid, row, col, row, col + 1)
				if found:
					return true
			if row + 1 < rows:
				_swap_in_grid(grid, row, col, row + 1, col)
				var found = _check_matches(grid, rows, columns).size() > 0
				_swap_in_grid(grid, row, col, row + 1, col)
				if found:
					return true
	return false

func _swap_in_grid(grid: Array, r1: int, c1: int, r2: int, c2: int) -> void:
	var temp = grid[r1][c1]
	grid[r1][c1] = grid[r2][c2]
	grid[r2][c2] = temp

func _get_piece(grid: Array, row: int, col: int) -> Piece:
	return grid[row][col]
