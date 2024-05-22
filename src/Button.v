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

fn (btn Button) draw(app App) {
	// Draw button background
	app.gg.draw_rect_filled(
		(btn.center.x - 0.5*btn.size.x),
		(btn.center.y - 0.5*btn.size.y),
		btn.size.x,
		btn.size.y,
		btn.color
	)
	// Draw button text
	text_config := gx.TextCfg{
		align: .center
		vertical_align: .middle
	}
	app.gg.draw_text(int(btn.center.x), int(btn.center.y), btn.text, text_config)
}
