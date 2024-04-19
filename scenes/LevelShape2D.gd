@tool
extends StaticBody2D
class_name LevelShape2D

"""

For all sprites - three states: transparent (alpha=100%), lucid: >0%, solid (0%)

Sprite gets painted as is, it is if a tile is applied 
- Sprite (image), clip children = clip only
-- Sprite with tile as texture, region with inf width and height

Collision: solid
LightOccluder: solid and lucid (lucid: todo)

"""

@export var tiled_texture: Texture = null
@export var level_shape: Texture = null

func _ready():
	
	var bitMap: BitMap = BitMap.new()	
	bitMap.create_from_image_alpha(level_shape.get_image())

	# add transparent lines to bitMap  
	for x in bitMap.get_size().x:
		bitMap.set_bit(x, bitMap.get_size().y/2, 0)
	var imgpols = bitMap.opaque_to_polygons(Rect2(Vector2(), bitMap.get_size()), 2)
	
	var sprite_node = Sprite2D.new()
	sprite_node.texture = level_shape
	add_child(sprite_node) 
	
	if(tiled_texture != null):
		sprite_node.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		var rock: Sprite2D = Sprite2D.new()
		rock.texture = tiled_texture
		rock.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		rock.region_enabled = true
		rock.region_rect = Rect2(0,0,100000,100000)
		rock.light_mask = 2 # matches drone's outer light cull mask
		rock.modulate = Color(0.2,0.2,0.2)
		sprite_node.add_child(rock)
	
	# dont apply collision and light occluder polygons in editor
	if(Engine.is_editor_hint()): return
	
	for imgpol in imgpols:
		var pol = PackedVector2Array()
		for a in imgpol:
			# was needed before, no idea why not anymore: "+ sprite.global_position"
			pol.append(a - bitMap.get_size()/2.0)	
		
		var collision = CollisionPolygon2D.new()
		collision.polygon = pol;
		add_child(collision)
		
		var lightOccluder: LightOccluder2D = LightOccluder2D.new()
		lightOccluder.occluder = OccluderPolygon2D.new()
		lightOccluder.occluder.polygon = pol
		add_child(lightOccluder)
				
			

