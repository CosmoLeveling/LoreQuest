class_name Note
extends Reactive
var text: ReactiveString = ReactiveString.new("",self)
var title: ReactiveString = ReactiveString.new("",self)
func save()->Dictionary:
	var data:Dictionary = {
		"title":title.value,
		"text":text.value
	}
	return data
