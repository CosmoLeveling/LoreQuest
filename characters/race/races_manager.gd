extends Control

signal race_selected

# Constants
const RACE_TEMPLATE = preload("res://characters/race/template/race_template.tscn")

func _ready() -> void:
	Globals.races.reactive_changed.connect(reload_races)
	%NewRace.pressed.connect(func():
		%RaceCreate.show()
		)
	%SubmitRaceName.pressed.connect(func():
		%RaceCreate.hide()
		create_new_race(%RaceNameLine.text)
		)
	Globals.races.manually_emit()

# Function to Reload the races list
func reload_races(_reactive:Reactive):
	for c in %RaceGrid.get_children():
		c.queue_free()

	for race in Globals.races.value:
		var temp = RACE_TEMPLATE.instantiate()
		temp.race = race
		temp.race_selected.connect(select_race)
		%RaceGrid.add_child(temp)

# Function to handle the creation of a new race
func create_new_race(init_name:String):
	var has_race = false
	for race in Globals.races.value:
		if race.name.value == init_name:
			has_race = true
	if not has_race:
		Globals.races.append(Race.new(init_name))

# Function to handle the selection of a race
func select_race(race:Race):
	emit_signal("race_selected",race)
