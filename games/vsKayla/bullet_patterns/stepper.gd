extends Node2D
# alert flashes in zone
# alert drops the hitbox
# das ito

var is_dropping = false
var hit = false
@onready var collisionShape = $StepperArea/CollisionShape2D

signal dropped
func drop():
    %Alert.visible = true
    %StepperArea.visible = false
    collisionShape.disabled = true
    for i in range(randi_range(11,13)):
        %Alert.frame = (%Alert.frame + 1) % 3
        await get_tree().create_timer(.05).timeout
    %Alert.visible = false
    %StepperArea.position.y -= 90
    %StepperArea.visible = true
    collisionShape.disabled = false
    is_dropping = true
    await dropped


func _process(delta: float) -> void:
    if is_dropping:
        %StepperArea.position.y += 500 * delta
        if %StepperArea.position.y >= 0:
            is_dropping = false
            dropped.emit()

func _ready() -> void:
    %StepperArea.add_to_group("bullets")
    %StepperArea.add_to_group("onehit")
    #%StepperArea.area_entered.connect(func(area):%StepperArea.queue_free())

