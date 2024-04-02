import gg
import math

const win_width = 601
const win_height = 601
const bg_color = gg.Color{
	r: 0
	g: 200
	b: 0
}

struct App {
mut:
	gg &gg.Context = unsafe { nil }
	frame_count int
	map Map
	size gg.Size
}

struct Map {
	ennemi_spawn [][]f32
	circuits [][][]f32
mut:
	hero Hero
	projectiles []Projectile
	tours []Tower
	ennemis []Ennemi
	pv int
	placing_mode bool
	can_place bool
	money int
	hero_selected bool
}

struct Ennemi {
	circuit int
	radius int
	degats int
	money int
	vitesse int
	max_pv int
mut:
	fighting bool
	hit_cooldown int = 60
	pos_xy []f32
	pos_relatif int
	pv int
}

struct Tower {
	radius int
	range int
	degats int
	pos []int
	prix int
mut:
	cooldown int = 60
}

struct Projectile {
	radius int
	vitesse int
	degats int
mut:
	pos []f32
	life_span int
	vecteur_directeur []f32
}

struct Hero {
	max_pv int
	degats f32
	vision int
	portee int
	respawn_time int
mut:
	respawn_cooldown int
	pos []f32
	standby_pos []f32
	en_deplacement bool
	cible_deplacement []f32
	pv f32
	fighting bool
}


fn main() {
	mut app := &App{}
	app.gg = gg.new_context(
		width: win_width
		height: win_height
		create_window: true
		window_title: 'TD.v'
		user_data: app
		fullscreen: true
		bg_color: bg_color
		frame_fn: on_frame
		event_fn: on_event
		sample_count: 2
	)
	
	// lancement du programme/de la fenêtre
	app.gg.run()
}

