extends Control

var indiceMiniTabelloneX : int
var indiceMiniTabelloneY : int
var concluso : bool

signal miniTabSelezionato(mini_tabellone, casella)
signal terminato(mini_tabellone)

@onready var scenaCasella = preload("res://casella.tscn")
@onready var scenaCerchio = preload("res://cerchio.tscn")
@onready var scenaCroce = preload("res://croce.tscn")

var matriceMiniTab : Array
var numeroMosse : int
var sommaDiag1 : int
var sommaDiag2 : int
var sommaColonna : int
var sommaRiga : int
var vincitore : int

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(3):
		for j in range(3):
			creaCaselle(i, j)
	nuovaPartita()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func creaCaselle(indiceY, indiceX):
	var nuovaCasella = scenaCasella.instantiate()
	nuovaCasella.indiceCasellaX = indiceX
	nuovaCasella.indiceCasellaY = indiceY
	$ContenitoreCaselle.add_child(nuovaCasella)
	#print("casella creata")
	nuovaCasella.eSelezionata.connect(su_casa_selezionata)
	
func su_casa_selezionata(Casella):
	emit_signal("miniTabSelezionato", self, Casella)
	#if Casella.libera:
		#aggiungiIndicatore(Casella)

func nuovaPartita():
	vincitore = 0
	numeroMosse = 0
	sommaDiag1 = 0
	sommaDiag2 = 0
	sommaColonna = 0
	sommaRiga = 0
	matriceMiniTab = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]

func controllaVittoria()->int:
	sommaDiag1 = matriceMiniTab[0][0] + matriceMiniTab[1][1] + matriceMiniTab[2][2]
	sommaDiag2 = matriceMiniTab[2][0] + matriceMiniTab[1][1] + matriceMiniTab[0][2]
	for i in len(matriceMiniTab):
		sommaColonna = matriceMiniTab[i][0] + matriceMiniTab[i][1] + matriceMiniTab[i][2]
		sommaRiga = matriceMiniTab[0][i] + matriceMiniTab[1][i] + matriceMiniTab[2][i]
		if sommaColonna == 3 or sommaRiga == 3 or sommaDiag2 == 3 or sommaDiag1 == 3:
			vincitore = 1
		elif sommaColonna == -3 or sommaRiga == -3 or sommaDiag2 == -3 or sommaDiag1 == -3:
			vincitore = -1
	return vincitore
	
func aggiungiIndicatore(Casella, giocatore):
	Casella.libera = false
	matriceMiniTab[Casella.indiceCasellaX][Casella.indiceCasellaY] = giocatore
	numeroMosse += 1
	var offsetIntraTabelloneX = 100*Casella.indiceCasellaX
	var offsetIntraTabelloneY = 100*Casella.indiceCasellaY
	var offsetInterTabelloneX = 300*indiceMiniTabelloneX
	var offsetInterTabelloneY = 300*indiceMiniTabelloneY
	var offset = Vector2(offsetIntraTabelloneX+offsetInterTabelloneX, offsetIntraTabelloneY+offsetInterTabelloneY)
	if giocatore == -1:
		var cerchio = scenaCerchio.instantiate()
		cerchio.position = offset
		Casella.add_child(cerchio)
		#print("cerchio piazzato")
	else:
		var croce = scenaCroce.instantiate()
		croce.position = offset
		Casella.add_child(croce)
		#print("Croce piazzata")
	if controllaVittoria() != 0:
		concluso = true
		emit_signal("terminato", self)
		#if vincitore == 1:
			#print("vince x")
		#elif vincitore == -1:
			#print("vince o")
	elif numeroMosse == 9:
		concluso = true
		emit_signal("terminato", self)
		#print("pareggio")
	#print(matriceMiniTab)
