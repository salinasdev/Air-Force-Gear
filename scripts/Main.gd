extends Node2D

const W := 320
const H := 480
const SAVE_PATH := "user://as2_records.save"

enum Screen { MENU, LEVELS, GAME, PAUSE, GAME_OVER, LEVEL_COMPLETE, CREDITS }
var menu_item := 0
var level_item := 0
var screen: Screen = Screen.MENU
var level := 1
var selected_level_idx := 0
var selected_level_name := "Taiga mañana"
var score := 0
var high_score := 0
var lives := 3
var health := 100.0
var fuel := 100.0
var fuel_kill_counter := 0
var health_flash_timer := 0.0
var fuel_flash_timer := 0.0
var game_time := 0.0
var spawn_time := 0.0
var item_time := 0.0
var lapsed_time := 0.0
var bg_offset := 0.0
var can_shoot := true
var player_weapon := "normal"
var player_weapon_damage := 1
var player_speed := 210.0
var enemies_to_clear := 28
var killed := 0
var enemies_spawned := 0
var rank_scores: Array[int] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
var tournament_best_score := 0
var dragging := false
var result_anim_time := 0.0
var result_anim_kind := ""
var result_anim_done := false
var extra_flight := false
var tournament_mode := false
var tournament_sequence: Array[int] = [0, 3, 6, 1, 4, 7, 2, 5, 8]
var tournament_pos := 0
var tournament_giant_mode := false
var tournament_bg_key := ""
var tournament_scroll_finished := false
var boss_active := false
var boss_dead := false
var boss_dying := false
var boss_death_timer := 0.0
var boss_death_explode_timer := 0.0
var boss_intro := true
var boss: Dictionary = {}
var boss_attack_time := 0.0
var boss_attack_kind := 0
var boss_sprite_frame := 0
var boss_sprite_timer := 0.0
var boss_missile: Dictionary = {}
var attack_banner: Dictionary = {}
var boss_damage_flash_timer := 0.0
var player_frozen_timer := 0.0
var frozen_effect: Dictionary = {}
var radio_scan: Dictionary = {}
var igneus_attack: Dictionary = {}
var extra_scroll_speed := 62.0

var player: Sprite2D
var player_hit_flash := 0.0
var bullets: Array = []
var enemies: Array = []
var enemy_bullets: Array = []
var items: Array = []
var effects: Array = []
var clouds: Array = []
var stars: Array = []
var rng := RandomNumberGenerator.new()

var tex := {}
var snd := {}
var music: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 6
var current_music_key := ""
var current_level_cfg: Dictionary = {}
var ui_layer: CanvasLayer
var bg1: Sprite2D
var bg2: Sprite2D
var game_root: Node2D

func _ready() -> void:
	get_window().min_size = Vector2i(W, H)
	_setup_input_map()
	rng.randomize()
	_load_resources()
	_load_records()
	_build_base_nodes()
	show_menu()

