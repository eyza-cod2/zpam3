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
	level.streamer = ::menuStreamer;
	level.weapon = ::menuWeapon;

	level.spawnPlayer = ::spawnPlayer;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;


	// Define gametype specific cvars here
	// Default values of these variables are overwrited by rules
	// Event onCvarChanged is called on every cvar registration
	// Make sure that onCvarChanged event is added first before cvar registration
	registerCvarEx("C", "scr_ctf_timelimit", "FLOAT", 0, 0, 99999);
	registerCvarEx("C", "scr_ctf_half_score", "INT", 0, 0, 99999);
	registerCvarEx("C", "scr_ctf_end_score", "INT", 0, 0, 99999);
	registerCvarEx("C", "scr_ctf_halftime", "BOOL", 1);

	registerCvar("scr_ctf_strat_time", "FLOAT", 5, 0, 15);	// Time before round starts (sec) (0 - 10, default 5)
	registerCvar("scr_ctf_flag_autoreturn_time", "INT", 120, 0, 300);
	registerCvar("scr_ctf_respawn_time",  "INT", 10, 0, 60);




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
		case "scr_ctf_timelimit": 	level.timelimit = value; 	return true;
		case "scr_ctf_half_score": 	level.halfscore = value; 	return true;
		case "scr_ctf_end_score": 	level.scorelimit = value; 	return true;
		case "scr_ctf_halftime": 	level.halftime_enabled = value; return true;
		case "scr_ctf_strat_time": 	level.strat_time = value; return true;
		case "scr_ctf_flag_autoreturn_time": 	level.flag_auto_return = value; return true;
		case "scr_ctf_respawn_time": 	level.respawndelay = value; return true;
	}
	return false;
}



// Precache specific stuff for this gametype
// Is called only once per map
precache()
{
	precacheStatusIcon(level.hudflag_allies);
	precacheStatusIcon(level.hudflag_axis);
	precacheStatusIcon("compassping_enemyfiring");

	precacheShader(level.compassflag_allies);
	precacheShader(level.compassflag_axis);
	precacheShader(level.objpointflag_allies);
	precacheShader(level.objpointflag_axis);
	precacheShader(level.hudflag_allies);
	precacheShader(level.hudflag_axis);
	precacheShader(level.hudflagflash_allies);
	precacheShader(level.hudflagflash_axis);
	precacheShader(level.objpointflag_allies);
	precacheShader(level.objpointflag_axis);
	precacheShader(level.objpointflagmissing_allies);
	precacheShader(level.objpointflagmissing_axis);

	precacheModel("xmodel/prop_flag_" + game["allies"]);
	precacheModel("xmodel/prop_flag_" + game["axis"]);
	precacheModel("xmodel/prop_flag_" + game["allies"] + "_carry");
	precacheModel("xmodel/prop_flag_" + game["axis"] + "_carry");
	precacheModel("xmodel/prop_flag_base");
	precacheString(&"MP_TIME_TILL_SPAWN");
	precacheString(&"MP_CTF_OBJ_TEXT");
	precacheString(&"MP_ENEMY_FLAG_TAKEN");
	precacheString(&"MP_ENEMY_FLAG_CAPTURED");
	precacheString(&"MP_YOUR_FLAG_WAS_TAKEN");
	precacheString(&"MP_YOUR_FLAG_WAS_CAPTURED");
	precacheString(&"MP_YOUR_FLAG_WAS_RETURNED");
	precacheString(&"PLATFORM_PRESS_TO_SPAWN");
	// HUD: Strattime
	precacheString2("STRING_STRAT_TIME", &"Strat Time");

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

		game["allies_score"] = 0;
		game["axis_score"] = 0;
		game["half_1_allies_score"] = 0;
		game["half_1_axis_score"] = 0;
		game["half_2_allies_score"] = 0;
		game["half_2_axis_score"] = 0;

	}

	// Main scores
	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);


	// Gametype specific variables
	level.mapended = false;
	level.matchstarted = false;
	level.in_strattime = false;
	level.compassflag_allies = "compass_flag_" + game["allies"];
	level.compassflag_axis = "compass_flag_" + game["axis"];
	level.objpointflag_allies = "objpoint_flagpatch1_" + game["allies"];
	level.objpointflag_axis = "objpoint_flagpatch1_" + game["axis"];
	level.objpointflagmissing_allies = "objpoint_flagmissing_" + game["allies"];
	level.objpointflagmissing_axis = "objpoint_flagmissing_" + game["axis"];
	level.hudflag_allies = "compass_flag_" + game["allies"];
	level.hudflag_axis = "compass_flag_" + game["axis"];
	level.hudflagflash_allies = "hud_flagflash_" + game["allies"];
	level.hudflagflash_axis = "hud_flagflash_" + game["axis"];



	// Precache gametype specific stuff
	if (game["firstInit"])
		precache();





	spawnpointname = "mp_ctf_spawn_allied";
	spawnpoints = getentarray(spawnpointname, "classname");
	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();


	spawnpointname = "mp_ctf_spawn_axis";
	spawnpoints = getentarray(spawnpointname, "classname");
	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] PlaceSpawnpoint();



	allowed[0] = "ctf";
	maps\mp\gametypes\_gameobjects::main(allowed);



	minefields = [];
	minefields = getentarray("minefield", "targetname");
	trigger_hurts = [];
	trigger_hurts = getentarray("trigger_hurt", "classname");

	level.flag_returners = minefields;
	for(i = 0; i < trigger_hurts.size; i++)
		level.flag_returners[level.flag_returners.size] = trigger_hurts[i];




	setClientNameMode("auto_change");

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

	// If is players first connect, his team is undefined
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
		team = self.pers["team"];
		if (team == "streamer")
			team = "spectator";
		self.sessionteam = team;
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
	else if (self.pers["team"] == "spectator" || self.pers["team"] == "streamer")
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
	self dropFlag();

	iprintln(&"MP_DISCONNECTED", self.name);
}


onPlayerDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// In readyup there is own onPlayerDamaging function
	if (level.in_readyup)
		return false;

	// Prevent damage when:
	if (!level.matchstarted || level.in_strattime || level.mapended)
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

	self dropFlag();

	// Kill is handled in readyup functions
	if (level.in_readyup)
		return;

	// send out an obituary message to all clients about the kill
	obituary(self, attacker, sWeapon, sMeansOfDeath);

	// Weapon/Nade Drops
	if (!isDefined(self.switching_teams) && level.matchstarted && !level.mapended)
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
		}
		else
		{
			doKillcam = true;
			attackerNum = attacker getEntityNumber();

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

		self.pers["score"]--;
		self.score = self.pers["score"];
	}


	self notify("killed_player");

	level notify("log_kill", self, attacker,  sWeapon, iDamage, sMeansOfDeath, sHitLoc);

	// Wait before dead body is spawned to allow double kills (bullets may stop in this dead body)
	// Ignore this for shotgun, because it create a smoke effect on dead body (for good feeling)
	if (sWeapon != "shotgun_mp")
		waittillframeend;

	// Stop thread if map ended on this death
	if(level.mapended)
		return;

	body = undefined;
	if(!isdefined(self.switching_teams))
		body = self cloneplayer(deathAnimDuration);
	self.switching_teams = undefined;

	delay = level.fps_multiplier * 1.5;
	wait delay;

	// Handle respawn of player
	self thread respawn();

	// Do killcam - if enabled, wait here until killcam is done
	if(doKillcam && level.scr_killcam)
		self maps\mp\gametypes\_killcam::killcam(attackerNum, 4, 5, psOffsetTime, true);

	// Spawn from "dead" player session to spectator
	self.sessionstate = "spectator";
	self spawn(self.origin + (0, 0, 60), self.angles);
}

