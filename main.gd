extends Node2D

const CELL := 64
const FRAME_COUNT := 8
const FRAME_TIME := 0.1

var sprite_texture: Texture2D
var frame_index := 0
var elapsed := 0.0
var playing := false
var status := "Press E to play the intro"

func _ready() -> void:
    var image := Image.new()
    var error := image.load("res://assets/spritesheet.png")
    if error != OK:
        status = "Add your 1024x1024 PNG as assets/spritesheet.png"
        push_warning(status)
    else:
        sprite_texture = ImageTexture.create_from_image(image)
    queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
        if sprite_texture != null:
            frame_index = 0
            elapsed = 0.0
            playing = true
            status = "Playing intro..."
            queue_redraw()

func _process(delta: float) -> void:
    if not playing:
        return
    elapsed += delta
    while elapsed >= FRAME_TIME:
        elapsed -= FRAME_TIME
        frame_index += 1
        if frame_index >= FRAME_COUNT:
            frame_index = FRAME_COUNT - 1
            playing = false
            status = "Intro finished. Press E to replay."
            break
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#171b27"))
    if sprite_texture != null:
        var source := Rect2(frame_index * CELL, 0, CELL, CELL)
        var scale_factor := 4.0
        var dest_size := Vector2(CELL, CELL) * scale_factor
        var dest := Rect2((get_viewport_rect().size - dest_size) / 2.0, dest_size)
        draw_texture_rect_region(sprite_texture, dest, source, Color.WHITE)
    var font := ThemeDB.fallback_font
    draw_string(font, Vector2(28, 42), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