fn on_frame(mut app App) {
	if app.frame_count == 0 {
		app.size = app.gg.window_size()
		app.map = Map {ennemi_spawn: [[f32(0), f32(484)]], circuits: [][][]f32{len: 1, init: [][]f32{len: 2400, init: [circuit_compose(index)[0], circuit_compose(index)[1]]}}, hero: Hero{max_pv: 500, pos: [f32(500), f32(484)], standby_pos: [f32(500), f32(484)], degats: 5, vision: 100, portee: 5, respawn_time: 3600, respawn_cooldown: 3600, pv: 500},  money: 40, pv: 10}
	}
	if app.map.pv > 0 {
		app.frame_count += 1
		if app.frame_count % 60  == 0 {
			app.map.ennemis << Ennemi{pos_xy: app.map.ennemi_spawn[0].clone(), radius: 10, pos_relatif: 0, circuit: 0, max_pv: 5 + app.frame_count / 600, pv: 5 + app.frame_count / 600, degats: 1, vitesse: 1 + app.frame_count / 6000}
		}
		
		mut distance_min := f32(60 * 60)
		for circuit in app.map.circuits {
			for point_circuit in circuit {
				if (point_circuit[0] - app.gg.mouse_pos_x) * (point_circuit[0] - app.gg.mouse_pos_x) + (point_circuit[1] - app.gg.mouse_pos_y) * (point_circuit[1] - app.gg.mouse_pos_y) < distance_min {
					distance_min = (point_circuit[0] - app.gg.mouse_pos_x) * (point_circuit[0] - app.gg.mouse_pos_x) + (point_circuit[1] - app.gg.mouse_pos_y) * (point_circuit[1] - app.gg.mouse_pos_y)
				}
			}
		}
		mut collision := false
		for tours in app.map.tours {
			if gerer_collision_tour([app.gg.mouse_pos_x, app.gg.mouse_pos_y, 10], tours) {
				collision = true
			}
		}
		if distance_min < 60 * 60 || collision || app.map.money < 10{
			app.map.can_place = false
		} else {
			app.map.can_place = true
		}
		
		mut projectile_delete_indexes := []int{}
		for mut projectile in app.map.projectiles {
			projectile.pos[0] += projectile.vecteur_directeur[0]
			projectile.pos[1] += projectile.vecteur_directeur[1]
			projectile.life_span -= 1
			for mut ennemi in app.map.ennemis {
				if gerer_collision_projectile_ennemi(ennemi, projectile) {
					projectile.life_span = 0
					ennemi.pv -= projectile.degats
				}
			}
			if projectile.life_span <= 0 {
				projectile_delete_indexes << app.map.projectiles.index(projectile)
			}
		}
		for projectile_delete_indexes.len > 0 {
			for mut projectile_delete_index in projectile_delete_indexes {
				if projectile_delete_indexes[0] < projectile_delete_index {
					projectile_delete_index -= 1
				}
			}
			app.map.projectiles.delete(projectile_delete_indexes[0])
			projectile_delete_indexes.delete(0)
		}
		if app.map.hero.pv > 0 {
			if app.map.hero.en_deplacement && !(dist(app.map.hero.pos, app.map.hero.cible_deplacement) < 25 || (app.map.hero.fighting && dist(app.map.hero.pos, app.map.hero.cible_deplacement) <= 400)) {
				distance := dist(app.map.hero.cible_deplacement, app.map.hero.pos)
				app.map.hero.pos[0] += ((app.map.hero.cible_deplacement[0] - app.map.hero.pos[0]) / f32(math.sqrt(distance))) * 1
				app.map.hero.pos[1] += ((app.map.hero.cible_deplacement[1] - app.map.hero.pos[1]) / f32(math.sqrt(distance))) * 1
				if dist(app.map.hero.pos, app.map.hero.cible_deplacement) < 25 || (app.map.hero.fighting && dist(app.map.hero.pos, app.map.hero.cible_deplacement) <= 400){
					app.map.hero.en_deplacement = false
				}
			} else {
				app.map.hero.en_deplacement = false
				mut index := 0
				for index < app.map.ennemis.len && !app.map.hero.detect(app.map.ennemis[index]) {
					index += 1
				}
				if index < app.map.ennemis.len && dist(app.map.hero.standby_pos, app.map.ennemis[index].pos_xy) <= app.map.hero.vision * app.map.hero.vision {
					app.map.hero.en_deplacement = true
					app.map.hero.cible_deplacement = app.map.ennemis[index].pos_xy
					app.map.ennemis[index].fighting = true
					app.map.hero.fighting = true
				} else if dist(app.map.hero.standby_pos, app.map.hero.pos) > 25{
					app.map.hero.en_deplacement = true
					app.map.hero.cible_deplacement = app.map.hero.standby_pos
				}
			}
		} else {
			app.map.hero.respawn_cooldown -= 1
			if app.map.hero.respawn_cooldown == 0 {
				app.map.hero.pv = app.map.hero.max_pv
				app.map.hero.respawn_cooldown = app.map.hero.respawn_time
			}
		}
	}
	
	// Draw
	app.gg.begin()
	app.gg.draw_rect_filled(0, 484 - 50, 550, 100, gg.Color{r: 217, g: 186, b: 111})
	app.gg.draw_rect_filled(0, 284 - 50, 550, 100, gg.Color{r: 217, g: 186, b: 111})
	app.gg.draw_rect_filled(450, 284 - 50, 100, 200, gg.Color{r: 217, g: 186, b: 111})
	mut indexes := []int{}
	for mut ennemi in app.map.ennemis {
		app.gg.draw_circle_empty(ennemi.pos_xy[0], ennemi.pos_xy[1], ennemi.radius, gg.Color{r: 255})
		app.gg.draw_circle_filled(ennemi.pos_xy[0], ennemi.pos_xy[1], ennemi.radius*ennemi.pv/ennemi.max_pv, gg.Color{r: 255})		
		if ennemi.pos_relatif < app.map.circuits[ennemi.circuit].len - 1 && ennemi.pv > 0 {
			if !ennemi.fighting {
				ennemi.pos_relatif, ennemi.pos_xy =  ennemi.move(app.map.circuits[ennemi.circuit])
			} else {
				ennemi.hit(mut app.map.hero)
				if app.map.hero.pv <= 0 || !app.map.hero.fighting {
					ennemi.fighting = false
				}
			}
		} else {
			indexes << app.map.ennemis.index(ennemi)
		}
	}
	for indexes.len > 0 {
		for mut index in indexes {
			if indexes[0] < index {
				index -=1
			}
		}
		if app.map.pv > 0 {
			if app.map.ennemis[indexes[0]].pos_relatif == app.map.circuits[app.map.ennemis[indexes[0]].circuit].len - 1 {
				app.map.pv -= app.map.ennemis[indexes[0]].degats
			} else {
				app.map.money += 2
			}
		}
		app.map.ennemis.delete(indexes[0])
		indexes.delete(0)
	}
	if app.map.placing_mode {
		if app.map.can_place {
			app.gg.draw_circle_filled(app.gg.mouse_pos_x, app.gg.mouse_pos_y, 10, gg.Color{r: 103, g: 103, b: 103, a: 150})
			app.gg.draw_circle_filled(app.gg.mouse_pos_x, app.gg.mouse_pos_y, 100, gg.Color{r: 103, g: 103, b: 103, a: 50})
		} else {
			app.gg.draw_circle_filled(app.gg.mouse_pos_x, app.gg.mouse_pos_y, 10, gg.Color{r: 228, g: 103, b: 103, a: 150})
			app.gg.draw_circle_filled(app.gg.mouse_pos_x, app.gg.mouse_pos_y, 100, gg.Color{r: 220, g: 103, b: 103, a: 50})
		}
	}
	for mut tour in app.map.tours {
		if tour.cooldown > 0 {
			tour.cooldown -= 1
		}
		app.gg.draw_circle_filled(tour.pos[0], tour.pos[1], tour.radius, gg.Color{r: 103, g: 103, b: 103})
		app.gg.draw_circle_empty(tour.pos[0], tour.pos[1], tour.range, gg.Color{r: 103, g: 103, b: 103, a: 100})
		for ennemi in app.map.ennemis {
			if tour.detect(ennemi) && tour.cooldown == 0 {
				tour.cooldown = 60
				app.map.projectiles << Projectile{radius: 2, pos: [f32(tour.pos[0]), f32(tour.pos[1])], vitesse: 10, life_span: 120, degats: 1}
				app.map.projectiles[app.map.projectiles.len - 1].vecteur_directeur = app.map.projectiles[app.map.projectiles.len - 1].find_vector(ennemi, app.map.circuits[ennemi.circuit])
			}
		}
	}
	if app.map.hero.pv > 0 {
		app.gg.draw_circle_filled(app.map.hero.pos[0], app.map.hero.pos[1], 10, gg.Color{b: 255})
	}
	for projectile in app.map.projectiles {
		app.gg.draw_circle_filled(projectile.pos[0], projectile.pos[1], projectile.radius, gg.Color{})
	}
	app.gg.show_fps()
	app.gg.draw_text(app.size.width - 150, 10, "money : ${app.map.money}    pv : ${app.map.pv}")
	if app.map.pv <= 0 {
		app.gg.draw_text(app.size.width/2 - 150, app.size.height/2, "YOU LOSE! You survived for ${app.frame_count / 60}seconds !")
	}
	app.gg.end()
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			match e.key_code {
				.p {
					if !app.map.placing_mode {
						app.map.placing_mode = true
					} else {
						app.map.placing_mode = false
					}
				}
				.escape {
					app.gg.quit()
				}
				else {}
			}
		}
		.key_up {
			match e.key_code {
				.enter {
					if app.map.placing_mode && app.map.can_place {
						app.map.tours << Tower{radius: 10, pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y], range: 100}
						app.map.money -= 10
					}
				}
				else {}
			}
		}
		.mouse_up {
			if app.map.placing_mode && app.map.can_place {
				app.map.tours << Tower{radius: 10, pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y], range: 100}
				app.map.money -= 10
			} else if app.map.hero_selected {
				app.map.hero_selected = false
				app.map.hero.en_deplacement = true
				app.map.hero.fighting = false
				app.map.hero.cible_deplacement = [f32(app.gg.mouse_pos_x), f32(app.gg.mouse_pos_y)]
				app.map.hero.standby_pos = [f32(app.gg.mouse_pos_x), f32(app.gg.mouse_pos_y)]
			} else if !app.map.placing_mode && dist([f32(app.gg.mouse_pos_x), f32(app.gg.mouse_pos_y)], app.map.hero.pos) < 100 {
				app.map.hero_selected = true
			} 
		}
		else {}
	}
}

