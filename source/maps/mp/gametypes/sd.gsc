#include maps\mp\gametypes\global\_global;

// Rallypoints should be destroyed on leaving your team/getting killed
// Compass icons need to be looked at
// Doesn't seem to be setting angle on spawn so that you are facing your rallypoint

/*
	Search and Destroy
	Attackers objective: Bomb one of 2 positions
	Defenders objective: Defend these 2 positions / Defuse planted bombs
	Round ends:	When one team is eliminated, bomb explodes, bomb is defused, or roundlength time is reached
	Map ends:	When one team reaches the score limit, or time limit or round limit is reached
	Respawning:	Players remain dead for the round and will respawn at the beginning of the next round

	Level requirements
	------------------
		Allied Spawnpoints:
			classname		mp_sd_spawn_attacker
			Allied players spawn from these. Place at least 16 of these relatively close together.

		Axis Spawnpoints:
			classname		mp_sd_spawn_defender
			Axis players spawn from these. Place at least 16 of these relatively close together.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

		Bombzones:
			classname					trigger_multiple
			targetname					bombzone
			script_gameobjectname		bombzone
			script_bombmode_original	<if defined this bombzone will be used in the original bomb mode>
			script_bombmode_single		<if defined this bombzone will be used in the single bomb mode>
			script_bombmode_dual		<if defined this bombzone will be used in the dual bomb mode>
			script_team					Set to allies or axis. This is used to set which team a bombzone is used by in dual bomb mode.
			script_label				Set to A or B. This sets the letter shown on the compass in original mode.
			This is a volume of space in which the bomb can planted. Must contain an origin brush.

		Bomb:
			classname				trigger_lookat
			targetname				bombtrigger
			script_gameobjectname	bombzone
			This should be a 16x16 unit trigger with an origin brush placed so that it's center lies on the bottom plane of the trigger.
			Must be in the level somewhere. This is the trigger that is used when defusing a bomb.
			It gets moved to the position of the planted bomb model.

	Level script requirements
	-------------------------
		Team Definitions:
			game["allies"] = "american";
			game["axis"] = "german";
			This sets the nationalities of the teams. Allies can be american, british, or russian. Axis can be german.

			game["attackers"] = "allies";
			game["defenders"] = "axis";
			This sets which team is attacking and which team is defending. Attackers plant the bombs. Defenders protect the targets.

		If using minefields or exploders:
			maps\mp\_load::main();

	Optional level script settings
	------------------------------
		Soldier Type and Variation:
			game["american_soldiertype"] = "normandy";
			game["german_soldiertype"] = "normandy";
			This sets what character models are used for each nationality on a particular map.

			Valid settings:
				american_soldiertype	normandy
				british_soldiertype		normandy, africa
				russian_soldiertype		coats, padded
				german_soldiertype		normandy, africa, winterlight, winterdark

		Exploder Effects:
			Setting script_noteworthy on a bombzone trigger to an exploder group can be used to trigger additional effects.

	Note
	----
		Setting "script_gameobjectname" to "bombzone" on any entity in a level will cause that entity to be removed in any gametype that
		does not explicitly allow it. This is done to remove unused entities when playing a map in other gametypes that have no use for them.
*/

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
	registerCvarEx("C", "scr_sd_timelimit", "FLOAT", 0, 0, 1440); 	// Total Time limit per map
	registerCvarEx("C", "scr_sd_half_round", "INT", 0, 0, 99999);	// Round limit for 1st half (0 means there is no half time)
	registerCvarEx("C", "scr_sd_half_score", "INT", 0, 0, 99999);	// Score limit for 1st half (0 means there is no half time)
	registerCvarEx("C", "scr_sd_end_round", "INT", 20, 0, 99999);	// Total round limit for map
	registerCvarEx("C", "scr_sd_end_score", "INT", 0, 0, 99999);	// Total score limit for map

	registerCvar("scr_sd_strat_time", "FLOAT", 5, 0, 15);	// Time before round starts (sec) (0 - 10, default 5)
	registerCvar("scr_sd_roundlength", "FLOAT", 4, 0, 10);	// Time length of each round (min) (0 - 10, default 4)
	registerCvar("scr_sd_end_time", "FLOAT", 0, 0, 15);		// Timer at the end of the round
	registerCvar("scr_sd_count_draws", "BOOL", 1);		// Count Draws? (may happend if last players from allies and axis are killed in same time)

	registerCvar("scr_sd_bombtimer", "FLOAT", 60, 0, 60);	// Time untill bomb explodes. (seconds)
	registerCvar("scr_sd_bombtimer_show", "BOOL", 1);		// Show bombtimr stopwatch
	registerCvar("scr_sd_planttime", "FLOAT", 5, 0, 10);
	registerCvar("scr_sd_defusetime", "FLOAT", 10, 0, 10);
	registerCvar("scr_sd_plant_points", "INT", 0, 0, 10);	// Points for planter
	registerCvar("scr_sd_defuse_points", "INT", 0, 0, 10);	// Points for defuser

	registerCvar("scr_sd_sniper_shotgun_info", "BOOL", 0);	// Show weapon info about sniper and shotgun players

	registerCvar("scr_auto_deadchat", "BOOL", 0);


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
	// Server info update
	if (!isRegisterTime && !game["firstInit"] && !isDefined(game["cvars"][cvar]["inQuiet"]) && cvar != "pam_mode_custom")
	{
		thread serverInfo();
	}

	switch(cvar)
	{
		case "scr_sd_timelimit": 		level.timelimit = value; return true;
		case "scr_sd_half_round": 		level.halfround = value; return true;
		case "scr_sd_half_score": 		level.halfscore = value; return true;
		case "scr_sd_end_round": 		level.matchround = value; return true;
		case "scr_sd_end_score": 		level.scorelimit = value; return true;

		case "scr_sd_strat_time": 		level.strat_time = value; return true;
		case "scr_sd_roundlength": 		level.roundlength = value; return true;
		case "scr_sd_end_time": 		level.round_endtime = value; return true;
		case "scr_sd_count_draws": 		level.countdraws = value; return true;

		case "scr_sd_bombtimer": 		level.bombtimer = value; return true;
		case "scr_sd_bombtimer_show": 		level.show_bombtimer = value; return true;
		case "scr_sd_planttime": 		level.planttime = value; return true;
		case "scr_sd_defusetime": 		level.defusetime = value; return true;
		case "scr_sd_plant_points": 		level.bomb_plant_points = value; return true;
		case "scr_sd_defuse_points": 		level.bomb_defuse_points = value; return true;

		case "scr_sd_sniper_shotgun_info": 	level.scr_sd_sniper_shotgun_info = value; return true;

		case "scr_auto_deadchat": 		level.scr_auto_deadchat = value; return true;
	}


	return false;
}

// Precache specific stuff for this gametype
// Is called only once per map
precache()
{
	precacheShader("plantbomb");
	precacheShader("defusebomb");
	precacheShader("objective");
	precacheShader("objectiveA");
	precacheShader("objectiveB");
	precacheShader("bombplanted");
	precacheShader("objpoint_bomb");
	precacheShader("objpoint_A");
	precacheShader("objpoint_B");
	precacheShader("objpoint_star");
	precacheString(&"MP_MATCHSTARTING");
	precacheString(&"MP_MATCHRESUMING");
	precacheString(&"MP_EXPLOSIVESPLANTED");
	precacheString(&"MP_EXPLOSIVESDEFUSED");
	precacheString(&"MP_ROUNDDRAW");
	precacheString(&"MP_TIMEHASEXPIRED");
	precacheString(&"MP_ALLIEDMISSIONACCOMPLISHED");
	precacheString(&"MP_AXISMISSIONACCOMPLISHED");
	precacheString(&"MP_ALLIESHAVEBEENELIMINATED");
	precacheString(&"MP_AXISHAVEBEENELIMINATED");
	precacheString(&"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES");
	precacheString(&"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES");
	precacheModel("xmodel/mp_tntbomb");
	precacheModel("xmodel/mp_tntbomb_obj");

	precacheString2("STRING_ROUND", &"Round");
	precacheString2("STRING_ROUND_STARTING", &"Starting");

	precacheString2("STRING_ROUND_FIRST", &"First Round");
	precacheString2("STRING_ROUND_LAST_HALF", &"Last round before half");
	precacheString2("STRING_ROUND_LAST", &"Last round");

	// HUD: Strattime
	precacheString2("STRING_STRAT_TIME", &"Strat Time");

	precacheString2("STRING_SPECTATOR_KILLCAM_REPLAY", &"Spectator killcam replay");
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
		if(!isdefined(game["attackers"]))
			game["attackers"] = "allies";
		if(!isdefined(game["defenders"]))
			game["defenders"] = "axis";


		// Main scores
		game["allies_score"] = 0;
		game["axis_score"] = 0;

		// For spectators
		game["allies_score_history"] = "";
		game["axis_score_history"] = "";

		// Half-separed scoresg
		game["half_1_allies_score"] = 0;
		game["half_1_axis_score"] = 0;
		game["half_2_allies_score"] = 0;
		game["half_2_axis_score"] = 0;

		// Other variables
		game["state"] = "playing";
		game["roundsplayed"] = 0;
		game["round"] = 0;

		// Counts length of all rounds (used for scr_sd_timelimit)
		game["timepassed"] = 0;
	}

	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);

	// Gametype specific variables
	level.matchstarted = false;
	level.in_strattime = false;
	level.starttime = 0;
	level.roundstarted = false;
	level.roundended = false;
	level.bombplanted = false;
	level.bombexploded = false;
	level.bombKill = false;



	// Variables to determinate endRound()
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;
	level.exist["teams"] = false;
	level.didexist["allies"] = false;
	level.didexist["axis"] = false;




	// Spawn points
	spawnpointname = "mp_sd_spawn_attacker";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
		AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	spawnpointname = "mp_sd_spawn_defender";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
		AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] PlaceSpawnpoint();

	level._effect["bombexplosion"] = loadfx("fx/props/barrelexp.efx");

	allowed[0] = "sd";
	allowed[1] = "bombzone";
	allowed[2] = "blocker";
	maps\mp\gametypes\_gameobjects::main(allowed);




	// Disable name changing to avoid spamming (is enabled in readyup)
	setClientNameMode("manual_change"); // name is changed after map restart ()


	thread serverInfo();



	// Wait here untill there is atleast one player connected
	if (game["firstInit"])
	{
		for(;;)
		{
			players = getentarray("player", "classname");
			if (players.size > 0)
				break;
			wait level.fps_multiplier * 1;
		}

		// For public mode, wait untill most of player connect
		if (game["is_public_mode"])
		{
			for(;;)
			{
				allies = 0;
				axis = 0;

				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					if (players[i].pers["team"] == "allies")
						allies++;
					else if (players[i].pers["team"] == "axis")
						axis++;
				}

				if (allies > 0 && axis > 0)
				{
					iprintln("Match is starting");

					wait level.fps_multiplier * 8;

					if (!level.pam_mode_change)
						map_restart(true);

					break;
				}

				wait level.fps_multiplier * 3;
			}
		}
	}



	thread bombzones();


	level.starttime = getTime();
	level.matchstarted = true;

	// Show weapon info about sniper and shotgun players
	level thread maps\mp\gametypes\_sniper_shotgun_info::updateSniperShotgunHUD();

	thread deadchat();

	if (!level.in_readyup)
	{
		thread startRound();
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
	if (!isDefined(self.pers["team"]))
	{
		// Show player in spectator team
		// If mod is not downloaded or blackout is needed to show, player is moved to none team in another script
		self.pers["team"] = "none";
		self.sessionteam = "none";

		// Print "<NAME> Connected" to all
		iprintln(&"MP_CONNECTED", self.name);
	}
	else
	{
		// If is team selected from last round, set the real team variable
		self.sessionteam = self.pers["team"];
	}

	// Define default variables specific for this gametype
	self.bombinteraction = false;
	self.spawnsInStrattime = 0;

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
			spawnSpectator();
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

	// If player disconnect in middle of the planting/defusing, release triggers
	if (isDefined(self.triggerRelease1))
		self clientreleasetrigger(self.triggerRelease1);
	if (isDefined(self.triggerRelease2))
		self clientreleasetrigger(self.triggerRelease2);


	level thread updateTeamStatus(); // in thread because of wait 0
}