func _setup_input_map() -> void:
	var defs = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"shoot": [KEY_SPACE],
		"pause": [KEY_P, KEY_ESCAPE]
	}
	for action in defs.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode in defs[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = keycode
			var exists := false
			for old in InputMap.action_get_events(action):
				if old is InputEventKey and old.physical_keycode == keycode:
					exists = true
					break
			if not exists:
				InputMap.action_add_event(action, ev)

func _load_resources() -> void:
	var names = {
		"title":"AFG-MainTitle.png", "title_shadow":"AFG-MainTitle-Shadow.png", "logo":"AFG-NewTitle_100.png",
		"menu_panel":"AFG-MainTitle-Shadow.png", "menu_options":"AFG-AllOptionsExtra.png", "menu_selector":"AFG-TitleSelectBar.png",
		"sound_icon":"sonido2.png", "levels_bg":"AFG-Levels.png", "level_select":"AFG-Levels-Select.png", "credits_bg":"AFG-credits.png",
		"ranking_default":"AFG-Ranking_Default.png", "ranking_tournament":"AFG-Ranking_Tournament.png", "ranking_unlocked":"AFG-Ranking_Desbloqueado.png", "rank_reset":"AFG-ReiniciarRanking.png",
		"rank1":"AFG-R1.png", "rank2":"AFG-R2.png", "rank3":"AFG-R3.png", "rank4":"AFG-R4.png",
		"fade1":"b1.png", "fade2":"b2.png", "fade3":"b3.png", "fade4":"b4.png", "fade5":"b5.png",
		"player":"av1.png", "player_l":"avizq.png", "player_r":"avder.png",
		"bullet":"bnormal.png", "bullet_normal":"bnormal.png", "bullet_mave":"bmave.png", "bullet_harry":"bharry.png", "enemy_bullet":"dispEne.png", "enemy_bullet_mave":"emave.png", "enemy_bullet_harry":"eharry.png", "enemy1":"e1.png", "enemy2":"e2.png", "enemy3":"e3.png", "enemy4":"e4.png", "enemy5":"e5.png", "enemy6":"e6.png", "enemy7":"e7.png",
		"bg_taiga_day":"fondo1_day.png", "bg_sea_day":"sea.png", "bg_tundra_day":"Tundra.png",
		"bg_sea_taiga":"AFG-Sea-Taiga.png", "bg_taiga_tundra":"AFG-Taiga-Tundra.png", "bg_tournament_route":"AFG-Tournament-Route.png",
		"bg_taiga_after":"AFG-TaigaAfternoon.png", "bg_sea_after":"sea-afternoon.png", "bg_tundra_after":"TundraAfternoon.png",
		"bg_taiga_night":"AFG-TaigaNight.png", "bg_sea_night":"sea-night.png", "bg_tundra_night":"TundraNight.png",
		"weapon_item_normal":"inormal.png", "weapon_item_mave":"imave.png", "weapon_item_harry":"iharry.png", "weapon_msg_normal":"mnormal.png", "weapon_msg_mave":"mmave.png", "weapon_msg_harry":"mharry.png", "fuel":"iFuel.png", "lapsed_fuel":"lficon.png", "lapsed_fuel_effect":"AFG-AnimLapsedFuel.png", "fuel_pickup":"mfuel.png", "fuel_bar":"AFG-Fuel.png", "life_bar":"AFG-Vida.png", "fuel_damage":"AFG-DanoFuel.png", "life_damage":"AFG-DanoVida.png", "heart":"irepa.png", "enemy_die":"AFG-EnemyDie.png", "player_die":"AFG-ProtaDie.png", "level_completed":"AFG-LevelCompleted.png", "level_game_over":"AFG-LevelGameOver.png", "gameover_small":"gameover.png",
		"cloud1":"nube1.png", "cloud2":"nube2.png", "cloud3":"nube3.png", "storm":"AFG-Storm.png", "bg_extra":"AFG-DestroyedMetropolis2.png", "acorazado":"AFG-acorazado43.png", "boss_explosion":"AFG-boss-explosiones.png", "boss_missile":"AFG-misil.png", "ice_bala":"AFG-ice_bala.png", "ice_charge":"AFG-ice_carga.png", "boss_attack_banner":"AFG-carteles-especiales.png", "frozen":"AFG-congelado.png", "radiolocation":"AFG-radiolocation.png", "igneus_charge":"AFG-igneousbreath-carga.png", "igneus_breath":"AFG-igneousbreath.png"
	}
	for k in names.keys():
		var p = "res://assets/" + names[k]
		if ResourceLoader.exists(p): tex[k] = load(p)
	var sounds = {"shot":"AFG-ProtaShots.ogg", "hit":"AFG-DamagePlane.wav", "boom":"AFG-EnemyDestroyPlane.wav", "select":"AFG-SelectOption.wav", "accept":"AFG-AcceptOption.ogg", "menu":"AFG-Main Title.mp3", "music":"AFG-Taiga.mp3", "music_taiga":"AFG_Taiga.ogg", "music_sea":"AFG-Sea.mp3", "music_tundra":"AFG- Tundra.mp3", "over":"AFG- Game Over.mp3", "complete":"AFG- Level Completed.mp3", "lapsed":"AFG-LapsedFuel.wav", "depleted":"AFG-DepletedFuel.wav", "lowfuel":"AFG-AlertaFuel.ogg", "music_extra":"Destroyed Metropolis.mp3", "music_tournament":"AFG-Tournament.mp3"}
	for k in sounds.keys():
		var p = "res://assets/" + sounds[k]
		if ResourceLoader.exists(p): snd[k] = load(p)

func _build_base_nodes() -> void:
	music = AudioStreamPlayer.new(); add_child(music)
	music.finished.connect(_on_music_finished)
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_pool.append(p)
	game_root = Node2D.new(); add_child(game_root)
	ui_layer = CanvasLayer.new(); add_child(ui_layer)

func clear_all() -> void:
	for c in game_root.get_children(): c.queue_free()
	for c in ui_layer.get_children(): c.queue_free()
	bullets.clear(); enemies.clear(); enemy_bullets.clear(); items.clear(); effects.clear(); clouds.clear(); stars.clear(); boss.clear(); boss_missile.clear(); _clear_attack_banner(); _clear_radio_scan(); boss_active = false; boss_dead = false; boss_dying = false; boss_death_timer = 0.0; boss_death_explode_timer = 0.0; boss_intro = true

func play_music(key: String) -> void:
	if not snd.has(key): return
	current_music_key = key
	if music.stream == snd[key] and music.playing: return
	music.stop(); music.stream = snd[key]; music.play()

func _on_music_finished() -> void:
	# Los temas de niveles normales deben ir en bucle como en Android.
	# También dejamos en bucle menú y Extra Flight; Game Over/Completed no se re-lanzan.
	if current_music_key in ["music_taiga", "music_sea", "music_tundra", "music", "menu", "music_extra", "music_tournament"]:
		if snd.has(current_music_key):
			music.stream = snd[current_music_key]
			music.play()

func play_sfx(key: String) -> void:
	if not snd.has(key): return
	for p in sfx_pool:
		if not p.playing:
			p.stream = snd[key]
			p.play()
			return
	# Todos ocupados: reutiliza el primero del pool
	sfx_pool[0].stream = snd[key]
	sfx_pool[0].play()

func show_menu() -> void:
	screen = Screen.MENU; clear_all(); game_root.visible = false; play_music("menu")
	menu_item = 0
	_image("title", Vector2(0,0), ui_layer)
	_image("logo", Vector2(25,110), ui_layer)
	var de_lbl := _label("✦  Definitive Edition  ✦", Vector2(0, 168), 11, Color(1.0, 0.88, 0.35), true)
	de_lbl.add_theme_color_override("font_shadow_color", Color(0.3, 0.18, 0.0, 0.85))
	de_lbl.add_theme_constant_override("shadow_offset_x", 1)
	de_lbl.add_theme_constant_override("shadow_offset_y", 1)
	var mp = _image("menu_panel", Vector2(70,210), ui_layer); mp.z_index = 0
	_draw_menu_selector()
	var mo = _image("menu_options", Vector2(78,220), ui_layer); mo.z_index = 2
	_image_region("sound_icon", Vector2(W-40,0), Rect2(0,0,38,32), ui_layer)
	var rects = [
		Rect2(78,220,175,25), Rect2(78,249,175,25), Rect2(78,278,175,25),
		Rect2(78,307,175,25), Rect2(78,336,175,25), Rect2(78,365,175,25)
	]
	for i in range(rects.size()):
		_hotspot(rects[i], Callable(self, "_on_menu_option_pressed").bind(i))

func _on_menu_option_pressed(idx:int) -> void:
	if screen != Screen.MENU:
		return
	if menu_item != idx:
		menu_item = idx
		play_sfx("select")
		_draw_menu_selector()
		return
	match idx:
		0:
			show_levels()
		1:
			start_extra_flight()
		2:
			start_tournament()
		3:
			show_records()
		4:
			show_credits()
		5:
			get_tree().quit()

func _on_level_option_pressed(idx:int) -> void:
	if screen != Screen.LEVELS:
		return
	if level_item != idx:
		level_item = idx
		play_sfx("select")
		_draw_level_selector()
		return
	start_game(_map_original_level_to_remake(idx))

func _draw_menu_selector() -> void:
	var old = ui_layer.get_node_or_null("MenuSelector")
	if old: old.free()
	var s = _image("menu_selector", Vector2(0,220 + 29 * menu_item), ui_layer)
	s.z_index = 1
	s.name = "MenuSelector"

func show_levels() -> void:
	screen = Screen.LEVELS; clear_all(); game_root.visible = false; play_sfx("select")
	level_item = 0
	_image("levels_bg", Vector2(0,0), ui_layer)
	_draw_level_selector()
	var rects = [
		Rect2(8,118,65,66), Rect2(128,118,65,66), Rect2(247,118,65,66),
		Rect2(8,214,65,66), Rect2(128,214,65,66), Rect2(247,214,65,66),
		Rect2(8,310,65,66), Rect2(128,310,65,66), Rect2(247,310,65,66)
	]
	for i in range(rects.size()):
		_hotspot(rects[i], Callable(self, "_on_level_option_pressed").bind(i))
	_hotspot(Rect2(110,450,120,30), func(): show_menu())

func _draw_level_selector() -> void:
	var old = ui_layer.get_node_or_null("LevelSelector")
	if old: old.free()
	var positions = [Vector2(8,118), Vector2(128,118), Vector2(247,118), Vector2(8,214), Vector2(128,214), Vector2(247,214), Vector2(8,310), Vector2(128,310), Vector2(247,310)]
	var s = _image_region("level_select", positions[level_item], Rect2(65 * level_item, 0, 65, 66), ui_layer)
	s.name = "LevelSelector"

func _map_original_level_to_remake(idx:int) -> int:
	# Conserva los 9 botones originales: 3 escenarios x 3 momentos del día.
	return LevelConfig.map_original_level_to_remake(idx)

func _level_config(idx:int) -> Dictionary:
	return LevelConfig.get_config(idx)

func show_records() -> void:
	screen = Screen.CREDITS
	clear_all()
	game_root.visible = false
	_draw_ranking_screen()

func _draw_ranking_screen() -> void:
	for c in ui_layer.get_children():
		c.queue_free()
	# Port 1:1: always use the original unlocked ranking board as the base art.
	_image("ranking_unlocked", Vector2(0, 0), ui_layer)
	# Visual order from AFG-Ranking_Desbloqueado.png:
	# Taiga, Sea Night, Tundra, Taiga Afternoon, Sea, Tundra Afternoon,
	# Taiga Night, Sea Afternoon, Tundra Night, Tournament, Destroyed Metropolis.
	var original_order: Array[int] = [0, 7, 2, 3, 1, 5, 6, 4, 8]
	var y_positions: Array[int] = [157, 176, 195, 214, 233, 252, 272, 291, 309]
	for i in range(original_order.size()):
		var level_index: int = original_order[i]
		var rank_value: int = clampi(rank_scores[level_index], 1, 4)
		_image(_rank_asset_key(rank_value), Vector2(235, y_positions[i]), ui_layer)

	# Tournament keeps a numeric best score in its own slot.
	# Center it inside the original board cell so it aligns with the R1-R4 badges.
	var tournament_label := _label("%06d" % tournament_best_score, Vector2(235, 328), 8, Color.WHITE, false, "TournamentBest")
	tournament_label.size = Vector2(75, 12)
	tournament_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tournament_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tournament_label.z_index = 20

	# Extra Flight / Destroyed Metropolis uses the same R1-R4 system as normal stages.
	var destroyed_rank: int = clampi(rank_scores[9], 1, 4)
	_image(_rank_asset_key(destroyed_rank), Vector2(235, 348), ui_layer)

	_hotspot(Rect2(0, H - 34, 145, 34), func(): show_menu())
	_hotspot(Rect2(175, H - 34, 145, 34), Callable(self, "_reset_ranking"))

func _ranking_background_key() -> String:
	return "ranking_unlocked"

func _rank_asset_key(rank_value: int) -> String:
	return "rank%d" % clampi(rank_value, 1, 4)

func _reset_ranking() -> void:
	rank_scores = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	tournament_best_score = 0
	_save_records()
	play_sfx("accept")
	_draw_ranking_screen()

func show_credits() -> void:
	screen = Screen.CREDITS; clear_all(); game_root.visible = false
	_image("credits_bg", Vector2(0,0), ui_layer)
	_hotspot(Rect2(0,0,W,H), func(): show_menu())

func start_game(level_idx:int) -> void:
	tournament_mode = false
	tournament_giant_mode = false
	_start_normal_level(level_idx, true)

func start_tournament() -> void:
	# Port 1:1: Tournament is one long daytime stage, not separate levels.
	# Route: Sea -> Sea/Taiga transition -> Taiga -> Taiga/Tundra transition -> Tundra.
	tournament_mode = true
	tournament_giant_mode = true
	extra_flight = false
	tournament_pos = 0
	current_level_cfg = {
		"name":"Tournament",
		"bg":"bg_tournament_route",
		"music":"music_tournament",
		"difficulty":2,
		"time":"day",
		"enemies":240,
		"spawn_min":0.34,
		"spawn_base":0.86,
		"speed_mul":1.08,
		"hp_bonus":0,
		"shoot_mul":1.04,
		"fuel_drain":0.92,
		"lapsed":false
	}
	screen = Screen.GAME
	clear_all()
	game_root.visible = true
	play_music("music_tournament")
	selected_level_idx = 0
	selected_level_name = "Tournament"
	level = 2
	score = 0
	lives = 3
	health = 100.0
	fuel = 100.0
	player_weapon = "normal"
	player_weapon_damage = 1
	fuel_kill_counter = 0
	health_flash_timer = 0.0
	fuel_flash_timer = 0.0
	player_frozen_timer = 0.0
	_clear_frozen_effect()
	game_time = 0.0
	lapsed_time = _next_lapsed_delay()
	spawn_time = 0.0
	item_time = 0.0
	killed = 0
	enemies_spawned = 0
	enemies_to_clear = int(current_level_cfg["enemies"])
	tournament_bg_key = "bg_tournament_route"
	tournament_scroll_finished = false
	_add_background(tournament_bg_key)
	_spawn_clouds()
	player = _sprite("player", Vector2(W/2,H-65), game_root)
	player.z_index = 5
	_make_ui_game()

func _start_tournament_stage(reset_stats: bool=false) -> void:
	# Kept only for compatibility with older save/menu flow.
	start_tournament()

func _start_normal_level(level_idx:int, reset_stats: bool) -> void:
	tournament_giant_mode = false
	tournament_scroll_finished = false
	extra_flight = false
	var cfg := _level_config(level_idx)
	current_level_cfg = cfg.duplicate(true)
	screen = Screen.GAME
	clear_all()
	game_root.visible = true
	play_music(str(cfg["music"]))
	selected_level_idx = level_idx
	selected_level_name = str(cfg["name"])
	level = int(cfg["difficulty"])
	if reset_stats:
		score = 0
		lives = 3
		health = 100.0
		fuel = 100.0
		player_weapon = "normal"
		player_weapon_damage = 1
	fuel_kill_counter = 0
	health_flash_timer = 0.0
	fuel_flash_timer = 0.0
	player_frozen_timer = 0.0
	_clear_frozen_effect()
	health = clampf(health, 1.0, 100.0)
	fuel = clampf(fuel, 1.0, 100.0)
	lives = max(1, int(ceil(health / 34.0)))
	game_time = 0.0
	lapsed_time = _next_lapsed_delay()
	spawn_time = 0.0
	item_time = 0.0
	killed = 0
	enemies_spawned = 0
	enemies_to_clear = int(cfg.get("enemies", 38 + level * 18))
	_add_background(str(cfg["bg"]))
	_spawn_clouds()
	player = _sprite("player", Vector2(W/2,H-65), game_root)
	player.z_index = 5
	_make_ui_game()

func start_extra_flight() -> void:
	tournament_mode = false
	tournament_giant_mode = false
	extra_flight = true
	current_level_cfg = {}
	screen = Screen.GAME
	clear_all()
	game_root.visible = true
	play_music("music_extra")
	selected_level_idx = 9
	selected_level_name = "Extra Flight - Metropolis destruida"
	level = 4
	score = 0
	lives = 3
	health = 100.0
	fuel = 100.0
	fuel_kill_counter = 0
	player_weapon = "normal"
	player_weapon_damage = 1
	health_flash_timer = 0.0
	fuel_flash_timer = 0.0
	boss_damage_flash_timer = 0.0
	player_frozen_timer = 0.0
	_clear_frozen_effect()
	game_time = 0.0
	spawn_time = 0.0
	item_time = 0.0
	lapsed_time = 7.0
	killed = 0
	enemies_spawned = 0
	enemies_to_clear = 70
	_add_background("bg_extra")
	player = _sprite("player", Vector2(W / 2, H - 65), game_root)
	player.z_index = 5
	_make_ui_game()

func _process(delta: float) -> void:
	if screen == Screen.GAME:
		_update_game(delta)
	elif screen == Screen.PAUSE:
		if Input.is_action_just_pressed("pause"): resume_game()
	elif screen == Screen.GAME_OVER or screen == Screen.LEVEL_COMPLETE:
		_update_result_animation(delta)

func _unhandled_input(event: InputEvent) -> void:
	if screen == Screen.GAME and event.is_action_pressed("pause"):
		pause_game()
	elif screen == Screen.GAME and event is InputEventScreenTouch:
		dragging = event.pressed
	elif screen == Screen.GAME and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed

func _update_game(delta: float) -> void:
	var drain_mul: float = float(current_level_cfg.get("fuel_drain", 1.0))
	game_time += delta; spawn_time -= delta; item_time -= delta; fuel -= delta * (0.82 + level * 0.22 + (0.35 if extra_flight else 0.0)) * drain_mul; player_hit_flash = max(0, player_hit_flash - delta); health_flash_timer = max(0, health_flash_timer - delta); fuel_flash_timer = max(0, fuel_flash_timer - delta); boss_damage_flash_timer = max(0, boss_damage_flash_timer - delta); player_frozen_timer = max(0, player_frozen_timer - delta)
	_scroll_background(delta)
	if tournament_giant_mode:
		_update_tournament_background()
	_move_clouds(delta)
	_control_player(delta)
	if can_shoot and (Input.is_action_pressed("shoot") or dragging): _fire_player()
	if spawn_time <= 0:
		if extra_flight:
			if not boss_active and not boss_dead and enemies_spawned < enemies_to_clear:
				_spawn_enemy()
				spawn_time = 1.00
		else:
			_spawn_enemy()
			var spawn_min: float = float(current_level_cfg.get("spawn_min", 0.20))
			var spawn_base: float = float(current_level_cfg.get("spawn_base", 1.15 - level * 0.20))
			spawn_time = max(spawn_min, spawn_base - game_time * 0.0025)
	if bool(current_level_cfg.get("lapsed", level >= 2)):
		lapsed_time -= delta
		if lapsed_time <= 0.0:
			_spawn_lapsed_fuel()
			lapsed_time = _next_lapsed_delay()
	# El fuel ya no aparece por temporizador: lo sueltan algunos enemigos al morir.
	_update_bullets(delta); _update_enemies(delta); _update_boss(delta); _update_items(delta); _update_effects(delta); _check_collisions(); _refresh_hud()
	if fuel <= 0:
		fuel = 0
		game_over()
	if health <= 0 or lives <= 0: game_over()
	if extra_flight:
		# Port 1:1 original Extra Flight: the Acorazado appears only after
		# all 70 regular enemies have been created and none remain alive/on screen.
		if enemies_spawned >= enemies_to_clear and enemies.size() == 0 and not boss_active and not boss_dead and not boss_dying:
			_spawn_boss()
		elif boss_dead and not boss_dying:
			level_complete()
	elif killed >= enemies_to_clear:
		level_complete()

func _control_player(delta: float) -> void:
	var v := Vector2.ZERO
	if player_frozen_timer <= 0.0:
		if Input.is_action_pressed("move_left"): v.x -= 1
		if Input.is_action_pressed("move_right"): v.x += 1
		if Input.is_action_pressed("move_up"): v.y -= 1
		if Input.is_action_pressed("move_down"): v.y += 1
		if dragging:
			var target := get_viewport().get_mouse_position()
			player.position = player.position.lerp(target, min(1, 12*delta))
		elif v.length() > 0:
			player.position += v.normalized() * player_speed * delta
	player.position.x = clamp(player.position.x, 22, W-22); player.position.y = clamp(player.position.y, 60, H-35)
	player.texture = tex.get("player", null)
	if v.x < 0: player.texture = tex.get("player_l", player.texture)
	elif v.x > 0: player.texture = tex.get("player_r", player.texture)
	player.modulate = Color(1,0.55,0.55) if player_hit_flash > 0 else Color.WHITE

func _fire_player() -> void:
	can_shoot = false
	var fire_rate := 0.18
	if player_weapon == "mave":
		fire_rate = 0.17
	elif player_weapon == "harry":
		fire_rate = 0.16
	get_tree().create_timer(fire_rate).timeout.connect(func(): can_shoot = true)
	var bullet_key := _player_bullet_key()
	var offsets: Array[float] = [-9.0, 9.0]
	if player_weapon == "mave":
		offsets = [-12.0, 12.0]
	elif player_weapon == "harry":
		offsets = [-15.0, 0.0, 15.0]
	for off in offsets:
		var b = _sprite(bullet_key, player.position + Vector2(off,-26), game_root)
		b.z_index = 4
		b.scale = Vector2(1.1,1.1)
		bullets.append({"node":b, "speed":420.0, "damage":player_weapon_damage, "weapon":player_weapon})
	play_sfx("shot")

func _player_bullet_key() -> String:
	if player_weapon == "harry" and tex.has("bullet_harry"):
		return "bullet_harry"
	if player_weapon == "mave" and tex.has("bullet_mave"):
		return "bullet_mave"
	return "bullet_normal" if tex.has("bullet_normal") else "bullet"

# Elige patrón de movimiento según la dificultad del nivel:
# straight = bajada sinusoidal suave (clásico)
# zigzag   = oscilación lateral amplia y rápida
# dive     = persigue la X del jugador mientras baja
# strafe   = entra desde un lateral cruzando la pantalla
func _pick_enemy_pattern() -> String:
	var r := rng.randf()
	if level <= 1:
		if r < 0.70: return "straight"
		if r < 0.90: return "zigzag"
		return "dive"
	if level == 2:
		if r < 0.38: return "straight"
		if r < 0.63: return "zigzag"
		if r < 0.83: return "dive"
		return "strafe"
	if r < 0.18: return "straight"
	if r < 0.43: return "zigzag"
	if r < 0.68: return "dive"
	return "strafe"

# Elige patrón de disparo según dificultad:
# straight = bala recta hacia abajo
# aimed    = bala apuntada al jugador
# spread3  = abanico de 3 balas
func _pick_enemy_shot_type() -> String:
	var r := rng.randf()
	if level <= 1:
		return "aimed" if r < 0.12 else "straight"
	if level == 2:
		if r < 0.10: return "spread3"
		if r < 0.32: return "aimed"
		return "straight"
	if r < 0.20: return "spread3"
	if r < 0.52: return "aimed"
	return "straight"

func _spawn_enemy() -> void:
	var type := rng.randi_range(1, min(7, 2 + min(level, 3) * 2))
	var speed_mul: float = float(current_level_cfg.get("speed_mul", 1.0))
	var shoot_mul: float = float(current_level_cfg.get("shoot_mul", 1.0))
	var pattern := _pick_enemy_pattern()
	var shot_type := _pick_enemy_shot_type()
	var vx := 0.0
	var spawn_pos: Vector2
	if pattern == "strafe":
		var from_left := rng.randf() < 0.5
		spawn_pos = Vector2(-30.0 if from_left else W + 30.0, rng.randf_range(50.0, 220.0))
		vx = rng.randf_range(65.0, 105.0) * speed_mul * (1.0 if from_left else -1.0)
	else:
		spawn_pos = Vector2(rng.randf_range(36.0, W - 36.0), -30.0)
	var e = _sprite("enemy%d" % type, spawn_pos, game_root)
	e.z_index = 3
	if pattern == "strafe":
		e.flip_h = (vx < 0.0)
	var hp := 1 + int(type / 3) + level - 1 + int(current_level_cfg.get("hp_bonus", 0))
	hp = max(1, hp)
	if level == 3 and rng.randf() < 0.25:
		hp += 1
	var speed := rng.randf_range(42.0 + level * 18.0, 88.0 + level * 32.0) * speed_mul
	var drift := rng.randf_range(-30.0, 30.0) * speed_mul
	if pattern == "zigzag":
		drift = rng.randf_range(60.0, 100.0) * speed_mul
	enemies_spawned += 1
	var shoot_delay: float = rng.randf_range(0.95, 2.9) / max(0.1, shoot_mul)
	var enemy_weapon := _random_enemy_weapon()
	enemies.append({"node":e, "hp":hp, "speed":speed, "drift":drift, "shoot":shoot_delay,
		"score":100*hp, "weapon":enemy_weapon, "pattern":pattern, "shot_type":shot_type, "vx":vx})

func _spawn_item() -> void:
	_spawn_fuel_drop(Vector2(rng.randf_range(28,W-28), -20))

func _spawn_fuel_drop(pos:Vector2) -> void:
	var it = _sprite("fuel", pos, game_root)
	it.z_index = 4
	it.scale = Vector2(1.0, 1.0)
	items.append({"node":it, "kind":"fuel", "speed":70.0})

func _spawn_lapsed_fuel() -> void:
	if not tex.has("lapsed_fuel"):
		return
	var it := _sprite("lapsed_fuel", Vector2(rng.randf_range(28.0, W - 28.0), -20.0), game_root)
	it.z_index = 4
	it.scale = Vector2(1.0, 1.0)
	items.append({"node":it, "kind":"lapsed_fuel", "speed":80.0 + level * 18.0})


func _spawn_weapon_drop(pos:Vector2, weapon:String) -> void:
	var key := _weapon_item_key(weapon)
	if not tex.has(key):
		return
	var it := _sprite(key, pos, game_root)
	it.z_index = 4
	it.scale = Vector2(1.0, 1.0)
	items.append({"node":it, "kind":"weapon", "weapon":weapon, "speed":74.0 + level * 8.0})

func _next_lapsed_delay() -> float:
	if level < 2:
		return 9999.0
	return rng.randf_range(8.0, 13.0) if level == 2 else rng.randf_range(4.8, 8.0)

func _random_enemy_weapon() -> String:
	# Algunos enemigos nacen con disparos potenciados. En día casi no ocurre;
	# en tarde aumenta, y en noche es bastante más frecuente.
	var r := rng.randf()
	if level <= 1:
		return "mave" if r < 0.04 else "normal"
	if level == 2:
		if r < 0.04:
			return "harry"
		if r < 0.18:
			return "mave"
		return "normal"
	if r < 0.12:
		return "harry"
	if r < 0.38:
		return "mave"
	return "normal"

func _enemy_bullet_key(weapon:String) -> String:
	if weapon == "harry":
		return "enemy_bullet_harry" if tex.has("enemy_bullet_harry") else ("bullet_harry" if tex.has("bullet_harry") else "enemy_bullet")
	if weapon == "mave":
		return "enemy_bullet_mave" if tex.has("enemy_bullet_mave") else ("bullet_mave" if tex.has("bullet_mave") else "enemy_bullet")
	return "enemy_bullet"

func _weapon_damage(weapon:String) -> int:
	if weapon == "harry":
		return 3
	if weapon == "mave":
		return 2
	return 1

func _weapon_item_key(weapon:String) -> String:
	if weapon == "harry":
		return "weapon_item_harry"
	if weapon == "mave":
		return "weapon_item_mave"
	return "weapon_item_normal"

func _random_weapon_drop() -> String:
	var r := rng.randf()
	# El normal también puede molestar porque baja el arma si llevas una superior.
	if level <= 1:
		if r < 0.62:
			return "normal"
		if r < 0.91:
			return "mave"
		return "harry"
	if level == 2:
		if r < 0.46:
			return "normal"
		if r < 0.84:
			return "mave"
		return "harry"
	if r < 0.34:
		return "normal"
	if r < 0.74:
		return "mave"
	return "harry"

func _weapon_drop_chance() -> float:
	if level <= 1:
		return 0.025
	if level == 2:
		return 0.040
	return 0.060

func _health_drop_chance() -> float:
	# Raro en niveles fáciles, algo más frecuente en los difíciles donde el daño escala.
	if level <= 1:
		return 0.015
	if level == 2:
		return 0.025
	return 0.038

func _spawn_clouds() -> void:
	for i in range(6):
		var key = "cloud%d" % rng.randi_range(1,3)
		if tex.has(key):
			var c = _sprite(key, Vector2(rng.randf_range(0,W), rng.randf_range(0,H)), game_root)
			c.z_index = 2; c.modulate.a = 0.45; c.scale = Vector2(0.7,0.7)
			clouds.append({"node":c, "speed":rng.randf_range(15,35)})

func _update_bullets(delta: float) -> void:
	for arr in [bullets, enemy_bullets]:
		for i in range(arr.size()-1, -1, -1):
			var d = arr[i]; var n: Sprite2D = d.node
			n.position.y += (-d.speed if arr == bullets else d.speed) * delta
			if arr == enemy_bullets:
				n.position.x += float(d.get("vx", 0.0)) * delta
			if n.position.y < -30 or n.position.y > H + 30 or n.position.x < -40 or n.position.x > W + 40:
				n.queue_free(); arr.remove_at(i)

func _update_enemies(delta: float) -> void:
	for i in range(enemies.size()-1, -1, -1):
		var d = enemies[i]; var n: Sprite2D = d.node
		var pattern: String = str(d.get("pattern", "straight"))
		match pattern:
			"straight":
				n.position.y += d.speed * delta
				n.position.x += sin(game_time * 2.0 + n.position.y * 0.03) * d.drift * delta
			"zigzag":
				n.position.y += d.speed * delta
				n.position.x += sin(game_time * 3.5 + n.position.y * 0.05) * d.drift * delta
			"dive":
				n.position.y += d.speed * delta
				if is_instance_valid(player):
					n.position.x = move_toward(n.position.x, player.position.x, d.speed * 0.55 * delta)
			"strafe":
				n.position.y += d.speed * 0.30 * delta
				n.position.x += float(d.get("vx", 0.0)) * delta
		if pattern != "strafe":
			n.position.x = clamp(n.position.x, 10.0, float(W) - 10.0)
		d.shoot -= delta
		if d.shoot <= 0 and n.position.y > 20 and n.position.y < H - 120:
			var eweapon: String = str(d.get("weapon", "normal"))
			var shoot_mul: float = float(current_level_cfg.get("shoot_mul", 1.0))
			var edamage := _weapon_damage(eweapon)
			var bspeed := (150.0 + level * 28.0) * (0.9 + shoot_mul * 0.18)
			var shot_type: String = str(d.get("shot_type", "straight"))
			match shot_type:
				"aimed":
					if is_instance_valid(player):
						var dir := (player.position - n.position).normalized()
						var eb = _sprite(_enemy_bullet_key(eweapon), n.position + Vector2(0, 18), game_root)
						eb.z_index = 4
						enemy_bullets.append({"node":eb, "speed":bspeed * max(0.35, dir.y), "vx":bspeed * dir.x, "kind":"enemy_weapon", "weapon":eweapon, "damage":edamage})
				"spread3":
					for angle_deg in [-20, 0, 20]:
						var dir := Vector2(sin(deg_to_rad(float(angle_deg))), cos(deg_to_rad(float(angle_deg))))
						var eb = _sprite(_enemy_bullet_key(eweapon), n.position + Vector2(0, 18), game_root)
						eb.z_index = 4
						enemy_bullets.append({"node":eb, "speed":bspeed * dir.y, "vx":bspeed * dir.x, "kind":"enemy_weapon", "weapon":eweapon, "damage":edamage})
				_:
					var eb = _sprite(_enemy_bullet_key(eweapon), n.position + Vector2(0, 18), game_root)
					eb.z_index = 4
					enemy_bullets.append({"node":eb, "speed":bspeed, "vx":0.0, "kind":"enemy_weapon", "weapon":eweapon, "damage":edamage})
			d.shoot = rng.randf_range(1.7 - level * 0.16, 3.6 - level * 0.22) / max(0.1, shoot_mul)
		if n.position.y > H + 40 or n.position.x < -60.0 or n.position.x > float(W) + 60.0:
			n.queue_free(); enemies.remove_at(i)

func _update_items(delta: float) -> void:
	for i in range(items.size()-1, -1, -1):
		var d=items[i]; var n:Sprite2D=d.node; n.position.y += d.speed*delta
		if d.kind == "fuel":
			n.rotation += delta*2
		elif d.kind == "lapsed_fuel":
			n.rotation -= delta * 2.0
		elif d.kind == "weapon":
			n.rotation += delta * 1.3
		elif d.kind == "boss_missile":
			d.anim += delta * 8.0
			var mf: int = int(floor(d.anim)) % 2
			n.region_rect = Rect2(10 * mf, 0, 10, 51)
			if is_instance_valid(player):
				n.position.x = move_toward(n.position.x, player.position.x, 105.0 * delta)
		if n.position.y > H+30: n.queue_free(); items.remove_at(i)

func _update_effects(delta: float) -> void:
	for i in range(effects.size()-1, -1, -1):
		var d=effects[i]; var n:Sprite2D=d.node
		if d.has("kind") and d.kind == "fuel_pickup":
			d.cont += delta * 60.0
			n.position = player.position + d.offset
			if d.cont < 10.0:
				d.offset.y -= 60.0 * delta
				if d.cont <= 50.0 and d.cass > 0:
					d.cass = max(0, d.cass - int(delta * 18.0 + 1.0))
			elif d.cont > 90.0:
				d.cass = min(4, d.cass + int(delta * 18.0 + 1.0))
			n.region_rect = Rect2(0, d.cass * d.sy, d.sx, d.sy)
			n.modulate.a = clamp(1.0 - max(0.0, d.cont - 82.0) / 18.0, 0.0, 1.0)
			if d.cont >= 100.0:
				n.queue_free(); effects.remove_at(i)
		elif d.has("kind") and d.kind == "lapsed_fuel_effect":
			d.time += delta
			if is_instance_valid(player):
				n.position = player.position + d.offset
			var lframe: int = int(floor(float(d.time) * float(d.fps)))
			if lframe >= int(d.frames):
				n.queue_free(); effects.remove_at(i)
			else:
				n.region_rect = Rect2(float(lframe * int(d.sx)), 0.0, float(d.sx), float(d.sy))
				n.modulate.a = clamp(1.0 - float(lframe) / float(d.frames), 0.25, 1.0)
		elif d.has("kind") and d.kind == "weapon_msg":
			d.time += delta
			if is_instance_valid(player):
				n.position = player.position + d.offset
			var wframe: int = int(floor(float(d.time) * float(d.fps)))
			if wframe >= int(d.frames):
				n.queue_free(); effects.remove_at(i)
			else:
				n.region_rect = Rect2(0.0, float(wframe * int(d.sy)), float(d.sx), float(d.sy))
				n.modulate.a = 1.0
		elif d.has("kind") and d.kind == "enemy_die":
			d.time += delta
			var frame: int = int(floor(float(d.time) * float(d.fps)))
			if frame >= int(d.frames):
				if d.has("base") and is_instance_valid(d.base):
					d.base.queue_free()
				n.queue_free(); effects.remove_at(i)
			else:
				n.region_rect = Rect2(float(frame * int(d.sx)), 0.0, float(d.sx), float(d.sy))
		elif d.has("kind") and d.kind == "boss_explosion":
			d.time += delta
			var frame_boss: int = int(floor(float(d.time) * float(d.fps)))
			if frame_boss >= int(d.frames):
				n.queue_free(); effects.remove_at(i)
			else:
				n.region_rect = Rect2(float(frame_boss * int(d.sx)), 0.0, float(d.sx), float(d.sy))
		else:
			d.life -= delta; n.scale += Vector2(delta*1.8, delta*1.8); n.modulate.a = max(0,d.life/d.maxlife)
			if d.life <= 0: n.queue_free(); effects.remove_at(i)
	_update_frozen_effect(delta)

func _update_frozen_effect(delta: float) -> void:
	if frozen_effect.is_empty():
		return
	if not frozen_effect.has("node") or not is_instance_valid(frozen_effect["node"]):
		frozen_effect.clear()
		return
	if player_frozen_timer <= 0.0:
		_clear_frozen_effect()
		return
	var fr := frozen_effect["node"] as Sprite2D
	frozen_effect["anim"] = float(frozen_effect["anim"]) + delta * 8.0
	var frame: int = int(floor(float(frozen_effect["anim"]))) % 4
	fr.position = player.position
	fr.region_rect = Rect2(frame * 98, 0, 98, 118)

func _spawn_boss() -> void:
	boss_active = true
	boss_dead = false
	boss_intro = true
	enemies.clear()
	for n in game_root.get_children():
		if n is Sprite2D and n.z_index == 3:
			n.queue_free()
	var b := _sprite("acorazado", Vector2(35, -280), game_root)
	b.centered = false
	b.z_index = 4
	b.region_enabled = true
	b.region_rect = Rect2(0, 0, 243, 180)
	boss = {"node": b, "hp": 200, "dir": 1.0, "shoot": 1.0, "attack": 2.0, "state": "intro"}

func _update_boss(delta: float) -> void:
	# --- Secuencia espectacular de muerte ---
	if boss_dying:
		if not boss.has("node") or not is_instance_valid(boss["node"] as Sprite2D):
			boss_dying = false; boss_dead = true
			return
		var bd := boss["node"] as Sprite2D
		boss_death_timer -= delta
		boss_death_explode_timer -= delta
		# La nave se hunde lentamente y vibra
		bd.position.y += 22.0 * delta
		bd.position.x += sin(boss_death_timer * 18.0) * 55.0 * delta
		# Desvanecimiento gradual en la última mitad de la secuencia
		if boss_death_timer < 1.9:
			bd.modulate.a = max(0.0, boss_death_timer / 1.9)
		# Explosiones escalonadas cada vez más frecuentes
		var explode_interval: float
		if boss_death_timer > 2.8:
			explode_interval = 0.28
		elif boss_death_timer > 1.4:
			explode_interval = 0.14
		else:
			explode_interval = 0.07
		if boss_death_explode_timer <= 0.0:
			boss_death_explode_timer = explode_interval
			var center := bd.position + Vector2(121.0, 90.0)
			var spread_x := rng.randf_range(-100.0, 100.0)
			var spread_y := rng.randf_range(-70.0, 70.0)
			_boss_explosion(center + Vector2(spread_x, spread_y))
			play_sfx("boom")
		# Fin de secuencia: explosión final gigante
		if boss_death_timer <= 0.0:
			var center := bd.position + Vector2(121.0, 90.0)
			for i in range(12):
				_boss_explosion(center + Vector2(rng.randf_range(-110.0, 110.0), rng.randf_range(-80.0, 80.0)))
			play_sfx("boom")
			bd.queue_free()
			boss_dying = false
			boss_dead = true
		return
	# --- Lógica normal del jefe ---
	if not boss_active or not boss.has("node"):
		return
	var b := boss["node"] as Sprite2D
	if b == null or not is_instance_valid(b):
		return
	b.region_rect = Rect2(0, 0, 243, 180)
	b.modulate = Color(1, 0.25, 0.25) if boss_damage_flash_timer > 0.0 else Color.WHITE
	_update_attack_banner(delta)
	_update_radio_location(delta)
	_update_igneus_breath(delta)
	if boss_intro:
		b.position.y += 42.0 * delta
		if b.position.y >= -5.0:
			b.position.y = -5.0
			boss_intro = false
		return
	var dir: float = float(boss["dir"])
	b.position.x += dir * 45.0 * delta
	if b.position.x >= 150.0:
		b.position.x = 150.0
		boss["dir"] = -1.0
	elif b.position.x <= -80.0:
		b.position.x = -80.0
		boss["dir"] = 1.0
	boss["shoot"] = float(boss["shoot"]) - delta
	boss["attack"] = float(boss["attack"]) - delta
	if float(boss["shoot"]) <= 0.0:
		_boss_basic_shots(b.position)
		boss["shoot"] = rng.randf_range(0.55, 0.95)
	if float(boss["attack"]) <= 0.0:
		_boss_special_attack(b.position)
		boss["attack"] = rng.randf_range(2.2, 3.6)

func _boss_basic_shots(pos: Vector2) -> void:
	for off in [Vector2(18, 40), Vector2(223, 40)]:
		var eb := _sprite("enemy_bullet", pos + off, game_root)
		eb.z_index = 5
		enemy_bullets.append({"node": eb, "speed": 235.0})

func _boss_special_attack(pos: Vector2) -> void:
	# Port 1:1 de la tabla original: 1-2 Radiolocation, 3-4 Icy Prison,
	# 5-6 Igneus Breath, 7-10 Error 43. Error 43 queda más frecuente.
	var roll: int = rng.randi_range(1, 10)
	if roll <= 2:
		_show_attack_banner(0) # Radio location
		_start_radio_location(pos)
	elif roll <= 4:
		_show_attack_banner(1) # Icy Prision
		# En el original, Icy Prison no congela al lanzar el ataque: congela solo
		# si uno de sus proyectiles impacta al jugador.
		for x in [pos.x + 70.0, pos.x + 120.0, pos.x + 170.0]:
			var ice := _sprite("ice_bala", Vector2(x, pos.y + 96.0), game_root)
			ice.z_index = 5
			ice.region_enabled = true
			ice.region_rect = Rect2(0, 0, 18, 24)
			enemy_bullets.append({"node": ice, "speed": 185.0, "kind": "icy_prison"})
	elif roll <= 6:
		_show_attack_banner(2) # Igneus Breath
		_start_igneus_breath(pos)
	else:
		_show_attack_banner(4) # Error 43
		_spawn_fuel_drop(Vector2(pos.x + 82.0, pos.y + 118.0))
		_spawn_health_drop(Vector2(pos.x + 122.0, pos.y + 118.0))
		_spawn_fuel_drop(Vector2(pos.x + 162.0, pos.y + 118.0))

func _start_igneus_breath(pos: Vector2) -> void:
	if not tex.has("igneus_charge") or not tex.has("igneus_breath"):
		return
	_clear_igneus_breath()
	var cannon_offset: float = 70.0 if rng.randi_range(0, 1) == 0 else 152.0
	var cannon_x: float = clamp(pos.x + cannon_offset, 0.0, float(W - 34))
	var charge := _sprite("igneus_charge", Vector2(cannon_x, 90.0), game_root)
	charge.z_index = 8
	charge.centered = false
	charge.region_enabled = true
	charge.region_rect = Rect2(0.0, 0.0, 48.0, 43.0)
	igneus_attack = {"stage":"charge", "node":charge, "x":cannon_x, "offset_x":cannon_offset, "time":0.0, "hit":false}

func _update_igneus_breath(delta: float) -> void:
	if igneus_attack.is_empty():
		return
	if not igneus_attack.has("node") or not is_instance_valid(igneus_attack["node"]):
		igneus_attack.clear()
		return
	var n := igneus_attack["node"] as Sprite2D
	var elapsed: float = float(igneus_attack["time"]) + delta
	igneus_attack["time"] = elapsed
	var stage: String = str(igneus_attack.get("stage", "charge"))
	var attack_x: float = float(igneus_attack.get("x", 0.0))
	if boss_active and boss.has("node") and is_instance_valid(boss["node"]):
		var boss_node := boss["node"] as Sprite2D
		attack_x = clamp(boss_node.position.x + float(igneus_attack.get("offset_x", 0.0)), 0.0, float(W - 48))
		igneus_attack["x"] = attack_x
	n.position.x = attack_x
	if stage == "charge":
		var charge_frame: int = clamp(int(floor(elapsed / 0.22)), 0, 3)
		n.region_rect = Rect2(float(charge_frame * 48), 0.0, 48.0, 43.0)
		if elapsed >= 0.88:
			n.texture = tex["igneus_breath"]
			n.region_enabled = false
			n.position = Vector2(attack_x, 90.0)
			n.centered = false
			igneus_attack["stage"] = "fire"
			igneus_attack["time"] = 0.0
			igneus_attack["hit"] = false
	else:
		# El sprite original es un haz vertical de fuego; daña solo si el jugador entra en su columna.
		var fire_rect := Rect2(Vector2(attack_x, 90.0), Vector2(43.0, 368.0))
		var player_rect := Rect2(player.position - Vector2(32.0, 24.0), Vector2(64.0, 48.0))
		if not bool(igneus_attack.get("hit", false)) and fire_rect.intersects(player_rect):
			health = max(0.0, health - 35.0)
			health_flash_timer = 0.75
			player_hit_flash = 0.75
			play_sfx("hit")
			igneus_attack["hit"] = true
		if elapsed >= 0.75:
			_clear_igneus_breath()

func _clear_igneus_breath() -> void:
	if igneus_attack.has("node") and is_instance_valid(igneus_attack["node"]):
		var n := igneus_attack["node"] as Node
		if n != null:
			n.queue_free()
	igneus_attack.clear()

func _start_radio_location(pos: Vector2) -> void:
	if not tex.has("radiolocation"):
		return
	_clear_radio_scan()
	var candidate_offsets: Array[float] = [18.0 - 60.0, 121.0 - 60.0, 223.0 - 60.0]
	var selected_offset: float = candidate_offsets[0]
	var scan_x: float = clamp(pos.x + selected_offset, 0.0, float(W - 154))
	var best_dist: float = abs((scan_x + 77.0) - player.position.x)
	for off in candidate_offsets:
		var x: float = clamp(pos.x + off, 0.0, float(W - 154))
		var d: float = abs((x + 77.0) - player.position.x)
		if d < best_dist:
			best_dist = d
			selected_offset = off
			scan_x = x
	var scan := _sprite("radiolocation", Vector2(scan_x, 90.0), game_root)
	scan.z_index = 7
	scan.centered = false
	scan.modulate.a = 0.75
	radio_scan = {"node": scan, "x": scan_x, "offset_x": selected_offset, "time": 0.0, "duration": 2.5, "blink": 0.0, "locked": false}

func _update_radio_location(delta: float) -> void:
	if radio_scan.is_empty():
		return
	if not radio_scan.has("node") or not is_instance_valid(radio_scan["node"]):
		radio_scan.clear()
		return
	var scan := radio_scan["node"] as Sprite2D
	var elapsed: float = float(radio_scan["time"]) + delta
	radio_scan["time"] = elapsed
	radio_scan["blink"] = float(radio_scan["blink"]) + delta
	var visible_now: bool = int(floor(float(radio_scan["blink"]) / 0.08)) % 2 == 0
	scan.visible = visible_now
	var scan_x: float = float(radio_scan["x"])
	if boss_active and boss.has("node") and is_instance_valid(boss["node"]):
		var boss_node := boss["node"] as Sprite2D
		scan_x = clamp(boss_node.position.x + float(radio_scan.get("offset_x", 0.0)), 0.0, float(W - 154))
		radio_scan["x"] = scan_x
		scan.position.x = scan_x
	var scan_rect := Rect2(Vector2(scan_x, 90.0), Vector2(154.0, 353.0))
	var player_rect := Rect2(player.position - Vector2(32.0, 24.0), Vector2(64.0, 48.0))
	if scan_rect.intersects(player_rect):
		radio_scan["locked"] = true
	if elapsed >= float(radio_scan["duration"]):
		var locked: bool = bool(radio_scan.get("locked", false))
		var missile_x: float = float(radio_scan["x"]) + 72.0
		_clear_radio_scan()
		if locked:
			_spawn_boss_missile(Vector2(missile_x, 75.0))

func _spawn_boss_missile(pos: Vector2) -> void:
	if not tex.has("boss_missile"):
		return
	var m := _sprite("boss_missile", pos, game_root)
	m.z_index = 8
	m.centered = true
	m.region_enabled = true
	m.region_rect = Rect2(0, 0, 10, 51)
	items.append({"node": m, "kind": "boss_missile", "speed": 225.0, "anim": 0.0})

func _clear_radio_scan() -> void:
	if radio_scan.has("node") and is_instance_valid(radio_scan["node"]):
		var n := radio_scan["node"] as Node
		n.queue_free()
	radio_scan.clear()

func _spawn_health_drop(pos: Vector2) -> void:
	var it := _sprite("heart", pos, game_root)
	it.z_index = 5
	# Item original de reparación/vida. No usar la barra de daño.
	it.region_enabled = false
	it.scale = Vector2.ONE
	items.append({"node": it, "kind": "health", "speed": 85.0, "anim": 0.0})

func _freeze_player(seconds: float) -> void:
	player_frozen_timer = max(player_frozen_timer, seconds)
	if not tex.has("frozen"):
		return
	if frozen_effect.has("node") and is_instance_valid(frozen_effect["node"]):
		return
	var fr := _sprite("frozen", player.position, game_root)
	fr.z_index = 8
	fr.centered = true
	fr.region_enabled = true
	fr.region_rect = Rect2(0, 0, 98, 118)
	frozen_effect = {"node": fr, "anim": 0.0}

func _clear_frozen_effect() -> void:
	if frozen_effect.has("node") and is_instance_valid(frozen_effect["node"]):
		var n := frozen_effect["node"] as Node
		if n != null:
			n.queue_free()
	frozen_effect.clear()

func _show_attack_banner(frame: int) -> void:
	if not tex.has("boss_attack_banner"):
		return
	_clear_attack_banner()
	var banner := _image_region("boss_attack_banner", Vector2((W - 144) / 2, 18), Rect2(0, frame * 20, 144, 20), ui_layer)
	banner.z_index = 40
	attack_banner = {"node": banner, "time": 1.15}

func _update_attack_banner(delta: float) -> void:
	if attack_banner.is_empty():
		return
	if not attack_banner.has("node") or not is_instance_valid(attack_banner["node"]):
		attack_banner.clear()
		return
	attack_banner["time"] = float(attack_banner["time"]) - delta
	if float(attack_banner["time"]) <= 0.0:
		_clear_attack_banner()

func _clear_attack_banner() -> void:
	if attack_banner.has("node") and is_instance_valid(attack_banner["node"]):
		var n := attack_banner["node"] as Node
		if n != null:
			n.queue_free()
	attack_banner.clear()

func _spawn_lapsed_fuel_at(pos: Vector2) -> void:
	if not tex.has("lapsed_fuel"):
		return
	var it := _sprite("lapsed_fuel", pos, game_root)
	it.z_index = 5
	it.scale = Vector2(1.0, 1.0)
	items.append({"node": it, "kind": "lapsed_fuel", "speed": 115.0})

func _kill_boss() -> void:
	if not boss.has("node"):
		return
	score += 10000
	boss_active = false
	boss_dying = true
	boss_death_timer = 3.8
	boss_death_explode_timer = 0.0
	# Detener todos los ataques en curso
	_clear_attack_banner()
	_clear_radio_scan()
	_clear_igneus_breath()
	# Vaciar balas enemigas para que el jugador no sea castigado durante la secuencia
	for eb in enemy_bullets:
		if eb.has("node") and is_instance_valid(eb["node"]):
			eb["node"].queue_free()
	enemy_bullets.clear()
	play_sfx("boom")

func _boss_explosion(pos: Vector2) -> void:
	var e := _sprite("boss_explosion", pos, game_root)
	e.z_index = 9
	e.centered = true
	e.region_enabled = true
	e.region_rect = Rect2(0, 0, 32, 33)
	effects.append({"node": e, "kind": "boss_explosion", "time": 0.0, "frames": 13, "sx": 32, "sy": 33, "fps": 18.0})

func _check_collisions() -> void:
	var prect := Rect2(player.position-Vector2(22,18), Vector2(44,36))
	for bi in range(bullets.size()-1, -1, -1):
		var b = bullets[bi]; var brect := Rect2(b.node.position-Vector2(3,7), Vector2(6,14))
		var hit := false
		for ei in range(enemies.size()-1, -1, -1):
			var e = enemies[ei]; var erect := Rect2(e.node.position-Vector2(30,17), Vector2(60,34))
			if brect.intersects(erect):
				e.hp -= int(b.get("damage", 1)); b.node.queue_free(); bullets.remove_at(bi); hit = true
				if e.hp <= 0: _kill_enemy(ei)
				else: e.node.modulate = Color(1,0.6,0.6)
				break
		if hit: continue
	if boss_active and boss.has("node") and is_instance_valid(boss["node"]):
		for bi in range(bullets.size()-1, -1, -1):
			var bb = bullets[bi]
			var bbr := Rect2(bb.node.position - Vector2(3, 7), Vector2(6, 14))
			var boss_node := boss["node"] as Sprite2D
			# Port 1:1: el Acorazado solo recibe daño en el núcleo central,
			# no en alas ni extremos del sprite.
			var br := Rect2(boss_node.position + Vector2(92.0, 38.0), Vector2(60.0, 104.0))
			if bbr.intersects(br) and not boss_intro:
				bb.node.queue_free()
				bullets.remove_at(bi)
				boss["hp"] = int(boss["hp"]) - int(bb.get("damage", 1))
				boss_damage_flash_timer = 0.75
				boss_node.modulate = Color(1, 0.25, 0.25)
				if int(boss["hp"]) <= 0:
					_kill_boss()
					break
	for ei in range(enemies.size()-1, -1, -1):
		var e=enemies[ei]; var erect := Rect2(e.node.position-Vector2(28,16), Vector2(56,32))
		if prect.intersects(erect): _kill_enemy(ei); _damage_player(1)
	for bi in range(enemy_bullets.size()-1, -1, -1):
		var b=enemy_bullets[bi]; var r := Rect2(b.node.position-Vector2(4,6), Vector2(8,12))
		if prect.intersects(r):
			var bullet_kind: String = str(b.get("kind", "normal"))
			var enemy_damage: int = int(b.get("damage", 1))
			b.node.queue_free(); enemy_bullets.remove_at(bi); _damage_player(enemy_damage)
			if bullet_kind == "icy_prison":
				_freeze_player(2.6)
	for ii in range(items.size()-1, -1, -1):
		var it=items[ii]; var r := Rect2(it.node.position-Vector2(16,16), Vector2(32,32))
		if prect.intersects(r):
			if it.kind == "fuel":
				fuel = min(100, fuel + 25)
				fuel_flash_timer = 0.45
				_pickup_fuel_effect()
				play_sfx("accept")
			elif it.kind == "boss_missile":
				health = max(0, health - 35)
				health_flash_timer = 0.75
				player_hit_flash = 0.75
				play_sfx("hit")
			elif it.kind == "lapsed_fuel":
				fuel = max(0, fuel - (18 + level * 7))
				fuel_flash_timer = 0.8
				_lapsed_fuel_effect()
				play_sfx("lapsed")
			elif it.kind == "weapon":
				_set_player_weapon(str(it.get("weapon", "normal")))
				play_sfx("accept")
			elif it.kind == "health":
				health = min(100, health + 25)
				health_flash_timer = 0.45
				play_sfx("accept")
			it.node.queue_free(); items.remove_at(ii)

func _kill_enemy(index:int) -> void:
	if index < 0 or index >= enemies.size(): return
	var e=enemies[index]
	score += e.score; killed += 1
	fuel_kill_counter += 1
	var drop_pos: Vector2 = e.node.position
	var must_drop: bool = fuel_kill_counter >= int(18 - level * 3)
	if must_drop or rng.randf() < (0.012 + level * 0.008):
		fuel_kill_counter = 0
		_spawn_fuel_drop(drop_pos)
	elif rng.randf() < _health_drop_chance():
		_spawn_health_drop(drop_pos)
	elif rng.randf() < _weapon_drop_chance():
		_spawn_weapon_drop(drop_pos, _random_weapon_drop())
	_enemy_die_effect(e.node.position, e.node.texture)
	e.node.queue_free(); enemies.remove_at(index); play_sfx("boom")

func _damage_player(amount:int) -> void:
	health -= amount * 20.0
	health_flash_timer = 0.65
	player_hit_flash = 0.8
	lives = max(0, int(ceil(health / 34.0)))
	play_sfx("hit")
	_effect("player_die", player.position, 0.3)

func game_over() -> void:
	screen = Screen.GAME_OVER; _save_if_record(); play_music("over")
	_result_screen(false)

func level_complete() -> void:
	screen = Screen.LEVEL_COMPLETE
	_save_level_rank()
	_save_if_record()
	play_music("complete")
	_result_screen(true)

func _tournament_has_next_stage() -> bool:
	return tournament_mode and not extra_flight and tournament_pos < tournament_sequence.size() - 1

func _advance_tournament() -> void:
	if not _tournament_has_next_stage():
		tournament_mode = false
		show_records()
		return
	tournament_pos += 1
	# El torneo conserva puntuación, arma, vida y fuel entre niveles.
	_start_tournament_stage(false)

func _tournament_label() -> String:
	if not tournament_mode:
		return ""
	if tournament_giant_mode:
		return "TOURNAMENT"
	return "TOURNAMENT %d/%d" % [tournament_pos + 1, tournament_sequence.size()]

func _result_screen(completed: bool) -> void:
	# Port 1:1: the original result screens are not labels/tweens.
	# They are horizontal spritesheets. Each frame is shown from left to right.
	for c in ui_layer.get_children():
		c.queue_free()
	result_anim_time = 0.0
	result_anim_done = false
	result_anim_kind = "level_completed" if completed else "level_game_over"
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.18)
	shade.size = Vector2(W, H)
	shade.name = "ResultShade"
	ui_layer.add_child(shade)
	var key := "level_completed" if completed else "level_game_over"
	var frame_w := 297 if completed else 202
	var frame_h := 67 if completed else 69
	var pos := Vector2((W - frame_w) / 2.0, 190.0 if completed else 188.0)
	var img := _image_region(key, pos, Rect2(0, 0, frame_w, frame_h), ui_layer)
	img.name = "ResultSprite"
	img.z_index = 20
	_hotspot(Rect2(0, 0, W, H), Callable(self, "_on_result_pressed"))

