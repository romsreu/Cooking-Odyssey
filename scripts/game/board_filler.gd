class_name BoardFiller
extends Object

static func fill(board: GameBoard) -> void:
	await board.drop_existing_pieces()
	await board.spawn_new_pieces()

static func drop_existing_pieces(board: GameBoard) -> void:
	var tweens = []

	for col in board.columns:
		var empty_row = board.rows - 1

		for row in range(board.rows - 1, -1, -1):
			if board.grid[row][col] != null:
				if row != empty_row:
					var piece = board.grid[row][col]
					board.grid[empty_row][col] = piece
					board.grid[row][col] = null

					var fall_distance = empty_row - row
					var duration = 0.1 + fall_distance * 0.04
					var tween = board.create_tween()
					tween.tween_property(piece, "position", board.get_screen_pos(empty_row, col), duration) \
						.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
					tweens.append(tween)

				empty_row -= 1

	if tweens.size() > 0:
		await tweens[tweens.size() - 1].finished

static func spawn_new_pieces(board: GameBoard) -> void:
	var tweens = []

	for col in board.columns:
		var spawn_offset = 0

		for row in range(board.rows - 1, -1, -1):
			if board.grid[row][col] == null:
				spawn_offset += 1
				var piece = board.create_piece_at(row, col)

				piece.position = board.get_screen_pos(-spawn_offset, col)

				var duration = 0.1 + spawn_offset * 0.04
				var tween = board.create_tween()
				tween.tween_property(piece, "position", board.get_screen_pos(row, col), duration) \
					.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				tweens.append(tween)

	if tweens.size() > 0:
		await tweens[tweens.size() - 1].finished