fn (e Ennemi) move (circuit [][]f32) (int, []f32) {
	if  e.pos_relatif + e.vitesse <= circuit.len - 1 {
		return e.pos_relatif + e.vitesse, circuit[e.pos_relatif + e.vitesse].clone()
	} else {
		return circuit.len - 1, circuit[circuit.len - 1].clone()
	}
}

fn (t Tower) detect (ennemi Ennemi) bool {
	mut detection := false
	if dist(ennemi.pos_xy, [f32(t.pos[0]), f32(t.pos[1])]) <= (t.range + ennemi.radius) * (t.range + ennemi.radius) {
		detection = true
	}
	return detection
}

fn (h Hero) detect (ennemi Ennemi) bool {
	mut detection := false
	if dist(ennemi.pos_xy, h.pos) <= (h.vision + ennemi.radius) * (h.vision + ennemi.radius) {
		detection = true
	}
	return detection
}

fn (p Projectile) find_vector (ennemi Ennemi, circuit[][]f32) []f32 {
	norme := dist(circuit[ennemi.pos_relatif], p.pos)
	return [((circuit[ennemi.pos_relatif][0] - p.pos[0]) / f32(math.sqrt(norme))) * p.vitesse, ((circuit[ennemi.pos_relatif][1] - p.pos[1]) / f32(math.sqrt(norme))) * p.vitesse]
}

