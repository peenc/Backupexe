extends CharacterBody2D
#
#var velocidade_movimento = 40.0
#
#func _fisica_processo(delta):
		#movimento()
		#
#
#func movimento():
	#var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	#var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	#var mov = Vector2(x_mov,y_mov)
	#velocity = mov.normalized()*velocidade_movimento
	#move_and_slide()
	#
#Velocidade
var SPEED := 100
var dano_base = 2.0
var player_level = 1
#Controle de Hp
@export var hpmax: int = 100
var hp: int = hpmax

#Controle de Stamina
@export var stamina_max: int = 100
var stamina: float = stamina_max
@export var stamina_regen_rate: float = 5.0  # Quanto regenera por segundo

#Controle de Dash
@export var dash_cost: int = 25  
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
const DASH_DURATION: float = 0.2
const DASH_SPEED: float = 600.0        
var direction: Vector2 = Vector2.ZERO
	  # Quanto custa o dash


#Controle de Skills
var owned_skills: Array = []
var tem_packet_blaster := true
var tem_quarantine_field := false
var tem_pendrive_orbital := false
var tem_firewall_boost := false
var tem_clean_sweep := false
var tem_data_beam := false


#GUI
@onready var StaminaBar = get_node("%StaminaBar")
@onready var lblStamina = get_node("%LabelStamina")
@onready var HPBar = get_node("%HPBar")
@onready var lblHP = get_node("%LabelHP")
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%LabelLevel")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var sndLevelUp = get_node("%sound_levelUp")
@onready var itemOptions = preload("res://Scripts/item_option.tscn")
@onready var pontuacao = get_node("%Pontuacao")

func _ready():
	add_to_group("player")
	set_process_input(true)
	atualizar_hp_barra()
	set_expbar(experience, calcular_experiencia_necessaria())
	atualizar_stamina_barra()
	lblStamina.text = "Stamina: " + str(int(stamina))
	lblHP.text = str("HP: ", hp)

#Exportação das habilidaades
@export var packet_blaster: PackedScene
@export var pendrive_scene: PackedScene
@export var quarantine_field_scene: PackedScene
@export var firewall_scene: PackedScene
@export var clean_sweep: PackedScene
@export var data_beam_scene: PackedScene  

#Quantidade de Pendrives
var pendrives = []

#BacketBlaster Skill
var nivel_blaster = 0
func backet_blaster():
	if not tem_packet_blaster:
		return
	
	if not packet_blaster:
		return
	
	var habilidade = packet_blaster.instantiate()
	habilidade.global_position = global_position
	habilidade.aplicar_upgrade(nivel_blaster, dano_base)
	habilidade.target = get_alvo_proximo()
	get_tree().current_scene.add_child(habilidade)

var quantidade_tiros = 1

func _on_timer_timeout() -> void:
	if tem_packet_blaster:
		for i in range(quantidade_tiros):
			backet_blaster()

		
func get_alvo_proximo() -> Vector2:
	var inimigos = get_tree().get_nodes_in_group("inimigo")
	var mais_proximo : Node2D= null
	var menor_dist := INF
	for inimigo in inimigos:
		var dist = global_position.distance_to(inimigo.global_position)
		if dist < menor_dist:
			menor_dist = dist
			mais_proximo = inimigo
	if mais_proximo:
		return mais_proximo.global_position
	return global_position + Vector2.RIGHT * 100  # direção padrão
	


func _input(event):
	if event.is_action_pressed("tecla1") and pode_usar_qf and tem_quarantine_field:
		print("LANÇANDO SKILL QUARANTINE_FIELD")
		disparar_skill_qf()
	if event.is_action_pressed("dash") and not is_dashing and direction != Vector2.ZERO:
		if stamina >= dash_cost:
			start_dash()
	if event.is_action_pressed("tecla2") and pode_usar_fb and tem_firewall_boost:
		print("Ativando escudo")
		ativar_escudo()
	if event.is_action_pressed("usar_ultimate"):
		if tem_overclock and overclock_pronto and not overclock_ativo:
			ativar_overclock()
	if event.is_action_pressed("tecla3"):
		if tem_clean_sweep and pode_usar_explosao:
			ativar_explosao()
	if event.is_action_pressed("tecla4") and pode_usar_databeam and tem_data_beam:
		usar_data_beam()


