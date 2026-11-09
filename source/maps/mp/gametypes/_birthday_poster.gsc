#include maps\mp\gametypes\global\_global;

// Call of Duty 2 birthday event (released Oct 25, 2005), enabled by scr_event_birthday (global/cvars.gsc)
// Birthday poster: the aim trainer poster in both spawns of the zPAM maps (a brush on the ground, targetname
// trainer_activator, with a damage trigger over it, targetname trainer_activator_damage) is hidden during ready-up.
// First a birthday cake with 21 candles stands on it (_birthday_cake.gsc), then, once the cake has exploded, the
// birthday poster (xmodel/zpam_bday_poster, one flat model with the "21 YEARS" image for all maps, placed where the aim
// trainer image was) with the anniversary emblem floating over it. A hit of the cake or the poster (any weapon, one counted in
// level.birthday_poster_hitDelay) shows its number flying up, 1 .. 21, on the cake it lights the next candle.
// The 21st hit explodes the cake or bursts the poster, celebrated for about 5 seconds, and throws out:
// - the first time on the map: 5 party hats (10 of both posters for 10 players), a player without the party hat picks
//   one up by walking over it (_party_hat.gsc)
// - every later time: a party hat launcher when there is none of the poster lying around, anybody without a loaded
//   launcher picks it up (_hat_launcher.gsc)
// Both posters (one in each spawn) work on their own. The hits are counted for the whole map. Nothing that affects the
// match.
// Engine limits: effects (64, the event loads 31), entities (1024, see _hat_launcher::canSpawnEntities), models
// attached to a player (6, see _party_hat::attachPartyHat).
// The models and effects are generated (by a tool outside the repository, from the maps in zpam_maps_v7.iwd)

init()
{
	// Models and effects are precached only when the event is enabled at the map start
	if (game["firstInit"])
	{
		game["birthday_poster_precached"] = level.scr_event_birthday;

		if (game["birthday_poster_precached"])
		{
			if (getPosters().size)
			{
				precacheModel("xmodel/zpam_bday_poster");
				precacheModel("xmodel/weapon_zpam_hat_launcher");
				for(n = 1; n <= 21; n++)
					game["birthday_poster_fx_" + n] = loadfx("fx/zpam/bday_num_" + n + ".efx");
				game["birthday_poster_fx_burst"] = loadfx("fx/zpam/bday_burst.efx");	// with the anniversary emblem popping up
				game["birthday_poster_fx_emblem"] = loadfx("fx/zpam/bday_emblem.efx");	// the emblem staying over the poster
				game["birthday_poster_fx_burst_confetti"] = loadfx("fx/zpam/bday_burst_confetti.efx");
				game["birthday_poster_fx_firework"] = loadfx("fx/zpam/bday_firework.efx");
				game["birthday_poster_fx_fountain"] = loadfx("fx/zpam/bday_fountain.efx");
				game["birthday_poster_fx_finale"] = loadfx("fx/zpam/bday_finale.efx");
				game["birthday_poster_fx_explosion"] = loadfx("fx/explosions/grenadeExp_dirt.efx");
				maps\mp\gametypes\_birthday_cake::precache();
			}
		}
	}

	level.birthday_poster_hitsGoal = 21;	// hits to burst the poster
	level.birthday_poster_hitDelay = 400;	// ms: one hit of a poster is counted in this time (a Thompson is not too fast)
	level.birthday_poster_hats = 5;	// party hats of the first burst of each poster (10 for 10 players)
	level.birthday_poster_fireworks = 8;	// fireworks of the celebration (about 5 s in all)
	level.birthday_poster_dropsMax = 12;	// hats and the launcher lying around, the oldest goes
	level.birthday_poster_drops = [];
	level.birthday_poster_active = false;
}

isEnabled()
{
	return level.scr_event_birthday && isDefined(game["birthday_poster_precached"]) && game["birthday_poster_precached"];
}

