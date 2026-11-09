#include maps\mp\gametypes\global\_global;

// Call of Duty 2 birthday event (released Oct 25, 2005), enabled by scr_event_birthday (global/cvars.gsc)
// Party hat launcher: weapons/mp/zpam_hat_launcher_mp, a panzerschreck firing party hats (no explosion; a hat bouncing
// off a player takes 1 HP).
// Everything is done by script: a flying hat is deleted right before it hits something (so the engine plays no rocket
// impact). A hat that hits a player bounces off him and flies on, a hat that hits a surface (ground, wall, ceiling) is
// placed there, stuck in the shooter's team color, until the end of ready-up.
// A player gets the launcher by picking it up at the birthday poster (_birthday_poster.gsc), then he has it in every
// ready-up of the map (secondary weapon slot, 20 hats). Once empty or at the end of ready-up it is taken (the secondary
// weapon given back with its ammo), at the end of ready-up the hats are removed. It is never dropped (_weapons.gsc::dropWeapon). Nothing that affects the match.
// Models are generated (by a tool outside the repository)

init()
{
	// Weapon is precached only when the event is enabled at the map start
	if (game["firstInit"])
	{
		game["hat_launcher_precached"] = level.scr_event_birthday;

		if (game["hat_launcher_precached"])
		{
			precacheItem("zpam_hat_launcher_mp");
			precacheModel("xmodel/projectile_zpam_hat");	// the flying hat
		}
	}

	level.hat_launcher_weapon = "zpam_hat_launcher_mp";
	level.hat_launcher_hats = [];		// hats stuck on surfaces
	level.hat_launcher_flying = [];		// flights of the hats in the air (hatLaunch)
	level.hat_launcher_hatsMax = 40;	// oldest placed hat is removed
	level.hat_launcher_speed = 1200;	// projectileSpeed of weapons/mp/zpam_hat_launcher_mp
	level.hat_launcher_speedUp = 60;	// upward speed of the flying hat
	level.hat_launcher_flightTime = 5;	// seconds a flying hat lasts when it hits nothing
	level.hat_launcher_muzzle = 48;	// the flying hat appears this far in front of the eye of the shooter
	level.hat_launcher_spinDelay = 0.15;	// seconds the hat flies tip forward before it spins
	level.hat_launcher_bounce = 0.12;	// speed kept when a hat bounces off a player
	level.hat_launcher_bounceUp = 40;	// upward speed added by a bounce
	level.hat_launcher_bouncesMax = 3;	// a hat bouncing off more players is gone
	level.hat_launcher_damage = 1;		// HP taken from a player a hat bounces off
	// The engine has 1024 entities, one more ends the map ("G_Spawn: no free entities"). A deleted entity is free again
	// only after a second, and the rockets spawned by the engine are not counted: keep a margin
	level.hat_launcher_entitiesMax = 1024 - 160;

	addEventListener("onSpawnedPlayer", ::onSpawnedPlayer);
}

isEnabled()
{
	return level.scr_event_birthday && isDefined(game["hat_launcher_precached"]) && game["hat_launcher_precached"];
}

// Called from _readyup::Start_Readyup_Mode, also when ready-up is started in the middle of the game (timeout)
readyupStarted()
{
	if (!isEnabled())
		return;

	// Players that are already alive (timeout)
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if (players[i] hasHatLauncher())
			players[i] giveHatLauncher(false);
	}

	level thread hatsWatch();

	level waittill("rupover");

	// Map restart takes the weapons and removes the hats, but ready-up in timeout does not restart the map
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] takeHatLauncher();

	deleteAll(level.hat_launcher_hats);
	level.hat_launcher_hats = [];
	for(i = 0; i < level.hat_launcher_flying.size; i++)
	{
		if (isDefined(level.hat_launcher_flying[i].ent))
			level.hat_launcher_flying[i].ent delete();
	}
	level.hat_launcher_flying = [];
}

// The entities of the array that still exist are deleted
deleteAll(ents)
{
	for(i = 0; i < ents.size; i++)
	{
		if (isDefined(ents[i]))
			ents[i] delete();
	}
}