respawn()
{
	self endon("disconnect");

	if(level.respawndelay > 0)
	{
		// This thread is already running
		if(isDefined(self.respawntimer))
			return;

		self.respawntimer = newClientHudElem(self);
		self.respawntimer.x = 0;
		self.respawntimer.y = -50;
		self.respawntimer.alignX = "center";
		self.respawntimer.alignY = "middle";
		self.respawntimer.horzAlign = "center_safearea";
		self.respawntimer.vertAlign = "center_safearea";
		self.respawntimer.alpha = 1;
		self.respawntimer.archived = false;
		self.respawntimer.font = "default";
		self.respawntimer.fontscale = 2;
		self.respawntimer.label = (&"MP_TIME_TILL_SPAWN");
		self.respawntimer setTimer (level.respawndelay);


		self thread respawn_timer();
		self thread respawn_spawned();

		// Respawn is ended when time elapsed or player spawned other way
		self waittill("end_respawn");

		if(isdefined(self.respawntimer))
			self.respawntimer destroy();
	}

	if(isDefined(self.pers["weapon"]))
		self thread spawnPlayer();
}

respawn_timer()
{
	self endon("disconnect");
	self endon("spawned");

	wait level.fps_multiplier * level.respawndelay;

	while(level.in_timeout)
		wait level.fps_multiplier * 1;

	self notify("end_respawn");
}

respawn_spawned()
{
	self endon("disconnect");

	self waittill("spawned");

	self notify("end_respawn");
}


spawnPlayer()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	if (game["state"] == "intermission")
		return;

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");


	self.sessionteam = self.pers["team"];
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
		if(self.pers["team"] == "allies")
			spawnpointname = "mp_ctf_spawn_allied";
		else
			spawnpointname = "mp_ctf_spawn_axis";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(spawnpoints);

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
	self setSpawnWeapon(self.pers["weapon"]);

	if (level.in_readyup && !level.in_timeout)
	{
		maps\mp\gametypes\_weapons::giveSmokesFor(self.pers["weapon"], 0);
		maps\mp\gametypes\_weapons::giveGrenadesFor(self.pers["weapon"], 0); // grenades are handled in readyup now
	} else {
		maps\mp\gametypes\_weapons::giveSmokesFor(self.pers["weapon"]);
		maps\mp\gametypes\_weapons::giveGrenadesFor(self.pers["weapon"]);
	}
	maps\mp\gametypes\_weapons::givePistol();
	maps\mp\gametypes\_weapons::giveBinoculars();



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

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	else if(self.pers["team"] == "streamer")
		self.statusicon = "compassping_enemyfiring"; // recording icon
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

	// Notify "spawned" notifications
	self notify("spawned");

	// If is real spectator (is in team spectator, not session state spectator)
	if (self.pers["team"] == "spectator")
	{
		self notify("spawned_spectator");
	}
	else if (self.pers["team"] == "streamer")
	{
		self notify("spawned_streamer");
	}

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
	thread initFlags();

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

		// End strattime when time expires or timeout is called
		level thread strattime_end_timer(level.strat_time);
		level thread strattime_end_ontimeout();

		level waittill("strat_time_end");

		// Out of strat time
		level.in_strattime = false;
	}

	// Hide pam info hud
	if (!level.in_timeout)
		thread maps\mp\gametypes\_pam::PAM_Header_Delete();

	level.matchstarted = true;
	level.starttime = getTime();

	if(level.timelimit > 0)
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
		level.clock setTimer(level.timelimit * 60);

		// If strattime is enabled, show fade-in animation
		if (level.strat_time > 0 && !level.in_timeout)
		{
			level.clock.alpha = 0;

			level.clock FadeOverTime(0.5);
			level.clock.alpha = 1;

			level.clock.x = 40;
			level.clock moveovertime(0.5);
			level.clock.x = 0;
		}

		time_before_timeout = 0;
		for(;;)
		{
			// CheckTimeLimit
			timepassed = (getTime() - level.starttime) / 1000;	// elapsed time in seconds
			timepassed = timepassed - level.timeout_elapsedTime;	// exclude time of timeout

			//iprintln(timepassed);

			// Freeze time if in timeout
			if (level.in_timeout)
			{
				if (time_before_timeout == 0)
					time_before_timeout = level.timelimit * 60 - timepassed;

				level.clock setTimer(int(time_before_timeout) + 0.9);
				level.clock.color = (1, 0.6, 0.15);	// Orange
			}
			else if (time_before_timeout != 0)
			{
				time_before_timeout = 0;
				level.clock.color = (1, 1, 1);
			}

			// Time elapsed
			if (!level.in_timeout && timepassed >= level.timelimit * 60)
			{
				if(level.mapended) return;
				level.mapended = true;

				iprintln(&"MP_TIME_LIMIT_REACHED");

				if (level.halftime_enabled && !game["is_halftime"])
				{
					thread maps\mp\gametypes\_halftime::Do_Half_Time();
				}
				else
				{
					level thread endMap();
				}
			}


			wait level.fps_multiplier * .5;
		}
	}
}