// Debug log of the birthday event (poster, cake, party hats, hat launcher), enabled by the cvar debug_birthday
// (global/developer.gsc): printed to all players and to the server console
debug(text)
{
	if (!isDefined(level.debug_birthday) || !level.debug_birthday)
		return;
	iprintln("^5BDAY ^7" + text);
	println("BDAY " + text);
}

// The birthday poster replaces the aim trainer poster in this ready-up (_aim_trainer.gsc shows no hint on its hits)
isActive()
{
	return isDefined(level.birthday_poster_active) && level.birthday_poster_active;
}

// Called from _readyup::Start_Readyup_Mode, also when ready-up is started in the middle of the game (timeout)
readyupStarted()
{
	if (!isEnabled())
		return;

	posters = getPosters();
	if (!posters.size)
	{
		debug("no birthday poster on " + getcvar("mapname"));
		return;
	}

	// Aim trainer brushes and their damage triggers (deleted by _aim_trainer.gsc when the map starts out of ready-up)
	brushes = getentarray("trainer_activator", "targetname");
	triggers = getentarray("trainer_activator_damage", "targetname");
	if (!brushes.size || !triggers.size)
	{
		debug("no aim trainer poster in the map: " + brushes.size + " brushes, " + triggers.size + " damage triggers");
		return;
	}
	debug("ready-up: " + posters.size + " posters, " + triggers.size + " damage triggers");

	level.birthday_poster_active = true;

	for(i = 0; i < brushes.size; i++)
		brushes[i] hide();

	for(i = 0; i < posters.size; i++)
	{
		poster = posters[i];

		// The birthday cake on the poster until it has exploded (a candle lit for each hit counted so far), then the
		// birthday poster with the emblem
		if (!maps\mp\gametypes\_birthday_cake::isDone(poster))
		{
			hits = 0;
			if (isDefined(game["birthday_poster_hits_" + poster.index]))
				hits = game["birthday_poster_hits_" + poster.index];
			maps\mp\gametypes\_birthday_cake::spawnCake(poster, hits);
			debug("poster " + poster.index + ": cake, " + hits + " hits so far");
		}
		else
		{
			showPoster(poster);
			startEmblem(poster);
			debug("poster " + poster.index + ": poster with the emblem (the cake exploded already)");
		}
	}
	// The game gives a trigger no model name (only the brush model) and no origin: a hit is of the poster aimed at
	for(i = 0; i < triggers.size; i++)
		level thread posterThink(posters, triggers[i]);
	level thread maps\mp\gametypes\_birthday_cake::shotsThink(posters);

	level waittill("rupover");

	// Map restart removes everything, but ready-up in timeout does not restart the map
	level.birthday_poster_active = false;
	for(i = 0; i < brushes.size; i++)
	{
		if (isDefined(brushes[i]))
			brushes[i] show();
	}
	for(i = 0; i < posters.size; i++)
	{
		if (isDefined(posters[i].ent))
			posters[i].ent delete();
		if (isDefined(posters[i].emblem))
			posters[i].emblem delete();
		maps\mp\gametypes\_birthday_cake::removeCake(posters[i]);
	}
	for(i = 0; i < level.birthday_poster_drops.size; i++)
	{
		if (isDefined(level.birthday_poster_drops[i]))
			level.birthday_poster_drops[i] delete();
	}
	level.birthday_poster_drops = [];
}

posterThink(posters, trigger)
{
	level endon("rupover");

	for(;;)
	{
		trigger waittill("damage", damage, attacker);

		if (!isDefined(attacker) || !isPlayer(attacker))
			continue;

		poster = getAimedPoster(posters, attacker);
		if (isDefined(poster))
			countHit(poster);
		else
			debug("trigger hit by " + attacker.name + ", no poster in his line of fire");
	}
}

