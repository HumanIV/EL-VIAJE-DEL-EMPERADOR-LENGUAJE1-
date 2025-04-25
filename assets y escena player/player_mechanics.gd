extends CharacterBody2D
@export var max_health = 3
@export var max_lives = 3
@export var move_speed: float
@export var jump_speed: float

@export var hud: Node

var is_facing_right=true
@onready var animated_sprite= $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking=false #controla si el personaje ataca
#@export var health: int = 3
#@export var lives: int = 3
var is_dead = false
var is_hit = false
var invincible = false
@onready var invincibility_timer = $InvincibilityTimer

#sonido espada
@onready var attack_sound=$AttackSound

#Cambiar las colisiones cuando se agache
@onready var normal_collision=$CollisionShape2D
@onready var crouch_collision=$CrouchCollisionShape2D

#referenciar al ataque
@onready var attack_area=$AnimatedSprite2D/Area2D
@onready var crouch_attack_area=$AnimatedSprite2D/CrouchArea2D
@onready var jump_attack_area=$AnimatedSprite2D/JumpArea2D
var axis : Vector2

func _ready() -> void:
	if !GameState.initialized:
		GameState.initialize(max_health, max_lives)

func _process(_delta):
	if position.y > 330:
		queue_free()

func _physics_process(delta: float) -> void:
	if not is_attacking and not Input.is_action_pressed("crouch"):
			move_x()
	if not is_on_floor():
		velocity.y+=gravity*delta
	move_and_slide()
	update_animations()
	attack()

func update_animations():
	if is_dead:
		return
	if is_hit:
		animated_sprite.play("hit")
		return
		
	if is_attacking:
		return
	if Input.is_action_pressed("crouch") and is_on_floor():
		var crouch_axis= Input.get_axis("left", "right")
		if crouch_axis !=0:
			$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x) * crouch_axis
		animated_sprite.play("crouch")
		if is_attacking:
			animated_sprite.play("crouch_attack")
		return
		
	"""if Input.is_action_just_pressed("attack"):
		animated_sprite.play("attack")
		return"""
	
	if not is_on_floor():
		if is_attacking:
			animated_sprite.play("jump_attack")
		elif velocity.y<0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		return
	
	if velocity.x:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	

func jump():
	velocity.y= -jump_speed

#func flip():
	"""if (is_facing_right and velocity.x<0) or (not is_facing_right and velocity.x>0):
		scale.x*=-1
		is_facing_right = not is_facing_right"""
	#if velocity.x > 0:
		#animated_sprite.flip_h = false  # Mirando a la derecha
		#is_facing_right = true
	#elif velocity.x<0:
		#animated_sprite.flip_h = true  # Mirando a la izquierda
		#is_facing_right = false
		
func get_axis() -> Vector2:
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	axis.y = 0
	return axis.normalized() if axis != Vector2() else Vector2()
	
func move_x():
	if not get_axis().x == 0:
		$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x) * get_axis().x
	velocity.x = get_axis().x * move_speed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor() and not Input.is_action_pressed("attack"):
		jump()
	if event.is_action_pressed("crouch")  and is_on_floor() and not Input.is_action_pressed("attack"):
		crouch()

func crouch():
	velocity.x = 0
	if Input.is_action_pressed("crouch"):
		normal_collision.disabled=true
		crouch_collision.disabled=false
	else:
		normal_collision.disabled=false
		crouch_collision.disabled=true

func attack():
	if Input.is_action_just_pressed("attack") and not is_attacking:
		velocity.x = 0
		is_attacking=true
		#seleccionar area de ataque
		var current_attack_area
		if is_on_floor() and Input.is_action_pressed("crouch"):
			animated_sprite.play("crouch_attack")
			current_attack_area= crouch_attack_area
		elif is_on_floor():
			animated_sprite.play("attack")
			current_attack_area=attack_area
		else:
			animated_sprite.play("jump_attack")
			current_attack_area=jump_attack_area
		if is_attacking:
			attack_sound.play()
			
		detect_enemies(current_attack_area)
			
		# Aquí puedes agregar lógica adicional para el ataque, como detectar colisiones con enemigos

func take_damage(amount):
	if invincible or is_dead:
		return
	
	invincible = true
	invincibility_timer.start()
	
	GameState.current_health = max(0, GameState.current_health - amount)
	is_hit = true
	is_attacking = false  # Cancela cualquier ataque en progreso
	animated_sprite.play("hit")
	#var canvasLayer = get_tree().get_root().find_node("res://UI/HUD.tscn", true, false)
	#canvasLayer.handlehearths(GameState.current_health)
	hud.handlehearts(GameState.current_health)
	
	if GameState.current_health <= 0:
		die()
		
func die():
	is_dead= true
	animated_sprite.play("die")
	set_physics_process(false)
	set_process_input(false)
	$CollisionShape2D.disabled=true
	
func respawn():
	GameState.reset_health()
	get_tree().reload_current_scene()

#func  _on_InvincibilityTimer_timeout():
	#invincible=false

func detect_enemies(damage_area): # llamada al current attack area como parametro
	#obtener todos los cuerpos del area de ataque
	var bodies = damage_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy"): #verificar si el cuerpo es un enemigo
			#aplicar daño o logica de ataque
			body.take_damage(1) #ejemplo el enemigo tiene la funcion take_damage""" #aún no config el enemy

#script para el enemigo
""" var health = 3  # Salud inicial del enemigo

func take_damage(amount):
	health -= amount  # Reducir la salud según el daño recibido
	if health <= 0:
		queue_free()  # Eliminar el enemigo si su salud llega a 0"""


func _on_animated_sprite_2d_animation_finished() -> void:
	match $AnimatedSprite2D.animation:
		"attack":
			is_attacking = false
		"crouch_attack":
			is_attacking = false
		"jump_attack":
			is_attacking = false 
		"hit":
			is_hit = false
		"die":
			GameState.current_lives -= 1
			if GameState.current_lives > 0:
				respawn()
			else:
				GameState.reset()
				get_tree().change_scene_to_file("res://UI/gameover.tscn")


func _on_invincibility_timer_timeout() -> void:
	invincible=false # Replace with function body.d
