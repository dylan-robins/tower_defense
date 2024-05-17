interface Tower {
	radius int
	range  int
	pos    []int
	prix   int
	base_cooldown int
mut:
	bullet Projectile
	cooldown int
}

struct Gattling {
	radius int = 15
	range  int = 75
	pos    []int
	prix   int = 20
	base_cooldown int = 5
mut:
	bullet Projectile = Projectile{
		radius: 2
		vitesse: 10
		life_span: 60
		degats: 1
	}
	cooldown int = 5
}

struct Gun {
	radius int = 10
	range  int = 100
	pos    []int
	prix   int = 10
	base_cooldown int = 60
mut:
	bullet Projectile = Projectile{
		radius: 2
		vitesse: 15
		life_span: 60
		degats: 4
	}
	cooldown int = 15
}

struct Sniper {
	radius int = 20
	range  int = 150
	pos    []int
	prix   int = 20
	base_cooldown int = 300
mut:
	bullet Projectile = Projectile{
		radius: 2
		vitesse: 5
		life_span: 60
		degats: 20
	}
	cooldown int = 300
}

struct Laser {
	radius int = 12
	range  int = 75
	pos    []int
	prix   int = 50
	base_cooldown int = 2
mut:
	bullet Projectile = Projectile{
		radius: 2
		vitesse: 60
		life_span: 60
		degats: 1
	}
	cooldown int = 2
}

fn (t Tower) detect(e Ennemi, app App) bool {
	mut detection := false
	if e.pos_relatif + e.vitesse * t.bullet.vitesse < app.map.circuits[e.circuit][e.lane].len {
		if dist(app.map.circuits[e.circuit][e.lane][e.pos_relatif + e.vitesse * t.bullet.vitesse], [f32(t.pos[0]), f32(t.pos[1])]) <= (t.range + e.radius) * (
			t.range + e.radius) {
			detection = true
		}
	}
	return detection
}