// The poster nearest to the line of fire of the player (a hit of a damage trigger, all of them are over a poster)
getAimedPoster(posters, player)
{
	eye = player maps\mp\gametypes\global\player::getEyeOrigin();
	forward = anglesToForward(player getPlayerAngles());

	aimed = undefined;
	best = 0;
	for(i = 0; i < posters.size; i++)
	{
		t = vectorDot(posters[i].origin - eye, forward);
		if (t <= 0)
			continue;
		dist = distance(eye + maps\mp\_utility::vectorScale(forward, t), posters[i].origin);
		if (dist > posters[i].radius + 64)
			continue;
		if (!isDefined(aimed) || dist < best)
		{
			aimed = posters[i];
			best = dist;
		}
	}
	return aimed;
}

// A hit of the poster or its cake (also from _birthday_cake.gsc)
countHit(poster)
{
	// Not while it celebrates the 21st hit
	if (poster.celebrating)
	{
		debug("poster " + poster.index + ": hit not counted, it celebrates");
		return;
	}

	// One hit in a while (fast weapons, pellets of a shotgun, an explosion, a shot seen at the cake and its trigger)
	if (isDefined(poster.hitTime) && gettime() - poster.hitTime < level.birthday_poster_hitDelay)
	{
		debug("poster " + poster.index + ": hit not counted, " + (gettime() - poster.hitTime) + " ms after the last one");
		return;
	}
	poster.hitTime = gettime();

	posterHit(poster);
}

// The anniversary emblem over the poster for good, after the cake exploded: the looped effect (a 4 s particle of
// fx/zpam/bday_emblem.efx, repeated every 3.9 s), removed at the end of ready-up
startEmblem(poster)
{
	if (isDefined(poster.emblem))
		return;
	if (!maps\mp\gametypes\_hat_launcher::canSpawnEntities(1))
	{
		debug("poster " + poster.index + ": no emblem, too many entities");
		return;
	}
	poster.emblem = playLoopedFx(game["birthday_poster_fx_emblem"], 3.9, poster.origin, 0, (0, 0, 1), (1, 0, 0));
}

// The emblem popping up in the explosion of the cake (1.6 s) is taken over by the one staying there: started well before
// the end, the clients see the new entity a snapshot or two later (no gap between the two)
emblemAfterBurst(poster)
{
	level endon("rupover");

	wait level.fps_multiplier * 0.9;
	startEmblem(poster);
}

// The birthday poster is shown (in place of the cake)
showPoster(poster)
{
	if (isDefined(poster.ent))
		return;
	if (!maps\mp\gametypes\_hat_launcher::canSpawnEntities(1))
	{
		debug("poster " + poster.index + ": not shown, too many entities");
		return;
	}
	poster.ent = spawn("script_model", poster.origin);
	poster.ent setModel("xmodel/zpam_bday_poster");
	poster.ent.angles = poster.angles;
	poster.ent notsolid();	// a script model stops bullets (CONTENTS_CLIPSHOT): shots fly through into the damage trigger
}

// Sound from the cake or the poster
posterSound(poster, alias)
{
	if (isDefined(poster.cake))
		poster.cake playSound(alias);
	else if (isDefined(poster.ent))
		poster.ent playSound(alias);
}

posterHit(poster)
{
	key = "birthday_poster_hits_" + poster.index;
	if (!isDefined(game[key]))
		game[key] = 0;
	game[key]++;
	hits = game[key];
	debug("poster " + poster.index + ": hit " + hits + "/" + level.birthday_poster_hitsGoal);

	// The number flies up from the poster, or from the top of the cake
	origin = poster.origin;
	if (isDefined(poster.cake))
		origin = poster.cake.origin + (0, 0, 22);
	playfx(game["birthday_poster_fx_" + hits], origin);
	maps\mp\gametypes\_birthday_cake::lightCandle(poster, true);
	// A match lights the candle
	posterSound(poster, "zpam_bday_candle");

	if (hits >= level.birthday_poster_hitsGoal)
	{
		game[key] = 0;
		level thread posterBurst(poster);
	}
}

