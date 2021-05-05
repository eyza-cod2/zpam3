#include maps\mp\gametypes\global\_global;

main()
{
	// Initialize global systems (scripts for events, cvars, hud, player...)
	InitSystems();


	// Register events that should be caught
	addEventListener("onStartGameType", ::onStartGameType);
	addEventListener("onConnecting", ::onConnecting);
	addEventListener("onConnected", ::onConnected);
	addEventListener("onDisconnect", ::onDisconnect);
	addEventListener("onPlayerDamaging", ::onPlayerDamaging);
	addEventListener("onPlayerDamaged", ::onPlayerDamaged);
	addEventListener("onPlayerKilling", ::onPlayerKilling);
	addEventListener("onPlayerKilled", ::onPlayerKilled);
	addEventListener("onCvarChanged", ::onCvarChanged);

	// Events for this gametype that are called last after all events are processed
	level.onAfterConnected = ::onAfterConnected;
	level.onAfterPlayerDamaged = ::onAfterPlayerDamaged;
	level.onAfterPlayerKilled = ::onAfterPlayerKilled;

	// Same functions across gametypes
	level.autoassign = ::menuAutoAssign;
	level.allies = ::menuAllies;
	level.axis = ::menuAxis;
	level.spectator = ::menuSpectator;
	level.weapon = ::menuWeapon;

	level.spawnPlayer = ::spawnPlayer;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;


	// Define gametype specific cvars here
	// Default values of these variables are overwrited by rules
	// Event onCvarChanged is called on every cvar registration
	// Make sure that onCvarChanged event is added first before cvar registration
	registerCvar("scr_dm_timelimit", "INT", 0, 0, 99999);
	registerCvar("scr_dm_half_score", "INT", 0, 0, 99999);
	registerCvar("scr_dm_end_score", "INT", 0, 0, 99999);
	registerCvar("scr_dm_halftime", "BOOL", 1);


	// Precache gametype specific stuff
	if (game["firstInit"])
		precache();

	// Init all shared modules in this pam (scripts with underscore)
	InitModules();
}


// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_dm_timelimit": 	level.timelimit = value; 	return true;
		case "scr_dm_half_score": 	level.halfscorelimit = value; 	return true;
		case "scr_dm_end_score": 	level.scorelimit = value; 	return true;
		case "scr_dm_halftime": 	level.halftime_enabled = value; return true;
	}
	return false;
}



// Precache specific stuff for this gametype
// Is called only once per map
precache()
{

}


// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	if(game["firstInit"])
	{
		// defaults if not defined in level script
		if(!isdefined(game["allies"]))
			game["allies"] = "american";
		if(!isdefined(game["axis"]))
			game["axis"] = "german";

		// Other variables
		game["state"] = "playing";
	}

	// Main scores (not needed in DM, but needed for other scripts)
	game["allies_score"] = 0;
	game["axis_score"] = 0;
	game["half_1_allies_score"] = 0;
	game["half_1_axis_score"] = 0;
	game["half_2_allies_score"] = 0;
	game["half_2_axis_score"] = 0;


	// Gametype specific variables
	level.mapended = false;





	// Spawn points
	spawnpointname = "mp_dm_spawn";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] PlaceSpawnpoint();



	// If map supports SD, show SD objects instead
	spawnpointname = "mp_sd_spawn_attacker";
	spawnpoints = getentarray(spawnpointname, "classname");
	if(spawnpoints.size)
	{
		allowed[0] = "sd";
		allowed[1] = "bombzone";
		maps\mp\gametypes\_gameobjects::main(allowed);
		thread bombzones();
	}


	setClientNameMode("auto_change");

	serverInfo();


	if (!level.in_readyup)
	{
		thread startGame();
	}
}





/*================
Called when a player begins connecting to the server.
Called again for every map change or tournement restart.

Return undefined if the client should be allowed, otherwise return
a string with the reason for denial.

Otherwise, the client will be sent the current gamestate
and will eventually get to ClientBegin.

firstTime will be qtrue the very first time a client connects
to the server machine, but qfalse on map changes and tournement
restarts.
================*/
onConnecting()
{
	self.statusicon = "hud_status_connecting";
	self.sessionteam = "spectator";
}

