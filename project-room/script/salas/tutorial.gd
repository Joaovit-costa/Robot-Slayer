extends Node2D


@onready var menu_compras: Control = $Menu_Compras
@onready var tutorial_0: Control = $Tutorial_0
@onready var tutorial_1: Control = $Tutorial_1
@onready var tutorial_2: Control = $Tutorial_2
@onready var tutorial_3: Control = $Tutorial_3
@onready var tutorial_4: Control = $Tutorial_4
@onready var tutorial_5: Control = $Tutorial_5
@onready var tutorial_6: Control = $Tutorial_6
@onready var tutorial_7: Control = $Tutorial_7
@onready var tutorial_8: Control = $Tutorial_8
@onready var tutorial_geral : Array = [tutorial_0, tutorial_1, tutorial_2,
										tutorial_3, tutorial_4, tutorial_5,
										tutorial_6, tutorial_7, tutorial_8]
var tutorial = 0