var data_beam_instance: Node2D = null
var pode_usar_databeam := true
var tempo_databeam := 2.0  # duração
var cooldown_databeam := 15  # cooldown
var nivel_databeam := 0

func usar_data_beam():
	print("Tentando usar databeam")
	if not is_instance_valid(data_beam_instance):
		data_beam_instance = data_beam_scene.instantiate()
		get_parent().add_child(data_beam_instance)
		data_beam_instance.player = self
	
	data_beam_instance.aplicar_upgrade(nivel_databeam, dano_base)
	data_beam_instance.global_position = global_position
	data_beam_instance.ativar_databeam()
	print("Databeam ativado")

	pode_usar_databeam = false
	await get_tree().create_timer(cooldown_databeam).timeout
	pode_usar_databeam = true
	print("Cooldown liberado")



var cleansweep_scene = preload("res://Scripts/cleansweep.tscn")
var cooldown_cs := 10.0
var pode_usar_explosao := true
var nivel_clean_sweep := 0

func ativar_explosao():
	if not tem_clean_sweep:
		return
	if not pode_usar_explosao:
		return

	pode_usar_explosao = false
	var explosao = cleansweep_scene.instantiate()
	explosao.global_position = global_position
	explosao.aplicar_upgrade(nivel_clean_sweep, dano_base)
	get_parent().add_child(explosao)

	await get_tree().create_timer(cooldown_cs).timeout
	pode_usar_explosao = true

var nivel_quarantine = 0
var pode_usar_qf := true 
@export var cooldown_qf := 5.0
var quarantine_field = preload("res://Scripts/quarantine_field.tscn")

func disparar_skill_qf():
	#particulas da skill
	#var particula = particulas_habilidade.instantiate()
	#get_tree().current_scene.add_child(particula)
	#particula.global_position = get_global_mouse_position()
	
	#criar habilidade qf
	pode_usar_qf = false
	var habilidadeqf = quarantine_field.instantiate()
	habilidadeqf.aplicar_upgrade(nivel_quarantine, dano_base)
	habilidadeqf.global_position = get_global_mouse_position()
	get_tree().current_scene.add_child(habilidadeqf)
	await get_tree().create_timer(cooldown_qf,true).timeout
	pode_usar_qf = true

var pode_usar_fb := true
@export var cooldown_fb := 6.0
var escudo = preload("res://Scripts/firewall_boost.tscn")
var nivel_firewall := 0

func ativar_escudo():
	if not pode_usar_fb:
		return

	pode_usar_fb = false
	var habilidadefb = escudo.instantiate()
	habilidadefb.aplicar_upgrade(nivel_firewall)
	add_child(habilidadefb)

	habilidadefb.escudo_finalizado.connect(func():
		await get_tree().create_timer(cooldown_fb, true).timeout
		pode_usar_fb = true
	)

	habilidadefb.position = Vector2.ZERO  # já está no player, então só zera a posição

var tem_overclock := false
var overclock_ativo := false
var overclock_duracao := 8.0
var overclock_cooldown := 30.0
var overclock_pronto := true

var overclock_aumento_dano := 1.5
var overclock_aumento_speed := 1.5


func ativar_overclock():
	overclock_ativo = true
	overclock_pronto = false

	dano_base *= overclock_aumento_dano
	SPEED *= overclock_aumento_speed

	# Efeito visual: liga animação
	$OverclockEffect.visible = true
	if $OverclockEffect.has_method("play"):
		$OverclockEffect.play("default")  # ou o nome da animação

	# Começa a piscar o jogador
	start_blinking()

	print("Overclock ativado!")

	var dur_timer = Timer.new()
	dur_timer.wait_time = overclock_duracao
	dur_timer.one_shot = true
	dur_timer.connect("timeout", func():
		dano_base /= overclock_aumento_dano
		SPEED /= overclock_aumento_speed
		overclock_ativo = false

		# Desliga efeito visual
		$OverclockEffect.visible = false
		stop_blinking()

		print("Overclock acabou.")
		dur_timer.queue_free()
	)
	add_child(dur_timer)
	dur_timer.start()

	var cd_timer = Timer.new()
	cd_timer.wait_time = overclock_cooldown
	cd_timer.one_shot = true
	cd_timer.connect("timeout", func():
		overclock_pronto = true
		print("Overclock pronto de novo!")
		cd_timer.queue_free()
	)
	add_child(cd_timer)
	cd_timer.start()

