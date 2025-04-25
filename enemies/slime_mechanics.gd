extends CharacterBody2D

# Variables exportables para ajustar en el editor
@export var speed: float = 50.0  # Velocidad horizontal durante el salto
@export var jump_force: float = 400.0  # Fuerza del salto (más alto)
@export var gravity: float = 800.0    # Gravedad
@export var damage: int = 1
@export var health: int = 3

# Referencias a nodos
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var player: Node2D  # Jugador

# Variables internas
var is_jumping: bool = false
var is_hurt: bool = false
var is_dead: bool = false

func _ready():
	# Buscar al jugador por grupo
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("Error: No se encontró al jugador. Asegúrate de que tiene el grupo 'player'.")
	
	# Iniciar con la animación "idle"
	animated_sprite.play("idle")

func _physics_process(delta):
	if is_dead or player == null:
		return  # Si está muerto o no hay jugador, no hacer nada

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Resetear la velocidad vertical si está en el suelo

	# Perseguir al jugador si no está herido
	if not is_hurt:
		var direction = (player.global_position - global_position).normalized()

		# Girar la animación en espejo si va hacia la izquierda
		if direction.x < 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false

		# Solo mover en el eje X si está saltando (en el aire)
		if is_jumping:
			velocity.x = direction.x * speed
		else:
			velocity.x = 0  # No moverse en el eje X si está en el suelo

		# Saltar si no está en el aire
		if not is_jumping and is_on_floor():
			jump()

		# Mover al Slime
		move_and_slide()

		# Cambiar la animación según el estado
		if is_jumping:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("idle")

func jump():
	is_jumping = true
	velocity.y = -jump_force  # Aplicar fuerza vertical hacia arriba
	animated_sprite.play("jump")

func take_damage(amount: int):
	if is_dead:
		return

	health -= amount
	if health <= 0:
		die()
	else:
		# Animación de daño
		is_hurt = true
		animated_sprite.play("hurt")
		await get_tree().create_timer(0.5).timeout  # Esperar medio segundo
		is_hurt = false

func die():
	is_dead = true
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	queue_free()  # Eliminar el Slime de la escena

"""func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and not is_dead:
		# Quitar vida al jugador
		body.take_damage(damage)"""


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_dead:
		# Quitar vida al jugador
		body.take_damage(damage)