stratTime_g_speed()
{
	// Disable players movement
	maps\mp\gametypes\global\cvar_system::setCvarQuiet("g_speed", 0);

	level waittill("strat_time_end");

	if (!level.in_timeout)
		maps\mp\gametypes\global\cvar_system::restoreCvarQuiet("g_speed");
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




checkScoreLimit()
{
	waittillframeend;
	if(level.mapended) return;

	// Is it a score-based Halftime?
	if(!game["is_halftime"] && level.halfscore != 0)
	{
		if(game["half_1_allies_score"] >= level.halfscore || game["half_1_axis_score"] >= level.halfscore)
		{
			level.mapended = true;
			level thread maps\mp\gametypes\_halftime::Do_Half_Time();
			return true;
		}
	}


	/* Match Score Check */
	if (level.scorelimit > 0)
	{
		if(game["allies_score"] < level.scorelimit && game["axis_score"] < level.scorelimit)
			return;

		iprintln(&"MP_SCORE_LIMIT_REACHED");

		level.mapended = true;
		thread endMap();
	}
}



endMap()
{
	alliedscore = getTeamScore("allies");
	axisscore = getTeamScore("axis");

	if(alliedscore == axisscore)
	{
		winningteam = "tie";
		losingteam = "tie";
		text = "MP_THE_GAME_IS_A_TIE";
	}
	else if(alliedscore > axisscore)
	{
		winningteam = "allies";
		losingteam = "axis";
		text = &"MP_ALLIES_WIN";
	}
	else
	{
		winningteam = "axis";
		losingteam = "allies";
		text = &"MP_AXIS_WIN";
	}

	winners = "";
	losers = "";

	if(winningteam == "allies")
		level thread playSoundOnPlayers("MP_announcer_allies_win");
	else if(winningteam == "axis")
		level thread playSoundOnPlayers("MP_announcer_axis_win");
	else
		level thread playSoundOnPlayers("MP_announcer_round_draw");

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player closeMenu();
		player closeInGameMenu();
		player setClientCvar2("cg_objectiveText", text);
	}


	level thread maps\mp\gametypes\_end_of_map::Do_Map_End();
}