// The later bangs of the explosion sound (zpam_bday_explosion: bangs at 0, 0.48, 0.66 and 0.84 s), a firework each
explosionFireworks(origin)
{
	level endon("rupover");

	bangs = [];
	bangs[0] = 0.48;
	bangs[1] = 0.66;
	bangs[2] = 0.84;
	last = 0;
	for(i = 0; i < bangs.size; i++)
	{
		wait level.fps_multiplier * (bangs[i] - last);
		last = bangs[i];
		playfx(game["birthday_poster_fx_firework"], origin + (randomfloatrange(-70, 70), randomfloatrange(-70, 70), randomfloatrange(90, 160)));
	}
}

// The crowd cheers, a moment after the bang of the cake explosion
cheer(poster)
{
	level endon("rupover");

	wait level.fps_multiplier * 0.3;
	posterSound(poster, "zpam_bday_cheer");
}

// 21st hit. The cake explodes: the celebration of 21 years of Call of Duty 2 (about 5 seconds), an explosion and a
// fountain of confetti with the anniversary emblem popping up high over the poster (it stays there),
// fireworks around it with more fountains, and a finale. A later burst of the poster: just the explosion with a short burst of confetti.
// The first burst of the poster on the map throws out its party hats, every later one the party hat launcher, when its
// last one does not lie around.
posterBurst(poster)
{
	level endon("rupover");

	poster.celebrating = true;
	origin = poster.origin;

	cakeExplodes = isDefined(poster.cake);
	if (cakeExplodes)
	{
		debug("poster " + poster.index + ": the cake explodes, the poster appears");
		maps\mp\gametypes\_birthday_cake::setDone(poster);
		maps\mp\gametypes\_birthday_cake::removeCake(poster);
	}
	showPoster(poster);

	playfx(game["birthday_poster_fx_explosion"], origin);
	if (cakeExplodes)
		playfx(game["birthday_poster_fx_burst"], origin);
	else
		playfx(game["birthday_poster_fx_burst_confetti"], origin);
	posterSound(poster, "zpam_bday_explosion");
	level thread explosionFireworks(origin);
	if (cakeExplodes)
	{
		level thread emblemAfterBurst(poster);
		level thread cheer(poster);
	}

	// Each poster on its own: its hats, then its launcher
	if (!isDefined(game["birthday_poster_hatsDropped_" + poster.index]))
	{
		game["birthday_poster_hatsDropped_" + poster.index] = true;
		debug("poster " + poster.index + ": burst, " + level.birthday_poster_hats + " party hats thrown out");
		for(i = 0; i < level.birthday_poster_hats; i++)
		{
			model = "xmodel/zpam_party_hat_allies";
			if (i % 2)
				model = "xmodel/zpam_party_hat_axis";
			angle = i * 360 / level.birthday_poster_hats + randomfloatrange(-12, 12);
			level thread dropThink(poster, model, "hat", angle, randomfloatrange(24, 80));
		}
	}
	else if (!isDefined(poster.launcher))
	{
		debug("poster " + poster.index + ": burst, the hat launcher thrown out");
		level thread dropThink(poster, "xmodel/weapon_zpam_hat_launcher", "launcher", randomfloat(360), 40);
	}
	else
		debug("poster " + poster.index + ": burst, nothing thrown out (a hat launcher lies around)");

	// A later burst of the poster: just the explosion with a short burst of confetti
	if (!cakeExplodes)
	{
		wait level.fps_multiplier * 1.5;
		poster.celebrating = false;
		debug("poster " + poster.index + ": burst over, hits are counted again");
		return;
	}

	// Fireworks over the poster, and a fountain of confetti every fourth one
	for(i = 0; i < level.birthday_poster_fireworks; i++)
	{
		wait level.fps_multiplier * 0.35;
		playfx(game["birthday_poster_fx_firework"], origin + (randomfloatrange(-90, 90), randomfloatrange(-90, 90), randomfloatrange(110, 190)));
		posterSound(poster, "zpam_bday_firework");
		if (i % 4 == 3)
		{
			playfx(game["birthday_poster_fx_fountain"], origin);
			posterSound(poster, "zpam_bday_confetti");
		}
	}

	// Finale
	wait level.fps_multiplier * 0.3;
	playfx(game["birthday_poster_fx_finale"], origin);
	posterSound(poster, "zpam_bday_explosion");
	posterSound(poster, "zpam_bday_confetti");
	level thread explosionFireworks(origin);

	wait level.fps_multiplier * 1.5;
	poster.celebrating = false;
	debug("poster " + poster.index + ": celebration over, hits are counted again");
}

