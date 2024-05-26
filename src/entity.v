struct Vec2D {
	x f32
	y f32
}

struct BoundingBox {
	top_left Vec2D
	bot_right Vec2D
}

interface Entity {
	draw(app App)
	bounding_box() BoundingBox
}