initFlags()
{
	maperrors = [];

	allied_flags = getentarray("allied_flag", "targetname");
	if(allied_flags.size < 1)
		maperrors[maperrors.size] = "^1No entities found with \"targetname\" \"allied_flag\"";
	else if(allied_flags.size > 1)
		maperrors[maperrors.size] = "^1More than 1 entity found with \"targetname\" \"allied_flag\"";

	axis_flags = getentarray("axis_flag", "targetname");
	if(axis_flags.size < 1)
		maperrors[maperrors.size] = "^1No entities found with \"targetname\" \"axis_flag\"";
	else if(axis_flags.size > 1)
		maperrors[maperrors.size] = "^1More than 1 entity found with \"targetname\" \"axis_flag\"";

	if(maperrors.size)
	{
		println("^1------------ Map Errors ------------");
		for(i = 0; i < maperrors.size; i++)
			println(maperrors[i]);
		println("^1------------------------------------");

		return;
	}

	allied_flag = getent("allied_flag", "targetname");
	allied_flag.home_origin = allied_flag.origin;
	allied_flag.home_angles = allied_flag.angles;
	allied_flag.flagmodel = spawn("script_model", allied_flag.home_origin);
	allied_flag.flagmodel.angles = allied_flag.home_angles;
	allied_flag.flagmodel setmodel("xmodel/prop_flag_" + game["allies"]);
	allied_flag.basemodel = spawn("script_model", allied_flag.home_origin);
	allied_flag.basemodel.angles = allied_flag.home_angles;
	allied_flag.basemodel setmodel("xmodel/prop_flag_base");
	allied_flag.team = "allies";
	allied_flag.atbase = true;
	allied_flag.objective = 0;
	allied_flag.compassflag = level.compassflag_allies;
	allied_flag.objpointflag = level.objpointflag_allies;
	allied_flag.objpointflagmissing = level.objpointflagmissing_allies;
	allied_flag thread flag();

	axis_flag = getent("axis_flag", "targetname");
	axis_flag.home_origin = axis_flag.origin;
	axis_flag.home_angles = axis_flag.angles;
	axis_flag.flagmodel = spawn("script_model", axis_flag.home_origin);
	axis_flag.flagmodel.angles = axis_flag.home_angles;
	axis_flag.flagmodel setmodel("xmodel/prop_flag_" + game["axis"]);
	axis_flag.basemodel = spawn("script_model", axis_flag.home_origin);
	axis_flag.basemodel.angles = axis_flag.home_angles;
	axis_flag.basemodel setmodel("xmodel/prop_flag_base");
	axis_flag.team = "axis";
	axis_flag.atbase = true;
	axis_flag.objective = 1;
	axis_flag.compassflag = level.compassflag_axis;
	axis_flag.objpointflag = level.objpointflag_axis;
	axis_flag.objpointflagmissing = level.objpointflagmissing_axis;
	axis_flag thread flag();
}

