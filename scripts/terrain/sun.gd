extends Node3D

@export var enable_time_passage: bool
@export var world_env : WorldEnvironment
@export var cycle_duration : float = 500
@export var night_color : Color = Color(0.1, 0.1, 0.2)
@export var day_color : Color = Color(0.6, 0.96, 0.9)
@export var day_horizon_color : Color = Color(0.7, 1.0, 0.9)
@export var sun : DirectionalLight3D
@export var moon : DirectionalLight3D
@export var anchor: Node3D

var time_elapsed : float = 0.0

func _process(delta):
	if !enable_time_passage:
		return

	time_elapsed += delta
	var cycle_progress = (time_elapsed / cycle_duration)    
	if cycle_progress >= 1:
		time_elapsed = 0
		cycle_progress = 0

	anchor.rotation_degrees.x = -cycle_progress * 360 * 2

	var intensity = clamp(sin(cycle_progress * 4 * PI), 0.0, 1.0)

	if world_env:
		var sky_material = world_env.environment.sky.get_material()
		if sky_material:
			sky_material.sky_top_color = night_color.lerp(day_color, intensity)
			sky_material.sky_horizon_color = night_color.lerp(day_horizon_color, intensity)
			sky_material.ground_horizon_color = night_color.lerp(day_horizon_color, intensity)
