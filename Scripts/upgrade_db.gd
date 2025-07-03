extends Node

class_name UpgradesDB

# Estrutura básica de uma skill
class Skill:
	var id: String
	var name: String
	var icon_path: String
	var level: String
	var description: String
	var pre_requisite: String
	var type: String
	var repeatable: bool

	func _init(id, name, icon_path, description, level, pre_requisite, type, repeatable := false):
		self.id = id
		self.name = name
		self.icon_path = icon_path
		self.description = description
		self.level = level
		self.pre_requisite = pre_requisite
		self.type = type
		self.repeatable = repeatable


# Dicionário contendo todas as skills
static var skills = {}

func _ready():
	# Preenche o banco de dados
	_add_skill("penDriveOrbital1", "Pen Drive Orbital", "res://Textures/Items/Weapons/pendrivefaca.png", "Pen Drives que causam dano ao contato orbitam o jogador.", "1", "", "skill")
	_add_skill("penDriveOrbital2", "Pen Drive Orbital", "res://Textures/Items/Weapons/pendrivefaca.png", "Pen Drives que causam dano ao contato orbitam o jogador.", "2", "penDriveOrbital1", "skill")
	_add_skill("penDriveOrbital3", "Pen Drive Orbital", "res://Textures/Items/Weapons/pendrivefaca.png", "Pen Drives que causam dano ao contato orbitam o jogador.", "3", "penDriveOrbital2", "skill")
	_add_skill("quarentineField1", "Tecla 1: Quarentine Field", "res://Textures/Items/Weapons/Quarentine Field.png", "Cria um campo espiral que causa dano por segundo e lentidão a inimigos próximos" , "1", "", "skill")
	_add_skill("quarentineField2", "Tecla 1: Quarentine Field", "res://Textures/Items/Weapons/Quarentine Field.png", "Cria um campo espiral que causa dano por segundo e lentidão a inimigos próximos" , "2", "quarentineField1", "skill")
	_add_skill("quarentineField3", "Tecla 1: Quarentine Field", "res://Textures/Items/Weapons/Quarentine Field.png", "Cria um campo espiral que causa dano por segundo e lentidão a inimigos próximos" , "3", "quarentineField2", "skill")
	_add_skill("packetBlaster1", "Packet Blaster", "res://Textures/Items/Weapons/boladeenergia.png", "Arma que dispara pacotes e causam dano ao atingir o inimigo",  "1", "", "skill")
	_add_skill("packetBlaster2", "Packet Blaster", "res://Textures/Items/Weapons/boladeenergia.png", "Arma que dispara pacotes e causam dano ao atingir o inimigo",  "2", "packetBlaster1", "skill")
	_add_skill("packetBlaster3", "Packet Blaster", "res://Textures/Items/Weapons/boladeenergia.png", "Arma que dispara pacotes e causam dano ao atingir o inimigo",  "3", "packetBlaster2", "skill")
	_add_skill("firewallBoost1", "Tecla 2: Firewall Boost", "res://Textures/spot.png", "Cria um escudo temporário em volta do jogador",  "1", "", "skill")
	_add_skill("firewallBoost2", "Tecla 2: Firewall Boost", "res://Textures/spot.png", "Cria um escudo temporário em volta do jogador",  "2", "firewallBoost1", "skill")
	_add_skill("firewallBoost3", "Tecla 2: Firewall Boost", "res://Textures/spot.png", "Cria um escudo temporário em volta do jogador",  "3", "firewallBoost2", "skill")
	_add_skill("food", "Food","res://Textures/Items/Upgrades/chunk.png","Cura 20 de HP", "N/A","", "item",true) 
	_add_skill("boots1", "Boots","res://Textures/Items/Upgrades/boots_4_green.png","Aumenta a velocidade de movimento em 1%", "N/A","", "item") 
	_add_skill("boots2", "Boots","res://Textures/Items/Upgrades/boots_4_green.png","Aumenta a velocidade de movimento em 2%", "N/A","boots1", "item") 
	_add_skill("boots3", "Boots","res://Textures/Items/Upgrades/boots_4_green.png","Aumenta a velocidade de movimento em 3%", "N/A","boots2", "item") 
	_add_skill("boots4", "Boots","res://Textures/Items/Upgrades/boots_4_green.png","Aumenta a velocidade de movimento em 4%", "N/A","boots3", "item") 
	_add_skill("cleanSweep1", "Tecla 3: Clean Sweep", "res://Textures/Items/Gems/XP_BOSS.png", "Cria uma grande explosão em área",  "1", "", "skill")
	_add_skill("cleanSweep2", "Tecla 3: Clean Sweep", "res://Textures/Items/Gems/XP_BOSS.png", "Cria uma grande explosão em área",  "2", "cleanSweep1", "skill")
	_add_skill("cleanSweep3", "Tecla 3: Clean Sweep", "res://Textures/Items/Gems/XP_BOSS.png", "Cria uma grande explosão em área",  "3", "cleanSweep2", "skill")
	_add_skill("dataBeam1", "Tecla 4: Data Beam", "res://Textures/Items/Weapons/javelin_3_new_attack.png", "Cria um feixe de dados em linha reta que causa dano por segundo ao contato",  "1", "", "skill")
	_add_skill("dataBeam2", "Tecla 4: Data Beam", "res://Textures/Items/Weapons/javelin_3_new_attack.png", "Cria um feixe de dados em linha reta que causa dano por segundo ao contato",  "2", "databeam1", "skill")
	_add_skill("dataBeam3", "Tecla 4: Data Beam", "res://Textures/Items/Weapons/javelin_3_new_attack.png", "Cria um feixe de dados em linha reta que causa dano por segundo ao contato",  "3", "databeam2", "skill")
	
func _add_skill(id, name, icon_path, description, level, pre_requisite, type, repeatable := false):
	skills[id] = Skill.new(id, name, icon_path, description, level, pre_requisite, type, repeatable)


static func get_skill(id: String) -> Skill:
	return skills.get(id)
