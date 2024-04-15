extends StaticBody2D

func _ready():
	var pol = PackedVector2Array()
	for a in $Line2D.points:
		pol.append(a+$Line2D.global_position)	
	pol.append(pol[0])
	
	var collision = CollisionPolygon2D.new()
	collision.polygon = pol;
	add_child(collision);
	


func _process(delta):
	pass
