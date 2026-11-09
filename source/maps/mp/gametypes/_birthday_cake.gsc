#include maps\mp\gametypes\global\_global;

// Call of Duty 2 birthday event: a birthday cake with 21 candles on each birthday poster (_birthday_poster.gsc).
// The cake stands on the hidden aim trainer poster, a counted shot at it lights the next candle (a looped flame effect
// at its wick), the 21st makes it explode and the poster appears. Once per poster in the map (game["birthday_cake_done_<n>"]).
// A script model can not be damaged: the shots are the players firing (clip ammo drops) with the cake in the line of fire, and
// the shots through the cake (not solid) into the damage trigger of the poster under it.
// Model and effect are generated (by a tool outside the repository)

// Called from _birthday_poster::init when the event is enabled at the map start
precache()
{
	precacheModel("xmodel/zpam_bday_cake");
	game["birthday_cake_fx_candle"] = loadfx("fx/zpam/bday_candle.efx");
	game["birthday_cake_fx_candle_light"] = loadfx("fx/zpam/bday_candle_light.efx");
}

isDone(poster)
{
	return isDefined(game["birthday_cake_done_" + poster.index]);
}

setDone(poster)
{
	game["birthday_cake_done_" + poster.index] = true;
}

// On the center of the poster, with the candles lit for the hits already counted
spawnCake(poster, hits)
{
	poster.cake = undefined;
	poster.candles = [];

	if (!maps\mp\gametypes\_hat_launcher::canSpawnEntities(1))
	{
		maps\mp\gametypes\_birthday_poster::debug("poster " + poster.index + ": no cake, too many entities");
		return;
	}
	poster.cake = spawn("script_model", poster.origin);
	poster.cake setModel("xmodel/zpam_bday_cake");
	poster.cake notsolid();	// shots fly through into the damage trigger of the poster

	for(i = 0; i < hits; i++)
		lightCandle(poster, false);
}

// Shots at the cakes: a player fires (the clip of the weapon in hands drops) with a cake in the line of fire, nothing in the way
shotsThink(posters)
{
	level endon("rupover");

	lastWeapon = [];	// by entity number
	lastClip = [];

	for(;;)
	{
		wait level.frame;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			num = player getEntityNumber();

			weapon = "none";
			clip = -1;
			if (player.sessionstate == "playing")
			{
				weapon = player getcurrentweapon();
				if (maps\mp\gametypes\_hat_launcher::isHatLauncher(weapon))
					weapon = "none";	// its hats are no shots (they never hit the poster either)
				if (weapon != "none" && weapon == player getweaponslotweapon("primary"))
					clip = player getweaponslotclipammo("primary");
				else if (weapon != "none" && weapon == player getweaponslotweapon("primaryb"))
					clip = player getweaponslotclipammo("primaryb");
			}

			// Holding attack is not a shot: empty clip, reloading, switching weapons, a weapon still rechambering
			fired = isDefined(lastWeapon[num]) && lastWeapon[num] == weapon && clip >= 0 && clip < lastClip[num];
			lastWeapon[num] = weapon;
			lastClip[num] = clip;
			if (!fired)
				continue;

			eye = player maps\mp\gametypes\global\player::getEyeOrigin();
			forward = anglesToForward(player getPlayerAngles());
			for(j = 0; j < posters.size; j++)
			{
				if (isDefined(posters[j].cake) && aimsAtCake(player, eye, forward, posters[j].cake.origin))
				{
					maps\mp\gametypes\_birthday_poster::debug("poster " + posters[j].index + ": " + player.name + " shoots at the cake");
					maps\mp\gametypes\_birthday_poster::countHit(posters[j]);
				}
			}
		}
	}
}

// The line of fire passes the cake (a cylinder 16 wide and 23 high around its center) and no wall is in the way
aimsAtCake(player, eye, forward, origin)
{
	center = origin + (0, 0, 11);
	t = vectorDot(center - eye, forward);
	if (t <= 0)
		return false;
	point = eye + maps\mp\_utility::vectorScale(forward, t);
	dz = point[2] - center[2];
	if (dz * dz > 12 * 12)
		return false;
	if (distance((point[0], point[1], 0), (center[0], center[1], 0)) > 16)
		return false;

	// The damage trigger around the cake stops the trace too
	trace = bulletTrace(eye, point, false, player);
	return trace["fraction"] == 1 || distance(eye, trace["position"]) > t - 48;
}

// The next candle starts to burn, struck: a flare and sparks at its wick with the match strike sound (zpam_bday_candle,
// played by _birthday_poster::posterHit in the same frame)
lightCandle(poster, struck)
{
	if (!isDefined(poster.cake))
		return;

	candles = getCandles();
	i = poster.candles.size;
	if (i >= candles.size)
		return;
	if (!maps\mp\gametypes\_hat_launcher::canSpawnEntities(1))
	{
		maps\mp\gametypes\_birthday_poster::debug("poster " + poster.index + ": candle " + (i + 1) + " not lit, too many entities");
		return;
	}
	poster.candles[i] = playLoopedFx(game["birthday_cake_fx_candle"], 0.1, poster.cake.origin + candles[i], 0, (0, 0, 1), (1, 0, 0));
	if (struck)
		playfx(game["birthday_cake_fx_candle_light"], poster.cake.origin + candles[i], (0, 0, 1), (1, 0, 0));
}

// All candles go out
blowOut(poster)
{
	if (!isDefined(poster.candles))
		return;
	for(i = 0; i < poster.candles.size; i++)
	{
		if (isDefined(poster.candles[i]))
			poster.candles[i] delete();
	}
	poster.candles = [];
}

removeCake(poster)
{
	blowOut(poster);
	if (isDefined(poster.cake))
		poster.cake delete();
}

getCandles()
{
	candles = [];
	// <generated>
	// Wicks of the 21 candles of xmodel/zpam_bday_cake, relative to its origin, in lighting order
	candles[candles.size] = (10.53, 2.4, 13.3);
	candles[candles.size] = (8.44, 6.73, 13.3);
	candles[candles.size] = (4.69, 9.73, 13.3);
	candles[candles.size] = (0, 10.8, 13.3);
	candles[candles.size] = (-4.69, 9.73, 13.3);
	candles[candles.size] = (-8.44, 6.73, 13.3);
	candles[candles.size] = (-10.53, 2.4, 13.3);
	candles[candles.size] = (-10.53, -2.4, 13.3);
	candles[candles.size] = (-8.44, -6.73, 13.3);
	candles[candles.size] = (-4.69, -9.73, 13.3);
	candles[candles.size] = (0, -10.8, 13.3);
	candles[candles.size] = (4.69, -9.73, 13.3);
	candles[candles.size] = (8.44, -6.73, 13.3);
	candles[candles.size] = (10.53, -2.4, 13.3);
	candles[candles.size] = (4.87, 2.34, 19.3);
	candles[candles.size] = (1.2, 5.26, 19.3);
	candles[candles.size] = (-3.37, 4.22, 19.3);
	candles[candles.size] = (-5.4, 0, 19.3);
	candles[candles.size] = (-3.37, -4.22, 19.3);
	candles[candles.size] = (1.2, -5.26, 19.3);
	candles[candles.size] = (4.87, -2.34, 19.3);
	// </generated>
	return candles;
}