func _update_result_animation(delta: float) -> void:
	var img := ui_layer.get_node_or_null("ResultSprite") as Sprite2D
	if img == null:
		return
	result_anim_time += delta
	var completed: bool = result_anim_kind == "level_completed"
	var frame: int = ResultFrames.frame_index(result_anim_time)
	img.region_rect = ResultFrames.frame_rect(completed, result_anim_time)
	if frame == ResultFrames.FRAME_COUNT - 1 and not result_anim_done:
		result_anim_done = true

func _on_result_pressed() -> void:
	if screen == Screen.GAME_OVER:
		tournament_mode = false
		show_menu()
	elif screen == Screen.LEVEL_COMPLETE:
		tournament_mode = false
		tournament_giant_mode = false
		show_records()

func pause_game() -> void:
	screen = Screen.PAUSE
	_overlay("PAUSA", "Pulsa CONTINUAR o tecla P", func(): resume_game(), true)

func resume_game() -> void:
	screen = Screen.GAME
	for c in ui_layer.get_children():
		if c.name.begins_with("Overlay"): c.queue_free()
	_make_ui_game()

func _add_background(key:String) -> void:
	if not tex.has(key): return
	bg1 = _sprite(key, Vector2(W/2, H/2), game_root); bg2 = _sprite(key, Vector2(W/2, H/2-480), game_root)
	bg1.z_index = 0; bg2.z_index = 0
	# Crop-like scaling: original backgrounds are 320x1440; use as long scrolling texture.
	bg1.region_enabled = true; bg2.region_enabled = true
	bg1.region_rect = Rect2(0,0,320,480); bg2.region_rect = Rect2(0,480,320,480)

