extends KinematicBody2D

#PARA QUE RESTEN VIDAS LOS ENEMIGOS
signal player_hit

export (PackedScene) var ice

const acceleration = 70
const max_speed = 150
const PROYECTIL = preload("res://Proyectil.tscn")

var speed = 10
var jump_speed = 620
var gravity = 40

var velocity = Vector2.ZERO
#?
var lifes = 3 

var motion = Vector2()



func _ready():
	$AnimatedSprite.playing = true
	

func _physics_process(_delta):
	move()
	jump()
	velocity = move_and_slide(velocity, Vector2(0,-1))

func move():
	velocity.y += gravity
	
	if Input.is_action_just_pressed("shoot"):
		$Bonus.playing = true
		$Timer.start()
		var midisparo = PROYECTIL.instance()
		get_parent().add_child(midisparo)
		midisparo.position = $Position2D.global_position
		
		#DIRECCIÓN DEL DISPARO
		if sign($Position2D.position.x) == 1:
			midisparo.set_direccion_proyectil(1)
		else:
			midisparo.set_direccion_proyectil(-1)
			
	
			
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = min(velocity.x + acceleration, max_speed)
		$AnimatedSprite.flip_h = false
		#DIRECCIÓN DEL DISPARO
		if sign($Position2D.position.x) == -1:
			$Position2D.position.x *= -1
	elif Input.is_action_pressed("ui_left"):
		velocity.x = max(velocity.x - acceleration, -max_speed)
		$AnimatedSprite.flip_h = true
		#DIRECCIÓN DEL DISPARO
		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1
	else:
		velocity.x = 0
	
	
	if velocity.x == 0:
		$AnimatedSprite.animation = "Idle"
	elif velocity.x > 0 or velocity.x < 0:
		$AnimatedSprite.animation = "Run"
	

func jump():
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			$Jump.playing = true
			velocity.y -= jump_speed
		else:
			$Jump.playing = false
		
	
	if !is_on_floor():
		if velocity.y < -1:
			$AnimatedSprite.animation = "Jump"
		if velocity.y > 1:
			$AnimatedSprite.animation = "Falling"
	

func _loseLife(var enemyposx):
	#Para cuando está a la izquierda del enemigo
	if position.x < enemyposx:
		velocity.x = -500
		velocity.y = -250
	#Para cuando está a la derecha del enemigo
	if position.x > enemyposx:
		motion.x = 500
		motion.y = -250
	
	lifes = lifes - 1
	
	var canvasLayer = get_tree().get_root().find_node("CanvasLayer",true,false)
	canvasLayer.handleHearts(lifes)
	
	#Ponemos menor igual por si acaso se le restan varias a la vez, que no rompa
	if lifes <= 0:
		get_tree().reload_current_scene()





func _on_Timer_timeout():
	$Bonus.playing = false
