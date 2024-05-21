import rand
import gg
import math

const win_width = 1366
const win_height = 768
const bg_color = gg.Color{
	r: 0
	g: 200
	b: 0
}

struct App {
mut:
	gg          &gg.Context = unsafe { nil }
	frame_count int
	map         Map
	size        gg.Size
	escaped     bool
}

struct Map {
mut:
	circuits       [][][][]f32
	//hero          Hero
	projectiles   []Projectile
	tours         []Tower
	ennemis       []Ennemi
	pv            int
	type_de_tours []Tower = [Gun{}, Gattling{}, Sniper{}, Laser{}]
	tour_a_placer int
	placing_mode   bool
	can_place      bool
	money          int
	hero_selected  bool
	difficulte     int = 0
	vague          int
}

struct Projectile {
	radius  int
	vitesse int
	degats  int
mut:
	pos               []f32
	life_span         int
	vecteur_directeur []f32
}

/*
struct Hero {
	speed        int
	radius_size  int
	max_pv       int
	degats       f32
	vision       int
	portee       int
	respawn_time int
mut:
	hit_cooldown      int = 60
	respawn_cooldown  int
	pos               []f32
	st&&by_pos       []f32
	en_deplacement    bool
	cible_deplacement []f32
	pv                f32
	fighting          bool
	cible_fighting    Ennemi
}*/

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
	if !app.escaped {
		if app.map.pv > 0 {
			app.frame_count += 1
			if app.frame_count % 60 == 0 {
				if app.frame_count < 3600 {
					app.map.vague = 1
					app.map.ennemis << Goblin{
						pos_relatif: 0
						circuit: 0
						lane: rand.int_in_range(0, 3) or {0}
					}
					mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
					new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
				} else if app.frame_count < 7200 {
					app.map.vague = 2
					app.map.ennemis << Orc{
						pos_relatif: 0
						circuit: 0
						lane: rand.int_in_range(0, 3) or {0}
					}
					mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
					new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
				} else if app.frame_count < 10800 {
					app.map.ennemis << Hyena{
						pos_relatif: 0
						circuit: 0
						lane: rand.int_in_range(0, 3) or {0}
					}
					mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
					new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
				} else if app.frame_count < 14400 {
					ennemi_a_spawn := rand.int_in_range(1, 3) or {0}
					if ennemi_a_spawn == 1 {
						app.map.ennemis << Hyena{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					} else {
						app.map.ennemis << Orc{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					}
				} else if app.frame_count < 18000 {
					ennemi_a_spawn := rand.int_in_range(1, 6) or {0}
					if ennemi_a_spawn < 3 {
						app.map.ennemis << Hyena{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					} else if ennemi_a_spawn < 5 {
						app.map.ennemis << Orc{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					} else {
						app.map.ennemis << Giant{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					}
				} else if app.frame_count < 21600 {
					ennemi_a_spawn := rand.int_in_range(1, 11) or {0}
					if ennemi_a_spawn < 4 {
						app.map.ennemis << Hyena{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					} else if ennemi_a_spawn < 8 {
						app.map.ennemis << Orc{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					} else {
						app.map.ennemis << Giant{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					}
				} else if app.frame_count < 25200 {
					ennemi_a_spawn := rand.int_in_range(1, 11) or {0}
					if ennemi_a_spawn < 2 {
						app.map.ennemis << Hyena{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					} else if ennemi_a_spawn < 6 {
						app.map.ennemis << Orc{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					} else {
						app.map.ennemis << Giant{
							pos_relatif: 0
							circuit: 0
							lane: rand.int_in_range(0, 3) or {0}
						}
						mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
						new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
					}
				} else if app.frame_count > 25500 && app.frame_count < 28800 {
					app.map.ennemis << Giant{
						pos_relatif: 0
						circuit: 0
						lane: rand.int_in_range(0, 3) or {0}
					}
					mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
					new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
				} else if app.frame_count > 28800 && !(app.frame_count % 240 == 0) && !(app.frame_count % 180 == 0) && !(app.frame_count % 120 == 0) {
					app.map.ennemis << OrcChieftain{
						pos_relatif: 0
						circuit: 0
						lane: rand.int_in_range(0, 3) or {0}
					}
					mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
					new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
				} else if app.frame_count > 39600 {
					app.map.ennemis << OrcChieftain{
						pos_relatif: 0
						circuit: 0
						lane: rand.int_in_range(0, 3) or {0}
					}
					mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
					new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
				}
			} else if app.frame_count > 50400 {
				app.map.ennemis << OrcChieftain{
					pos_relatif: 0
					circuit: 0
					lane: rand.int_in_range(0, 3) or {0}
				}
				mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
				new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
			}
			
			if app.frame_count == 25200 {
				app.map.ennemis << OrcChieftain{
					pos_relatif: 0
					circuit: 0
					lane: rand.int_in_range(0, 3) or {0}
				}
				mut new_ennemi := app.map.ennemis[app.map.ennemis.len - 1]
				new_ennemi.pos_xy = app.map.circuits[new_ennemi.circuit][new_ennemi.lane][0]
			}
		
			app.map.vague = int(app.frame_count / 3600) + 1

			mut collision := false
			mut distance_min := f32((50 +  app.map.type_de_tours[app.map.tour_a_placer].radius) * (50 +  app.map.type_de_tours[app.map.tour_a_placer].radius))
			for circuit in app.map.circuits {
				for point_circuit in circuit[1] {
					if dist(point_circuit, [f32(app.gg.mouse_pos_x), f32(app.gg.mouse_pos_y)]) < distance_min {
						collision = true
					}
				}
			}
			for tours in app.map.tours {
				if gerer_collision_tour([app.gg.mouse_pos_x, app.gg.mouse_pos_y, app.map.type_de_tours[app.map.tour_a_placer].radius], tours) {
					collision = true
				}
			}
			if collision || app.map.money < app.map.type_de_tours[app.map.tour_a_placer].prix {
				app.map.can_place = false
			} else {
				app.map.can_place = true
			}

			mut projectile_delete_indexes := []int{}
			for mut projectile in app.map.projectiles {
				projectile.pos = [projectile.pos[0] + projectile.vecteur_directeur[0], projectile.pos[1] + projectile.vecteur_directeur[1]].clone()
				projectile.life_span -= 1
				for mut ennemi in app.map.ennemis {
					if gerer_collision_projectile_ennemi(ennemi, projectile) && projectile.life_span != 0 {
						projectile.life_span = 0
						ennemi.pv -= projectile.degats
					}
				}
				if projectile.life_span <= 0 {
					projectile_delete_indexes << app.map.projectiles.index(projectile)
				}
				/*for mut tour in app.map.tours {
					tour.bullet.pos = [f32(tour.pos[0]), f32(tour.pos[1])]
				}*/
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
			/*
			if app.map.hero.pv > 0 {
				if app.map.hero.en_deplacement && !(dist(app.map.hero.pos, app.map.hero.cible_deplacement) < 25) {
					distance := dist(app.map.hero.cible_deplacement, app.map.hero.pos)
					app.map.hero.pos[0] += ((app.map.hero.cible_deplacement[0] - app.map.hero.pos[0]) / f32(math.sqrt(distance))) * app.map.hero.speed
					app.map.hero.pos[1] += ((app.map.hero.cible_deplacement[1] - app.map.hero.pos[1]) / f32(math.sqrt(distance))) * app.map.hero.speed
					if dist(app.map.hero.pos, app.map.hero.cible_deplacement) < 25 {
						app.map.hero.en_deplacement = false
					}
				} else {
					if !app.map.hero.fighting{
						mut distmin := f32(10000)
						for mut ennemi in app.map.ennemis {
							if dist(ennemi.pos_xy, app.map.hero.pos) < distmin {
								distmin = dist(ennemi.pos_xy, app.map.hero.pos)
								app.map.hero.fighting = true
							}
						}
					} else {
						cible := app.map.hero.cible_fighting
						if dist(cible.pos_xy, app.map.hero.pos) > (app.map.hero.radius_size + cible.radius) *(app.map.hero.radius_size + cible.radius) {
							distance := dist(cible.pos_xy, app.map.hero.pos)
							app.map.hero.pos[0] += ((cible.pos_xy[0] - app.map.hero.pos[0]) / f32(math.sqrt(distance))) * app.map.hero.speed
							app.map.hero.pos[1] += ((cible.pos_xy[1] - app.map.hero.pos[1]) / f32(math.sqrt(distance))) * app.map.hero.speed
						} //else if app.map.hero.hit_cooldown == 60
					}
				}
			} else {
				app.map.hero.respawn_cooldown -= 1
				if app.map.hero.respawn_cooldown == 0 {
					app.map.hero.pv = app.map.hero.max_pv
					app.map.hero.respawn_cooldown = app.map.hero.respawn_time
				}
			}*/
		}

		// Draw
		app.gg.begin()
		app.gg.end(how: .clear)
		
		app.gg.begin()
		app.gg.draw_rect_filled(0, 484 - 50, 1000 + 50, 100, gg.Color{ r: 217, g: 186, b: 111 })
		app.gg.draw_rect_filled(0, 284 - 50, 1000 + 50, 100, gg.Color{ r: 217, g: 186, b: 111 })
		app.gg.draw_rect_filled(1000 - 50, 284 - 50, 100, 200, gg.Color{ r: 217, g: 186, b: 111 })
		
		mut indexes := []int{}
		for mut ennemi in app.map.ennemis {
			app.gg.draw_circle_empty(ennemi.pos_xy[0], ennemi.pos_xy[1], ennemi.radius, gg.Color{ r: 255 })
			app.gg.draw_circle_filled(ennemi.pos_xy[0], ennemi.pos_xy[1], ennemi.radius * ennemi.pv / ennemi.max_pv,
				gg.Color{ r: 255 })
			if ennemi.pos_relatif < app.map.circuits[ennemi.circuit][ennemi.lane].len - 1 && ennemi.pv > 0 {
				ennemi.pos_relatif, ennemi.pos_xy = ennemi.move(app.map.circuits[ennemi.circuit][ennemi.lane])
			} else {
				indexes << app.map.ennemis.index(*ennemi)
			}
		}
		for indexes.len > 0 {
			if app.map.pv > 0 {
				if app.map.ennemis[indexes[0]].pos_relatif == app.map.circuits[app.map.ennemis[indexes[0]].circuit][app.map.ennemis[indexes[0]].lane].len - 1 {
					app.map.pv -= app.map.ennemis[indexes[0]].degats
				} else {
					app.map.money += app.map.ennemis[indexes[0]].money
				}
			}
			app.map.ennemis.delete(indexes[0])
			indexes.delete(0)
		}
		app.gg.end(how: .passthru)
		
		app.gg.begin()
		if app.map.placing_mode {
			if app.map.can_place {
				app.gg.draw_circle_filled(app.gg.mouse_pos_x, app.gg.mouse_pos_y, app.map.type_de_tours[app.map.tour_a_placer].radius, gg.Color{
					r: 103
					g: 103
					b: 103
					a: 150
				})
				app.gg.draw_circle_filled(app.gg.mouse_pos_x, app.gg.mouse_pos_y, app.map.type_de_tours[app.map.tour_a_placer].range, gg.Color{
					r: 103
					g: 103
					b: 103
					a: 50
				})
			} else {
				app.gg.draw_circle_filled(app.gg.mouse_pos_x, app.gg.mouse_pos_y, app.map.type_de_tours[app.map.tour_a_placer].radius, gg.Color{
					r: 220
					g: 103
					b: 103
					a: 150
				})
				app.gg.draw_circle_filled(app.gg.mouse_pos_x, app.gg.mouse_pos_y, app.map.type_de_tours[app.map.tour_a_placer].range, gg.Color{
					r: 220
					g: 103
					b: 103
					a: 50
				})
			}
		}
		
		for mut tour in app.map.tours {
			if tour.cooldown > 0 {
				tour.cooldown -= 1
			}
			app.gg.draw_circle_filled(tour.pos[0], tour.pos[1], tour.radius, gg.Color{
				r: 103
				g: 103
				b: 103
			})
			app.gg.draw_circle_empty(tour.pos[0], tour.pos[1], tour.range, gg.Color{
				r: 103
				g: 103
				b: 103
				a: 100
			})
			mut ls_dist := []Ennemi{}
			for ennemi in app.map.ennemis {
				if tour.detect(ennemi, app) && tour.cooldown == 0 {
					ls_dist << ennemi
				}
			}
			if ls_dist.len > 0 {
				app.map.projectiles << tour.bullet
				ennemi_to_shoot := closest_ennemi(ls_dist, app)
				app.map.projectiles[app.map.projectiles.len - 1].vecteur_directeur = app.map.projectiles[app.map.projectiles.len - 1].find_vector(ennemi_to_shoot,
					app.map.circuits[ennemi_to_shoot.circuit][ennemi_to_shoot.lane])
				tour.cooldown = tour.base_cooldown
			}
		}
		
		/*
		if app.map.hero.pv > 0 {
			app.gg.draw_circle_filled(app.map.hero.pos[0], app.map.hero.pos[1], app.map.hero.radius_size, gg.Color{ b: 255 })
		}*/
		for projectile in app.map.projectiles {
			app.gg.draw_circle_filled(projectile.pos[0], projectile.pos[1], projectile.radius,
				gg.Color{})
		}
		
		app.gg.show_fps()
		app.gg.draw_text(app.size.width - 150, 10, 'money : ${app.map.money}    pv : ${app.map.pv}')
		app.gg.draw_text(30, 10, 'vague : ${app.map.vague}')
		if app.map.pv <= 0 {
			app.gg.draw_text(app.size.width / 2 - 150, app.size.height / 2, 'YOU LOSE! You survived for ${app.frame_count / 60}seconds !')
		}
		app.gg.end(how: .passthru)
	} else {
		app.gg.begin()
		app.gg.draw_rect_filled(0, 0, app.size.width, app.size.height, gg.Color{ r: 53, g: 53, b: 53})
		app.gg.draw_rect_filled(app.size.width / 2 - 250, app.size.height / 2 - 75, 500, 150, gg.Color{ r: 155, g: 123, b: 91})
		app.gg.draw_rect_filled(app.size.width / 2 - 225, app.size.height / 2 - 50, 125, 100, gg.Color{ r: 120, g: 88, b: 56})
		app.gg.draw_rect_filled(app.size.width / 2 + 100, app.size.height / 2 - 50, 125, 100, gg.Color{ r: 120, g: 88, b: 56})
		app.gg.draw_text(app.size.width / 2 - 200, app.size.height / 2 - 10, ' Continue ?                                                                    Quit ?')
		app.gg.end(how: .clear)
	}
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			match e.key_code {
				.b {
					app.map.placing_mode = !app.map.placing_mode
				}
				.n {
					app.map.tour_a_placer = (app.map.tour_a_placer + 1) % app.map.type_de_tours.len
				}
				.v {
					app.map.tour_a_placer = (app.map.tour_a_placer - 1)
					if app.map.tour_a_placer < 0 {
						app.map.tour_a_placer = app.map.type_de_tours.len - 1
					}
				}
				.escape {
					app.escaped = !app.escaped
				}
				else {}
			}
		}
		.key_up {
			match e.key_code {
				.enter {
					if app.map.placing_mode && app.map.can_place && app.map.pv > 0 {
						if app.map.type_de_tours[app.map.tour_a_placer].type_name() == 'Gun' {
							app.map.tours << Gun{
								pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y]
							}
							app.map.tours[app.map.tours.len - 1].bullet.pos = [f32(app.map.tours[app.map.tours.len - 1].pos[0]), f32(app.map.tours[app.map.tours.len - 1].pos[1])]
							app.map.money -= app.map.tours[app.map.tours.len - 1].prix
						} else if app.map.type_de_tours[app.map.tour_a_placer].type_name() == 'Gattling' {
							app.map.tours << Gattling{
								pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y]
							}
							app.map.tours[app.map.tours.len - 1].bullet.pos = [f32(app.map.tours[app.map.tours.len - 1].pos[0]), f32(app.map.tours[app.map.tours.len - 1].pos[1])]
							app.map.money -= app.map.tours[app.map.tours.len - 1].prix
						} else if app.map.type_de_tours[app.map.tour_a_placer].type_name() == 'Sniper' {
							app.map.tours << Sniper{
								pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y]
							}
							app.map.tours[app.map.tours.len - 1].bullet.pos = [f32(app.map.tours[app.map.tours.len - 1].pos[0]), f32(app.map.tours[app.map.tours.len - 1].pos[1])]
							app.map.money -= app.map.tours[app.map.tours.len - 1].prix
						} else if app.map.type_de_tours[app.map.tour_a_placer].type_name() == 'Laser' {
							app.map.tours << Laser{
								pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y]
							}
							app.map.tours[app.map.tours.len - 1].bullet.pos = [f32(app.map.tours[app.map.tours.len - 1].pos[0]), f32(app.map.tours[app.map.tours.len - 1].pos[1])]
							app.map.money -= app.map.tours[app.map.tours.len - 1].prix
						}
					}
				}
				else {}
			}
		}
		.mouse_up {
			if app.escaped {
				if app.gg.mouse_pos_y >= app.size.height / 2 - 50 && app.gg.mouse_pos_y <= app.size.height / 2 + 50 {
					if app.gg.mouse_pos_x >= app.size.width / 2 - 225 && app.gg.mouse_pos_x <= app.size.width / 2 - 100 {
						app.escaped = false
					} else if app.gg.mouse_pos_x >= app.size.width / 2 + 100 && app.gg.mouse_pos_x <= app.size.width / 2 + 225 {
						app.gg.quit()
					}
				}
			} else if app.map.placing_mode && app.map.can_place && app.map.pv > 0 {
				if app.map.type_de_tours[app.map.tour_a_placer].type_name() == 'Gun' {
					app.map.tours << Gun{
						pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y]
					}
					app.map.tours[app.map.tours.len - 1].bullet.pos = [f32(app.map.tours[app.map.tours.len - 1].pos[0]), f32(app.map.tours[app.map.tours.len - 1].pos[1])]
					app.map.money -= app.map.tours[app.map.tours.len - 1].prix
				} else if app.map.type_de_tours[app.map.tour_a_placer].type_name() == 'Gattling' {
					app.map.tours << Gattling{
						pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y]
					}
					app.map.tours[app.map.tours.len - 1].bullet.pos = [f32(app.map.tours[app.map.tours.len - 1].pos[0]), f32(app.map.tours[app.map.tours.len - 1].pos[1])]
					app.map.money -= app.map.tours[app.map.tours.len - 1].prix
				} else if app.map.type_de_tours[app.map.tour_a_placer].type_name() == 'Sniper' {
					app.map.tours << Sniper{
						pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y]
					}
					app.map.tours[app.map.tours.len - 1].bullet.pos = [f32(app.map.tours[app.map.tours.len - 1].pos[0]), f32(app.map.tours[app.map.tours.len - 1].pos[1])]
					app.map.money -= app.map.tours[app.map.tours.len - 1].prix
				} else if app.map.type_de_tours[app.map.tour_a_placer].type_name() == 'Laser' {
					app.map.tours << Laser{
						pos: [app.gg.mouse_pos_x, app.gg.mouse_pos_y]
					}
					app.map.tours[app.map.tours.len - 1].bullet.pos = [f32(app.map.tours[app.map.tours.len - 1].pos[0]), f32(app.map.tours[app.map.tours.len - 1].pos[1])]
					app.map.money -= app.map.tours[app.map.tours.len - 1].prix
				}
			}
			/* else if app.map.hero_selected {
				app.map.hero_selected = false
				app.map.hero.en_deplacement = true
				app.map.hero.fighting = false
				app.map.hero.cible_deplacement = [f32(app.gg.mouse_pos_x), f32(app.gg.mouse_pos_y)]
				app.map.hero.st&&by_pos = [f32(app.gg.mouse_pos_x), f32(app.gg.mouse_pos_y)]
			} else if !app.map.placing_mode && dist([f32(app.gg.mouse_pos_x), f32(app.gg.mouse_pos_y)], app.map.hero.pos) < 100 {
				app.map.hero_selected = true
			}*/
		}
		else {}
	}
}

fn (e Ennemi) move(circuit [][]f32) (int, []f32) {
	if e.pos_relatif + e.vitesse <= circuit.len - 1 {
		return e.pos_relatif + e.vitesse, circuit[e.pos_relatif + e.vitesse].clone()
	} else {
		return circuit.len - 1, circuit[circuit.len - 1].clone()
	}
}

/*
fn (h Hero) detect(ennemi Ennemi) bool {
	mut detection := false
	if dist(ennemi.pos_xy, h.pos) <= (h.vision + ennemi.radius) * (h.vision + ennemi.radius) {
		detection = true
	}
	return detection
}*/

fn (p Projectile) find_vector(ennemi Ennemi, circuit [][]f32) []f32 {
	target := circuit[ennemi.pos_relatif + ennemi.vitesse * p.vitesse]
	norme := f32(math.sqrt(dist(target, p.pos)))
	
	return [
		((target[0] - p.pos[0]) / norme) * (norme / p.vitesse),
		((target[1] - p.pos[1]) / norme) * (norme / p.vitesse),
	]
}

fn gerer_collision_tour(tour1 []int, tour2 Tower) bool {
	mut collision := false
	if dist([f32(tour1[0]), f32(tour1[1])], [f32(tour2.pos[0]), f32(tour2.pos[1])]) < (tour1[2] + tour2.radius) * (tour1[2] + tour2.radius) {
		collision = true
	}
	return collision
}

fn gerer_collision_projectile_ennemi(ennemi Ennemi, projectile Projectile) bool {
	mut collision := false
	if dist(ennemi.pos_xy, projectile.pos) < (ennemi.radius + projectile.radius) * (ennemi.radius + projectile.radius) {
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

fn circuit_compose1lane1(index int) []f32 {
	mut x := f32(0)
	mut y := f32(0)
	if index <= 9750 {
		x = f32(index) / 10
		y = f32(459)
	} else if index <= 11250 {
		x = f32(975)
		y = f32(9750 - index) / 10 + 459
	} else {
		x = f32(21000 - index) / 10
		y = f32(309)
	}
	return [x, y]
}

fn circuit_compose1lane2(index int) []f32 {
	mut x := f32(0)
	mut y := f32(0)
	if index <= 10000 {
		x = f32(index) / 10
		y = f32(484)
	} else if index <= 12000 {
		x = f32(1000)
		y = f32(10000 - index) / 10 + 484
	} else {
		x = f32(22000 - index) / 10
		y = f32(284)
	}
	return [x, y]
}

fn circuit_compose1lane3(index int) []f32 {
	mut x := f32(0)
	mut y := f32(0)
	if index <= 10250 {
		x = f32(index) / 10
		y = f32(509)
	} else if index <= 12750 {
		x = f32(1025)
		y = f32(10250 - index) / 10 + 509
	} else {
		x = f32(23000 - index) / 10
		y = f32(259)
	}
	return [x, y]
}

fn dist(pos1 []f32, pos2 []f32) f32 {
	return (pos1[0] - pos2[0]) * (pos1[0] - pos2[0]) + (pos1[1] - pos2[1]) * (pos1[1] - pos2[1])
}

fn closest_ennemi(l []Ennemi, app App) Ennemi {
	mut index := 0
	mut min := app.map.circuits[l[0].circuit][l[0].lane].len - l[0].pos_relatif
	for i in 1..l.len {
		if min > app.map.circuits[l[i].circuit][l[i].lane].len - l[i].pos_relatif {
			min = app.map.circuits[l[i].circuit][l[i].lane].len - l[i].pos_relatif
			index = i
		}
	}
	return l[index]
}

/*
fn (mut e Ennemi) hit(mut target Hero) {
	if dist(e.pos_xy, target.pos) <= 400 && e.hit_cooldown >= 60 {
		target.pv -= 1
		e.hit_cooldown = 0
	} else {
		e.hit_cooldown += 1
	}
}*/