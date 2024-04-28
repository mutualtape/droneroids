extends Object
class_name Global

class GameStat:
	var time: int 
	var energy: float
	func _init(t: int, e: float): 
		time = t
		energy = e

static func text_for_millis(milli_seconds: int):
	var seconds = (milli_seconds/1000) % 60
	var minutes = (milli_seconds/(1000 * 60)) % 60
	return "%02d:%02d" % [minutes, seconds]
