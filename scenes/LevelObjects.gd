extends StaticBody2D

func _ready():
	
	for sprite in get_children():
	
		if ! sprite is Sprite2D: 
			continue
		sprite.visible = false
	
		var bitMap = BitMap.new()	
		bitMap.create_from_image_alpha(sprite.texture.get_image())
	
		# TODO: add transparent lines to bitMap to fix tube issue 
	
		var imgpols = bitMap.opaque_to_polygons(Rect2(Vector2(), bitMap.get_size()), 2)
		
		for imgpol in imgpols:
			var pol = PackedVector2Array()
			for a in imgpol:
				# was needed before, no idea why not anymore: "+ sprite.global_position"
				pol.append(a - bitMap.get_size()/2.0)	
			
			var collision = CollisionPolygon2D.new()
			collision.polygon = pol;
			
			$Rock.polygon = pol
			$LightOccluder2D.occluder.polygon = pol
			
			#collision.modulate = Color(233,0,0,0.5)
			add_child(collision);

func _process(_delta):
	pass
