extends Control

@onready var scenaMiniTabellone = preload("res://mini_tabellone.tscn")
@onready var scenaCerchio = preload("res://cerchio.tscn")
@onready var scenaCroce = preload("res://croce.tscn")

var matriceTabGrande : Array
var giocatore : int
var primaMossa : bool
var tabProssimaMossaX : int
var tabProssimaMossaY : int
var mossaPrecedenteTabConcluso : bool
var controllaPuntatore : bool
var nTabelloniFiniti : int

var g_sommaDiag1 : int
var g_sommaDiag2 : int
var g_sommaColonna : int
var g_sommaRiga : int
var vincitoreTot : int

# Called when the node enters the scene tree for the first time.
func _ready():
	nuovaPartitaGrande()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func creaTabelloni(indiceY, indiceX):
	var nuovoTabellone = scenaMiniTabellone.instantiate()
	nuovoTabellone.indiceMiniTabelloneX = indiceX
	nuovoTabellone.indiceMiniTabelloneY = indiceY
	var offsetTabs = Vector2(300*nuovoTabellone.indiceMiniTabelloneX, 300*nuovoTabellone.indiceMiniTabelloneY)
	nuovoTabellone.position = offsetTabs
	$GridContainer.add_child(nuovoTabellone)
	nuovoTabellone.miniTabSelezionato.connect(su_miniTab_selezionato)
	nuovoTabellone.terminato.connect(miniTabelloneTermina)

func nuovaPartitaGrande():
	for i in range(3):
		for j in range(3):
			creaTabelloni(i, j)
	g_sommaDiag1 = 0
	g_sommaDiag2 = 0
	g_sommaColonna = 0
	g_sommaRiga = 0
	nTabelloniFiniti = 0
	giocatore = 1
	vincitoreTot = 0
	primaMossa = true
	matriceTabGrande = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]

func su_miniTab_selezionato(tabellone, casella):
	if primaMossa:
		primaMossa = false
		casella.libera = false
		tabProssimaMossaX = casella.indiceCasellaX
		tabProssimaMossaY = casella.indiceCasellaY
		tabellone.aggiungiIndicatore(casella, giocatore)
		giocatore *= -1
	else:
		if !tabellone.concluso:
			if (tabellone.indiceMiniTabelloneX == tabProssimaMossaX and tabellone.indiceMiniTabelloneY == tabProssimaMossaY) or controllaPuntatore:
				if casella.libera:
					casella.libera = false
					tabProssimaMossaX = casella.indiceCasellaX
					tabProssimaMossaY = casella.indiceCasellaY
					tabellone.aggiungiIndicatore(casella, giocatore)
					giocatore *= -1
					controllaPuntatore = matriceTabGrande[tabProssimaMossaX][tabProssimaMossaY] != 0
					if controllaVittoria() != 0 or nTabelloniFiniti == 9:
						$RicominciaPartita.show()
						$sfondoFinePartita.show()
		#else:
		#	mossaPrecedenteTabConcluso = true
	var indiceTabGiocato = tabellone.indiceMiniTabelloneX + tabellone.indiceMiniTabelloneY*3
	$GridContainer.get_child(indiceTabGiocato).get_node("FiltroDaGiocare").hide()
	aggiungiFiltroDaGiocare(tabProssimaMossaX, tabProssimaMossaY)

func miniTabelloneTermina(tabellone):
	tabellone.get_node("FiltroTerminato").position = tabellone.position
	tabellone.get_node("FiltroTerminato").position -= Vector2(3.3*tabellone.indiceMiniTabelloneX, 3.3*tabellone.indiceMiniTabelloneY)
	tabellone.get_node("FiltroTerminato").show()
	matriceTabGrande[tabellone.indiceMiniTabelloneX][tabellone.indiceMiniTabelloneY] = giocatore
	nTabelloniFiniti += 1
	var offset = Vector2(300*tabellone.indiceMiniTabelloneX, 300*tabellone.indiceMiniTabelloneY)
	if tabellone.vincitore == 1:
		var croce = scenaCroce.instantiate()
		croce.scale = Vector2(2.5, 2.5)
		croce.position = offset
		tabellone.add_child(croce)
	elif tabellone.vincitore == -1:
		var cerchio = scenaCerchio.instantiate()
		cerchio.scale = Vector2(2.5, 2.5)
		cerchio.position = offset
		tabellone.add_child(cerchio)
	#print(matriceTabGrande)

func controllaVittoria()->int:
	g_sommaDiag1 = matriceTabGrande[0][0] + matriceTabGrande[1][1] + matriceTabGrande[2][2]
	g_sommaDiag2 = matriceTabGrande[2][0] + matriceTabGrande[1][1] + matriceTabGrande[0][2]
	for i in len(matriceTabGrande):
		g_sommaColonna = matriceTabGrande[i][0] + matriceTabGrande[i][1] + matriceTabGrande[i][2]
		g_sommaRiga = matriceTabGrande[0][i] + matriceTabGrande[1][i] + matriceTabGrande[2][i]
		if g_sommaColonna == 3 or g_sommaRiga == 3 or g_sommaDiag2 == 3 or g_sommaDiag1 == 3:
			vincitoreTot = 1
		elif g_sommaColonna == -3 or g_sommaRiga == -3 or g_sommaDiag2 == -3 or g_sommaDiag1 == -3:
			vincitoreTot = -1
	return vincitoreTot


func _on_ricomincia_partita_gui_input(event):
	if event.is_action_pressed("mouse1"):
		$sfondoFinePartita.hide()
		$RicominciaPartita.hide()
		var n = $GridContainer.get_child_count()
		for i in range(n):
			$GridContainer.get_child(i).queue_free()
		nuovaPartitaGrande()

func aggiungiFiltroDaGiocare(daGiocareX, daGiocareY):
	if !controllaPuntatore:
		var indiceTabDaGiocare = daGiocareX + daGiocareY*3
		$GridContainer.get_child(indiceTabDaGiocare).get_node("FiltroDaGiocare").position = $GridContainer.get_child(indiceTabDaGiocare).position
		$GridContainer.get_child(indiceTabDaGiocare).get_node("FiltroDaGiocare").position -= Vector2(3.3*daGiocareX, 3.3*daGiocareY)
		$GridContainer.get_child(indiceTabDaGiocare).get_node("FiltroDaGiocare").show()
