import gg

struct App {
mut:
	gg          &gg.Context = unsafe { nil }
	frame_count int
	map         Map
	size        gg.Size
	escaped     bool
}

fn (mut app App) do_first_frame() {
	app.size = app.gg.window_size()
	app.map = Map{
		/*hero: Hero{
			speed: 1
			radius_size: 10
			max_pv: 500
			pos: [f32(500), f32(484)]
			st&&by_pos: [f32(500), f32(484)]
			degats: 5
			vision: 100
			portee: 5
			respawn_time: 3600
			respawn_cooldown: 3600
			pv: 500
		}*/
		money: 40
		pv: 10
	}
	app.frame_count = app.map.difficulte * 3600
	app.map.circuits << [][][]f32{}
	app.map.circuits[0] << [][]f32{len: 21000, init: [circuit_compose1lane1(index)[0], circuit_compose1lane1(index)[1]]}
	app.map.circuits[0] << [][]f32{len: 22000, init: [circuit_compose1lane2(index)[0], circuit_compose1lane2(index)[1]]}
	app.map.circuits[0] << [][]f32{len: 23000, init: [circuit_compose1lane3(index)[0], circuit_compose1lane3(index)[1]]}
}

fn (mut app App) do_pause_menu() {
	window_bg_color := gg.Color{ r: 53, g: 53, b: 53 }
	
	// background
	app.gg.draw_rect_filled(0, 0, app.size.width, app.size.height, window_bg_color)
	
	app.gg.begin()

	Button{
		size: Vec2D{125, 100}
		center: Vec2D{app.size.width / 2 - 200, app.size.height / 2}
		text: "Continue ?"
	}.draw(app)

	Button{
		size: Vec2D{125, 100}
		center: Vec2D{app.size.width / 2, app.size.height / 2}
		text: "Restart ?"
	}.draw(app)

	Button{
		size: Vec2D{125, 100}
		center: Vec2D{app.size.width / 2 + 200, app.size.height / 2}
		text: "Quit ?"
	}.draw(app)
	// btn area background
	// app.gg.draw_rect_filled(app.size.width / 2 - 250, app.size.height / 2 - 75, 500, button_height+2*button_width, btn_area_bg_color)

	app.gg.end(how: .clear)
}