onSpawnedPlayer()
{
	self endon("disconnect");

	// The launcher in the secondary slot right after the spawn (a frame later, after everything else that runs on spawn),
	// the primary weapon stays in the hands
	wait level.frame;
	if (level.in_readyup && isEnabled() && self hasHatLauncher())
		self giveHatLauncher(false);
}

// self is player: he picked up the launcher on this map
hasHatLauncher()
{
	return isDefined(self.pers["hat_launcher"]) && self.pers["hat_launcher"];
}

// self is player: he holds the launcher with hats left; a launcher lying around is picked up only by others (or to refill an empty one)
hasLoadedHatLauncher()
{
	return self getWeaponSlotWeapon("primaryb") == level.hat_launcher_weapon && self getWeaponSlotClipAmmo("primaryb") > 0;
}

// The weapon is the party hat launcher (also called when the event is disabled)
isHatLauncher(weapon)
{
	return isDefined(level.hat_launcher_weapon) && weapon == level.hat_launcher_weapon;
}

// Called from _birthday_poster.gsc when the player picked up the launcher: he has it in every ready-up of the map
earnHatLauncher()
{
	self.pers["hat_launcher"] = true;
	maps\mp\gametypes\_birthday_poster::debug(self.name + " earned the hat launcher");

	if (level.in_readyup && isEnabled())
		self giveHatLauncher(true);
}

// self is player: the launcher replaces the secondary weapon, inHands: switch to it right away (picked up)
giveHatLauncher(inHands)
{
	if (self.sessionstate != "playing")
		return;

	weapon = self getWeaponSlotWeapon("primaryb");
	if (weapon != level.hat_launcher_weapon)
	{
		// Given back with its ammo at the end of ready-up (ready-up in timeout keeps the weapons for the match)
		self.hat_launcher_oldWeapon = weapon;
		self.hat_launcher_oldAmmo = self getWeaponSlotAmmo("primaryb");
		self.hat_launcher_oldClip = self getWeaponSlotClipAmmo("primaryb");
	}

	self setWeaponSlotWeapon("primaryb", level.hat_launcher_weapon);
	// No reloading: all 20 hats are in the clip, no ammo left over. Not a clipOnly weapon: the engine takes an empty clipOnly
	// weapon right in the move of its last shot (PM_SwitchIfEmpty), and the shot is then fired by the next weapon (a bullet)
	self setWeaponSlotAmmo("primaryb", 0);
	self setWeaponSlotClipAmmo("primaryb", 20);
	if (inHands)
		self switchToWeapon(level.hat_launcher_weapon);
	else if (self getcurrentweapon() == weapon || self getcurrentweapon() == level.hat_launcher_weapon)
		self switchToWeapon(self getWeaponSlotWeapon("primary"));	// the replaced secondary was in the hands
	maps\mp\gametypes\_birthday_poster::debug(self.name + " got the hat launcher (secondary weapon was " + weapon + ")");
}

// self is player: the launcher is taken, the secondary weapon given back with its ammo
takeHatLauncher()
{
	if (self getWeaponSlotWeapon("primaryb") != level.hat_launcher_weapon)
		return;

	inHands = self getCurrentWeapon() == level.hat_launcher_weapon;
	self takeWeapon(level.hat_launcher_weapon);
	maps\mp\gametypes\_birthday_poster::debug(self.name + ": hat launcher taken");
	if (isDefined(self.hat_launcher_oldWeapon) && self.hat_launcher_oldWeapon != "none")
	{
		self setWeaponSlotWeapon("primaryb", self.hat_launcher_oldWeapon);
		self setWeaponSlotAmmo("primaryb", self.hat_launcher_oldAmmo);
		self setWeaponSlotClipAmmo("primaryb", self.hat_launcher_oldClip);
	}
	if (inHands)
		self switchToWeapon(self getWeaponSlotWeapon("primary"));
	self.hat_launcher_oldWeapon = undefined;
	self.hat_launcher_oldAmmo = undefined;
	self.hat_launcher_oldClip = undefined;
}