func _switch_background(key: String) -> void:
	if key == tournament_bg_key:
		return
	tournament_bg_key = key
	# Reset the scroll when entering a new Tournament section so transition
	# maps start at the correct edge (Sea -> Taiga, Taiga -> Tundra).
	if tournament_giant_mode:
		bg_offset = 0.0
	if bg1:
		bg1.queue_free()
		bg1 = null
	if bg2:
		bg2.queue_free()
		bg2 = null
	_add_background(key)

func _update_tournament_background() -> void:
	# Tournament uses one stitched route texture to avoid visible jumps between
	# Sea -> Sea/Taiga -> Taiga -> Taiga/Tundra -> Tundra.
	# No per-section texture switching is needed.
	pass

func _scroll_background(delta: float) -> void:
	bg_offset += delta * (45 + level * 12)
	if not bg1:
		return

	# Tournament is one stitched route texture. It is stacked top-to-bottom as
	# Tundra -> Taiga/Tundra -> Taiga -> Sea/Taiga -> Sea, then sampled
	# from bottom to top so the playable route is Sea -> Taiga -> Tundra.
	if tournament_giant_mode:
		var texture_height: int = 480
		if bg1.texture:
			texture_height = int(bg1.texture.get_height())
		var max_y: int = texture_height - 480
		if max_y < 0:
			max_y = 0
		# Tournament must not loop. It is a single giant route:
		# Sea -> Sea/Taiga -> Taiga -> Taiga/Tundra -> Tundra.
		# When the scroll reaches the end of Tundra, finish the stage instead
		# of wrapping back to Sea.
		var progress: int = int(min(bg_offset, float(max_y)))
		var source_y: int = max_y - progress
		bg1.region_rect.position.y = source_y
		if bg2:
			bg2.visible = false
		if progress >= max_y and not tournament_scroll_finished and screen == Screen.GAME:
			tournament_scroll_finished = true
			call_deferred("level_complete")
		return

	bg_offset = fmod(bg_offset, 960.0)
	if bg2:
		bg2.visible = true
		bg1.region_rect.position.y = int(bg_offset) % 960
		bg2.region_rect.position.y = (int(bg_offset) + 480) % 960