/*
Called when player is about to take a damage.
self is the player that took damage.
Return true to prevent the damage.
*/
onPlayerDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// In readyup there is own onPlayerDamaging function
	if (level.in_readyup)
		return false;

	// Prevent damage when:
	if (!level.matchstarted || level.in_strattime || level.roundended)
		return true;

	// In bash mode allow damage only via pistol bash
	if (level.in_bash && (sMeansOfDeath != "MOD_MELEE" || !maps\mp\gametypes\_weapons::isPistol(sWeapon)))
		return true;

	// Friendly fire is disabled - prevent damage
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]))
		{
			if(level.scr_friendlyfire == 0)
			{
				return true;
			}
		}
	}
}

/*
Called when player has taken damage.
self is the player that took damage.
*/
onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// check for completely getting out of the damage
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		// Player's stats - increase damage points (_player_stat.gsc)
		if (isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self && eAttacker.pers["team"] != self.pers["team"] && !level.in_readyup && level.roundstarted && !level.roundended)
		{
			eAttacker thread watchPlayerDamageForStats(self, iDamage, sMeansOfDeath, sWeapon);

			// For assists
			if (isDefined(self.lastAttacker) && self.lastAttacker != eAttacker)
			{
				self.lastAttacker2 = self.lastAttacker;
				self.lastAttackerTime2 = self.lastAttackerTime;
			}

			self.lastAttacker = eAttacker;
			self.lastAttackerTime = gettime();
		}
	}
}

// Called as last funtction after all onPlayerDamaged events are processed
onAfterPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// If bomb explodes, set the planting player as the attacker of bomb explosion
	if (level.bombKill && isDefined(level.planting_player) && isPlayer(level.planting_player) && eAttacker.classname == "worldspawn")
	{
		//iprintln("Killed by bomb!!");
		// Prevent killing teammates by player - it can be abused to decrease player kill score
		//if (self.pers["team"] != level.planting_player.pers["team"])
		eAttacker = level.planting_player;
	}

	isFriendlyFire = false; // used for log

	//println("^2"+self.name+" took damage " + iDamage + " idflags " + iDFlags);

	// check for completely getting out of the damage
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]))
		{
			if(level.scr_friendlyfire == 1)
			{
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				self notify("damaged_player", iDamage);

				// Shellshock/Rumble
				self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
			}
			else if(level.scr_friendlyfire == 2)
			{
				eAttacker.friendlydamage = true;

				iDamage = int(iDamage * .5);

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker notify("damaged_player", iDamage);
				eAttacker.friendlydamage = undefined;

				isFriendlyFire = true;
			}
			else if(level.scr_friendlyfire == 3)
			{
				eAttacker.friendlydamage = true;

				iDamage = int(iDamage * .5);

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				self notify("damaged_player", iDamage);

				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker notify("damaged_player", iDamage);

				eAttacker.friendlydamage = undefined;

				// Shellshock/Rumble
				self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);

				isFriendlyFire = true;
			}
		}
		else
		{
			// Make sure at least one point of damage is done
			if(iDamage < 1)
				iDamage = 1;

			self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			self notify("damaged_player", iDamage);

			// Shellshock/Rumble
			self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
		}
	}


	if(self.sessionstate != "dead" && !level.in_readyup)
		level notify("log_damage", self, eAttacker, sWeapon, iDamage, sMeansOfDeath, sHitLoc, isFriendlyFire);
}

