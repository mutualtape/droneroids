extends StaticBody2D

"""
For all sprites - three states: transparent (alpha=100%), lucid: >0%, solid (0%)

Sprite gets painted as is, it is if a tile is applied 
- Sprite (image), clip children = clip only
-- Sprite with tile as texture, region with inf width and height

Collision: solid
LightOccluder: solid and lucid (lucid: todo)

"""

@export var tiled_texture: Texture = null

func _ready():
	
	for sprite in get_children():
		if ! sprite is Sprite2D: 
			continue
	
		var bitMap = BitMap.new()	
		bitMap.create_from_image_alpha(sprite.texture.get_image())
	
		# TODO: add transparent lines to bitMap to fix tube issue 
		for x in bitMap.get_size().x:
			bitMap.set_bit(x, bitMap.get_size().y/2, 0)
	
		var imgpols = bitMap.opaque_to_polygons(Rect2(Vector2(), bitMap.get_size()), 2)
		
		if(tiled_texture != null):
			sprite.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
			var rock: Sprite2D = Sprite2D.new()
			rock.texture = tiled_texture
			rock.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
			rock.region_enabled = true
			rock.region_rect = Rect2(0,0,100000,100000)
			rock.light_mask = 2 # matches drone's outer light cull mask
			rock.modulate = Color(0.2,0.2,0.2)
			sprite.add_child(rock)
		
		for imgpol in imgpols:
			var pol = PackedVector2Array()
			for a in imgpol:
				# was needed before, no idea why not anymore: "+ sprite.global_position"
				pol.append(a - bitMap.get_size()/2.0)	
			
			var collision = CollisionPolygon2D.new()
			collision.polygon = pol;
			add_child(collision)
			
			var lightOccluder: LightOccluder2D = $LightOccluder2D.duplicate()
			lightOccluder.occluder = OccluderPolygon2D.new()
			lightOccluder.occluder.polygon = pol
			add_child(lightOccluder)
				
			