// The launcher fires rockets like the stock panzerschreck (weaponType projectile, cod2rev fire_rocket), so it fires as
// soon as the sight is up (adsFire). A grenade launcher would throw the hat in an arc, but a grenade waits the whole
// holdFireTime before every shot, also when aiming down the sight (client PM_Weapon_StartFiring).
// The rocket is only the trigger: the script deletes it right away (no impact, no explosion) and flies a hat model in
// its place, in an arc (moveGravity: projectileSpeed forward, projectileSpeedUp up) and spinning like a thrown grenade
// (fire_grenade). Its path is traced every frame: the hat bounces off a player and is stuck where it hits a surface.
hatsWatch()
{
	level endon("rupover");

	for(;;)
	{
		wait level.frame;

		// Players who hold the launcher or held it in the last frame (switched away right after a shot)
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			holds = player.sessionstate == "playing" && player getCurrentWeapon() == level.hat_launcher_weapon;
			player.hat_shooter = holds || (isDefined(player.hat_held) && player.hat_held);
			player.hat_held = holds;
		}

		// Follow the flying hats
		flying = [];
		for(i = 0; i < level.hat_launcher_flying.size; i++)
		{
			t = level.hat_launcher_flying[i];
			if (!isDefined(t.ent))
				continue;
			if (hatFly(t))
				continue;	// stuck or flown out
			flying[flying.size] = t;
		}
		level.hat_launcher_flying = flying;

		// New hats: a new rocket fired by a player with the launcher: the player next to it holds the launcher (another
		// player may fire a panzerschreck). The game sets no model on a missile (the client draws the projectile model of
		// the weapon); a missile with another model is not of the launcher.
		rockets = getentarray("rocket", "classname");
		for(i = 0; i < rockets.size; i++)
		{
			g = rockets[i];
			if (isDefined(g.hat_checked))
				continue;
			g.hat_checked = true;
			if (isDefined(g.model) && g.model != "" && !isSubStr(toLower(g.model), "projectile_zpam_hat"))
				continue;

			shooter = undefined;
			best = 128;
			for(j = 0; j < players.size; j++)
			{
				if (players[j].sessionstate != "playing")
					continue;
				d = distance(players[j] maps\mp\gametypes\global\player::getEyeOrigin(), g.origin);
				if (d < best)
				{
					best = d;
					shooter = players[j];
				}
			}
			if (!isDefined(shooter) || !shooter.hat_shooter)
			{
				maps\mp\gametypes\_birthday_poster::debug("rocket at " + g.origin + " is not a hat: the player next to it has no hat launcher");
				continue;
			}

			t = hatLaunch(g, shooter);
			if (isDefined(t))
				level.hat_launcher_flying[level.hat_launcher_flying.size] = t;
		}

		// An empty launcher is taken from the slot (the secondary weapon given back), after its last hat was launched above
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.sessionstate == "playing" && player getWeaponSlotWeapon("primaryb") == level.hat_launcher_weapon &&
				player getWeaponSlotClipAmmo("primaryb") == 0 && player getWeaponSlotAmmo("primaryb") == 0)
			{
				maps\mp\gametypes\_birthday_poster::debug(player.name + ": the hat launcher is empty");
				player takeHatLauncher();
			}
		}
	}
}

