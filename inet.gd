extends Node2D

func _ready() -> void:
	$music.play()
	$anims.play("bop")
	$transition.play("in")