var blink_timer: Timer = null


func start_blinking():
	blink_timer = Timer.new()
	blink_timer.wait_time = 0.15
	blink_timer.autostart = true
	blink_timer.one_shot = false
	blink_timer.connect("timeout", Callable(self, "_on_blink"))
	add_child(blink_timer)

func _on_blink():
	modulate.a = 0.3 if modulate.a == 1.0 else 1.0

func stop_blinking():
	if blink_timer and blink_timer.is_inside_tree():
		blink_timer.queue_free()
	modulate.a = 1.0  # Restaura transparência


func adicionar_pendrive(quantidade):
	if not tem_pendrive_orbital:
		return

	for _i in range(quantidade):
		if pendrives.size() >= 10:
			break  # Limite máximo de 10 pendrives
		var novo_pendrive = pendrive_scene.instantiate()
		novo_pendrive.player = self
		pendrives.append(novo_pendrive)
		add_child(novo_pendrive)


func _process(delta):
	atualizar_posicoes_orbitais(delta)
	pontuacao.text = "Pontos: %d" % Pontuacao.pontos
var tempo_oscilar: float = 10.0
@export var raio_base: float = 50.0
@export var raio_variacao: float = 30.0  # Quanto oscila o raio
@export var velocidade_orbita: float = 1.5  # Velocidade da rotação

func atualizar_posicoes_orbitais(delta):
	var count := pendrives.size()
	if count == 0:
		return

	tempo_oscilar += delta * 2.0  # Velocidade da oscilação do raio

	# Faz o raio pulsar (aumenta e diminui suavemente)
	var raio := raio_base + sin(tempo_oscilar) * raio_variacao

	for i in range(count):
		var angulo := i * (2 * PI / count) + tempo_oscilar * velocidade_orbita
		var offset := Vector2(cos(angulo), sin(angulo)) * raio
		pendrives[i].global_position = global_position + offset

		# Faz o pendrive olhar sempre para fora do centro
		pendrives[i].rotation = angulo + PI / 2

		# 🔥 Atualiza o raio de dano na skill
		pendrives[i].raio = raio
		pendrives[i].rotacao_velocidade = velocidade_orbita



func piscar_dano():
	var sprite = $AnimatedSprite2D
	print("Piscando!")
	sprite.modulate = Color(1, 0, 0)  # Fica vermelho
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)  # Volta ao normal

func heal(valor: int):
	if hp <= 0:
		return  # não cura se estiver morto
	hp = clamp(hp + valor, 0, hpmax)
	atualizar_hp_barra()
	lblHP.text = str("HP: ", hp)
	print("Curou", valor, "- HP atual:", hp)


	
func take_damage(dano: int) -> void:
	if hp <= 0:
		return  # já está morto, ignora
	if get_meta("imune", false):
		print("Jogador está imune!")
		return
	hp = clamp(hp - dano, 0, hpmax)
	atualizar_hp_barra()
	lblHP.text = str("HP: ", hp)
	print("Levou", dano, "de dano - HP atual:", hp)
	piscar_dano()
	$DamageSound.play()
	if hp <= 0:
		die()


func die() -> void:
	#print("Player morreu!")
	get_tree().change_scene_to_file("res://Scripts/game_over.tscn")
	

func start_dash():
	$CollisionShape2D.disabled = true
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_direction = direction.normalized()
	stamina -= dash_cost
	lblStamina.text = "Stamina: " + str(int(stamina))
	atualizar_stamina_barra()
	$DashSound.play()
	# Toca a animação
	if dash_direction.x > 0:
		$AnimatedSprite2D.play("dash_direita")
	elif dash_direction.x < 0:
		$AnimatedSprite2D.play("dash_esquerda")
	elif dash_direction.y > 0:		$AnimatedSprite2D.play("dash_baixo")
	elif dash_direction.y < 0:
		$AnimatedSprite2D.play("dash_cima")
	
	


