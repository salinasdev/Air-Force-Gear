extends RefCounted
class_name LevelConfig

const LEVELS: Array[Dictionary] = [
    {"name":"Taiga - mañana", "bg":"bg_taiga_day", "music":"music_taiga", "difficulty":1, "time":"day", "enemies":54, "spawn_min":0.62, "spawn_base":1.30, "speed_mul":0.82, "hp_bonus":-1, "shoot_mul":0.68, "fuel_drain":0.95, "lapsed":false},
    {"name":"Sea - mañana", "bg":"bg_sea_day", "music":"music_sea", "difficulty":1, "time":"day", "enemies":56, "spawn_min":0.60, "spawn_base":1.26, "speed_mul":0.86, "hp_bonus":-1, "shoot_mul":0.72, "fuel_drain":1.00, "lapsed":false},
    {"name":"Tundra - mañana", "bg":"bg_tundra_day", "music":"music_tundra", "difficulty":1, "time":"day", "enemies":58, "spawn_min":0.58, "spawn_base":1.22, "speed_mul":0.90, "hp_bonus":0, "shoot_mul":0.78, "fuel_drain":1.04, "lapsed":false},
    {"name":"Taiga - tarde", "bg":"bg_taiga_after", "music":"music_taiga", "difficulty":2, "time":"after", "enemies":76, "spawn_min":0.44, "spawn_base":1.02, "speed_mul":1.00, "hp_bonus":0, "shoot_mul":1.00, "fuel_drain":1.22, "lapsed":true},
    {"name":"Sea - tarde", "bg":"bg_sea_after", "music":"music_sea", "difficulty":2, "time":"after", "enemies":80, "spawn_min":0.42, "spawn_base":0.98, "speed_mul":1.06, "hp_bonus":0, "shoot_mul":1.08, "fuel_drain":1.27, "lapsed":true},
    {"name":"Tundra - tarde", "bg":"bg_tundra_after", "music":"music_tundra", "difficulty":2, "time":"after", "enemies":84, "spawn_min":0.40, "spawn_base":0.94, "speed_mul":1.12, "hp_bonus":1, "shoot_mul":1.15, "fuel_drain":1.32, "lapsed":true},
    {"name":"Taiga - noche", "bg":"bg_taiga_night", "music":"music_taiga", "difficulty":3, "time":"night", "enemies":104, "spawn_min":0.30, "spawn_base":0.78, "speed_mul":1.28, "hp_bonus":1, "shoot_mul":1.42, "fuel_drain":1.55, "lapsed":true},
    {"name":"Sea - noche", "bg":"bg_sea_night", "music":"music_sea", "difficulty":3, "time":"night", "enemies":112, "spawn_min":0.28, "spawn_base":0.74, "speed_mul":1.38, "hp_bonus":1, "shoot_mul":1.55, "fuel_drain":1.68, "lapsed":true},
    {"name":"Tundra - noche", "bg":"bg_tundra_night", "music":"music_tundra", "difficulty":3, "time":"night", "enemies":120, "spawn_min":0.26, "spawn_base":0.70, "speed_mul":1.48, "hp_bonus":2, "shoot_mul":1.70, "fuel_drain":1.82, "lapsed":true}
]

static func map_original_level_to_remake(idx: int) -> int:
    return clampi(idx, 0, LEVELS.size() - 1)

static func get_config(idx: int) -> Dictionary:
    return LEVELS[map_original_level_to_remake(idx)]

static func is_hard_time(level_time: String) -> bool:
    return level_time == "after" or level_time == "night"
