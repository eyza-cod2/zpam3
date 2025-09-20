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
	registerCvarEx("C", "scr_tdm_timelimit", "FLOAT", 0, 0, 99999);
	registerCvarEx("C", "scr_tdm_half_score", "INT", 0, 0, 99999);
	registerCvarEx("C", "scr_tdm_end_score", "INT", 0, 0, 99999);
	registerCvarEx("C", "scr_tdm_halftime", "BOOL", 1);
	registerCvar("scr_tdm_strat_time", "FLOAT", 5, 0, 15);	// Time before round starts (sec) (0 - 10, default 5)


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
		case "scr_tdm_timelimit": level.timelimit = value; return true;
		case "scr_tdm_half_score": level.halfscorelimit = value; return true;
		case "scr_tdm_end_score": level.scorelimit = value; return true;
		case "scr_tdm_halftime": level.halftime_enabled = value; return true;
		case "scr_tdm_strat_time": 	level.strat_time = value; return true;
	}
	return false;
}


// Precache specific stuff for this gametype
// Is called only once per map
precache()
{
	precacheStatusIcon("compassping_enemyfiring"); // for streamers

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


		game["allies_score"] = 0;
		game["axis_score"] = 0;

		// Half-separed scoresg
		game["half_1_allies_score"] = 0;
		game["half_1_axis_score"] = 0;
		game["half_2_allies_score"] = 0;
		game["half_2_axis_score"] = 0;

		// Other variables
		game["state"] = "playing";

	}

	// Main scores
	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);

	// Gametype specific variables
	level.mapended = false;
	level.matchstarted = false;
	level.in_strattime = false;


	// Precache gametype specific stuff
	if (game["firstInit"])
		precache();


	// Spawn points
	spawnpointname = "mp_tdm_spawn";
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

firstTime will be qtrue the very first time a client connects
to the server machine, but qfalse on map changes and tournement
restarts.
================*/
onConnecting(firstTime)
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

			if(self.pers["team"] == attacker.pers["team"]) // killed by a friendly
			{
				attacker.pers["score"]--;
				attacker.score = attacker.pers["score"];
			}
			else
			{
				attacker.pers["score"]++;
				attacker.score = attacker.pers["score"];

				attacker TDM_Team_Scoring(1);

				checkScoreLimit();
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

	body = undefined;
	if(!isdefined(self.switching_teams))
		body = self cloneplayer(deathAnimDuration);
	self.switching_teams = undefined;

	delay = level.fps_multiplier * 1.5;
	wait delay;

	//if(isDefined(body))
	//	body delete();

	if(doKillcam && level.scr_killcam)
		self maps\mp\gametypes\_killcam::killcam(attackerNum, 7, 8, psOffsetTime, true);

	if(isDefined(self.pers["weapon"]))
		self thread spawnPlayer();
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
		spawnpointname = "mp_tdm_spawn";
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

	if (game["state"] == "intermission")
		return;

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

	else if(self.pers["team"] == "streamer")
	{
		// Spawn is handled in streamer system
	}
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



TDM_Team_Scoring(score)
{
	if (self.pers["team"] == "allies")
	{
		if (game["is_halftime"])
			game["half_2_allies_score"] += score;
		else
			game["half_1_allies_score"] += score;

		game["allies_score"] += score;
	}
	else if (self.pers["team"] == "axis")
	{
		if (game["is_halftime"])
			game["half_2_axis_score"] += score;
		else
			game["half_1_axis_score"] += score;

		game["axis_score"]++;
	}

	// Set Score
	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);

	// Update score
	level maps\mp\gametypes\_hud_teamscore::updateScore();
}





checkScoreLimit()
{
	waittillframeend;
	if(level.mapended) return;


	/* Is it a score-based Halftime? */
	if(level.halftime_enabled && !game["is_halftime"] && level.halfscorelimit > 0)
	{
		if(game["half_1_allies_score"] >= level.halfscorelimit || game["half_1_axis_score"] >= level.halfscorelimit)
		{
			level.mapended = true;
			thread maps\mp\gametypes\_halftime::Do_Half_Time();
			return;
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
	level thread maps\mp\gametypes\_end_of_map::Do_Map_End();

	alliedscore = getTeamScore("allies");
	axisscore = getTeamScore("axis");

	if(alliedscore == axisscore)
	{
		level thread playSoundOnPlayers("MP_announcer_round_draw");
	}
	else if(alliedscore > axisscore)
	{
		level thread playSoundOnPlayers("MP_announcer_allies_win");
	}
	else
	{
		level thread playSoundOnPlayers("MP_announcer_axis_win");
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
	if(!self maps\mp\gametypes\_weapon_limiter::isWeaponAvailable(response))
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
		if (level.halfscorelimit != 0) 	value += level.halfscorelimit + " points\n";
		else				value += "-" + "\n";

		title +="Score limit 2nd half:\n";
		if (level.scorelimit != 0)	value += level.scorelimit + " points\n";
		else				value += "-" + "\n";
	}


	title += "Strat time:\n";
	value += plural_s(level.strat_time, "second") + "\n";


	level.serverinfo_left1 = title;
	level.serverinfo_left2 = value;
}