// Self if player who is hitting enemy
watchPlayerDamageForStats(enemy, damage, sMeansOfDeath, sWeapon)
{
	self endon("disconnect");
	enemy endon("disconnect");

	weapons["m1carbine_mp"] = 		50;
	weapons["m1garand_mp"] = 		50;
	weapons["thompson_mp"] = 		50;
	weapons["bar_mp"] = 			50;
	weapons["springfield_mp"] = 		100;
	weapons["greasegun_mp"] = 		50;
	weapons["shotgun_mp"] = 		50;
	weapons["enfield_mp"] = 		100;
	weapons["sten_mp"] = 			50;
	weapons["bren_mp"] = 			50;
	weapons["enfield_scope_mp"] = 		100;
	weapons["mosin_nagant_mp"] = 		100;
	weapons["SVT40_mp"] = 			50;
	weapons["PPS42_mp"] = 			50;
	weapons["ppsh_mp"] = 			50;
	weapons["mosin_nagant_sniper_mp"] = 	100;
	weapons["kar98k_mp"] = 			100;
	weapons["g43_mp"] = 			50;
	weapons["mp40_mp"] = 			50;
	weapons["mp44_mp"] = 			50;
	weapons["kar98k_sniper_mp"] = 		50;/*
	weapons["colt_mp"] = 			50;
	weapons["luger_mp"] = 			50;
	weapons["tt30_mp"] = 			50;
	weapons["webley_mp"] = 			50;*/
	weapons["mg_mp"] = 			50;

	if (self.usingMG)
		sWeapon = "mg_mp";


	// Decide damage poins
	if (isDefined(weapons[sWeapon]) && (sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET"))
		damage = weapons[sWeapon];
	else
		return;

	//self iprintln("^2Hits: " + damage);

	// Make sure only 1 thread is running for player
	self notify("watchPlayerDamageForStats_kill_" + enemy getEntityNumber());
	self endon ("watchPlayerDamageForStats_kill_" + enemy getEntityNumber());

	// Wait untill player starts healing
	lastValue = enemy.health;
	for(;;)
	{
		wait level.fps_multiplier * 1;
		if (enemy.health > lastValue)
			break;
		if (enemy.health <= 0)	// if enemy is killed, dont count damage
			return;
		lastValue = enemy.health;
	}

	// Enemy was not killed in 5sec, count damage
	self maps\mp\gametypes\_player_stat::AddDamage(damage);

	//self iprintln("Hits: " + damage);
}

/*
Called when player is about to be killed.
self is the player that was killed.
Return true to prevent the kill.
*/
onPlayerKilling(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Prevent kill if round didnt start
	if (!level.matchstarted)
		return true;

	// Prevent death when round ended
	if (level.roundended && !isdefined(self.switching_teams))
		return true;
}

/*
Called when player is killed
self is the player that was killed.
*/
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Add score to Deaths
	if(!isdefined(self.switching_teams))
	{
		// Player's stats - increase kill points (_player_stat.gsc)
		if (!level.in_readyup && level.roundstarted && !level.roundended)
			self maps\mp\gametypes\_player_stat::AddDeath();
	}

	if(isPlayer(attacker) && attacker != self)
	{
		if(self.pers["team"] == attacker.pers["team"]) // killed by a friendly
		{
			// Player's stats - decrease score points (_player_stat.gsc)
			if (!level.in_readyup && level.roundstarted && !level.roundended)
				attacker maps\mp\gametypes\_player_stat::AddScore(-1);
		}
		else
		{
			// Player's stats - increase kill points (_player_stat.gsc)
			if (!level.in_readyup && level.roundstarted && !level.roundended)
			{
				attacker maps\mp\gametypes\_player_stat::AddKill();
				attacker maps\mp\gametypes\_player_stat::AddScore(1);

				if (sMeansOfDeath == "MOD_GRENADE_SPLASH")
				{
					attacker maps\mp\gametypes\_player_stat::AddGrenade();
				}

				// For assists
				if (isDefined(self.lastAttacker) && isDefined(self.lastAttacker2) && self.lastAttacker2 != attacker && (self.lastAttackerTime2 + 5000) > gettime())
				{
					self.lastAttacker2 thread maps\mp\gametypes\_damagefeedback::updateAssistsFeedback();

					self.lastAttacker2 maps\mp\gametypes\_player_stat::AddAssist();
					self.lastAttacker2 maps\mp\gametypes\_player_stat::AddScore(0.5);
				}

			}
		}
	}
}

// Called as last funtction after all onPlayerKilled events are processed
onAfterPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self endon("disconnect");
	self endon("spawned");

	// Kill is handled in readyup functions
	if (level.in_readyup)
		return;

	// Send out an obituary message to all clients about the kill
	obituary(self, attacker, sWeapon, sMeansOfDeath);

	// Weapon/Nade Drops
	if (!isDefined(self.switching_teams) && level.roundstarted && !level.roundended)
		self thread maps\mp\gametypes\_weapons::dropWeapons();


	// Show as dead
	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";

	// Add score to Deaths
	if(!isdefined(self.switching_teams))
	{
		self.pers["deaths"]++;
		self.deaths = self.pers["deaths"];
	}

	doKillcam = false;
	attackerNum = -1; // used for killcam
	if(isPlayer(attacker))
	{
		if(attacker == self) // killed himself
		{
			doKillcam = false;

			// switching teams
			if(isdefined(self.switching_teams))
			{
				if((self.leaving_team == "allies" && self.joining_team == "axis") || (self.leaving_team == "axis" && self.joining_team == "allies"))
				{
					players = maps\mp\gametypes\_teams::CountPlayers();
					players[self.leaving_team]--;
					players[self.joining_team]++;

					if((players[self.joining_team] - players[self.leaving_team]) > 1)
					{
						attacker.pers["score"]--;
						attacker.score = attacker.pers["score"];
					}
				}
			}

			if(isdefined(attacker.friendlydamage))
				attacker iprintln(&"MP_FRIENDLY_FIRE_WILL_NOT");
		}
		else
		{
			attackerNum = attacker getEntityNumber();
			doKillcam = true;

			if(self.pers["team"] == attacker.pers["team"]) // killed by a friendly
			{
				attacker.pers["score"]--;
				attacker.score = attacker.pers["score"];
			}
			else
			{
				attacker.pers["score"]++;
				attacker.score = attacker.pers["score"];
			}
		}
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;

		if (!level.bombKill) // Dont decrease score for planter if bomb kills friently
		{
			self.pers["score"]--;
			self.score = self.pers["score"];
		}
	}


	level notify("log_kill", self, attacker,  sWeapon, iDamage, sMeansOfDeath, sHitLoc);


	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;

	// Wait before dead body is spawned to allow double kills (bullets may stop in this dead body)
	// Ignore this for shotgun, because it create a smoke effect on dead body (for good feeling)
	if (sWeapon != "shotgun_mp")
		waittillframeend;

	// Clone players model for death animations
	body = undefined;
	if(!isdefined(self.switching_teams))
		body = self cloneplayer(deathAnimDuration);


	self.switching_teams = undefined;


	level thread updateTeamStatus(); // in thread because of wait 0


	delay = 2;	// Delay the player becoming a spectator till after he's done dying
	wait level.fps_multiplier * delay;	// ?? Also required for Callback_PlayerKilled to complete before killcam can execute


	// Delete dead body if its close to bomb
	if (isDefined(body) && isDefined(body.origin) && level.bombplanted && isDefined(level.bombmodel) && isDefined(level.bombmodel.origin))
	{
		distance = distance(body.origin, level.bombmodel.origin);

		if (distance < 70.0)
		{
			//iprintln(distance);
			body delete();
		}
	}


	// If the last player on a team was just killed
	if((self.pers["team"] == "allies" || self.pers["team"] == "axis") && !level.exist[self.pers["team"]])
	{
		// Dont do killcam
		doKillcam = false;
	}


	// Do killcam - if enabled, wait here until killcam is done
	if(doKillcam && level.scr_killcam && !level.roundended)
		self maps\mp\gametypes\_killcam::killcam(attackerNum, 7, 8, psOffsetTime);

	// In SD - show score for dead player even if score is disabled
	self maps\mp\gametypes\_hud_teamscore::showScore(0.5);

	// Spawn from "dead" player session to spectator
	self thread spawnSpectator(self.origin + (0, 0, 60), self.angles);
}

spawnPlayer()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");


	self.sessionteam = self.pers["team"];
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.maxhealth = 100;
	self.health = self.maxhealth;
	self.friendlydamage = undefined;

	self.statusicon = "";


	// Select correct spawn position according to selected team
	if(self.pers["team"] == "allies")
		spawnpointname = "mp_sd_spawn_attacker";
	else
		spawnpointname = "mp_sd_spawn_defender";

	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isdefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");


	// Update status about players into level.exist and check of round is draw/winner/atd..
	level thread updateTeamStatus(); // in thread because of wait 0


	if(!isdefined(self.pers["savedmodel"]))
		maps\mp\gametypes\_teams::model();
	else
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);




	// If there is saved weapons from last round
	if(isdefined(self.pers["weapon1"]) && isdefined(self.pers["weapon2"]))
	{
	 	self setWeaponSlotWeapon("primary", self.pers["weapon1"]);
		self giveMaxAmmo(self.pers["weapon1"]);

	 	self setWeaponSlotWeapon("primaryb", self.pers["weapon2"]);
		self giveMaxAmmo(self.pers["weapon2"]);

		self setSpawnWeapon(self.pers["weapon1"]);

		self.spawnedWeapon = self.pers["weapon1"];
	}
	else
	{
		self setWeaponSlotWeapon("primary", self.pers["weapon"]);
		self giveMaxAmmo(self.pers["weapon"]);

		self setSpawnWeapon(self.pers["weapon"]);

		self.spawnedWeapon = self.pers["weapon"];
	}

	// Give grenades only if we are in readyup
	if(level.in_readyup)
	{
		maps\mp\gametypes\_weapons::giveSmokesFor(self.spawnedWeapon, 0);
		maps\mp\gametypes\_weapons::giveGrenadesFor(self.spawnedWeapon, 0); // grenades are handled in readyup now
	}
	else
	{
		maps\mp\gametypes\_weapons::giveSmokesFor(self.spawnedWeapon, 0);
		maps\mp\gametypes\_weapons::giveGrenadesFor(self.spawnedWeapon, 0);	// grenades will be added after start time
	}
	maps\mp\gametypes\_weapons::givePistol();
	maps\mp\gametypes\_weapons::giveBinoculars();

	// Switch to pistol in bash mode
	if (level.in_bash)
	{
		self setSpawnWeapon(self getweaponslotweapon("primaryb"));
	}


	self.selectedWeaponOnRoundStart = self.pers["weapon"]; // to determine is weapon was changed during round


	// Hide score if it may be hidden
	if (level.roundstarted)
		self maps\mp\gametypes\_hud_teamscore::hideScore(0.5);

	// Count how many times player changed team in strattime (used to limit it in menu_weapon)
	if (level.in_strattime && (self.pers["team"] == "allies" || self.pers["team"] == "axis"))
		self.spawnsInStrattime++;

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
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	else if (self.pers["team"] == "allies" || self.pers["team"] == "axis") // dead team spectartor
		self.statusicon = "hud_status_dead";


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


	// Update status about players into level.exist and check of round is draw/winner/atd..
	level thread updateTeamStatus(); // in thread because of wait 0


	// Notify "spawned" notifications
	self notify("spawned");



	// If is real spectator (is in team spectator, not session state spectator)
	if(self.pers["team"] == "spectator")
	{
		self notify("spawned_spectator");
	}
}

spawnIntermission()
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
	self.friendlydamage = undefined;

	// Will disable spectating
	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isdefined(spawnpoint))
	{
		self spawn(spawnpoint.origin, spawnpoint.angles);
	}
	else
	{
		self spawn((0,0,0), (0,0,0));
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}

	// Specific for SD
	if(isdefined(level.bombmodel))
		level.bombmodel stopLoopSound();

  // Open alternative scoreboard
	self openMenu(game["menu_scoreboard"]);
	self setClientCvar2("g_scriptMainMenu", game["menu_ingame"]);
	self setClientCvar2("ui_allow_weaponchange", 0);
	self setClientCvar2("ui_allow_changeteam", 0);

	// Notify "spawned" notifications
	self notify("spawned");
	self notify("spawned_intermission");
}


