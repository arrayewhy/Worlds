# Source: https://www.reddit.com/r/godot/comments/1838ifx/how_to_improve_performance_with_many_sprites/
#BakedSprite2D.gd  
extends Sprite2D  
class_name BakedSprite2D

#Used to keep a reference to the sprites that must be drawn
var registeredSprites: Array[Sprite2D]    
static var relativePositions: Dictionary

#This function is meant to select several ones and return an instance of this script  
#Do note that it must be "static" to be called without an instance.
static func create_baked_sprite(spriteNodes: Array[Sprite2D], callerPath:String) -> BakedSprite2D:        

	#Abort nothing was passed
	if spriteNodes.is_empty():    
		push_error("There are no sprites to bake!")
		return null

	var bakedSprite := BakedSprite2D.new()  
	var positionAverage:Vector2  

	for sprite in spriteNodes:    
		positionAverage += sprite.global_position    

		#Hide sprites to prevent them from drawing anymore
		sprite.visible = false

	#Calculate the middle point of all sprites and place the baked one there.
	positionAverage /= spriteNodes.size()      
	bakedSprite.global_position = positionAverage    
	  
	#Now register where each texture goes by getting their position relative to the center  
	for sprite in spriteNodes:      

		#Get the location where the texture should be drawn to be where it's Sprite2D is, then store it  
		#This results in a Dictionary filled with Sprite2D:Vector2 pairs.
		relativePositions[sprite] = sprite.global_position - bakedSprite.global_position

	bakedSprite.registeredSprites = spriteNodes     

	return bakedSprite


#Here is where it draws everything, this is called automatically 
func _draw():  
	for sprite in registeredSprites:        
		draw_texture(sprite.texture, relativePositions[sprite])


func bake_room_a_sprites():  
	var sprites: Array[Sprite2D] = [    
		$FlowerPotSprite2DA,  
		$CouchSprite2DA,  
		$DoorSprite2DA
	]    

	#This function is static, so it can be accessed from anywhere.
	var newBaked := BakedSprite2D.create_baked_sprite(sprites, self.get_path())  
	  
	add_child(newBaked)  

	#Ensure it is properly drawn when added, instead of waiting for a "draw()" call.
	newBaked.queue_redraw()