func _move_clouds(delta: float) -> void:
	for c in clouds:
		c.node.position.y += c.speed * delta
		if c.node.position.y > H+60:
			c.node.position.y = -60; c.node.position.x = rng.randf_range(0,W)

func _image(key:String, pos:Vector2, parent:Node) -> Sprite2D:
	var s := Sprite2D.new()
	if tex.has(key): s.texture = tex[key]
	s.centered = false
	s.position = pos
	parent.add_child(s)
	return s

func _image_region(key:String, pos:Vector2, rect:Rect2, parent:Node) -> Sprite2D:
	var s := _image(key, pos, parent)
	s.region_enabled = true
	s.region_rect = rect
	return s

func _hotspot(rect:Rect2, cb:Callable) -> Button:
	var b := Button.new()
	b.position = rect.position
	b.size = rect.size
	b.flat = true
	b.modulate.a = 0.0
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(cb)
	ui_layer.add_child(b)
	return b

func _sprite(key:String, pos:Vector2, parent:Node) -> Sprite2D:
	var s := Sprite2D.new(); s.position = pos
	if tex.has(key): s.texture = tex[key]
	parent.add_child(s); return s

func _effect(key:String, pos:Vector2, life:float) -> void:
	var e = _sprite(key, pos, game_root); e.z_index=6; e.scale=Vector2(0.8,0.8)
	effects.append({"node":e, "life":life, "maxlife":life})