startRound()
{
	// Stop round-timer if bomb is planted or round ends another way
	level endon("bomb_planted");
	level endon("round_ended");


	logPrint("RoundStart;\n");
	logPrint("RoundInfo;score:"+game["allies_score"]+":"+game["axis_score"]+";round:"+game["round"]+"\n");

	// Define round number
	game["round"] = game["roundsplayed"] + 1;


	// If is bash, there is no time-limit
	if(level.in_bash)
	{
		objective_delete(0);
		objective_delete(1);
		maps\mp\gametypes\_weapons::deletePlacedEntity("misc_turret");
		maps\mp\gametypes\_weapons::deletePlacedEntity("misc_mg42");

		wait level.fps_multiplier * 1;

		// Hide score if it may be hidden
		level maps\mp\gametypes\_hud_teamscore::hideScore(0.5);
		thread sayObjective();

		return;
	}


	level.in_strattime = false;

	// Timeout was called from previous round, exit
	if (level.in_timeout)
		return;

	// Show name of league + pam version
	thread maps\mp\gametypes\_pam::PAM_Header();

	// Do strat time if is enabled
	if (level.strat_time > 0)
	{
		level.in_strattime = true;

		// Disable players movement
		level thread stratTime_g_speed();

		// Show HUD stuff...
		thread HUD_StratTime(level.strat_time);
		thread HUD_RoundInfo(level.strat_time);

		// End strattime when time expires or timeout is called
		level thread strattime_end_timer(level.strat_time);
		level thread strattime_end_ontimeout();

		level waittill("strat_time_end");

		// Out of strat time
		level.in_strattime = false;

		// Timeout was called in middle of strat time, exit
		if (level.in_timeout)
			return;
	}

	// Round started
	level.roundstarted = true;

	thread HUD_Clock(level.roundlength * 60);



	// Hide pam info hud
	thread maps\mp\gametypes\_pam::PAM_Header_Delete();
	// Hide score if it may be hidden
	level maps\mp\gametypes\_hud_teamscore::hideScore(0.5);



	thread sayObjective();






	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player.pers["team"] == "none" || player.pers["team"] == "spectator")
			continue;

		// Players on a team but without a weapon or dead show as dead since they can not get in this round
		if(player.sessionstate != "playing")
			player.statusicon = "hud_status_dead";

		// To all living player give grenades
		if (isDefined(player.selectedWeaponOnRoundStart) && player.sessionstate == "playing" && (player.pers["team"] == "allies" || player.pers["team"] == "axis") && !level.in_bash)
		{
			player maps\mp\gametypes\_weapons::giveSmokesFor(player.selectedWeaponOnRoundStart);
			player maps\mp\gametypes\_weapons::giveGrenadesFor(player.selectedWeaponOnRoundStart);
		}

	}


	// Wait until round time expires (2 min default)
	wait level.fps_multiplier * level.roundlength * 60;


	// Time expired
	iprintln(&"MP_TIMEHASEXPIRED");

	// If there is no opponent -> draw
	if(!level.exist[game["attackers"]] || !level.exist[game["defenders"]])
		level thread endRound("draw");

	// By default defenders wins if time expires, because attackers did not plant bonb
	else
		level thread endRound(game["defenders"]);
}

strattime_end_timer(time)
{
	level endon("strat_time_end");

	wait level.fps_multiplier * time;

	level notify("strat_time_end");
}

strattime_end_ontimeout()
{
	level endon("strat_time_end");

	level waittill("running_timeout");

	level notify("strat_time_end");
}

HUD_Clock(countDownTime)
{
	level.clock = newHudElem2();
	level.clock.font = "default";
	level.clock.fontscale = 2;
	level.clock.horzAlign = "center_safearea";
	level.clock.vertAlign = "top";
	level.clock.alignX = "center";
	level.clock.alignY = "top";
	level.clock.color = (1, 1, 1);
	level.clock.x = 0;
	level.clock.y = 445;
	level.clock setTimer(countDownTime);

	// If strattime is enabled, show fade-in animation
	if (level.strat_time > 0)
	{
		level.clock.alpha = 0;

		level.clock FadeOverTime(0.5);
		level.clock.alpha = 1;

		level.clock.x = 40;
		level.clock moveovertime(0.5);
		level.clock.x = 0;
	}


	waitTime = countDownTime - 30 - 0.3;
	if (waitTime <= 0)
		return;

	wait waitTime * level.fps_multiplier;
	if (!isDefined(level.clock) || level.roundended)
		return;

	// Orange
	level.clock.color = (1, 0.6, 0.15);

	waitTime = countDownTime - waitTime - 15;
	if (waitTime <= 0)
		return;

	wait waitTime * level.fps_multiplier;
	if (!isDefined(level.clock) || level.roundended)
		return;

	// Red
	level.clock.color = (1, 0.25, 0.25);
}

HUD_StratTime(time)
{
	if (time <= 0)
		return;

	// Strat Time
	strattime = addHUD(0, 450, 2, (.98, .827, .58), "center", "bottom", "center_safearea", "top");
	strattime setText(game["STRING_STRAT_TIME"]);

	// 0:05
	strat_clock = addHUD(0, 445, 2, (.98, .827, .58), "center", "top", "center_safearea", "top");
	strat_clock setTimer(time);


	// Wait untill time expired or timeout was called
	level waittill("strat_time_end");


	strattime FadeOverTime(0.5);
	strattime.alpha = 0;

	strat_clock FadeOverTime(0.5);
	strat_clock.alpha = 0;

	strat_clock moveovertime(0.5);
	strat_clock.x = -40;

	wait level.fps_multiplier * 0.5;

	strattime destroy2();
	strat_clock destroy2();
}


HUD_RoundInfo(time)
{
	if (game["round"] == 1)
	{
		roundInfo = addHUD(0, 430, 1.3, (.8, 1, 1), "center", "bottom", "center_safearea", "top");
		roundInfo setText(game["STRING_ROUND_FIRST"]);
		roundInfo.y = 360;
		roundInfo moveovertime(3);
		roundInfo.y = 428;
		level waittill("strat_time_end");
		roundInfo thread removeHUDSmooth(.5);
	}
	// Last round before half
	else if (level.halfround > 0 && !game["is_halftime"] && game["round"] >= level.halfround)
	{
		roundInfo = addHUD(0, 430, 1.3, (.8, 1, 1), "center", "bottom", "center_safearea", "top");
		roundInfo setText(game["STRING_ROUND_LAST_HALF"]);
		roundInfo.y = 360;
		roundInfo moveovertime(3);
		roundInfo.y = 428;
		level waittill("strat_time_end");
		roundInfo thread removeHUDSmooth(.5);
	}
	// Last match round
	else if (level.matchround > 0 && game["is_halftime"] && game["round"] >= level.matchround)
	{
		roundInfo = addHUD(0, 430, 1.3, (.8, 1, 1), "center", "bottom", "center_safearea", "top");
		roundInfo setText(game["STRING_ROUND_LAST"]);
		roundInfo.y = 360;
		roundInfo moveovertime(3);
		roundInfo.y = 428;
		level waittill("strat_time_end");
		roundInfo thread removeHUDSmooth(.5);
	}
	else
	{
		roundInfo1 = addHUD(10, 428, 1.3, (.8, 1, 1), "right", "bottom", "center_safearea", "top");
		roundInfo2 = addHUD(14, 428, 1.3, (.8, 1, 1), "left", "bottom", "center_safearea", "top");

		roundInfo1 setText(game["STRING_ROUND"]);
		roundInfo2 setValue(game["round"]);

		level waittill("strat_time_end");

		roundInfo1 thread removeHUDSmooth(.5);
		roundInfo2 thread removeHUDSmooth(.5);
	}


}



/*
              __
  Round     (    )
    8      (  .   )
 Starting   ( __ )
*/
HUD_NextRound()
{
	x = -90;
        y = 270;

	// Time to wait
	time = level.round_endtime;

	// Ccount-down stopwatch
	stopwatch = addHUD(x+80, y, undefined, undefined, "right", "top", "right");
	stopwatch showHUDSmooth(.5);
	stopwatch.sort = 4;
	stopwatch.foreground = true;  // above blackbg and visible if menu opened
	stopwatch setClock(time, 60, "hudStopwatch", 60, 60); // count down for 5 of 60 seconds, size is 64x64

	// Round
    	round = addHUD(x, y, 1.2, (1,1,0), "center", "top", "right");
	round showHUDSmooth(.5);
	round setText(game["STRING_ROUND"]);
	y += 27;

	// 6
    	roundnum = addHUD(x, y, 1.4, (1,1,0), "center", "middle", "right");
	roundnum showHUDSmooth(.5);
	roundnum setValue(game["roundsplayed"]+1);
	y += 28;

	// Starting
    	starting = addHUD(x, y, 1.2, (1,1,0), "center", "bottom", "right");
	starting showHUDSmooth(.5);
	starting setText(game["STRING_ROUND_STARTING"]);


	// Remove hud after time exlaped
	for(i = 0; i < level.sv_fps * time; i++)
	{
		// Remove HUD sooner in case timeout is called (new hud about timeout is whowed)
		if (game["do_timeout"])
			break;
		wait level.frame;
	}

	round thread removeHUDSmooth(.5);
	roundnum thread removeHUDSmooth(.5);
	starting thread removeHUDSmooth(.5);
	stopwatch thread removeHUDSmooth(.5);
}




stratTime_g_speed()
{
	// Disable players movement
	maps\mp\gametypes\global\cvar_system::setCvarQuiet("g_speed", 0);

	level waittill("strat_time_end");

	maps\mp\gametypes\global\cvar_system::restoreCvarQuiet("g_speed");
}