flag()
{
	if (!isDefined(self.objective))
		println("self.objective not defined");
	if (!isDefined(self.origin))
		println("self.origin not defined");
	if (!isDefined(self.compassflag))
		println("self.compassflag not defined");

	objective_add(self.objective, "current", self.origin, self.compassflag);


	//PAM
	self.status = "home";

	for(;;)
	{
		self waittill("trigger", other);

		//PAM
		if (level.mapended)
		{
			wait level.fps_multiplier * 1;
			continue;
		}

		while(level.in_readyup)
		{
			wait level.fps_multiplier * 1;
		}

		if(isPlayer(other) && isAlive(other) && (other.pers["team"] == "allies" || other.pers["team"] == "axis"))
		{
			if(other.pers["team"] == self.team) // Touched by team
			{
				if(self.atbase)
				{
					if(isdefined(other.flag)) // Captured flag
					{
						println("CAPTURED THE FLAG!");

						friendlyAlias = "ctf_touchcapture";
						enemyAlias = "ctf_enemy_touchcapture";



						if(self.team == "axis")
						{
							enemy = "allies";
							// ePAM
							level.rogueflag["axis"] = false;
						}
						else
						{
							enemy = "axis";
							// ePAM
							level.rogueflag["allies"] = false;
						}

						thread playSoundOnPlayers(friendlyAlias, self.team);
						thread playSoundOnPlayers(enemyAlias, enemy);

						//PAM
						other.pers["score"] += 10;
						other.score = other.pers["score"];

						//thread printOnTeam(&"MP_ENEMY_FLAG_CAPTURED", self.team);
						//thread printOnTeam(&"MP_YOUR_FLAG_WAS_CAPTURED", enemy);
						other thread printOnTeam(" ^3has ^2captured ^3the enemy flag!", self.team);
						other thread printOnTeam(" ^3has ^1captured ^3your flag!", enemy);
						other.statusicon = "";

						other.flag returnFlag();
						other detachFlag(other.flag);
						other.flag = undefined;


						if (other.pers["team"] == "allies")
						{
							if (game["is_halftime"])
								game["half_2_allies_score"]++;
							else
								game["half_1_allies_score"]++;

							game["allies_score"]++;
						}
						else
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

						// Update score
						level maps\mp\gametypes\_hud_teamscore::updateScore();

						checkScoreLimit();
					}
				}
				else // Returned flag
				{
					println("RETURNED THE FLAG!");
					thread playSoundOnPlayers("ctf_touchown", self.team);

					//PAM
					if(self.team == "axis")
					{
						enemy = "allies";
						// ePAM
						level.rogueflag["axis"] = false;
					}
					else
					{
						enemy = "axis";
						// ePAM
						level.rogueflag["allies"] = false;
					}

					other.pers["score"] += 2;
					other.score = other.pers["score"];


					other thread printOnTeam(" ^3has ^2returned ^3your flag!", self.team);
					other thread printOnTeam(" ^3has ^1returned ^3the enemy flag!", enemy);

					self returnFlag();

					// Update score
					level maps\mp\gametypes\_hud_teamscore::updateScore();
				}
			}
			else if(other.pers["team"] != self.team) // Touched by enemy
			{
				println("PICKED UP THE FLAG!");

				friendlyAlias = "ctf_touchenemy";
				enemyAlias = "ctf_enemy_touchenemy";

				if(self.team == "axis")
				{
					enemy = "allies";
					// ePAM
					level.rogueflag["axis"] = false;
				}
				else
				{
					enemy = "axis";
					// ePAM
					level.rogueflag["allies"] = false;
				}

				thread playSoundOnPlayers(friendlyAlias, self.team);
				thread playSoundOnPlayers(enemyAlias, enemy);

				other thread printOnTeam(" ^3has ^1taken ^3your flag!", self.team);
				other thread printOnTeam(" ^3has ^2taken ^3the enemy flag!", enemy);

				other pickupFlag(self); // Stolen flag
			}
		}
		wait level.frame;
	}
}

pickupFlag(flag)
{
	flag notify("end_autoreturn");

	//PAM
	flag notify("End_Roaming_Flag");

	// ePAM
	if (self.pers["team"] == "axis")
		level.rogueflag["allies"] = false;
	else
		level.rogueflag["axis"] = false;
	//

	flag.origin = flag.origin + (0, 0, -10000);
	flag.flagmodel hide();
	self.flag = flag;
	self.dont_auto_balance = true;

	objective_onEntity(self.flag.objective, self);
	objective_team(self.flag.objective, self.pers["team"]);

	//PAM
	flag.status = "stolen";
	if (self.pers["team"] == "axis")
		team = game["allies"];
	else
		team = "german";
	self.statusicon = "compass_flag_" + team;
	//

	self attachFlag();
}

dropFlag()
{
	if(isdefined(self.flag))
	{
		//PAM
		self.flag notify("End_Roaming_Flag");
		self.flag.status = "dropped";

		// ePAM
		if (self.pers["team"] == "axis")
			level.rogueflag["allies"] = true;
		else
			level.rogueflag["axis"] = true;
		//

		start = self.origin + (0, 0, 10);
		end = start + (0, 0, -2000);
		trace = bulletTrace(start, end, false, undefined);

		self.flag.origin = trace["position"];
		self.flag.flagmodel.origin = self.flag.origin;
		self.flag.flagmodel show();
		self.flag.atbase = false;

		// set compass flag position on player
		objective_position(self.flag.objective, self.flag.origin);
		objective_team(self.flag.objective, "none");

		level.flagtime = undefined;
		self.flag thread autoReturn();
		self detachFlag(self.flag);

		//check if it's in a flag_returner
		for(i = 0; i < level.flag_returners.size; i++)
		{
			if(self.flag.flagmodel istouching(level.flag_returners[i]))
			{
				self.flag returnFlag();
				break;
			}
		}

		self.flag = undefined;
		self.dont_auto_balance = undefined;
	}
}

