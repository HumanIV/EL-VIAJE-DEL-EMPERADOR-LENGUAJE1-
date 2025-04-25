extends CanvasLayer

var heart_1
var heart_2
var heart_3

func _ready():
	heart_1=get_node("Control/HBoxContainer/heart_1")
	heart_2=get_node("Control/HBoxContainer/heart_2")
	heart_3=get_node("Control/HBoxContainer/heart_3")
	
func handlehearts(current_health):
	if current_health==0:
		heart_1.visible=false
	if current_health==1:
		heart_2.visible=false
	if current_health==2:
		heart_3.visible=false
	if current_health==3:
		heart_3.visible=true
	
