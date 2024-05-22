import gg

struct Vec2D {
	x f32
	y f32
}

struct Button {
mut:
	size Vec2D @[required]
	center Vec2D @[required]
	text string
	color gg.Color = gg.Color{ r: 120, g: 88, b: 56}
}