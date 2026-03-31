extends Control

@onready var unit_2: Label = %unit_2
@onready var unit_1: Label = %unit_1
@onready var unit_0: Label = %unit_0
@onready var decimal_0: Label = %decimal_0
@onready var decimal_1: Label = %decimal_1
@onready var dot: Label = %dot
@onready var grams: Label = %grams

var current_weight: float = 0.0
var active_tween: Tween = null

const COLOR_ON: Color = Color(1, 1, 1, 1)
const COLOR_DIM: Color = Color(1, 1, 1, 0.4)
const COLOR_OFF: Color = Color(1, 1, 1, 0)

func _ready() -> void:
	dot.text = "."; grams.text = "g"
	turn_off()

func set_weight(target: float) -> void:
	if active_tween and active_tween.is_valid(): active_tween.kill()
	active_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	var duration: float = clampf(abs(target - current_weight) * 0.008, 0.4, 1.6)
	active_tween.tween_method(_update_display, current_weight, target, duration)

func _update_display(value: float) -> void:
	current_weight = value
	var absolute_value: float = abs(value)
	var total_cents: int = roundi(absolute_value * 100.0)
	var integer_part: int = floori(total_cents / 100.0)
	var decimal_part: int = total_cents % 100

	decimal_1.text = str(decimal_part % 10)
	decimal_0.text = str(floori(decimal_part / 10.0))
	unit_0.text = str(integer_part % 10)
	
	var tens_val: int = floori(integer_part / 10.0) % 10
	var hund_val: int = floori(integer_part / 100.0) % 10
	var tens_txt: String = str(tens_val); var hund_txt: String = str(hund_val)
	var tens_col: Color = COLOR_ON if integer_part >= 10 else COLOR_DIM
	var hund_col: Color = COLOR_ON if integer_part >= 100 else COLOR_DIM

	if value < -0.01:
		if integer_part < 10: tens_txt = "-"; tens_col = COLOR_ON
		elif integer_part < 100: hund_txt = "-"; hund_col = COLOR_ON
		else: hund_txt = "-" + hund_txt; hund_col = COLOR_ON

	unit_1.text = tens_txt
	unit_1.modulate = tens_col
	unit_2.text = hund_txt
	unit_2.modulate = hund_col
	for label in [unit_0, decimal_0, decimal_1]: label.modulate = COLOR_ON

func turn_on() -> void:
	dot.modulate = COLOR_ON; grams.modulate = COLOR_ON
	_update_display(0.0)

func turn_off() -> void:
	if active_tween and active_tween.is_valid(): active_tween.kill()
	current_weight = 0.0
	
	if unit_2 == null: return 
	for label in [unit_2, unit_1, unit_0, decimal_0, decimal_1]: 
		label.text = " "
	dot.modulate = COLOR_OFF
	grams.modulate = COLOR_OFF
