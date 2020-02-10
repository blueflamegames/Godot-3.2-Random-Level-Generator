extends Room
class_name RoomEnd

func _ready():
	bounds.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player:
		body.hud.visible = true
		body.message.text = "Win!"