func _physics_process(delta: float) -> void:
	# Atualiza a direção global
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

	var fator_lentidao := 1.0
	if has_node("/root/Clima"):
		fator_lentidao = get_node("/root/Clima").get_fator_lentidao()

	# Se estiver dando dash
	if is_dashing:
		velocity = dash_direction * DASH_SPEED * fator_lentidao
		dash_timer -= delta
		
		if dash_timer <= 0:
			is_dashing = false
			$CollisionShape2D.disabled = false

	else:
		# Movimento normal
		if direction != Vector2.ZERO:
			direction = direction.normalized()
			velocity = direction * SPEED * fator_lentidao

			# Animações
			if direction.x < 0:
				$AnimatedSprite2D.play("esquerda")
			elif direction.x > 0:
				$AnimatedSprite2D.play("direita")
			elif direction.y < 0:
				$AnimatedSprite2D.play("cima")
			elif direction.y > 0:
				$AnimatedSprite2D.play("baixo")

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			$AnimatedSprite2D.play("parado")

	# Regeneração de stamina
	regenerar_stamina(delta)

	# Movimento
	move_and_slide()

	
func regenerar_stamina(delta):
	if stamina < stamina_max:
		stamina += stamina_regen_rate * delta
		stamina = clamp(stamina, 0, stamina_max)
		lblStamina.text = "Stamina: " + str(int(stamina))
		atualizar_stamina_barra()





func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calcular_experiencia(gem_exp)

var experience = 0
var experience_level = 1
var collected_experience = 0
var pending_levelups = 0

func calcular_experiencia(gem_exp):
	var exp_necessaria = calcular_experiencia_necessaria()
	collected_experience += gem_exp
	
	var upou = false
	
	while experience + collected_experience >= exp_necessaria:
		collected_experience -= exp_necessaria - experience
		experience_level += 1
		experience = 0
		exp_necessaria = calcular_experiencia_necessaria()
		pending_levelups += 1
		upou = true 

	experience += collected_experience
	collected_experience = 0
	
	set_expbar(experience, exp_necessaria)

	if upou:
		levelup()

	
func calcular_experiencia_necessaria():
	var exp_rec = experience_level
	if experience_level < 20:
		exp_rec =  experience_level * 5
	elif experience_level < 40:
		exp_rec = 95 + (experience_level - 19) * 8
	else:
		exp_rec = 255 + (experience_level-39)*12
		
	return exp_rec

func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value;
	expBar.max_value = set_max_value
	
func atualizar_hp_barra():
	HPBar.value = hp
	HPBar.max_value = hpmax

func atualizar_stamina_barra():
	StaminaBar.max_value = stamina_max
	StaminaBar.value = stamina

	

func levelup():
	player_level = player_level+1
	dano_base += 1 + (dano_base * 0.1)
	if player_level == 10:
		tem_overclock = true
		print("System Overclock desbloqueado!")

	sndLevelUp.play()
	lblLevel.text = str("Level: ", experience_level)
		
	var viewport_size = get_viewport().get_visible_rect().size
	var painel_tamanho = levelPanel.size / 2.0
	var destino = viewport_size / 2.0 - painel_tamanho

	levelPanel.visible = true
	levelPanel.position = Vector2(viewport_size.x + 100, destino.y)  # Começa fora da tela à direita
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", destino, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)

	upgradeOptions.visible = true
	for child in upgradeOptions.get_children():
		child.queue_free()

	# 🟩 Aqui você pega as opções disponíveis
	var available_upgrades = get_available_upgrades()

	# 🟦 Se não tiver mais upgrades, fecha o painel
	if available_upgrades.size() == 0:
		print("Nenhum upgrade disponível.")
		levelPanel.visible = false
		get_tree().paused = false
		return

	# 🟧 Sorteia ou pega até 3 upgrades possíveis
	var options = 0
	var optionsmax = min(3, available_upgrades.size())
	var already_chosen = []

	while options < optionsmax:
		var skill = available_upgrades.pick_random()
		
		# Garante que não repita a mesma opção
		while already_chosen.has(skill):
			skill = available_upgrades.pick_random()

		already_chosen.append(skill)

		var option_choice = itemOptions.instantiate()
		upgradeOptions.add_child(option_choice)

		# Configura os dados da opção (nome, icone, descrição)
		option_choice.set_data(skill)

		# Conecta o clique
		option_choice.connect("selected_upgrade", Callable(self, "_on_upgrade_chosen"))

		options += 1

	get_tree().paused = true
	print("Jogo pausado")


