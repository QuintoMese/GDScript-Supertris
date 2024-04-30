extends ColorRect

signal eSelezionata(casella)

var libera : bool
var indiceCasellaX : int
var indiceCasellaY : int

# Called when the node enters the scene tree for the first time.
func _ready():
	libera = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_gui_input(event):
	if event.is_action_pressed("mouse1"):
		emit_signal("eSelezionata", self)
		#print("casella selezionata")
	
