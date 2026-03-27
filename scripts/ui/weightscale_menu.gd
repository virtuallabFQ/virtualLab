extends Control

@onready var unit_2: Label = $digits/unit_2
@onready var unit_1: Label = $digits/unit_1
@onready var unit_0: Label = $digits/unit_0
@onready var dot: Label = $digits/dot
@onready var decimal_0: Label = $digits/decimal_0
@onready var decimal_1: Label = $digits/decimal_1
@onready var grams: Label = $digits/grams

var current_weight: float = 0.0
var scroll_tween: Tween

const ACTIVE_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const HIDDEN = Color(1.0, 1.0, 1.0, 0.392)
const INVISIBLE = Color(1.0, 1.0, 1.0, 0.0)

func _ready():
	dot.text = "."
	grams.text = "g"
	turn_off()

func set_weight(new_weight: float):
	_animate_to(new_weight)

func _animate_to(target: float):
	if scroll_tween:
		scroll_tween.kill()
	scroll_tween = create_tween()
	var duration = clampf(abs(target - current_weight) * 0.008, 0.4, 1.6)
	scroll_tween.tween_method(
		_update_display, current_weight, target, duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	scroll_tween.tween_callback(func():
		current_weight = target
	)

func _update_display(w: float):
	current_weight = w
	var total    = roundi(w * 100.0)
	var integer  = total / 100
	var decimals = total % 100

	unit_0.text    = str(integer % 10)
	unit_1.text    = str((integer / 10) % 10)
	unit_2.text    = str((integer / 100) % 10)
	decimal_0.text = str(decimals / 10)
	decimal_1.text = str(decimals % 10)

	unit_0.modulate    = ACTIVE_COLOR
	decimal_0.modulate = ACTIVE_COLOR
	decimal_1.modulate = ACTIVE_COLOR
	unit_2.modulate    = HIDDEN if integer < 100 else ACTIVE_COLOR
	unit_1.modulate    = HIDDEN if integer < 10  else ACTIVE_COLOR

func turn_on():
	dot.modulate = ACTIVE_COLOR
	grams.modulate = ACTIVE_COLOR
	_update_display(0.0)

func turn_off():
	if scroll_tween:
		scroll_tween.kill()
	current_weight = 0.0
	
	unit_2.text = " "
	unit_1.text = " "
	unit_0.text = " "
	decimal_0.text = " "
	decimal_1.text = " "
	
	dot.modulate = INVISIBLE 
	grams.modulate = INVISIBLE