/*
Called when player is fully connected to game
*/
onConnected()
{
	self.statusicon = "";

	// Variables in self.pers[] stay defined after scriped map restart
	// Other like self.ownvariable will be undefined after scriped map restart
	// Except a few special vars, like self.sessionteam, their are defined after map restart, but with default value

	// If is players first connect, his team is undefined (in SD is PlayerConnected called every round)
	if (isDefined(self.pers["team"]) && self.pers["team"] != "spectator")
	{
		// Show player in spectator team
		self.sessionteam = "none";
	}
	else
	{
		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";
		// Print "<NAME> Connected" to all
		iprintln(&"MP_CONNECTED", self.name);
	}

	// Define default variables specific for this gametype

	// Set score and deaths
	if(!isdefined(self.pers["score"]))
		self.pers["score"] = 0;
	self.score = self.pers["score"];

	if(!isdefined(self.pers["deaths"]))
		self.pers["deaths"] = 0;
	self.deaths = self.pers["deaths"];
}

// This function is called as last after all events are processed
onAfterConnected()
{
	// If the game is at the post game state (scoreboard) the connecting player should spawn into intermission
	if (game["state"] == "intermission")
		spawnIntermission();

	// If player is just connected and blackout needs to be activated
	else if (self.pers["team"] == "none")
	{
		if (self maps\mp\gametypes\_blackout::isBlackoutNeeded())
			self maps\mp\gametypes\_blackout::spawnBlackout();
		else
			spawnSpectator(); // spawn spec but no movement
	}

	// Spectator team
	else if (self.pers["team"] == "spectator")
		spawnSpectator();

	// If team is selected
	else if (self.pers["team"] == "allies" || self.pers["team"] == "axis")
	{
		// If player have choozen weapon
		if(isDefined(self.pers["weapon"]))
			spawnPlayer();
		// If player have choosen team, but have not choosen weapon (he is selecting from weapons menu)
		else
			spawnSpectator();
	}

	else
		assertMsg("Unknown team");
}

/*================
Called when a player drops from the server.
Will not be called between levels.
self is the player that is disconnecting.
================*/
onDisconnect()
{
	iprintln(&"MP_DISCONNECTED", self.name);
}


onPlayerDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if (level.mapended)
		return true;
}

/*
Called when player has taken damage.
self is the player that took damage.
*/
onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
}

// Called as last funtction after all onPlayerDamaged events are processed
onAfterPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		// Make sure at least one point of damage is done
		if(iDamage < 1)
			iDamage = 1;

		self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
		self notify("damaged_player", iDamage);

		// Shellshock/Rumble
		self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
	}

	// LOG stuff
	if(self.sessionstate != "dead")
		level notify("log_damage", self, eAttacker, sWeapon, iDamage, sMeansOfDeath, sHitLoc, false);
}


/*
Called when player is about to be killed.
self is the player that was killed.
Return true to prevent the kill.
*/
onPlayerKilling(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if (level.mapended)
		return true;
}


/*
Called when player is killed
self is the player that was killed.
*/
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
}