returnFlag()
{
	self notify("end_autoreturn");

	//PAM
	self notify("End_Roaming_Flag");
	self.status = "home";

	// ePAM
	if (self.team == "axis")
		level.rogueflag["allies"] = false;
	else
		level.rogueflag["axis"] = false;
	//

 	self.origin = self.home_origin;
 	self.flagmodel.origin = self.home_origin;
 	self.flagmodel.angles = self.home_angles;
	self.flagmodel show();
	self.atbase = true;

	// set compass flag position on player
	objective_position(self.objective, self.origin);
	objective_team(self.objective, "none");
}



autoReturn()
{
	self endon("end_autoreturn");
	self endon("timeoutflag");
	if (isDefined(level.flagtime) && level.flagtime < level.flag_auto_return)
	{
		level.flag_auto_return = level.flagtime;
	}
	level.flagtime = undefined;
	if (level.flag_auto_return < 0)
		return;
	self thread monitorTO();
	self thread flagTime();
	wait level.fps_multiplier * level.flag_auto_return;
	self thread returnFlag();
}

monitorTO()
{
	self endon("end_autoreturn");
	level endon("timeoutover");
	while(!level.in_timeout)
		wait level.fps_multiplier * 1;
	self notify("timeoutflag");
}

flagTime()
{
	self endon("end_autoreturn");

	if (level.flag_auto_return == 0)
		return;

	level.flagtime = level.flag_auto_return;
	start = getTime();

	while (!level.in_timeout)
	{
		passed = (getTime() - start) / 1000;
		level.flagtime = level.flag_auto_return - passed;
		wait level.fps_multiplier * 1;
	}
}

attachFlag()
{
	if(isdefined(self.flagAttached))
		return;

	if(self.pers["team"] == "allies")
		flagModel = "xmodel/prop_flag_" + game["axis"] + "_carry";
	else
		flagModel = "xmodel/prop_flag_" + game["allies"] + "_carry";

	self attach(flagModel, "J_Spine4", true);
	self.flagAttached = true;

	self thread createHudIcon();
}

detachFlag(flag)
{
	if(!isdefined(self.flagAttached))
		return;

	if(flag.team == "allies")
		flagModel = "xmodel/prop_flag_" + game["allies"] + "_carry";
	else
		flagModel = "xmodel/prop_flag_" + game["axis"] + "_carry";

	self detach(flagModel, "J_Spine4");
	self.flagAttached = undefined;

	self thread deleteHudIcon();
}

createHudIcon()
{
	iconSize = 40;

	self.hud_flag = newClientHudElem(self);
	self.hud_flag.x = 30;
	self.hud_flag.y = 95;
	self.hud_flag.alignX = "center";
	self.hud_flag.alignY = "middle";
	self.hud_flag.horzAlign = "left";
	self.hud_flag.vertAlign = "top";
	self.hud_flag.alpha = 0;

	self.hud_flagflash = newClientHudElem(self);
	self.hud_flagflash.x = 30;
	self.hud_flagflash.y = 95;
	self.hud_flagflash.alignX = "center";
	self.hud_flagflash.alignY = "middle";
	self.hud_flagflash.horzAlign = "left";
	self.hud_flagflash.vertAlign = "top";
	self.hud_flagflash.alpha = 0;
	self.hud_flagflash.sort = 1;

	if(self.pers["team"] == "allies")
	{
		self.hud_flag setShader(level.hudflag_axis, iconSize, iconSize);
		self.hud_flagflash setShader(level.hudflagflash_axis, iconSize, iconSize);
	}
	else
	{
		assert(self.pers["team"] == "axis");
		self.hud_flag setShader(level.hudflag_allies, iconSize, iconSize);
		self.hud_flagflash setShader(level.hudflagflash_allies, iconSize, iconSize);
	}

	self.hud_flagflash fadeOverTime(.2);
	self.hud_flagflash.alpha = 1;

	self.hud_flag fadeOverTime(.2);
	self.hud_flag.alpha = 1;

	wait level.fps_multiplier * .2;

	if(isdefined(self.hud_flagflash))
	{
		self.hud_flagflash fadeOverTime(1);
		self.hud_flagflash.alpha = 0;
	}
}

