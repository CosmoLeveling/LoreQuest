class_name Race
extends Reactive

var name:ReactiveString=ReactiveString.new("",self)
var description:ReactiveString=ReactiveString.new("",self)

func _init(init_name):
	name.value = init_name

# Function to get race from data
static func from_data(data) -> Race:
	var race = Race.new(data["name"])
	race.description.value = data["description"]
	return race

func save() -> Dictionary:
	return {
		"name": name.value,
		"description": description.value
		}