// Is called when time expired, last player is killed, bomb expldoes, bomb is defused
endRound(roundwinner)
{
	level endon("intermission");

	// If this function was already called, dont do it again
	if(level.roundended)
		return;
 	level.roundended = true;




	// End bombzone threads and remove related hud elements and objectives
	level notify("round_ended");

	// Remove plant progress if round ended when some player was planting
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isdefined(player.progressbackground))
			player.progressbackground destroy2();

		if(isdefined(player.progressbar))
			player.progressbar destroy2();

		player unlink();
		player enableWeapon();
	}

	objective_delete(0);
	objective_delete(1);

	// Say: Axis/Allies Win   after 2 sec
	level thread announceWinner(roundwinner, 2);



	if (level.in_bash)
	{
		wait level.fps_multiplier * 4;

		game["Do_Ready_up"] = undefined; // will restart readyup

		// will allow team swap and correct teams rename
		game["match_teams_set"] = undefined;
		game["match_previous_map_processed"] = undefined;

		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			player.pers["score"] = undefined;
			player.pers["deaths"] = undefined;
		}

		if (!level.pam_mode_change)
        		map_restart(true);
		return;
	}


	// Show weapon info about sniper and shotgun players
	level thread maps\mp\gametypes\_sniper_shotgun_info::updateSniperShotgunHUD();




	if(roundwinner == "allies")
	{
		if (game["is_halftime"])
			game["half_2_allies_score"]++;
		else
			game["half_1_allies_score"]++;

		game["allies_score"]++;
	}
	else if(roundwinner == "axis")
	{
		if (game["is_halftime"])
			game["half_2_axis_score"]++;
		else
			game["half_1_axis_score"]++;

		game["axis_score"]++;
	}

	// Set Score
	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);

	// History score for spectators
	if(roundwinner == "allies")
	{
		game["allies_score_history"] += "^2#";
		game["axis_score_history"] += "^1=";
	}
	else if(roundwinner == "axis")
	{
		game["allies_score_history"] += "^1=";
		game["axis_score_history"] += "^2#";
	}
	else // draw
	{
		game["allies_score_history"] += "^7-";
		game["axis_score_history"] += "^7-";
	}


	// Update score
	level maps\mp\gametypes\_hud_teamscore::updateScore();

	// LOG stuff
	level notify("log_round_end", roundwinner);


	// Increase played rounds
	if ((roundwinner == "draw" && level.countdraws) || roundwinner == "allies" || roundwinner == "axis")
		game["roundsplayed"]++;


	// Check total time limit first (scr_sd_timelimit), may be used in pub
	game["timepassed"] = game["timepassed"] + ((getTime() - level.starttime) / 1000) / 60.0;




	// Wait a sec after last player is killed
	wait level.fps_multiplier * 2;


	thread maps\mp\gametypes\_pam::PAM_Header(true); // true = fadein

	// Show score even if is disabled
	level maps\mp\gametypes\_hud_teamscore::showScore(0.5);


	// Print damage stats
	maps\mp\gametypes\_round_report::printToAll();


	// In SD there are 3 checks: Time limit, Score limit and Round limit

	// Check Time Limit - if is reached, map-end is runned
	ended = checkTimeLimit(); // Time expired
	if(ended) return;

	// Check Score Limit - if is reached, half-time is runned or map-end is runned
	ended = checkMatchScoreLimit();
	if(ended) return;

	// Check Round Limit - if is reached, half-time is runned or map-end is runned
	ended = checkMatchRoundLimit();
	if(ended) return;





	if(level.round_endtime > 0)
	{
		if (game["do_timeout"] == true)
			thread maps\mp\gametypes\_timeout::HUD_Timeout(); // show at the end of the round we are going to timeout
		else
			thread HUD_NextRound();


		wait level.fps_multiplier * level.round_endtime;
	}
	else
	{
		// Wait a sec if no warup time defined
		wait level.fps_multiplier * 3;
	}


	// for all living players store their weapons
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		/*
		Recoded weapon saving system:

		Round start  	| End of Round 	| Next round	| Case selected weapon is
		Spawned weap 	| Weapon slots 	| Spawned weap	| changed to thompson during round
		--------------------------------------------------------------------------------
		M1		| M1	-	| M1	-	| thomp	-
		M1		| -	M1	| M1	-	| thomp	-
		M1		| M1	KAR	| M1	KAR	| thomp	KAR
		M1		| KAR	M1	| KAR	M1	| thomp M1
		M1		| KAR	MP44	| KAR	MP44	| thomp	MP44
		M1		| KAR	-	| KAR	-	| thomp	-
		M1		| -	KAR	| KAR	-	| thomp	-
		M1		| M1	thomp	| M1	thomp	| thomp	-
		M1		| thomp	M1	| thomp M1	| thomp M1
		M1		| -	-	| M1	-	| thomp	-

		*/


		if(isDefined(player.pers["weapon"]) && (player.pers["team"] == "allies" || player.pers["team"] == "axis") && player.sessionstate == "playing")
		{
			weapon1 = player getWeaponSlotWeapon("primary");
			weapon2 = player getWeaponSlotWeapon("primaryb");

			// Remove pistols and limited weapons
			if (!player maps\mp\gametypes\_weapon_limiter::isWeaponSaveable(weapon1))
				weapon1 = "none";
			if (!player maps\mp\gametypes\_weapon_limiter::isWeaponSaveable(weapon2))
				weapon2 = "none";

			// Give player selected weapon if selected weapon is changed
			if (player.selectedWeaponOnRoundStart != player.pers["weapon"])
			{
				weapon1 = player.pers["weapon"];
				// In case we change to weapon, that is actually in slot, avoid duplicate
				if (weapon1 == weapon2)
					weapon2 = "none";
			}

			// Give player spawned weapon if there is no saveable weapons
			if (weapon1 == "none" && weapon2 == "none")
				weapon1 = player.pers["weapon"];

			// Swap weapons if there is weapon in secondary slot only
			if (weapon1 == "none" && weapon2 != "none")
			{
				temp = weapon1;
				weapon1 = weapon2;
				weapon2 = temp;
			}

			// Save spawned weapon
			player.pers["weapon1"] = weapon1;
			player.pers["weapon2"] = weapon2;
		}
		else
		{
			player.pers["weapon1"] = undefined;
			player.pers["weapon2"] = undefined;
		}
	}


	// Check if some spectator is in killcam
	in_killcam = level isSpectatorInKillcam();
	if (in_killcam)
	{
		// HUD
		hud = addHUD(-85, 280, 1.2, (1,1,0), "center", "middle", "right");
		hud showHUDSmooth(.5);
		hud setText(game["STRING_SPECTATOR_KILLCAM_REPLAY"]);

		// Disable players weapons
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.sessionstate == "playing")
				player disableWeapon();
		}

		for (i = 0; i < level.weaponnames.size; i++)
		{
			weapon = level.weaponnames[i];

			// Delete weapons in map
			weapons = getentarray("weapon_" + weapon, "classname");
			for(j = 0; j < weapons.size; j++)
			{
				weapons[j] delete();
			}
		}

		count = 2;
		for(;;)
		{
			wait level.fps_multiplier * 1;
			in_killcam = level isSpectatorInKillcam();

			if (!in_killcam)
				count--;
			else
				count = 2;

			if (count <= 0)
				break;
		}

		hud hideHUDSmooth(.5);

		wait level.fps_multiplier * 0.5;
	}

	// Used for balance team at the end of the round
	level notify("restarting");

	if (!level.pam_mode_change)
		map_restart(true);


}


isSpectatorInKillcam()
{
	in_killcam = false;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player.sessionstate == "spectator" && isDefined(player.killcam) && player.killcam == true)
		{
			in_killcam = true;
			break;
		}
	}

	return in_killcam;
}

checkTimeLimit()
{
	if (level.timelimit > 0 && game["timepassed"] >= level.timelimit)
	{
		iprintln(&"MP_TIME_LIMIT_REACHED");

		level thread maps\mp\gametypes\_end_of_map::Do_Map_End();

		return true; // ended
	}

	return false;
}

// Score limit (not used in cg)
checkMatchScoreLimit()
{
	// Is it a score-based Halftime?
	if(!game["is_halftime"] && level.halfscore != 0)
	{
		if(game["half_1_allies_score"] >= level.halfscore || game["half_1_axis_score"] >= level.halfscore)
		{
			level thread maps\mp\gametypes\_halftime::Do_Half_Time();
			return true;
		}
	}

	// Is it a score-based Map-End?
	if (level.scorelimit != 0)
	{
		if (game["allies_score"] >= level.scorelimit || game["axis_score"] >= level.scorelimit)
		{
			level thread maps\mp\gametypes\_end_of_map::Do_Map_End();
			return true;
		}
	}

	return false;
}

// Round limit (20)
checkMatchRoundLimit()
{
	// Is it a round-based Halftime? (in cg is 10)
	if (!game["is_halftime"] && level.halfround != 0)
	{
		if(game["roundsplayed"] >= level.halfround)
		{
			level thread maps\mp\gametypes\_halftime::Do_Half_Time();
			return true;
		}
	}

	// Is it a round-based Map-End? (20)
	if (level.matchround != 0)
	{
		if (game["roundsplayed"] >= level.matchround)
		{
			if (level.scr_overtime && game["allies_score"] == game["axis_score"])
				level thread maps\mp\gametypes\_overtime::Do_Overtime();
			else
				level thread maps\mp\gametypes\_end_of_map::Do_Map_End();

			return true;
		}
	}

	return false;
}



// Update status about players into level.exist and check of round is draw/winner/atd..
// Called when: disconnect, player killed, player spawned, spectator spawned
updateTeamStatus()
{
	wait 0;	// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute

	resettimeout();

	//PAM - Dont want a round to end during readyup
	if (level.in_readyup)
		return;

	oldvalue["allies"] = level.exist["allies"];
	oldvalue["axis"] = level.exist["axis"];
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;


	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if((player.pers["team"] == "allies" || player.pers["team"] == "axis") && player.sessionstate == "playing")
			level.exist[player.pers["team"]]++;
	}

	if(level.exist["allies"])
		level.didexist["allies"] = true;
	if(level.exist["axis"])
		level.didexist["axis"] = true;

	if(level.roundended)
		return;

	// if both allies and axis were alive and now they are both dead in the same instance
	if(oldvalue["allies"] && !level.exist["allies"] && oldvalue["axis"] && !level.exist["axis"])
	{
		if(level.bombplanted)
		{
			// if allies planted the bomb, allies win
			iprintln(&"MP_ALLIEDMISSIONACCOMPLISHED");
			level thread endRound("allies");
			return;
		}

		// if there is no bomb planted the round is a draw
		iprintln(&"MP_ROUNDDRAW");
		level thread endRound("draw");
		return;
	}

	// if allies were alive and now they are not
	if(oldvalue["allies"] && !level.exist["allies"])
	{
		// if allies planted the bomb, continue the round
		if(level.bombplanted && level.planting_team == "allies")
			return;

		thread teamWinner("allies");
		level thread playSoundOnPlayers("mp_announcer_allieselim");
		level thread endRound("axis");
		return;
	}

	// if axis were alive and now they are not
	if(oldvalue["axis"] && !level.exist["axis"])
	{
		// if axis planted the bomb, continue the round
		if(level.bombplanted && level.planting_team == "axis")
			return;

		thread teamWinner("axis");
		level thread playSoundOnPlayers("mp_announcer_axiselim");
		level thread endRound("allies");
		return;
	}
}

