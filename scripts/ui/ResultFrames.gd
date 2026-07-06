extends RefCounted
class_name ResultFrames

const COMPLETED_FRAME_SIZE := Vector2i(297, 67)
const GAME_OVER_FRAME_SIZE := Vector2i(202, 69)
const FRAME_COUNT := 5
const FPS := 8.0

static func frame_size(completed: bool) -> Vector2i:
    return COMPLETED_FRAME_SIZE if completed else GAME_OVER_FRAME_SIZE

static func frame_index(elapsed: float) -> int:
    return clampi(int(floor(elapsed * FPS)), 0, FRAME_COUNT - 1)

static func frame_rect(completed: bool, elapsed: float) -> Rect2:
    var size: Vector2i = frame_size(completed)
    var frame: int = frame_index(elapsed)
    return Rect2(frame * size.x, 0, size.x, size.y)
