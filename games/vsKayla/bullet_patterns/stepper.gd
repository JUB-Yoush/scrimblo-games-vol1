extends Node2D
# alert flashes in zone
# alert drops the hitbox
# das ito

var is_dropping = false
signal dropped

func drop():
    print('drop')
    %Alert.visible = true
    for i in range(20):
        %Alert.frame = (%Alert.frame + 1) % 3
        await get_tree().create_timer(.05).timeout
    %Alert.visible = false
    %StepperArea.position.y -= 90
    %StepperArea.visible = false
    is_dropping = true
    await dropped


func _process(delta: float) -> void:
    if is_dropping:
        %StepperArea.position.y += 20 * delta
        if %StepperArea.position.y <= 0:
            is_dropping = false
            dropped.emit()