teamWinner(team) {
	wait level.frame;

	if (team == "axis") {
		iprintln(&"MP_AXISHAVEBEENELIMINATED");
	} else if (team == "allies") {
		iprintln(&"MP_ALLIESHAVEBEENELIMINATED");
	}
}

// Called before round starts
bombzones()
{
	maperrors = [];

	level.barsize = 192;


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
		bombzone0 = array[0];
		bombzone1 = array[1];
		bombzoneA = undefined;
		bombzoneB = undefined;

		if(bombzone0.script_label == "A" || bombzone0.script_label == "a")
		{
			bombzoneA = bombzone0;
			bombzoneB = bombzone1;
		}
		else if(bombzone0.script_label == "B" || bombzone0.script_label == "b")
		{
			bombzoneA = bombzone1;
			bombzoneB = bombzone0;
		}
		else
			maperrors[maperrors.size] = "^1Bombmode original: Bombzone found with an invalid \"script_label\", must be \"A\" or \"B\"";

		objective_add(0, "current", bombzoneA.origin, "objectiveA");
		objective_add(1, "current", bombzoneB.origin, "objectiveB");
		thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzoneA.origin, "0", "allies", "objpoint_A");
		thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzoneB.origin, "1", "allies", "objpoint_B");
		thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzoneA.origin, "0", "axis", "objpoint_A");
		thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombzoneB.origin, "1", "axis", "objpoint_B");

		bombzoneA thread bombzone_think(bombzoneB);
		bombzoneB thread bombzone_think(bombzoneA);
	}
	else if(array.size < 2)
		maperrors[maperrors.size] = "^1Bombmode original: Less than 2 bombzones found with \"script_bombmode_original\" \"1\"";
	else if(array.size > 2)
		maperrors[maperrors.size] = "^1Bombmode original: More than 2 bombzones found with \"script_bombmode_original\" \"1\"";


	bombtriggers = getentarray("bombtrigger", "targetname");
	if(bombtriggers.size < 1)
		maperrors[maperrors.size] = "^1No entities found with \"targetname\" \"bombtrigger\"";
	else if(bombtriggers.size > 1)
		maperrors[maperrors.size] = "^1More than 1 entity found with \"targetname\" \"bombtrigger\"";

	if(maperrors.size)
	{
		println("^1------------ Map Errors ------------");
		for(i = 0; i < maperrors.size; i++)
			println(maperrors[i]);
		println("^1------------------------------------");

		return;
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

// self is bombzone1 and bombzone_other is second bombzone
bombzone_think(bombzone_other)
{
	level endon("round_ended");

	// If bomplanting is not needed, hide
	if(level.in_readyup || level.in_bash)
	{
		self SetCursorHint("HINT_NONE");
		return;
	}

	self setteamfortrigger(game["attackers"]);
	self setHintString(&"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES");

	for(;;)
	{
		self waittill("trigger", player);

		// If timeout was called during strattime
		if(!level.roundstarted || level.in_timeout)
			return;

		// Another bombzone is already planting
		if(isdefined(bombzone_other) && isdefined(bombzone_other.planting))
			continue;

		team = game["attackers"]; // team wich is able to planting


		// Restrict planting in some areas
		positionOk = true;
		// 333 jump plant on carentan bomb B
		if (level.mapname == "mp_carentan" && (self.script_label == "B" || self.script_label == "b") && player.origin[2] > 0)
			positionOk = false;

		// check for having been triggered by a valid player
		if(isPlayer(player) && (player.pers["team"] == team) && player isOnGround() && positionOk)
		{
			while(player istouching(self) && isAlive(player) && player useButtonPressed())
			{
				self.planting = true;
				player.bombinteraction = true;

				// Hide "Hold F to plant explosives" for all
				player clientclaimtrigger(self);
				player clientclaimtrigger(bombzone_other);

				// Triggers that needs to be released if player disconnect in middle of planting/defusing
				player.triggerRelease1 = self;
				player.triggerRelease2 = bombzone_other;

				// Bar - black background
				if(!isdefined(player.progressbackground))
					player.progressbackground = addHUDClient(player, 0, 104, undefined, undefined, "center", "middle", "center_safearea", "center_safearea");
				player.progressbackground showHUDSmooth(0.2, 0, 0.5); // show from 0 to 0.5
				player.progressbackground setShader("black", (level.barsize + 4), 12);

				// Bar - white bar progress
				if(!isdefined(player.progressbar))
					player.progressbar = addHUDClient(player, int(level.barsize / (-2.0)), 104, undefined, undefined, "left", "middle", "center_safearea", "center_safearea");
				player.progressbar showHUDSmooth(0.2, 0, 1); // show from 0 to 1
				player.progressbar setShader("white", 0, 8);
				player.progressbar scaleOverTime(level.planttime, level.barsize, 8);


				player playsound("MP_bomb_plant");
				player linkTo(self);
				player disableWeapon();

				// Planting progress loop
				self.progresstime = 0;
				// Player ("player" variable) can disconnect here, so we need to make sure he is still defined
				while(isDefined(player) && isAlive(player) && player useButtonPressed() && (self.progresstime < level.planttime))
				{
					self.progresstime += level.frame;
					wait level.frame;
				}

				// If player disconnect during planting/defusing, end while loop
				if (!isDefined(player))
					break;

				player.bombinteraction = false;

				// Show "Hold F to plant explosives" again
				player clientreleasetrigger(self);
				player clientreleasetrigger(bombzone_other);

				player.triggerRelease1 = undefined;
				player.triggerRelease2 = undefined;

				// If "F" was holded enoguht to plant bomb
				if(self.progresstime >= level.planttime)
				{
					player.progressbackground destroy2();
					player.progressbar destroy2();
					player enableWeapon();

					if(isdefined(self.target))
					{
						exploder = getent(self.target, "targetname");

						if(isdefined(exploder) && isdefined(exploder.script_exploder))
							level.bombexploder = exploder.script_exploder;
					}

					bombzones = getentarray("bombzone", "targetname");
					for(i = 0; i < bombzones.size; i++)
						bombzones[i] delete();

					objective_delete(0);
					objective_delete(1);
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("allies");
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("axis");


					plant = player maps\mp\_utility::getPlant();

					// Spawn bomb
					level.bombmodel = spawn("script_model", plant.origin);
					level.bombmodel.angles = plant.angles;
					level.bombmodel setmodel("xmodel/mp_tntbomb");
					level.bombmodel playSound("Explo_plant_no_tick");
					level.bombglow = spawn("script_model", plant.origin);
					level.bombglow.angles = plant.angles;
					level.bombglow setmodel("xmodel/mp_tntbomb_obj");

					bombtrigger = getent("bombtrigger", "targetname");
					bombtrigger.origin = level.bombmodel.origin;

					objective_add(0, "current", bombtrigger.origin, "objective");
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("allies");
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("axis");
					thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombtrigger.origin, "bomb", "allies", "objpoint_star");
					thread maps\mp\gametypes\_objpoints::addTeamObjpoint(bombtrigger.origin, "bomb", "axis", "objpoint_star");

					level.bombplanted = true;
					level.bombtimerstart = gettime();
					level.planting_team = player.pers["team"];
					level.planting_player = player;

					lpselfnum = player getEntityNumber();
					lpselfguid = player getGuid();
					logPrint("Bomb;" + lpselfguid + ";" + lpselfnum + ";" + player.pers["team"] + ";" + player.name + ";" + "bomb_plant" + "\n");


					if (level.bomb_plant_points)
					{
						player.pers["score"] = player.pers["score"] + level.bomb_plant_points;
						player.score = player.pers["score"];
					}

					// Player's stats - increase plant points (_player_stat.gsc)
					player maps\mp\gametypes\_player_stat::AddPlant();
					player maps\mp\gametypes\_player_stat::AddScore(0.5);

					iprintln(&"MP_EXPLOSIVESPLANTED");

					level thread soundPlanted(player);

					bombtrigger thread bomb_think();
					bombtrigger thread bomb_countdown();

					level notify("bomb_planted");

					// Remove clock if bomb is planted
					if (isDefined(level.clock))
						level.clock removeHUD();

					return;	//TEMP, script should stop after the wait level.frame
				}
				else
				{
					if(isdefined(player.progressbackground))
						player.progressbackground removeHUD();

					if(isdefined(player.progressbar))
						player.progressbar removeHUD();

					player unlink();
					player enableWeapon();
				}

				wait level.frame;
			}

			self.planting = undefined;
		}
	}
}

