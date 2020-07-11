extends Node2D

func is_colliding():
	$Left.force_raycast_update()
	$Right.force_raycast_update()
	
	return $Left.is_colliding() or $Right.is_colliding()