func _enemy_die_effect(pos:Vector2, enemy_texture:Texture2D=null) -> void:
	if not tex.has("enemy_die"):
		_effect("enemy_die", pos, 0.35)
		return

	# AFG-EnemyDie.png is a horizontal spritesheet with 12 overlays.
	# Each frame is 72x34, matching the enemy plane size. The original
	# plane remains underneath while the red overlay advances frame by frame.
	var base := Sprite2D.new()
	base.texture = enemy_texture
	base.centered = true
	base.position = pos
	base.z_index = 6
	game_root.add_child(base)

	var e := Sprite2D.new()
	e.texture = tex["enemy_die"]
	e.centered = true
	e.region_enabled = true
	e.region_rect = Rect2(0, 0, 72, 34)
	e.position = pos
	e.z_index = 7
	game_root.add_child(e)
	effects.append({"node":e, "base":base, "kind":"enemy_die", "time":0.0, "frames":12, "sx":72, "sy":34, "fps":30.0})

func _lapsed_fuel_effect() -> void:
	if not tex.has("lapsed_fuel_effect"):
		_effect("fuel_damage", player.position + Vector2(0, -20), 0.45)
		return
	var e := Sprite2D.new()
	e.texture = tex["lapsed_fuel_effect"]
	e.centered = true
	e.region_enabled = true
	e.region_rect = Rect2(0, 0, 13, 13)
	e.position = player.position + Vector2(0, -24)
	e.z_index = 9
	game_root.add_child(e)
	effects.append({"node":e, "kind":"lapsed_fuel_effect", "time":0.0, "frames":4, "sx":13, "sy":13, "fps":10.0, "offset":Vector2(0, -24)})

