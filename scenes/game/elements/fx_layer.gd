class_name FXLayer
extends Node2D

const BOMB_FX = preload("uid://cdok2bcnyobfd")
const WRAP_FX = preload("uid://r7muo4rsjgpi")
const RAY_FX = preload("uid://c5g7sokh33irw")

func play_striped_h(piece_pos: Vector2) -> void:
	var fx = RAY_FX.instantiate()
	add_child(fx)
	fx.play_horizontal(piece_pos)

func play_striped_v(piece_pos: Vector2) -> void:
	var fx = RAY_FX.instantiate()
	add_child(fx)
	fx.play_vertical(piece_pos)

func play_wrapped(world_pos: Vector2) -> void:
	var fx = WRAP_FX.instantiate()
	add_child(fx)
	fx.position = world_pos
	fx.play()

func play_color_bomb(world_pos: Vector2) -> void:
	var fx = BOMB_FX.instantiate()
	add_child(fx)
	fx.position = world_pos
	fx.play()