// A party hat or the launcher thrown out of the poster in an arc to the ground at the angle (degrees) and distance from
// its edge. It lies there, slowly spinning, until a player who has none walks over it.
dropThink(poster, model, what, angle, dist)
{
	level endon("rupover");

	from = poster.origin + (0, 0, 8);

	// Landing spot: towards the angle, not through walls, on the ground
	dir = anglesToForward((0, angle, 0));
	start = poster.origin + (0, 0, 24);
	trace = bulletTrace(start, start + maps\mp\_utility::vectorScale(dir, poster.radius + dist), false, undefined);
	target = trace["position"] - maps\mp\_utility::vectorScale(dir, 12 * (1 - trace["fraction"]));
	trace = bulletTrace(target, target - (0, 0, 256), false, undefined);
	if (trace["fraction"] < 1)
		target = trace["position"];
	else
		target = poster.origin;
	if (what == "launcher")
		target = target + (0, 0, 10);	// floats above the ground

	if (!maps\mp\gametypes\_hat_launcher::canSpawnEntities(1))
	{
		debug("no " + what + " thrown out, too many entities");
		return;
	}
	drop = spawn("script_model", from);
	drop setModel(model);
	addDrop(drop);
	if (what == "launcher")
		poster.launcher = drop;	// one at a time at the poster (undefined again once it is picked up or removed)

	// Flight in the time, moved by script (a parabola, spinning)
	time = randomfloatrange(0.8, 1.1);
	gravity = getcvarfloat("g_gravity");
	velocity = maps\mp\_utility::vectorScale(target - from, 1 / time) + (0, 0, 0.5 * gravity * time);
	yaw = angle;
	for(t = level.frame; t < time; t += level.frame)
	{
		wait level.frame;
		if (!isDefined(drop))
			return;
		drop.origin = from + maps\mp\_utility::vectorScale(velocity, t) - (0, 0, 0.5 * gravity * t * t);
		yaw += 25;
		drop.angles = (0, yaw, 0);
	}
	drop.origin = target;

	for(;;)
	{
		wait level.frame;
		if (!isDefined(drop))
			return;	// the oldest drop was removed

		yaw += 6;
		drop.angles = (0, yaw, 0);

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.sessionstate != "playing")
				continue;
			if (what == "hat" && player maps\mp\gametypes\_party_hat::hasPartyHat())
				continue;
			if (what == "launcher" && player maps\mp\gametypes\_hat_launcher::hasLoadedHatLauncher())
				continue;

			dist = distance((player.origin[0], player.origin[1], 0), (target[0], target[1], 0));
			dz = player.origin[2] - target[2];
			if (dist > 32 || dz * dz > 48 * 48)
				continue;

			debug(player.name + " picked up the " + what);
			if (what == "hat")
			{
				player maps\mp\gametypes\_party_hat::earnPartyHat();
				player playSound("zpam_hat_pickup");
			}
			else
			{
				player maps\mp\gametypes\_hat_launcher::earnHatLauncher();
				player playLocalSound("weap_pickup");
			}
			drop delete();
			return;
		}
	}
}