func _on_upgrade_chosen(upgrade_data):
	print("Upgrade escolhido:", upgrade_data)

	# Marca a skill como adquirida, apenas se não for repetível
	if not upgrade_data.repeatable:
		owned_skills.append(upgrade_data.id)

	# Aplica o efeito do upgrade
	apply_upgrade(upgrade_data)

	# Limpa e fecha o painel de upgrades
	levelPanel.visible = false
	upgradeOptions.visible = false
	for child in upgradeOptions.get_children():
		child.queue_free()

	# Despausa o jogo
	get_tree().paused = false

	# Continua se houver mais levelups pendentes
	pending_levelups -= 1
	if pending_levelups > 0:
		levelup()

		
func get_available_upgrades() -> Array:
	var available = []

	for skill_id in UpgradesDB.skills.keys():
		var skill = UpgradesDB.get_skill(skill_id)

		# Verifica se já possui — exceto se for repetível
		if owned_skills.has(skill_id) and not skill.repeatable:
			continue

		# Verifica pré-requisito
		if skill.pre_requisite != "" and not owned_skills.has(skill.pre_requisite):
			continue

		available.append(skill)

	return available



func select_upgrade(skill_id: String):
	owned_skills.append(skill_id)
	print("Skill adquirida:", skill_id)


func apply_upgrade(upgrade_data):
	match upgrade_data.id:
		"packetBlaster1":
			tem_packet_blaster = true
			nivel_blaster = 1    # Sem aumento de tiros no nível 1
			quantidade_tiros = 1
			
		"packetBlaster2":
			tem_packet_blaster = true
			nivel_blaster = 2
			quantidade_tiros = 10
			
		"packetBlaster3":
			tem_packet_blaster = true
			nivel_blaster = 3
			quantidade_tiros = 20
			
		"quarentineField1":
			tem_quarantine_field = true
			nivel_quarantine = 1

		"quarentineField2":
			nivel_quarantine = 2

		"quarentineField3":
			tem_quarantine_field = true
			nivel_quarantine = 3

		"penDriveOrbital1":
			tem_pendrive_orbital = true
			adicionar_pendrive(2) # Adiciona 2 pendrives

		"penDriveOrbital2":
			tem_pendrive_orbital = true
			adicionar_pendrive(5) # Adiciona 5 pendrives

		"penDriveOrbital3":
			tem_pendrive_orbital = true
			adicionar_pendrive(10) # Adiciona 10 pendrives

		"food":
			heal(20)
		
		"boots1":
			SPEED = SPEED + (SPEED*0.1)
		"boots2":
			SPEED = SPEED + (SPEED*0.2)
		"boots3":
			SPEED = SPEED + (SPEED*0.3)
		"boots4":
			SPEED = SPEED + (SPEED*0.4)
			
		"firewallBoost1":
			tem_firewall_boost = true
			cooldown_fb = 6.0
			nivel_firewall = 1

		"firewallBoost2":
			nivel_firewall = 2
			cooldown_fb = 5.0
		"firewallBoost3":
			tem_firewall_boost = true
			nivel_firewall = 3
			cooldown_fb = 4.0
		"cleanSweep1":
			tem_clean_sweep = true
			nivel_clean_sweep = 1
			cooldown_cs = 10
		"cleanSweep2":			
			nivel_clean_sweep = 2
			cooldown_cs = 9
		"cleanSweep3":
			nivel_clean_sweep = 3
			cooldown_cs = 8
		"dataBeam1":
			tem_data_beam = true
			nivel_databeam = 1
			cooldown_databeam = 14 
		"dataBeam2":			
			nivel_databeam = 2
			cooldown_databeam = 13 
		"dataBeam3":
			nivel_databeam = 3
			cooldown_databeam = 10
		_:
			print("Upgrade sem efeito implementado:", upgrade_data.id)
