extends ProgressBar

@export var gauge:Gauge = null :
	set = set_gauge


func set_gauge(new_gauge:Gauge) -> void:
	if gauge:
		gauge.gauge_value_changed.disconnect(_on_gauge_value_changed)
		gauge.gauge_max_value_changed.disconnect(_on_gauge_max_value_changed)
	
	gauge = new_gauge
	_init_gauge()


func _init_gauge() -> void:
	gauge.gauge_value_changed.connect(_on_gauge_value_changed)
	gauge.gauge_max_value_changed.connect(_on_gauge_max_value_changed)
	max_value = gauge.max_value
	value = gauge.current_value


func _on_gauge_value_changed(new_value:float) -> void:
	value = gauge.current_value


func _on_gauge_max_value_changed(new_value:float) -> void:
	max_value = gauge.max_value
