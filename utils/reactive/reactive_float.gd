class_name ReactiveFloat
extends Reactive

func _init(initial_value:float,initial_owner : Reactive = null) -> void:
	super._init(initial_owner)
	value = initial_value

var value : float:
	set(v):
		value = v
		reactive_changed.emit(self)
		return value