deleteHudIcon()
{
	if(isdefined(self.hud_flagflash))
		self.hud_flagflash destroy();

	if(isdefined(self.hud_flag))
		self.hud_flag destroy();
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

printOnTeam(text, team)
{
	//PAM
	text = self.name + text;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == team))
			players[i] iprintln(text);
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

		if(player.pers["team"] != "allies" && player.pers["team"] != "axis")
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

	self.sessionteam = assignment;
	self.statusicon = "hud_status_dead";
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

	self.sessionteam = "allies";
	self.statusicon = "hud_status_dead";
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

	self.sessionteam = "axis";
	self.statusicon = "hud_status_dead";
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
	self.statusicon = "";
	self.pers["team"] = "spectator";
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;

	spawnSpectator();

	self notify("joined", "spectator");
	self notify("joined_spectators");

	level notify("joined", "spectator", self); // used in first round to check if someone joined team
}

menuStreamer()
{
	if(self.pers["team"] == "streamer")
		return;

	self.joining_team = "streamer";
	self.leaving_team = self.pers["team"];

	if(isAlive(self))
	{
		self.switching_teams = true;
		self suicide();
	}

	self.sessionteam = "spectator";
	self.statusicon = "";
	self.pers["team"] = "streamer";
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;

	spawnSpectator();

	self notify("joined", "streamer");
	self notify("joined_streamers");

	level notify("joined", "streamer", self); // used in first round to check if someone joined team
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

	// Readyup-mode
	if (level.in_readyup && !level.in_timeout)
	{
		if(isDefined(self.pers["weapon"]))
		{
			self.pers["weapon"] = weapon;

			// Remove weapon from slot (can be "none", takeWeapon() will take it)
			self takeWeapon(self getWeaponSlotWeapon("primary"));
			self takeWeapon(self getWeaponSlotWeapon("primaryb"));

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
	}


	// Used in wepoan_limiter
	self notify("weapon_changed", weapon, leavedWeapon, leavedWeaponFromTeam);
}




serverInfo()
{
	waittillframeend; // wait untill all other server change functions are processed

	title = "";
	value = "";


	if (level.timelimit > 0)
	{
		if (!level.halftime_enabled)	title +="Time limit:\n";
		else				title +="Time limit per half:\n";
		value += plural_s(level.timelimit, "minute") + "\n";
	}
	else
	{
		title +="Time limit\n";
		value += "-" + "\n";
	}


	// There is no halftime
	if (!level.halftime_enabled)
	{
		title +="Score limit:\n";
		if (level.scorelimit != 0)	value += level.scorelimit + " points\n";
		else				value += "-" + "\n";
	}
	else
	{
		title +="Score limit 1st half:\n";
		if (level.halfscore != 0) 	value += level.halfscore + " points\n";
		else				value += "-" + "\n";

		title +="Score limit 2nd half:\n";
		if (level.scorelimit != 0)	value += level.scorelimit + " points\n";
		else				value += "-" + "\n";
	}


	title += "Strat time:\n";
	value += plural_s(level.strat_time, "second") + "\n";

	title +="Respawn delay:\n";
	value += plural_s(level.respawndelay, "second") + "\n";

	title +="Flag auto return:\n";
	value += plural_s(level.flag_auto_return, "second") + "\n";


	level.serverinfo_left1 = title;
	level.serverinfo_left2 = value;
}