// Too many hats and launchers lying around: the oldest goes
addDrop(drop)
{
	drops = [];
	for(i = 0; i < level.birthday_poster_drops.size; i++)
	{
		if (isDefined(level.birthday_poster_drops[i]))
			drops[drops.size] = level.birthday_poster_drops[i];
	}
	if (drops.size >= level.birthday_poster_dropsMax)
	{
		debug("too many hats and launchers lying around, the oldest is removed");
		drops[0] delete();
		old = drops;
		drops = [];
		for(i = 1; i < old.size; i++)
			drops[drops.size] = old[i];
	}
	drops[drops.size] = drop;
	level.birthday_poster_drops = drops;
}

addPoster(posters, origin, radius, angles)
{
	poster = spawnstruct();
	poster.index = posters.size;
	poster.origin = origin;
	poster.radius = radius;
	poster.angles = angles;	// of the birthday poster model: its slope and the direction of the aim trainer image
	poster.celebrating = false;
	posters[posters.size] = poster;
	return posters;
}

// Posters of this map: center of the emblem of the aim trainer poster (a bit above it), its radius and the angles of
// the birthday poster model lying there
getPosters()
{
	mapname = toLower(getcvar("mapname"));
	posters = [];
	// <generated>
	// 10 zPAM maps with the aim trainer poster (zpam_maps_v7.iwd)
	if (mapname == "mp_burgundy_fix")
	{
		posters = addPoster(posters, (503.42, -354.65, 10), 47, (-0.62, 46.72, -0));
		posters = addPoster(posters, (-177.51, 2757.98, 3), 55, (-0, 180, 0));
	}
	if (mapname == "mp_carentan_bal")
	{
		posters = addPoster(posters, (413.91, 2775.03, -29), 40, (-0, 180, 0));
		posters = addPoster(posters, (464.96, 205.61, -4.76), 54, (0.41, -0, -0.04));
	}
	if (mapname == "mp_carentan_fix")
	{
		posters = addPoster(posters, (413.91, 2775.03, -29), 40, (-0, 180, 0));
		posters = addPoster(posters, (464.96, 205.61, -4.76), 54, (0.41, -0, -0.04));
	}
	if (mapname == "mp_chelm_fix")
	{
		posters = addPoster(posters, (-3640.47, -1056.71, -32.36), 64, (0.52, -90, -0.37));
		posters = addPoster(posters, (-203.33, -624.87, -108.62), 58, (0.53, 90.15, 10.95));
	}
	if (mapname == "mp_dawnville_fix")
	{
		posters = addPoster(posters, (-751.42, -17509.67, 37.43), 43, (-2.6, 0.14, -1.85));
		posters = addPoster(posters, (1326.63, -14959.65, -81.01), 37, (-2.02, 179.65, 8.59));
	}
	if (mapname == "mp_dawnville_sun")
	{
		posters = addPoster(posters, (-751.42, -17509.67, 37.43), 43, (-2.6, 0.14, -1.85));
		posters = addPoster(posters, (1326.63, -14959.65, -81.01), 37, (-2.02, 179.65, 8.59));
	}
	if (mapname == "mp_leningrad_tls")
	{
		posters = addPoster(posters, (-1357.22, 46.69, 27.73), 40, (-3.68, -90.68, 6.74));
		posters = addPoster(posters, (1280.82, 133.44, 63), 40, (0, 89.48, 0));
	}
	if (mapname == "mp_matmata_fix")
	{
		posters = addPoster(posters, (2820.41, 5614.66, -5.93), 38, (-0.2, -90, -0.1));
		posters = addPoster(posters, (5631.05, 7560.27, -13), 53, (-0, 90, 0));
	}
	if (mapname == "mp_toujane_fix")
	{
		posters = addPoster(posters, (110.91, 1350.85, -5.57), 40, (-1.32, -75.04, 0.62));
		posters = addPoster(posters, (1987.02, 2366.98, 36.6), 41, (1.52, 120.97, -1.82));
	}
	if (mapname == "mp_trainstation_fix")
	{
		posters = addPoster(posters, (4657.4, -3504.36, -29), 45, (-0, -90, 0));
		posters = addPoster(posters, (7614.83, -3024.79, -29), 50, (-0, 90, 0));
	}
	// </generated>
	return posters;
}
