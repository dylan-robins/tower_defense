import gg
import gx
import arrays

struct Button {
mut:
	size Vec2D @[required]
	center Vec2D @[required]
	text string
	color gg.Color = gg.Color{ r: 120, g: 88, b: 56}
}

fn (btn Button) bounding_box() BoundingBox {
	return BoundingBox{
		top_left: Vec2D{
			x: btn.center.x - btn.size.x / 2
			y: btn.center.y - btn.size.y / 2
		}
		bot_right: Vec2D{
			x: btn.center.x + btn.size.x / 2
			y: btn.center.y + btn.size.y / 2
		}
	}
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

struct ButtonContainer {
	children []Button @[required]
	color gg.Color @[required]
	padding int = 20
}

fn (container ButtonContainer) bounding_box() BoundingBox {
	child_bbs := container.children.map(it.bounding_box())
	return BoundingBox{
		top_left: Vec2D{
			x: arrays.min(child_bbs.map(it.top_left.x)) or {panic(err)} - container.padding
			y: arrays.min(child_bbs.map(it.top_left.y)) or {panic(err)} - container.padding
		}
		bot_right: Vec2D{
			x: arrays.max(child_bbs.map(it.bot_right.x)) or {panic(err)} + container.padding
			y: arrays.max(child_bbs.map(it.bot_right.y)) or {panic(err)} + container.padding
		}
	}
}

fn (container ButtonContainer) draw(app App) {
	// Draw button background

	bb := container.bounding_box()
	
	app.gg.draw_rect_filled(
		bb.top_left.x,
		bb.top_left.y,
		bb.bot_right.x - bb.top_left.x,
		bb.bot_right.y - bb.top_left.y,
		container.color
	)
	
	for child in container.children {
		child.draw(app)
	}
}