bomb_countdown()
{
	self endon("bomb_defused");
	level endon("intermission");

	//PAM
	if (level.show_bombtimer)
		thread showBombTimers();
	level.bombmodel playLoopSound("bomb_tick");

	wait level.fps_multiplier * level.bombtimer;

	// bomb timer is up
	objective_delete(0);
	thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("allies");
	thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("axis");
	thread deleteBombTimers();

	level.bombexploded = true;
	self notify("bomb_exploded");

	// Call object explosion
	if(isdefined(level.bombexploder))
		maps\mp\_utility::exploder(level.bombexploder);


	// Bomb explosion parameters
	origin = self getorigin();
	range = 600;
	maxdamage = 250;
	mindamage = 0;

	// Delete the defuse trigger and bomb xmodel
	self delete();
	level.bombmodel stopLoopSound();
	level.bombmodel delete();
	level.bombglow delete();

	// Add flame around bomb
	playfx(level._effect["bombexplosion"], origin);

	// Do damage to players near bomb
	level.bombKill = true;
	radiusDamage(origin, range, maxdamage, mindamage);

	// Wait untill all kills are processed
	waittillframeend;
	level.bombKill = false;

	// Add earth quake around bomb
	earthquake(0.2, 2, origin, 1200);

	level thread playSoundOnPlayers("mp_announcer_objdest");
	level thread endRound(level.planting_team);
}

bomb_think()
{
	self endon("bomb_exploded");

	self setteamfortrigger(game["defenders"]);
	self setHintString(&"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES");

	for(;;)
	{
		self waittill("trigger", player);

		// check for having been triggered by a valid player
		if(isPlayer(player) && (player.pers["team"] != level.planting_team) && player isOnGround())
		{
			while(isAlive(player) && player useButtonPressed())
			{
				player.bombinteraction = true;

				// Hide "Hold F to defuse bomb" for all others
				player clientclaimtrigger(self);

				// Triggers that needs to be released if player disconnect in middle of planting/defusing
				player.triggerRelease1 = self;
				player.triggerRelease2 = undefined;

				// Bar - black background
				if(!isdefined(player.progressbackground))
					player.progressbackground = addHUDClient(player, 0, 104, undefined, undefined, "center", "middle", "center_safearea", "center_safearea");
				player.progressbackground showHUDSmooth(0.2, 0, 0.5); // show from 0 to 0.5
				player.progressbackground setShader("black", (level.barsize + 4), 12);

				// Bar - white bar progress
				if(!isdefined(player.progressbar))
					player.progressbar = addHUDClient(player, int(level.barsize / (-2.0)), 104, undefined, undefined, "left", "middle", "center_safearea", "center_safearea");
				player.progressbar showHUDSmooth(0.2, 0, 1); // show from 0 to 1
				player.progressbar setShader("white", 0, 8);
				player.progressbar scaleOverTime(level.defusetime, level.barsize, 8);


				player playsound("MP_bomb_defuse");
				player linkTo(self);
				player disableWeapon();

				// defusing progress loop
				self.progresstime = 0;
				// Player ("player" variable) can disconnect here, so we need to make sure he is still defined
				while(isDefined(player) && isAlive(player) && player useButtonPressed() && (self.progresstime < level.defusetime))
				{
					self.progresstime += level.frame;
					wait level.frame;
				}

				// If player disconnect during planting/defusing, end while loop
				if (!isDefined(player))
					break;

				player.bombinteraction = false;

				// Show "Hold F to defuse bomb" again
				player clientreleasetrigger(self);

				// Triggers that needs to be released if player disconnect in middle of planting/defusing
				player.triggerRelease1 = undefined;
				player.triggerRelease2 = undefined;

				// Bomb defused
				if(self.progresstime >= level.defusetime && isAlive(player))
				{
					player.progressbackground destroy2();
					player.progressbar destroy2();
					player enableWeapon();

					objective_delete(0);
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("allies");
					thread maps\mp\gametypes\_objpoints::removeTeamObjpoints("axis");
					thread deleteBombTimers();

					self notify("bomb_defused");
					level.bombmodel stopLoopSound();
					level.bombglow delete();
					self delete();

					iprintln(&"MP_EXPLOSIVESDEFUSED");
					level thread playSoundOnPlayers("MP_announcer_bomb_defused");

					lpselfnum = player getEntityNumber();
					lpselfguid = player getGuid();
					logPrint("Bomb;" + lpselfguid + ";" + lpselfnum + ";" + player.pers["team"] + ";" + player.name + ";" + "bomb_defuse" + "\n");

					if (level.bomb_defuse_points)
					{
						player.pers["score"] = player.pers["score"] + level.bomb_defuse_points;
						player.score = player.pers["score"];
					}

					// Player's stats - increase defuse points (_player_stat.gsc)
					player maps\mp\gametypes\_player_stat::AddDefuse();
					player maps\mp\gametypes\_player_stat::AddScore(0.5);

					level thread endRound(player.pers["team"]);

					return;	//TEMP, script should stop after the wait level.frame
				}
				else
				{
					if(isdefined(player.progressbackground))
						player.progressbackground destroy2();

					if(isdefined(player.progressbar))
						player.progressbar destroy2();

					player unlink();
					player enableWeapon();
				}

				wait level.frame;
			}

			self.defusing = undefined;
		}
	}
}


sayObjective()
{
	level endon("running_timeout");

	attacksounds["american"] = "US_mp_cmd_movein";
	attacksounds["british"] = "UK_mp_cmd_movein";
	attacksounds["russian"] = "RU_mp_cmd_movein";
	attacksounds["german"] = "GE_mp_cmd_movein";
	defendsounds["american"] = "US_mp_defendbomb";
	defendsounds["british"] = "UK_mp_defendbomb";
	defendsounds["russian"] = "RU_mp_defendbomb";
	defendsounds["german"] = "GE_mp_defendbomb";

	soundAttackers = attacksounds[game[game["attackers"]]];
	soundDefenders = defendsounds[game[game["defenders"]]];

	if (game["is_public_mode"])
	{
		wait level.fps_multiplier * 2;

		level playSoundOnPlayers(soundAttackers, game["attackers"]);
		level playSoundOnPlayers(soundDefenders, game["defenders"]);
	}
	else
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if (players[i].pers["team"] == game["attackers"])
				players[i] thread sayObjectiveIfPlayerIsNotMoving(soundAttackers);
			if (players[i].pers["team"] == game["defenders"])
				players[i] thread sayObjectiveIfPlayerIsNotMoving(soundDefenders);
		}
	}
}

sayObjectiveIfPlayerIsNotMoving(sound)
{
	self endon("disconnect");
	level endon("running_timeout");

	for (i = 0; i < 4; i++)
	{
		origin = self.origin;

		wait level.fps_multiplier * 0.5;

		// Player moved
		if (distance(self.origin, origin) > 10)
			return;
	}

	self playLocalSound(sound);
}

showBombTimers()
{
	timeleft = (level.bombtimer - (getTime() - level.bombtimerstart) / 1000);

	level.bombtimerhud = addHUD(6, 76, undefined, undefined, "left", "top", "left", "top");
	level.bombtimerhud showHUDSmooth(0.1);
	//level.bombtimerhud.foreground = true;  // visible if menu opened
	level.bombtimerhud setClock(timeleft, 60, "hudStopwatch", 48, 48);
}

deleteBombTimers()
{
	if (isDefined(level.bombtimerhud))
		level.bombtimerhud removeHUD();
}

announceWinner(winner, delay)
{
	wait level.fps_multiplier * delay;

	// Announce winner
	if(winner == "allies")
	{
		level thread playSoundOnPlayers("MP_announcer_allies_win");
	}
	else if(winner == "axis")
	{
		level thread playSoundOnPlayers("MP_announcer_axis_win");
	}
	else if(winner == "draw")
	{
		level thread playSoundOnPlayers("MP_announcer_round_draw");
	}
}

playSoundOnPlayers(sound, team)
{
	players = getentarray("player", "classname");

	if(isdefined(team))
	{
		for(i = 0; i < players.size; i++)
		{
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == team))
				players[i] playLocalSound(sound);
		}
	}
	else
	{
		for(i = 0; i < players.size; i++)
			players[i] playLocalSound(sound);
	}
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
		if(getTeamScore("allies") == getTeamScore("axis"))
		{
			teams[0] = "allies";
			teams[1] = "axis";
			assignment = teams[randomInt(2)];
		}
		else if(getTeamScore("allies") < getTeamScore("axis"))
			assignment = "allies";
		else
			assignment = "axis";
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

	self.sessionteam = assignment;
	self.statusicon = "hud_status_dead";
	self.pers["team"] = assignment;
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["savedmodel"] = undefined;

	self notify("joined", assignment);
	self notify("joined_allies_axis");

	level notify("joined", assignment, self); // used in first round to check if someone joined team
}

menuAllies()
{
	// If team is already allies or we cannot join allies (to keep team balance), open team menu again
	if(self.pers["team"] == "allies" || !maps\mp\gametypes\_teams::getJoinTeamPermissions("allies"))
	{
		//self openMenu(game["menu_team"]);
		return;
	}

	self.joining_team = "allies";
	self.leaving_team = self.pers["team"];

	if(self.sessionstate == "playing")
	{
		self.switching_teams = true;
		self suicide();
	}

	self.sessionteam = "allies";
	self.statusicon = "hud_status_dead";
	self.pers["team"] = "allies";
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["savedmodel"] = undefined;


	self notify("joined", "allies");
	self notify("joined_allies_axis");

	level notify("joined", "allies", self); // used in first round to check if someone joined team
}