func _pickup_fuel_effect() -> void:
	if not tex.has("fuel_pickup"):
		return
	var e := Sprite2D.new()
	e.texture = tex["fuel_pickup"]
	e.centered = false
	e.region_enabled = true
	e.region_rect = Rect2(0, 32, 163, 8)
	e.position = player.position + Vector2(-82, -36)
	e.z_index = 9
	game_root.add_child(e)
	effects.append({"node":e, "kind":"fuel_pickup", "cont":0.0, "cass":4, "sx":163, "sy":8, "offset":Vector2(-82, -36)})


func _set_player_weapon(weapon:String) -> void:
	if weapon not in ["normal", "mave", "harry"]:
		weapon = "normal"
	player_weapon = weapon
	player_weapon_damage = _weapon_damage(weapon)
	_weapon_pickup_effect(weapon)

func _weapon_pickup_effect(weapon:String) -> void:
	var key := "weapon_msg_normal"
	if weapon == "mave":
		key = "weapon_msg_mave"
	elif weapon == "harry":
		key = "weapon_msg_harry"
	if not tex.has(key):
		return
	var e := Sprite2D.new()
	e.texture = tex[key]
	e.centered = true
	e.region_enabled = true
	var frames := 5
	var sx := int(tex[key].get_width())
	var sy := int(tex[key].get_height() / frames)
	e.region_rect = Rect2(0, 0, sx, sy)
	e.position = player.position + Vector2(0, -34)
	e.z_index = 10
	game_root.add_child(e)
	effects.append({"node":e, "kind":"weapon_msg", "time":0.0, "fps":10.0, "frames":frames, "sx":sx, "sy":sy, "offset":Vector2(0, -34)})

