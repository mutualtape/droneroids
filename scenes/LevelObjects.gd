extends StaticBody2D

func _ready():
	
	for sprite in get_children():
	
		if ! sprite is Sprite2D: 
			continue
		sprite.visible = false
	
		var bitMap = BitMap.new()	
		bitMap.create_from_image_alpha(sprite.texture.get_image())
	
		# TODO: add transparent lines to bitMap to fix tube issue 
		for x in bitMap.get_size().x:
			bitMap.set_bit(x, bitMap.get_size().y/2, 0)
	
		var imgpols = bitMap.opaque_to_polygons(Rect2(Vector2(), bitMap.get_size()), 2)
		
		for imgpol in imgpols:
			var pol = PackedVector2Array()
			for a in imgpol:
				# was needed before, no idea why not anymore: "+ sprite.global_position"
				pol.append(a - bitMap.get_size()/2.0)	
			
			var collision = CollisionPolygon2D.new()
			collision.polygon = pol;
			
			var rock = $Rock.duplicate()
			rock.polygon = pol
			add_child(rock)
			
			var lightOccluder: LightOccluder2D = $LightOccluder2D.duplicate()
			lightOccluder.occluder = OccluderPolygon2D.new()
			lightOccluder.occluder.polygon = pol
			
			add_child(lightOccluder)
			
			add_child(collision)
