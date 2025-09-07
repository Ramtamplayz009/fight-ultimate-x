extends Control
class_name Fight

signal home

@onready var bemo: Sprite2D = $Bemo
@onready var guy: Sprite2D = $Guy

@onready var enemy_pos: Control = $VBoxContainer/FightHBox/EnemyPos
@onready var player_pos: Control = $VBoxContainer/FightHBox/PlayerPos

@onready var player_hp_bar: ProgressBar = $VBoxContainer/MarginContainer/HBoxContainer/PlayerHPVBox/HPBar
@onready var bemo_hp_bar: ProgressBar = $VBoxContainer/MarginContainer/HBoxContainer/CPUHPVBox/HPBar

@onready var bemo_hp_amount: Label = $VBoxContainer/MarginContainer/HBoxContainer/CPUHPVBox/HPAmount
@onready var player_hp_amount: Label = $VBoxContainer/MarginContainer/HBoxContainer/PlayerHPVBox/HPAmount

var level: int

const MAX_PLAYER_HP: int = 100
var player_hp: int = 100

const MAX_BEMO_HP: int = 50
var bemo_hp: int = 50

# Sets player cooldown
const SHOOT_COOLDOWN: float = 2.5
var shoot_cooldown: float = 0
const EB_COOLDOWN: float = 5
var eb_cooldown: float = 2.5
const BOMB_COOLDOWN: float = 10
var bomb_cooldown: float = 5

# Sets bemo cooldown to 2.5
const BEMO_COOLDOWN: float = 2.5
var bemo_cooldown: float = BEMO_COOLDOWN

var player_dead: bool = false
var bemo_dead: bool = false

const SHOOT_DAMAGE: int = 10
const ENERGY_BALL_DAMAGE: int = 15
const BOMB_DAMAGE: int = 20

const BEMO_DAMAGE: int = 10

# Makes the ability buttons a varible
@onready var shoot_button: TextureButton = $VBoxContainer/PanelContainer/AbilityHbox/ShootButton
@onready var energy_ball_button: TextureButton = $VBoxContainer/PanelContainer/AbilityHbox/EnergyballButton
@onready var bomb_button: TextureButton = $VBoxContainer/PanelContainer/AbilityHbox/BombButton

@onready var u_lost: PanelContainer = $ULost
@onready var retry_button: Button = $ULost/PanelContainer/MarginContainer/VBoxContainer/RetryButton

@onready var coins_label: RichTextLabel = $VBoxContainer/MarginContainer/HBoxContainer/UsernameAndHomeVbox/CoinsLabel
@onready var gems_label: RichTextLabel = $VBoxContainer/MarginContainer/HBoxContainer/UsernameAndHomeVbox/GemsLabel
@onready var home_button: TextureButton = $VBoxContainer/MarginContainer/HBoxContainer/UsernameAndHomeVbox/HomeButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shoot_button.pressed.connect(_shoot)
	energy_ball_button.pressed.connect(_eb)
	bomb_button.pressed.connect(_bomb)
	
	retry_button.pressed.connect(_retry)
	
	home_button.pressed.connect(home.emit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_coins()
	_update_gems()
	
	if player_hp > 0:
		guy.position = player_pos.global_position - Vector2(0, guy.scale.y * guy.texture.get_size().y / 2)
	elif not player_dead:
		player_dead = true
		_animate_player_death()
	
	if bemo_hp > 0:
		bemo.position = enemy_pos.global_position - Vector2(0, bemo.scale.y * bemo.texture.get_size().y / 2)
	elif not bemo_dead:
		bemo_dead = true
		_animate_bemo_death()

	# Sets Visual to UI
	player_hp_bar.max_value = MAX_PLAYER_HP
	player_hp_bar.value = player_hp
	player_hp_amount.text = str(player_hp) + "/" + str(MAX_PLAYER_HP)
	
	bemo_hp_bar.max_value = MAX_BEMO_HP
	bemo_hp_bar.value = bemo_hp
	bemo_hp_amount.text = str(bemo_hp) + "/" + str(MAX_BEMO_HP)
	
	shoot_cooldown -= delta
	eb_cooldown -= delta
	bomb_cooldown -= delta
	
	(shoot_button.material.set_shader_parameter("progress", shoot_cooldown / SHOOT_COOLDOWN))
	(energy_ball_button.material.set_shader_parameter("progress", eb_cooldown / EB_COOLDOWN))
	(bomb_button.material.set_shader_parameter("progress", bomb_cooldown / BOMB_COOLDOWN))
	
	# Bemo shoots
	bemo_cooldown -= delta
	if player_hp > 0 and bemo_hp > 0 and bemo_cooldown < 0:
		_bemo_shoot()
		bemo_cooldown = BEMO_COOLDOWN
	
	if player_hp <= 0:
		u_lost.show()
	else:
		u_lost.hide()

func _shoot() -> void:
	if player_hp > 0 and bemo_hp > 0 and shoot_cooldown < 0:
		bemo_hp -= SHOOT_DAMAGE
		bemo_hp = max(0, bemo_hp)
		shoot_cooldown = SHOOT_COOLDOWN

func _retry() -> void:
	player_hp = MAX_PLAYER_HP
	player_dead = false
	bemo_hp = MAX_BEMO_HP
	bemo_dead = false
	shoot_cooldown = 0
	eb_cooldown = 2.5
	bomb_cooldown = 5
	bemo_cooldown = BEMO_COOLDOWN

func _eb() -> void:
	if player_hp > 0 and bemo_hp > 0 and eb_cooldown < 0:
		bemo_hp -= ENERGY_BALL_DAMAGE
		bemo_hp = max(0, bemo_hp)
		eb_cooldown = EB_COOLDOWN

func _bomb() -> void:
	if player_hp > 0 and bemo_hp > 0 and bomb_cooldown < 0:
		bemo_hp -= BOMB_DAMAGE
		bemo_hp = max(0, bemo_hp)
		bomb_cooldown = BOMB_COOLDOWN

func _bemo_shoot() -> void:
	player_hp -= BEMO_DAMAGE

func _animate_player_death() -> void:
	progress.coins -= 10
	progress.coins = max(0, progress.coins)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(guy, "position:y", guy.position.y + 1000, 1.5)

func _animate_bemo_death() -> void:
	progress.coins += 50
	progress.coins = min(9999, progress.coins)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(bemo, "position:y", bemo.position.y + 1000, 1.5)
	await tween.finished
	_retry()

func _update_coins() -> void:
	var text: String = "[center][img=64]res://coin.png[/img] [wave]%d[/wave][/center]" % progress.coins
	coins_label.text = text

func _update_gems() -> void:
	var text: String = "[center][img=64]res://Gem.png[/img] [wave]%d[/wave][/center]" % progress.gems
	gems_label.text = text