func _make_ui_game() -> void:
	for c in ui_layer.get_children():
		if not c.name.begins_with("Overlay"): c.queue_free()
	var box := ColorRect.new(); box.color = Color(0,0,0,0.26); box.size=Vector2(W,34); ui_layer.add_child(box)
	_label("", Vector2(82,4), 15, Color.WHITE, false, "HudScore")
	_label("", Vector2(82,19), 10, Color(0.95,0.95,0.95), false, "HudTournament")
	var life = _image_region("life_bar", Vector2(0,0), Rect2(0,0,51,24), ui_layer); life.name = "HudLifeBar"; life.z_index = 10
	var fuel_bar = _image_region("fuel_bar", Vector2(W-57,0), Rect2(0,0,57,58), ui_layer); fuel_bar.name = "HudFuelBar"; fuel_bar.z_index = 10
	var life_fx = _image_region("life_damage", Vector2(0,0), Rect2(0,0,51,24), ui_layer); life_fx.name = "HudLifeFx"; life_fx.z_index = 11; life_fx.visible = false
	var fuel_fx = _image_region("fuel_damage", Vector2(W-57,0), Rect2(0,0,57,58), ui_layer); fuel_fx.name = "HudFuelFx"; fuel_fx.z_index = 11; fuel_fx.visible = false

func _refresh_hud() -> void:
	var n = ui_layer.get_node_or_null("HudScore")
	if n:
		n.text = "PTS %06d" % score
	var t := ui_layer.get_node_or_null("HudTournament") as Label
	if t:
		t.text = _tournament_label()
	var life_idx: int = int(clamp(int(round((100.0 - health) / 100.0 * 25.0)), 0, 25))
	var fuel_idx: int = int(clamp(int(round((100.0 - fuel) / 100.0 * 14.0)), 0, 14))
	var life_bar := ui_layer.get_node_or_null("HudLifeBar") as Sprite2D
	if life_bar:
		life_bar.region_rect = Rect2(0, 24 * life_idx, 51, 24)
	var fuel_bar := ui_layer.get_node_or_null("HudFuelBar") as Sprite2D
	if fuel_bar:
		fuel_bar.region_rect = Rect2(57 * fuel_idx, 0, 57, 58)
	var life_fx := ui_layer.get_node_or_null("HudLifeFx") as Sprite2D
	if life_fx:
		life_fx.visible = health_flash_timer > 0
		if life_fx.visible:
			var fx_idx := int(floor(fmod(health_flash_timer * 18.0, 4.0)))
			life_fx.region_rect = Rect2(0, 24 * fx_idx, 51, 24)
	var fuel_fx := ui_layer.get_node_or_null("HudFuelFx") as Sprite2D
	if fuel_fx:
		fuel_fx.visible = fuel_flash_timer > 0 or fuel < 20
		if fuel_fx.visible:
			var fidx := int(floor(fmod(game_time * 12.0, 4.0)))
			fuel_fx.region_rect = Rect2(57 * fidx, 0, 57, 58)

func _overlay(title:String, body:String, action:Callable, keep_hud:=false) -> void:
	if not keep_hud:
		for c in ui_layer.get_children(): c.queue_free()
	var p := Panel.new(); p.name="OverlayPanel"; p.position=Vector2(30,110); p.size=Vector2(260,250); ui_layer.add_child(p)
	_label(title, Vector2(0,135), 26, Color.WHITE, true, "OverlayTitle")
	_label(body, Vector2(0,190), 17, Color.WHITE, true, "OverlayBody")
	_button("CONTINUAR" if keep_hud else "ACEPTAR", Vector2(80,290), Vector2(160,42), action, "OverlayButton")

func _label(text:String, pos:Vector2, size:int, color:Color, centered:bool, name:="") -> Label:
	var l := Label.new(); l.text=text; l.position=pos; l.add_theme_font_size_override("font_size", size); l.add_theme_color_override("font_color", color)
	if centered: l.size=Vector2(W,60); l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	if name != "": l.name=name
	ui_layer.add_child(l); return l

func _button(text:String, pos:Vector2, size:Vector2, cb:Callable, name:="") -> Button:
	var b := Button.new(); b.text=text; b.position=pos; b.size=size
	if name != "": b.name=name
	b.pressed.connect(func(): play_sfx("accept"); cb.call())
	ui_layer.add_child(b); return b

func _load_records() -> void:
	rank_scores = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	high_score = 0
	tournament_best_score = 0
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var raw := f.get_as_text().strip_edges()
	if raw.begins_with("{"):
		var parsed: Variant = JSON.parse_string(raw)
		if parsed is Dictionary:
			high_score = int(parsed.get("high_score", 0))
			tournament_best_score = int(parsed.get("tournament_best_score", high_score))
			var saved_ranks: Variant = parsed.get("ranks", [])
			if saved_ranks is Array:
				for i in range(min(rank_scores.size(), saved_ranks.size())):
					rank_scores[i] = clampi(int(saved_ranks[i]), 1, 4)
	elif raw != "":
		# Compatibilidad con las primeras versiones del remake, que solo guardaban puntuación.
		high_score = int(raw.split("\n")[0])

func _save_records() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	var data: Dictionary = {"high_score": high_score, "tournament_best_score": tournament_best_score, "ranks": rank_scores}
	f.store_string(JSON.stringify(data))

func _save_level_rank() -> void:
	if tournament_giant_mode:
		if score > tournament_best_score:
			tournament_best_score = score
		_save_records()
		return

	var total: int = max(max(enemies_spawned, enemies_to_clear), 1)
	var ratio: float = float(killed) / float(total)
	var new_rank: int = 2
	if killed >= total:
		new_rank = 4
	elif ratio >= 0.85:
		new_rank = 3
	elif ratio >= 0.55:
		new_rank = 2
	else:
		new_rank = 1
	var save_index: int = 9 if extra_flight else clampi(selected_level_idx, 0, 8)
	rank_scores[save_index] = max(rank_scores[save_index], new_rank)
	_save_records()

func _save_if_record() -> void:
	if tournament_giant_mode and score > tournament_best_score:
		tournament_best_score = score
	if score > high_score:
		high_score = score
		_save_records()
	elif tournament_giant_mode:
		_save_records()