// Called as last funtction after all onPlayerKilled events are processed
onAfterPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self endon("disconnect");
	self endon("spawned");
	self notify("killed_player");

	// send out an obituary message to all clients about the kill
	obituary(self, attacker, sWeapon, sMeansOfDeath);

	// Weapon/Nade Drops
	if (!isDefined(self.switching_teams))
		self thread maps\mp\gametypes\_weapons::dropWeapons();


	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";

	if(!isdefined(self.switching_teams))
	{
		self.pers["deaths"]++;
		self.deaths = self.pers["deaths"];
	}

	doKillcam = false;
	attackerNum = -1;
	if(isPlayer(attacker))
	{
		if(attacker == self) // killed himself
		{
			doKillcam = false;

			if(!isdefined(self.switching_teams))
			{
				attacker.pers["score"]--;
				attacker.score = attacker.pers["score"];
			}
		}
		else
		{
			doKillcam = true;
			attackerNum = attacker getEntityNumber();

			attacker.pers["score"]++;
			attacker.score = attacker.pers["score"];

			attacker checkScoreLimit();
		}
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;

		self.pers["score"]--;
		self.score = self.pers["score"];
	}


	self notify("killed_player");

	level notify("log_kill", self, attacker,  sWeapon, iDamage, sMeansOfDeath, sHitLoc);

	// Wait before dead body is spawned to allow double kills (bullets may stop in this dead body)
	// Ignore this for shotgun, because it create a smoke effect on dead body (for good feeling)
	if (sWeapon != "shotgun_mp")
		waittillframeend;

	body = undefined;
	if(!isdefined(self.switching_teams))
		body = self cloneplayer(deathAnimDuration);
	self.switching_teams = undefined;

	delay = level.fps_multiplier * 1.5;
	wait delay;

	if(isDefined(body))
		body delete();

	if(doKillcam && level.scr_killcam)
		self maps\mp\gametypes\_killcam::killcam(attackerNum, 4, 5, psOffsetTime, true);

	if(isDefined(self.pers["weapon"]))
		self thread spawnPlayer();
}


spawnPlayer()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");


	self.sessionteam = "none";
	self.sessionstate = "playing";
	self.statusicon = "";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.maxhealth = 100;
	self.health = self.maxhealth;


	// Spawn where player dies
	if (isDefined(self.spawnOrigin))
	{
		self spawn(self.spawnOrigin, self.spawnAngles);

		self.spawnOrigin = undefined;
		self.spawnAngles = undefined;
	}
	else
	{
		spawnpointname = "mp_dm_spawn";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM(spawnpoints);

		if(isDefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}


	if(!isdefined(self.pers["savedmodel"]))
		maps\mp\gametypes\_teams::model();
	else
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);



	// Give weapon
	self setWeaponSlotWeapon("primary", self.pers["weapon"]);
	self giveMaxAmmo(self.pers["weapon"]);

	maps\mp\gametypes\_weapons::givePistol();
	maps\mp\gametypes\_weapons::giveSmokesFor(self.pers["weapon"]);
	maps\mp\gametypes\_weapons::giveGrenadesFor(self.pers["weapon"]);
	maps\mp\gametypes\_weapons::giveBinoculars();

	self setSpawnWeapon(self.pers["weapon"]);

	// Notify "spawned" notifications
	self notify("spawned");
	self notify("spawned_player");
}



spawnSpectator(origin, angles)
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";

	if(isdefined(origin) && isdefined(angles))
		self spawn(origin, angles);
	else
	{
 		spawnpointname = "mp_global_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

		if(isdefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
		{
			self spawn((0,0,0), (0,0,0));
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
		}
	}

	// Notify "spawned" notifications
	self notify("spawned");
}

spawnIntermission()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
	{
		self spawn((0,0,0), (0,0,0));
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}

	// Notify "spawned" notifications
	self notify("spawned");
	self notify("spawned_intermission");
}



startGame()
{
	level.starttime = getTime();

	if(level.timelimit > 0)
	{
		level.clock = newHudElem2();
		level.clock.horzAlign = "center_safearea";
		level.clock.vertAlign = "top";
		level.clock.x = -25;
		level.clock.y = 450;
		level.clock.font = "default";
		level.clock.fontscale = 2;
		level.clock setTimer(level.timelimit * 60);

		for(;;)
		{
			checkTimeLimit();
			wait level.fps_multiplier * 1;
		}
	}
}


checkTimeLimit()
{
	if(level.timelimit <= 0)
		return;

	timepassed = (getTime() - level.starttime) / 1000;
	timepassed = timepassed / 60.0;

	if(timepassed < level.timelimit)
		return;

	if(level.mapended) return;
	level.mapended = true;

	iprintln(&"MP_TIME_LIMIT_REACHED");

	if (level.halftime_enabled && !game["is_halftime"])
	{
		thread maps\mp\gametypes\_halftime::Do_Half_Time();
		level.mapended = true;
	}
	else
	{
		level thread endMap();
		level.mapended = true;
	}
}


