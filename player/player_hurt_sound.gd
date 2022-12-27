extends AudioStreamPlayer


func _ready():
	finished.connect(queue_free)
