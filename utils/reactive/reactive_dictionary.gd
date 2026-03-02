class_name ReactiveDictionary
extends Reactive

func _init(initial_value:Dictionary={},initial_owner : Reactive = null) -> void:
	super._init(initial_owner)
	value = initial_value

var value:Dictionary:
	set(v):
		value = v
		reactive_changed.emit(self)
		return value

func get_at(key : Variant) -> Variant:
	return value[key]

func set_at(key : Variant, v : Variant) -> void:
	value[key] = v
	reactive_changed.emit(self)

func assign(dict:Dictionary) -> void:
	value.assign(dict)
	reactive_changed.emit(self)

func clear() -> void:
	value.clear()
	reactive_changed.emit(self)

func erase(key : Variant) -> void:
	value.erase(key)
	reactive_changed.emit(self)

func sort() -> void:
	value.sort()
	reactive_changed.emit(self)

func has(key:Variant) -> bool:
	return value.has(key)
