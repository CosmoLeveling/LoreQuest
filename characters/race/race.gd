class_name Race
extends Reactive

var name:ReactiveString=ReactiveString.new("",self)
var description:ReactiveString=ReactiveString.new("",self)

func _init(init_name):
	name.value = init_name
