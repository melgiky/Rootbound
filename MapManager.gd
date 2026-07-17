extends Node2D

@onready var tilemap = $Quebraveis
@onready var player = $Player
@onready var selector = $BlockSelector

const MINE_RANGE = 72.0


func _ready():

	
	SignalManager.connect(
		"SPAWN_BLOCK_PARTICLES",
		spawn_block_particles
	)

	randomize()


# ==========================================
# RANGE CHECK
# ==========================================

func can_mine(world_pos: Vector2) -> bool:

	return player.global_position.distance_to(world_pos) <= MINE_RANGE


# ==========================================
# RIGHT CLICK
# ==========================================

func _unhandled_input(event):

	if event.is_action_pressed("RIGHT_MOUSE"):

		var mouse_pos = get_global_mouse_position()

		if can_mine(mouse_pos):
			fall_block(mouse_pos)


# ==========================================
# DAMAGE BLOCK
# ==========================================

func damage_block(world_pos, damage = 1):

	if not can_mine(world_pos):
		return


	var tile_pos: Vector2i

	if world_pos is Vector2:
		tile_pos = tilemap.local_to_map(world_pos)
	else:
		tile_pos = world_pos


	# pega infos atuais do tile
	var source_id = tilemap.get_cell_source_id(0, tile_pos)
	var atlas_coord = tilemap.get_cell_atlas_coords(0, tile_pos)
	var alternative = tilemap.get_cell_alternative_tile(0, tile_pos)


	if source_id == -1:
		return


	var block_type = retrieve_terrain(tile_pos)


	AudioManager.play_audio("STONE_HIT")


	# novo estágio de dano
	var new_atlas = atlas_coord - Vector2i(damage, 0)


	# destruiu bloco
	if new_atlas.x < 0:

		destroy_block(
			tile_pos,
			atlas_coord,
			block_type
		)

		return


	# IMPORTANTE:
	# mantém source e alternative originais
	tilemap.set_cell(
		0,
		tile_pos,
		source_id,
		new_atlas,
		alternative
	)


	spawn_block_particles(
		block_type,
		2,
		tilemap.map_to_local(tile_pos),
		false
	)


	EffectsManager.play_vfx_at(
		"SMOKE",
		tilemap.map_to_local(tile_pos)
	)


# ==========================================
# DROP BLOCK
# ==========================================

func fall_block(world_pos):

	var tile_pos = tilemap.local_to_map(world_pos)

	var source_id = tilemap.get_cell_source_id(0, tile_pos)

	if source_id == -1:
		return


	var atlas_coord = tilemap.get_cell_atlas_coords(
		0,
		tile_pos
	)


	var block_type = retrieve_terrain(tile_pos)

	AudioManager.play_audio("STONE_BREAK")


	destroy_block(
		tile_pos,
		atlas_coord,
		block_type,
		false
	)


	EffectsManager.play_vfx_at(
		"SMOKE",
		world_pos
	)


# ==========================================
# DESTROY BLOCK
# ==========================================

func destroy_block(
	pos,
	atlas_coord,
	block_type = "DIRT",
	apply_force = true
):

	tilemap.erase_cell(0, pos)


	var physics_block = load(
		"res://assets/physics-block/PhysicsBlock.tscn"
	).instantiate()

	add_child(physics_block)


	physics_block.setup(
		atlas_coord,
		tilemap.map_to_local(pos),
		block_type,
		apply_force
	)


	spawn_block_particles(
		block_type,
		4,
		tilemap.map_to_local(pos)
	)


# ==========================================
# TERRAIN
# ==========================================

func retrieve_terrain(pos):

	if pos is Vector2:
		pos = tilemap.local_to_map(pos)


	var tile_data = tilemap.get_cell_tile_data(
		0,
		pos
	)


	if tile_data:

		var terrain_set = tile_data.terrain_set
		var terrain_id = tile_data.terrain


		return tilemap.tile_set.get(
			"terrain_set_%s/terrain_%s/name"
			% [terrain_set, terrain_id]
		)

	return null


# ==========================================
# PARTICLES
# ==========================================

func spawn_block_particles(
	block_type = "DIRT",
	max_particles = 6,
	pos = Vector2.ZERO,
	start_collision = true
):

	if block_type in GameData.tileData:

		if "PARTICLE_TYPE" in GameData.tileData[block_type]:

			block_type = GameData.tileData[block_type]["PARTICLE_TYPE"]


	var particles_amount = randi_range(
		1,
		max_particles
	)


	for i in range(particles_amount):

		var block_particle = load(
			"res://assets/physics-block/BlockParticle.tscn"
		).instantiate()

		add_child(block_particle)


		block_particle.setup(
			pos,
			block_type,
			start_collision
		)
		
func update_block_selector():

	var mouse_pos = get_global_mouse_position()

	var cell = tilemap.local_to_map(mouse_pos)

	var atlas = tilemap.get_cell_atlas_coords(0, cell)

	# Não existe bloco
	if atlas == Vector2i(-1, -1):
		selector.hide()
		return

	var block_pos = tilemap.map_to_local(cell)

	# transforma para coordenada global
	block_pos += tilemap.global_position

	# Fora do alcance
	if !can_mine(block_pos):
		selector.hide()
		return

	selector.show()
	selector.global_position = block_pos

func _process(delta):
	update_block_selector()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Transitions.transition()
		await Transitions.on_transition_finished
		Gamestate.pass_level()
		get_tree().change_scene_to_file("res://world2.tscn")


func _on_dialog_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		Dialogic.start_timeline("borda")
	