menuAxis()
{
	// If team is already axis or we cannot join axis (to keep team balance), open team menu again
	if(self.pers["team"] == "axis" || !maps\mp\gametypes\_teams::getJoinTeamPermissions("axis"))
	{
		//self openMenu(game["menu_team"]);
		return;
	}

	self.joining_team = "axis";
	self.leaving_team = self.pers["team"];

	if(self.sessionstate == "playing")
	{
		self.switching_teams = true;
		self suicide();
	}

	self.sessionteam = "axis";
	self.statusicon = "hud_status_dead";
	self.pers["team"] = "axis";
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
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
	self.statusicon = "";
	self.pers["team"] = "spectator";
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
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

	primary = self getWeaponSlotWeapon("primary");
	primaryb = self getWeaponSlotWeapon("primaryb");

	// After selecting a weapon, show "ingame" menu when ESC is pressed
	self setClientCvar2("g_scriptMainMenu", game["menu_ingame"]);

	// If newly selected weapon is same as actualy selected weapon and is in player slot -> do nothing
	if(isdefined(self.pers["weapon"]))
	{
		if (self.pers["weapon"] == weapon && primary == weapon && maps\mp\gametypes\_weapons::isPistol(primaryb))
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


	// Readyup-mode
	if (level.in_readyup)
	{
		if(isDefined(self.pers["weapon"]))
		{
			self.pers["weapon"] = weapon;
			self.selectedWeaponOnRoundStart = weapon; // to determine is weapon was changed during round

			// Remove weapon from slot (can be "none", takeWeapon() will take it)
			self takeWeapon(primary);
			self takeWeapon(primaryb);

			// Give weapon to primary slot
			self setWeaponSlotWeapon("primary", weapon);
			self giveMaxAmmo(weapon);

			// Give pistol to secondary slot + give grenades and smokes
			maps\mp\gametypes\_weapons::givePistol();
			maps\mp\gametypes\_weapons::giveSmokesFor(weapon, 0);
			maps\mp\gametypes\_weapons::giveGrenadesFor(weapon, 0);

			// Switch to main weapon
			self switchToWeapon(weapon);
		}
		else
		{
			self.pers["weapon"] = weapon;

			spawnPlayer();
		}
	}

	else
	{
		/*
		| ------------------------ Strat time --------------------------| -----Round start -----|
		| On spawm	| Action 1		| Action 2		| Final			|
		|---------------|-----------------------|-----------------------|-----------------------|
		| M1 pis	| Drop pistol		| Select thompson	| Thompson -
		| M1 pis	| Take KAR, drop pis	| Select thompson	| Thompson KAR
		| M1 pis	| Take KAR, drop M1	| Select thompson	| KAR pis (new weapon after next round)
		| M1 pis	| Take KAR, drop M1	| pick M1, Select thomp	| KAR M1 (new weapon after next round)

		| M1 pis	| Drop pistol		| Select M1		| M1 -
		| M1 pis	| Take KAR, drop pis	| Select M1		| M1 pis
		| M1 pis	| Take KAR, drop M1	| Select M1		| KAR pis (new weapon after next round)
		| M1 pis	| Take KAR, drop M1	| pick M1, Select M1	| KAR M1 (new weapon after next round)

		| M1 KAR	| Drop M1		| Select M1		| - KAR (new weapon after next round)

		| KAR pis	| Drop M1		| Select M1		| M1 -

		| BAB TOM	| Select thomson	| 			| M1 -

		*/



		allowedInStrattime = false;

		if (!isDefined(self.pers["weapon"]))
			allowedInStrattime = true;
		else
		{
			if (level.in_strattime && /*self.dropped_weapons == 0 && self.taked_weapons == 0 && */self.spawnsInStrattime < 2)
			{
				// If weapon I spawned with is still in slot, allow change
				if (self.spawnedWeapon == primary)
				{
					allowedInStrattime = true;
				}
			}
		}

		// Free weapon chaging - allowed in strat-time
		if(!level.matchstarted || (level.in_strattime && allowedInStrattime))
		{
			if(isDefined(self.pers["weapon"]))
			{
				self.pers["weapon"] = weapon;
				self.selectedWeaponOnRoundStart = weapon; // to determine if weapon was changed during round

				// Remove weapon from first slot
				self takeWeapon(primary);

				// If newly selected weapon is already in secondary slot, remove it to avoid duplicate weapon!
				if (weapon == primaryb)
				{
					self takeWeapon(primaryb); // Remove weapon

					maps\mp\gametypes\_weapons::givePistol();
				}

				// If I select the same weapon that is already in slot, it means I want to remove secondary weapon to pistol
				if (weapon == primary && maps\mp\gametypes\_weapons::isMainWeapon(primaryb))
				{
					self takeWeapon(primaryb); // Remove weapon
					maps\mp\gametypes\_weapons::givePistol();
				}

				self.spawnedWeapon = weapon;

				// Set new selected weapon into first slot
				self setWeaponSlotWeapon("primary", weapon);
				self giveMaxAmmo(weapon);

				// Give empty grenade/smoke slots
				self maps\mp\gametypes\_weapons::giveSmokesFor(weapon, 0);
				self maps\mp\gametypes\_weapons::giveGrenadesFor(weapon, 0);

				// Switch to new selected weapon
				self switchToWeapon(weapon);

			}
			else
			{
				self.pers["weapon"] = weapon;

				spawnPlayer();
			}
		}

		// else if round started or player drop weapon in strattime
		else
		{
			self.pers["weapon"] = weapon;

			// If joining an empty team, spawn
			if(!level.didexist[self.pers["team"]] && !level.roundended)
			{
				spawnPlayer();
			}
			// else you will spawn with selected weapon next round
			else
			{
				weaponname = maps\mp\gametypes\_weapons::getWeaponName(self.pers["weapon"]);

				if(self.pers["team"] == "allies")
				{
					if(maps\mp\gametypes\_weapons::useAn(self.pers["weapon"]))
						self iprintln(&"MP_YOU_WILL_SPAWN_ALLIED_WITH_AN_NEXT_ROUND", weaponname);
					else
						self iprintln(&"MP_YOU_WILL_SPAWN_ALLIED_WITH_A_NEXT_ROUND", weaponname);
				}
				else if(self.pers["team"] == "axis")
				{
					if(maps\mp\gametypes\_weapons::useAn(self.pers["weapon"]))
						self iprintln(&"MP_YOU_WILL_SPAWN_AXIS_WITH_AN_NEXT_ROUND", weaponname);
					else
						self iprintln(&"MP_YOU_WILL_SPAWN_AXIS_WITH_A_NEXT_ROUND", weaponname);
				}
			}
		}
	}

	// Used in wepoan_limiter
	self notify("weapon_changed", weapon, leavedWeapon, leavedWeaponFromTeam);
}


soundPlanted(player)
{
	if(game["allies"] == "british")
		alliedsound = "UK_mp_explosivesplanted";
	else if(game["allies"] == "russian")
		alliedsound = "RU_mp_explosivesplanted";
	else
		alliedsound = "US_mp_explosivesplanted";

	axissound = "GE_mp_explosivesplanted";

	level playSoundOnPlayers(alliedsound, "allies");
	level playSoundOnPlayers(axissound, "axis");
	level playSoundOnPlayers(alliedsound, "spectator");
/*
	wait level.fps_multiplier * 1.5;

	if(level.planting_team == "allies")
	{
		if(game["allies"] == "british")
			alliedsound = "UK_mp_defendbomb";
		else if(game["allies"] == "russian")
			alliedsound = "RU_mp_defendbomb";
		else
			alliedsound = "US_mp_defendbomb";

		level playSoundOnPlayers(alliedsound, "allies");
		level playSoundOnPlayers("GE_mp_defusebomb", "axis");
	}
	else if(level.planting_team == "axis")
	{
		if(game["allies"] == "british")
			alliedsound = "UK_mp_defusebomb";
		else if(game["allies"] == "russian")
			alliedsound = "RU_mp_defusebomb";
		else
			alliedsound = "US_mp_defusebomb";

		level playSoundOnPlayers(alliedsound, "allies");
		level playSoundOnPlayers("GE_mp_defendbomb", "axis");
	}*/

}



serverInfo()
{
	waittillframeend; // wait untill all other server change functions are processed

	title = "";
	value = "";


	if (level.timelimit > 0)
	{
		title +="Total time limit:\n";
		value += plural_s(level.timelimit, "minute") + "\n";
	}


	// There is no halftime
	if (level.halfround == 0 && level.halfscore == 0)
	{

		if (level.scorelimit != 0)
		{
			title +="Score limit:\n";
			value += level.scorelimit + "\n";
		}
		else
		{
			title +="Round limit:\n";
			value += level.matchround + "\n";
		}
	}
	else
	{
		title +="Limit 1st half:\n";
		if (level.halfscore != 0)
			value += level.halfscore + " points\n";
		else
			value += level.halfround + " rounds\n";

		title +="Limit 2nd half:\n";
		if (level.scorelimit != 0)
			value += level.scorelimit + " points\n";
		else
			value += level.matchround + " rounds\n";
	}


	title += "Strat time:\n";
	value += plural_s(level.strat_time, "second") + "\n";

	title +="Plant time:\n";
	value += plural_s(level.planttime, "second") + "\n";

	title +="Defuse time:\n";
	value += plural_s(level.defusetime, "second") + "\n";

	title +="Round length:\n";
	value += plural_s(level.roundlength, "minute") + "\n";


	title +="Overtime:\n";
	if (level.scr_overtime)
		value += "Yes" + "\n";
	else
		value += "No" + "\n";


	level.serverinfo_left1 = title;
	level.serverinfo_left2 = value;
}



deadchat()
{
	for(;;)
	{
		if (!level.scr_auto_deadchat)
			return;


		if ( (level.in_readyup || level.in_timeout || level.roundended) && level.deadchat == 0)
		{
			maps\mp\gametypes\global\cvar_system::restoreCvarQuiet("g_deadChat");
			maps\mp\gametypes\global\cvar_system::setCvarQuiet("g_deadChat", 1); //setcvar("g_deadchat", 1);
		}

		// Disable dead chat
		else if (level.roundstarted && !level.roundended && level.deadchat == 1)
		{
			maps\mp\gametypes\global\cvar_system::restoreCvarQuiet("g_deadChat");
			maps\mp\gametypes\global\cvar_system::setCvarQuiet("g_deadChat", 0); //setcvar("g_deadchat", 0);
		}

		wait level.fps_multiplier * 1;
	}
}