// The rocket is replaced by a flying hat model. Returns its flight, undefined when the hat is not flying (stuck right
// away on a surface in front of the launcher, or no entity can be spawned).
hatLaunch(rocket, shooter)
{
	rocket delete();	// launched from the eye of the shooter (Weapon_RocketLauncher_Fire: muzzleTrace)

	dir = anglesToForward(shooter getPlayerAngles());
	eye = shooter maps\mp\gametypes\global\player::getEyeOrigin();
	velocity = maps\mp\_utility::vectorScale(dir, level.hat_launcher_speed) + (0, 0, level.hat_launcher_speedUp);

	t = spawnstruct();
	t.shooter = shooter;
	t.team = shooter.pers["team"];
	t.lastOrigin = eye;
	t.lastMove = maps\mp\_utility::vectorScale(velocity, level.frame);
	t.frames = 0;
	t.ignore = shooter;	// not traced: the shooter, after a bounce the player it bounced off
	t.bounces = 0;

	// The hat appears in front of the launcher's muzzle, not in the camera; something closer is hit right away
	trace = bulletTrace(eye, eye + maps\mp\_utility::vectorScale(dir, level.hat_launcher_muzzle), true, shooter);
	hitsPlayer = trace["fraction"] < 1 && isDefined(trace["entity"]) && isPlayer(trace["entity"]);
	if (trace["fraction"] < 1 && !hitsPlayer)
	{
		maps\mp\gametypes\_birthday_poster::debug("hat of " + shooter.name + " hits right in front of the launcher");
		hatImpact(t, trace, t.lastMove);
		return undefined;
	}
	if (!canSpawnEntities(1))
	{
		maps\mp\gametypes\_birthday_poster::debug("hat of " + shooter.name + " not flying, too many entities");
		return undefined;
	}
	maps\mp\gametypes\_birthday_poster::debug("hat fired by " + shooter.name + " towards " + dir);

	origin = trace["position"];
	hat = spawn("script_model", origin);
	hat setModel("xmodel/projectile_zpam_hat");
	hat notsolid();
	hat.angles = vectorToAngles(dir);	// the tip (+X of the model) forward, as it leaves the launcher
	hat moveGravity(velocity, level.hat_launcher_flightTime);
	hat thread hatSpin();

	t.ent = hat;
	t.lastOrigin = origin;

	// A player right in front of the launcher: it bounces off him at once
	if (hitsPlayer && hatImpact(t, trace, t.lastMove))
		return undefined;
	return t;
}

// self is a flying hat: it starts to spin a moment after it left the launcher, like a thrown grenade (fire_grenade:
// 720 and 360 degrees a second)
hatSpin()
{
	self endon("death");
	wait level.hat_launcher_spinDelay;
	self rotateVelocity((720 + randomfloatrange(-45, 45), 0, 360 + randomfloatrange(-45, 45)), level.hat_launcher_flightTime);
}

// One frame of the flight of a hat: its path from the last position to a bit past the next one is traced (players too,
// not the shooter or the player it just bounced off). The model is not solid and would fly through. Returns true when done.
hatFly(t)
{
	t.frames++;
	origin = t.ent.origin;
	moved = origin - t.lastOrigin;
	// The next move: this one changed as much as since the last one (gravity)
	next = moved + (moved - t.lastMove);

	ignore = undefined;	// the player that is not traced may have disconnected
	if (isDefined(t.ignore))
		ignore = t.ignore;
	trace = bulletTrace(t.lastOrigin, origin + maps\mp\_utility::vectorScale(next, 1.5), true, ignore);
	if (trace["fraction"] < 1)
	{
		maps\mp\gametypes\_birthday_poster::debug("hat hits after " + t.frames + " frames at " + trace["position"]);
		return hatImpact(t, trace, moved);
	}

	// Nothing hit for the whole flight time
	if (t.frames * level.frame >= level.hat_launcher_flightTime)
	{
		maps\mp\gametypes\_birthday_poster::debug("hat hit nothing in " + level.hat_launcher_flightTime + " s, removed");
		t.ent delete();
		return true;
	}

	t.lastMove = moved;
	t.lastOrigin = origin;
	return false;
}

// Impact of a hat: off a player it bounces and flies on, on a surface the flying model is replaced by a hat stuck there.
// Returns true when the flight is over.
hatImpact(t, trace, move)
{
	ent = trace["entity"];
	if (isDefined(ent) && isPlayer(ent))
	{
		if (isDefined(t.ent) && t.bounces < level.hat_launcher_bouncesMax)
		{
			hatBounce(t, ent, trace["position"], move);
			return false;
		}
		maps\mp\gametypes\_birthday_poster::debug("hat hits player " + ent.name + " after " + t.bounces + " bounces, removed");
		if (isDefined(t.ent))
			t.ent delete();
		return true;
	}

	if (isDefined(t.ent))
		t.ent delete();
	maps\mp\gametypes\_birthday_poster::debug("hat stuck on a surface at " + trace["position"] + ", normal " + trace["normal"]);
	hatPlace(trace["position"], trace["normal"], t.team);
	return true;
}

