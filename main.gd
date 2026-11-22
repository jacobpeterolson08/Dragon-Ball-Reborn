extends Node2D

const CELL := 64
const ORIGINAL := [0, 1, 2, 3, 4, 5, 6, 7]
const SEVEN_BEFORE_FIVE := [0, 1, 2, 3, 6, 4, 5, 7]
const SEVEN_BEFORE_SIX := [0, 1, 2, 3, 4, 6, 5, 7]

var sprite_texture: Texture2D
var sequence: Array = ORIGINAL
var step := 0
var elapsed := 0.0
var frame_time := 0.1
var playing := false
var status := "E: original | R: 7 between 4/5 | T: 7 between 5/6"
var speed_label: Label

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var image := Image.new()
    var error := image.load("res://Untitled 11-22-2026 03-06-34.png")
    if error != OK:
        status = "Sprite sheet missing from repository root"
        push_warning(status)
    else:
        sprite_texture = ImageTexture.create_from_image(image)
    _create_speed_controls()
    queue_redraw()

func _create_speed_controls() -> void:
    var panel := HBoxContainer.new()
    panel.position = Vector2(130, 475)
    panel.custom_minimum_size = Vector2(700, 40)
    add_child(panel)

    var title := Label.new()
    title.text = "Frame delay"
    panel.add_child(title)

    var slider := HSlider.new()
    slider.min_value = 0.01
    slider.max_value = 1.0
    slider.step = 0.01
    slider.value = frame_time
    slider.custom_minimum_size = Vector2(440, 24)
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.add_child(slider)

    speed_label = Label.new()
    speed_label.custom_minimum_size = Vector2(110, 24)
    panel.add_child(speed_label)
    _on_delay_changed(frame_time)
    slider.value_changed.connect(_on_delay_changed)

func _on_delay_changed(value: float) -> void:
    frame_time = value
    speed_label.text = "%.2f sec" % frame_time

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_E:
            start_animation(ORIGINAL, "Original")
        KEY_R:
            start_animation(SEVEN_BEFORE_FIVE, "Sprite 7 between 4 and 5")
        KEY_T:
            start_animation(SEVEN_BEFORE_SIX, "Sprite 7 between 5 and 6")

func start_animation(new_sequence: Array, label: String) -> void:
    if sprite_texture == null:
        return
    sequence = new_sequence
    step = 0
    elapsed = 0.0
    playing = true
    status = label + " | E/R/T to compare"
    queue_redraw()

func _process(delta: float) -> void:
    if not playing:
        return
    elapsed += delta
    while elapsed >= frame_time:
        elapsed -= frame_time
        step += 1
        if step >= sequence.size():
            step = sequence.size() - 1
            playing = false
            break
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#171b27"))
    if sprite_texture != null:
        var frame: int = sequence[step]
        var source := Rect2(frame * CELL, 0, CELL, CELL)
        var dest_size := Vector2(CELL, CELL) * 5.0
        var dest := Rect2((get_viewport_rect().size - dest_size) / 2.0, dest_size)
        draw_texture_rect_region(sprite_texture, dest, source, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(28, 42), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