fn gerer_collision_tour (tour1 []int, tour2 Tower) bool {
	mut collision := false
	if (tour1[0] - tour2.pos[0]) * (tour1[0] - tour2.pos[0]) + (tour1[1] - tour2.pos[1]) * (tour1[1] - tour2.pos[1]) < (tour1[2] + tour2.radius) * (tour1[2] + tour2.radius) {
		collision = true
	}
	return collision
}

fn gerer_collision_projectile_ennemi (ennemi Ennemi, projectile Projectile) bool {
	mut collision := false
	if (ennemi.pos_xy[0] - projectile.pos[0]) * (ennemi.pos_xy[0] - projectile.pos[0]) + (ennemi.pos_xy[1] - projectile.pos[1]) * (ennemi.pos_xy[1] - projectile.pos[1]) < (ennemi.radius + projectile.radius) * (ennemi.radius + projectile.radius) {
		collision = true
	}
	return collision
}

fn min(x int, y int) int {
	if x >= y {
		return y
	} else {
		return x
	}
}

fn circuit_compose (index int) []f32 {
	mut x := f32(0)
	mut y := f32(0)
	if index <= 1000 {
		x = f32(index) / 2
		y = f32(484)
	} else if index <= 1400 {
		x = f32(500)
		y = f32(1000-index) / 2 + 484
	} else {
		x = f32(2400 - index) / 2
		y = f32(284)
	}
	return [x, y]
}

fn dist (pos1 []f32, pos2 []f32) f32 {
	return (pos1[0] - pos2[0]) * (pos1[0] - pos2[0]) + (pos1[1] - pos2[1]) * (pos1[1] - pos2[1])
}

fn (mut e Ennemi) hit (mut target Hero) {
	if dist(e.pos_xy, target.pos) <= 400 && e.hit_cooldown >= 60 {
		target.pv -= 1
		e.hit_cooldown = 0
	} else {
		e.hit_cooldown += 1
	}
}