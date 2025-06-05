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

	func _init(id: String, name: String, icon_path: String, description: String, level: String,pre_requisite: String,type: String):
		self.id = id
		self.name = name
		self.icon_path = icon_path
		self.description = description
		self.level = level
		self.pre_requisite = pre_requisite
		self.type = type

# Dicionário contendo todas as skills
static var skills = {}

func _ready():
	# Preenche o banco de dados
	_add_skill("penDriveOrbital1", "Pen Drive Orbital", "res://Textures/Items/Weapons/pendrivefaca.png", "Pen Drives que causam dano ao contato orbitam o jogador.", "1", "", "skill")
	_add_skill("penDriveOrbital2", "Pen Drive Orbital", "res://Textures/Items/Weapons/pendrivefaca.png", "Pen Drives que causam dano ao contato orbitam o jogador.", "2", "penDriveOrbital1", "skill")
	_add_skill("penDriveOrbital3", "Pen Drive Orbital", "res://Textures/Items/Weapons/pendrivefaca.png", "Pen Drives que causam dano ao contato orbitam o jogador.", "3", "penDriveOrbital2", "skill")
	_add_skill("quarentineField1", "Quarentine Field", "res://Textures/Items/Weapons/Quarentine Field.png", "Cria um campo espiral que causa dano por segundo e lentidão a inimigos próximos" , "1", "", "skill")
	_add_skill("quarentineField2", "Quarentine Field", "res://Textures/Items/Weapons/Quarentine Field.png", "Cria um campo espiral que causa dano por segundo e lentidão a inimigos próximos" , "2", "quarentineField1", "skill")
	_add_skill("quarentineField3", "Quarentine Field", "res://Textures/Items/Weapons/Quarentine Field.png", "Cria um campo espiral que causa dano por segundo e lentidão a inimigos próximos" , "3", "quarentineField2", "skill")
	_add_skill("packetBlaster1", "Packet Blaster", "res://Textures/Items/Weapons/boladeenergia.png", "Arma que dispara pacotes e causam dano ao atingir o inimigo",  "1", "", "skill")
	_add_skill("packetBlaster2", "Packet Blaster", "res://Textures/Items/Weapons/boladeenergia.png", "Arma que dispara pacotes e causam dano ao atingir o inimigo",  "2", "packetBlaster1", "skill")
	_add_skill("packetBlaster3", "Packet Blaster", "res://Textures/Items/Weapons/boladeenergia.png", "Arma que dispara pacotes e causam dano ao atingir o inimigo",  "3", "packetBlaster2", "skill")
	_add_skill("food", "Food","res://Textures/Items/Upgrades/chunk.png","Cura 20 de HP", "N/A","", "item") 
	

func _add_skill(id, name, icon_path, description, level, pre_requisite, type):
	skills[id] = Skill.new(id, name, icon_path, description, level, pre_requisite, type)

static func get_skill(id: String) -> Skill:
	return skills.get(id)