checkScoreLimit()
{
	waittillframeend;

	if(level.mapended) return;


	/* Is it a score-based Halftime? */
	if(level.halftime_enabled && !game["is_halftime"] && level.halfscorelimit > 0)
	{
		if(self.score >= level.halfscorelimit || self.score >= level.halfscorelimit)
		{
			thread maps\mp\gametypes\_halftime::Do_Half_Time();
			level.mapended = true;
			return;
		}
	}


	/* Match Score Check */
	if (level.scorelimit > 0)
	{
		if(self.score < level.scorelimit && self.score < level.scorelimit)
			return;

		iprintln(&"MP_SCORE_LIMIT_REACHED");

		thread endMap();
		level.mapended = true;
	}
}



endMap()
{
	level thread maps\mp\gametypes\_end_of_map::Do_Map_End();
}





menuAutoAssign()
{
	// Team is already selected, do nothing and open menu again
	if(self.pers["team"] == "allies" || self.pers["team"] == "axis")
	{
		return;
	}

	numonteam["allies"] = 0;
	numonteam["axis"] = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(player.pers["team"] == "spectator" || player.pers["team"] == "none")
			continue;

		numonteam[player.pers["team"]]++;
	}

	// if teams are equal return the team with the lowest score
	if(numonteam["allies"] == numonteam["axis"])
	{
		teams[0] = "allies";
		teams[1] = "axis";
		assignment = teams[randomInt(2)];
	}
	else if(numonteam["allies"] < numonteam["axis"])
		assignment = "allies";
	else
		assignment = "axis";


	self.joining_team = assignment; // can be allies or axis
	self.leaving_team = self.pers["team"]; // can be "spectator" or "none"

	if(assignment != self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead"))
	{
		self.switching_teams = true;
		self suicide();
	}

	self.pers["team"] = assignment;
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;


	self notify("joined", assignment);
	self notify("joined_allies_axis");

	level notify("joined", assignment, self); // used in first round to check if someone joined team
}

menuAllies()
{
	// If team is already axis or we cannot join axis (to keep team balance), open team menu again
	if(self.pers["team"] == "allies")
	{
		return;
	}

	self.joining_team = "allies";
	self.leaving_team = self.pers["team"];

	if(self.sessionstate == "playing")
	{
		self.switching_teams = true;
		self suicide();
	}

	self.pers["team"] = "allies";
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;


	self notify("joined", "allies");
	self notify("joined_allies_axis");

	level notify("joined", "allies", self); // used in first round to check if someone joined team
}

menuAxis()
{
	// If team is already axis or we cannot join axis (to keep team balance), open team menu again
	if(self.pers["team"] == "axis")
	{
		return;
	}

	self.joining_team = "axis";
	self.leaving_team = self.pers["team"];

	if(self.sessionstate == "playing")
	{
		self.switching_teams = true;
		self suicide();
	}

	self.pers["team"] = "axis";
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;

	self notify("joined", "axis");
	self notify("joined_allies_axis");

	level notify("joined", "axis", self); // used in first round to check if someone joined team
}

menuSpectator()
{
	if(self.pers["team"] == "spectator")
		return;

	self.joining_team = "spectator";
	self.leaving_team = self.pers["team"];

	if(isAlive(self))
	{
		self.switching_teams = true;
		self suicide();
	}

	self.sessionteam = "spectator";
	self.pers["team"] = "spectator";
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;

	spawnSpectator();

	self notify("joined", "spectator");
	self notify("joined_spectators");

	level notify("joined", "spectator", self); // used in first round to check if someone joined team
}

