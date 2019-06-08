extends Area2D

export (int) var speed
export (int) var damage
export (float) var steer_force = 0

var velocity = Vector2()
var acceleration = Vector2()
var target = null

func start(_position, _direction, _target=null):
	#if target:
	position = _position
	rotation = _direction.angle()
	velocity = _direction * speed
	# weakref because of https://godotengine.org/qa/3645/previously-freed-instance-error
	if(target):
		target = weakref(_target)
	

func seek():
	if target:
		var ref = target.get_ref()
		if ref:
			var desired = (ref.position - position).normalized() * speed
			var steer = (desired - velocity).normalized() * steer_force
			return steer

func _process(delta):
	if target:
		var ref = target.get_ref()
		if ref:
			acceleration += seek()
			velocity += acceleration * delta
			velocity = velocity.clamped(speed)
			rotation = velocity.angle()
	position += velocity * delta

func explode():
	set_process(false)
	velocity = Vector2()
	$Sprite.hide()
	$Explosion.show()
	$Explosion.play("smoke")

func _on_Bullet_body_entered(body):
	explode()
	if body.has_method('take_damage'):
		body.take_damage(damage)

func _on_Lifetime_timeout():
	explode()

func _on_Explosion_animation_finished():
	queue_free()