// The flying hat hit the player at the point, moving along the move (its last frame): it bounces off his body (the normal
// points away from his vertical axis), keeping a part of its speed, with a hop up and a new spin
hatBounce(t, player, point, move)
{
	t.bounces++;

	n = point - (player.origin[0], player.origin[1], point[2]);
	if (vectordot(n, n) < 1)
		n = (0 - move[0], 0 - move[1], 0);
	if (vectordot(n, n) < 0.0001)
		n = (0, 0, 1);
	n = vectornormalize(n);

	velocity = maps\mp\_utility::vectorScale(move, 1 / level.frame);
	d = vectordot(velocity, n);
	if (d < 0)
		velocity = velocity - maps\mp\_utility::vectorScale(n, 2 * d);	// reflected
	velocity = maps\mp\_utility::vectorScale(velocity, level.hat_launcher_bounce) + (0, 0, level.hat_launcher_bounceUp);

	maps\mp\gametypes\_birthday_poster::debug("hat bounces off " + player.name + " at " + point + ", velocity " + velocity);
	origin = point + maps\mp\_utility::vectorScale(n, 4);
	t.ent.origin = origin;
	t.ent moveGravity(velocity, level.hat_launcher_flightTime);
	t.ent rotateVelocity((randomfloatrange(-360, 360), randomfloatrange(-180, 180), randomfloatrange(-360, 360)), level.hat_launcher_flightTime);
	player playSound("zpam_hat_pickup");

	// 1 HP, by the damage callback of the game type like any hit (friendly fire, hit marker, log); not when the shooter
	// has left (no attacker)
	if (isDefined(t.shooter) && isPlayer(t.shooter) && player.sessionstate == "playing")
		player thread maps\mp\gametypes\_callbacksetup::CodeCallback_PlayerDamage(t.shooter, t.shooter, level.hat_launcher_damage, 0,
			"MOD_IMPACT", level.hat_launcher_weapon, point, vectornormalize(move), "none", 0);

	t.ignore = player;
	t.lastOrigin = origin;
	t.lastMove = maps\mp\_utility::vectorScale(velocity, level.frame);
	t.frames = 0;
}

// Entities of the event can be spawned: count more entities stay under the limit of the engine
canSpawnEntities(count)
{
	return getentarray().size + count <= level.hat_launcher_entitiesMax;
}

// A party hat stuck on the surface that was hit: its up axis (+Z) along the surface normal
hatPlace(origin, normal, team)
{
	model = "xmodel/zpam_party_hat_allies";
	if (team == "axis")
		model = "xmodel/zpam_party_hat_axis";

	// Oldest hat goes when there are too many
	hats = [];
	for(i = 0; i < level.hat_launcher_hats.size; i++)
	{
		if (isDefined(level.hat_launcher_hats[i]))
			hats[hats.size] = level.hat_launcher_hats[i];
	}
	if (hats.size >= level.hat_launcher_hatsMax)
	{
		maps\mp\gametypes\_birthday_poster::debug(hats.size + " hats on surfaces, the oldest is removed");
		hats[0] delete();
		old = hats;
		hats = [];
		for(i = 1; i < old.size; i++)
			hats[hats.size] = old[i];
	}
	level.hat_launcher_hats = hats;

	// Too many entities in the map: no hat (the flying one is gone anyway)
	if (!canSpawnEntities(1))
	{
		maps\mp\gametypes\_birthday_poster::debug("no hat on the surface, too many entities");
		return;
	}

	// vectortoangles() turns +X to the normal, 90 degrees more pitch turn +Z to it
	angles = vectortoangles(normal);
	hat = spawn("script_model", origin);
	hat setModel(model);
	hat.angles = (angles[0] + 90, angles[1], 0);
	hat playSound("zpam_hat_pickup");

	level.hat_launcher_hats[level.hat_launcher_hats.size] = hat;
}