menuWeapon(response)
{
	// You has to be "allies" or "axis" to change a weapon
	if(self.pers["team"] != "allies" && self.pers["team"] != "axis")
		return;

	// Used by bots
	if (response == "random")
		response = self maps\mp\gametypes\_weapons::getRandomWeapon();

	// Weapon is not valid or is in use
	if(!self maps\mp\gametypes\_weapon_limiter::isWeaponAvaible(response))
	{
		// Open menu with weapons again
		if(self.pers["team"] == "allies")
			self openMenu(game["menu_weapon_allies"]);
		else if(self.pers["team"] == "axis")
			self openMenu(game["menu_weapon_axis"]);
		return;
	}

	weapon = response;



	// After selecting a weapon, show "ingame" menu when ESC is pressed
	self setClientCvar2("g_scriptMainMenu", game["menu_ingame"]);

	// If new selected weapon is same as actualy selected weapon, do nothing
	if(isdefined(self.pers["weapon"]) && self.pers["weapon"] == weapon)
	{
		self switchToWeapon(weapon);
		return;
	}

	// Save weapon before change (used in weapon_limiter)
	leavedWeapon = undefined;
	leavedWeaponFromTeam = undefined;
	if (isDefined(self.pers["weapon"]))
	{
		leavedWeapon = self.pers["weapon"];
		leavedWeaponFromTeam = self.pers["team"];
	}

	if(isDefined(self.pers["weapon"]))
	{
		self.pers["weapon"] = weapon;

		weaponname = maps\mp\gametypes\_weapons::getWeaponName(self.pers["weapon"]);

		if(maps\mp\gametypes\_weapons::useAn(self.pers["weapon"]))
			self iprintln(&"MP_YOU_WILL_RESPAWN_WITH_AN", weaponname);
		else
			self iprintln(&"MP_YOU_WILL_RESPAWN_WITH_A", weaponname);
	}
	else
	{
		self.pers["weapon"] = weapon;

		spawnPlayer();
	}


	// Used in wepoan_limiter
	self notify("weapon_changed", weapon, leavedWeapon, leavedWeaponFromTeam);
}






// Called before round starts
bombzones()
{
	maperrors = [];

	wait level.fps_multiplier * .2;

	// Find bombzones (has to be 2 bomzones, A and B)
	bombzones = getentarray("bombzone", "targetname");
	array = [];
	for(i = 0; i < bombzones.size; i++)
	{
		bombzone = bombzones[i];

		if(isdefined(bombzone.script_bombmode_original) && isdefined(bombzone.script_label))
			array[array.size] = bombzone;
	}

	if(array.size == 2)
	{
		array[0] SetCursorHint("HINT_NONE");
		array[1] SetCursorHint("HINT_NONE");
	}

	bombtrigger = getent("bombtrigger", "targetname");
	bombtrigger maps\mp\_utility::triggerOff();

	// Kill unused bombzones and associated script_exploders
	accepted = [];
	for(i = 0; i < array.size; i++)
	{
		if(isdefined(array[i].script_noteworthy))
			accepted[accepted.size] = array[i].script_noteworthy;
	}

	remove = [];
	bombzones = getentarray("bombzone", "targetname");
	for(i = 0; i < bombzones.size; i++)
	{
		bombzone = bombzones[i];

		if(isdefined(bombzone.script_noteworthy))
		{
			addtolist = true;
			for(j = 0; j < accepted.size; j++)
			{
				if(bombzone.script_noteworthy == accepted[j])
				{
					addtolist = false;
					break;
				}
			}

			if(addtolist)
				remove[remove.size] = bombzone.script_noteworthy;
		}
	}

	ents = getentarray();
	for(i = 0; i < ents.size; i++)
	{
		ent = ents[i];

		if(isdefined(ent.script_exploder))
		{
			kill = false;
			for(j = 0; j < remove.size; j++)
			{
				if(ent.script_exploder == int(remove[j]))
				{
					kill = true;
					break;
				}
			}

			if(kill)
				ent delete();
		}
	}
}


serverInfo()
{
	setCvar("ui_serverinfo_left1", "");
	makeCvarServerInfo("ui_serverinfo_left1", "");

	setCvar("ui_serverinfo_left2", "");
	makeCvarServerInfo("ui_serverinfo_left2", "");


	setCvar("ui_serverinfo_right1", "");
	makeCvarServerInfo("ui_serverinfo_right1", "");

	setCvar("ui_serverinfo_right2", "");
	makeCvarServerInfo("ui_serverinfo_right2", "");


	setCvar("ui_motd", "");
	makeCvarServerInfo("ui_motd", "");
}
