extends Node2D

const CELL := 64
const FRAME_COUNT := 8
const FRAME_TIME := 0.1
const PAUSE_AFTER_FOUR := 0.3

var sprite_texture: Texture2D
var frame_index := 0
var elapsed := 0.0
var playing := false
var status := "Press E to play the intro"

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var image := Image.new()
    var error := image.load("res://Untitled 11-22-2026 03-06-34.png")
    if error != OK:
        status = "Sprite sheet missing from repository root"
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
            status = "Playing intro... (E to replay)"
            queue_redraw()

func _process(delta: float) -> void:
    if not playing:
        return
    elapsed += delta
    while playing:
        # Hold sprite 4 for 0.3 seconds before switching to sprite 5.
        var delay := PAUSE_AFTER_FOUR if frame_index == 3 else FRAME_TIME
        if elapsed < delay:
            break
        elapsed -= delay
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
        var dest_size := Vector2(CELL, CELL) * 5.0
        var dest := Rect2((get_viewport_rect().size - dest_size) / 2.0, dest_size)
        draw_texture_rect_region(sprite_texture, dest, source, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(28, 42), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
