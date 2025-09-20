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
	registerCvarEx("C", "scr_hq_timelimit", "FLOAT", 0, 0, 99999);
	registerCvarEx("C", "scr_hq_half_score", "INT", 0, 0, 99999);
	registerCvarEx("C", "scr_hq_end_score", "INT", 0, 0, 99999);
	registerCvarEx("C", "scr_hq_halftime", "BOOL", 1);

	registerCvar("scr_hq_strat_time", "FLOAT", 5, 0, 15);	// Time before round starts (sec) (0 - 10, default 5)
	registerCvar("scr_hq_respawn_time",  "INT", 10, 0, 60);

	registerCvar("scr_hq_radio_radius", "INT", 120, 0, 300);
	registerCvar("scr_hq_neutralizing_points", "INT", 10, 0, 300);

	registerCvar("scr_hq_radio_respawn_time", "INT", 15, 0, 300);
	registerCvar("scr_hq_radio_hold_time", "INT", 120, 0, 300);
	registerCvar("scr_hq_restricted_smoke", "BOOL", 0);
	registerCvar("scr_hq_radio_by_enemy", "BOOL", 1);


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
		case "scr_hq_timelimit": 	level.timelimit = value; 	return true;
		case "scr_hq_half_score": 	level.halfscore = value; 	return true;
		case "scr_hq_end_score": 	level.scorelimit = value; 	return true;
		case "scr_hq_halftime": 	level.halftime_enabled = value; return true;

		case "scr_hq_strat_time": 		level.strat_time = value; return true;
		case "scr_hq_respawn_time": 	level.respawndelay = value; return true;

		case "scr_hq_radio_radius": 		level.radioradius = value; return true;
		case "scr_hq_neutralizing_points": 	level.neutralizingpoints = value; return true;
		case "scr_hq_radio_respawn_time": 	level.radiospawndelay = value; return true;
		case "scr_hq_radio_hold_time": 		level.radiomaxholdseconds = value; return true;
		case "scr_hq_restricted_smoke": 	level.restricted_smoke = value; return true;
        case "scr_hq_radio_by_enemy": 		level.radio_establishing_enemy = value; return true;

	}
	return false;
}



// Precache specific stuff for this gametype
// Is called only once per map
precache()
{
	//custom radio colors for different nationalities
	if(game["allies"] == "american")
		game["radio_model"] = "xmodel/military_german_fieldradio_green_nonsolid";
	else if(game["allies"] == "british")
		game["radio_model"] = "xmodel/military_german_fieldradio_tan_nonsolid";
	else if(game["allies"] == "russian")
		game["radio_model"] = "xmodel/military_german_fieldradio_grey_nonsolid";

	// radio objective
	if(game["allies"] == "american")
		game["radio_model_obj"] = "xmodel/military_german_fieldradio_green_obj";
	else if(game["allies"] == "british")
		game["radio_model_obj"] = "xmodel/military_german_fieldradio_tan_obj";
	else if(game["allies"] == "russian")
		game["radio_model_obj"] = "xmodel/military_german_fieldradio_grey_obj";

	assert(isdefined(game["radio_model"]));
	assert(isdefined(game["radio_model_obj"]));


    game["RADIO_ESTABLISHING_ALLIES"] = &"HQ_RADIO_ESTABLISHING_ALLIES";
    game["RADIO_ESTABLISHING_AXIS"] = &"HQ_RADIO_ESTABLISHING_AXIS";
    game["RADIO_RESET_NO_DEFENDERS"] = &"HQ_RADIO_RESET_NO_DEFENDERS";


	precacheShader("white");
	precacheShader("objective");
	precacheShader("objectiveA");
	precacheShader("objectiveB");
	precacheShader("objective");
	precacheShader("objpoint_A");
	precacheShader("objpoint_B");
	precacheShader("objpoint_radio");
	precacheShader("field_radio");
	precacheShader(game["radio_allies"]);
	precacheShader(game["radio_axis"]);
	precacheRumble("damage_heavy");
	precacheModel(game["radio_model"]);
	precacheModel(game["radio_model_obj"]);
	precacheString(&"MP_TIME_TILL_SPAWN");
	precacheString(&"MP_ESTABLISHING_HQ");
	precacheString(&"MP_DESTROYING_HQ");
	precacheString(&"MP_LOSING_HQ");
	precacheString(&"MP_MAXHOLDTIME_MINUTESANDSECONDS");
	precacheString(&"MP_MAXHOLDTIME_MINUTES");
	precacheString(&"MP_MAXHOLDTIME_SECONDS");
	precacheString(&"MP_UPTEAM");
	precacheString(&"MP_DOWNTEAM");
	precacheString(&"MP_RESPAWN_WHEN_RADIO_NEUTRALIZED");
	precacheString(&"MP_MATCHSTARTING");
	precacheString(&"MP_MATCHRESUMING");

	precacheString(game["RADIO_ESTABLISHING_ALLIES"]);
	precacheString(game["RADIO_ESTABLISHING_AXIS"]);

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
	level.zradioradius = 72; // Z Distance players must be from a radio to capture/neutralize it
	level.captured_radios["allies"] = 0;
	level.captured_radios["axis"] = 0;
	level.timesCaptured = 0;
	level.nextradio = 0;
	level.spawnframe = 0;
	level.DefendingRadioTeam = "none";
	level.progressBarHeight = 12;
	level.progressBarWidth = 192;
	level.allies_give_smoke = false;
	level.axis_give_smoke = false;

	game["radio_prespawn"][0] = "objectiveA";
	game["radio_prespawn"][1] = "objectiveB";
	game["radio_prespawn"][2] = "objective";
	game["radio_prespawn_objpoint"][0] = "objpoint_A";
	game["radio_prespawn_objpoint"][1] = "objpoint_B";
	game["radio_prespawn_objpoint"][2] = "objpoint_star";
	game["radio_none"] = "objective";
	game["radio_axis"] = "objective_" + game["axis"];
	game["radio_allies"] = "objective_" + game["allies"];


	// Precache gametype specific stuff
	if (game["firstInit"])
		precache();

	spawnpointname = "mp_tdm_spawn";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	level._effect["radioexplosion"] = loadfx("fx/explosions/grenadeExp_blacktop.efx");


	allowed[0] = "tdm";
	maps\mp\gametypes\_gameobjects::main(allowed);


	thread serverInfo();

	setClientNameMode("auto_change");

	waitForPlayers = game["firstInit"];




	// Wait untill map.gsc script file is loaded and level.radio definitions are set
	wait level.frame;

	maperrors = [];

	// level.radio is defined in map.gsc script file
	if(!isdefined(level.radio))
		level.radio = getentarray("hqradio", "targetname");

	if(!isdefined(level.radio_obj))
	{
		level.radio_obj = spawn("script_model", (0,0,0));
		level.radio_obj notsolid();
	}

	if(level.radio.size < 3)
		maperrors[maperrors.size] = "^1Less than 3 entities found with \"targetname\" \"hqradio\"";

	if(maperrors.size)
	{
		println("^1------------ Map Errors ------------");
		for(i = 0; i < maperrors.size; i++)
			println(maperrors[i]);
		println("^1------------------------------------");

		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	hq_init_radios();
	hq_randomize_radioarray();



	// Wait here untill there is atleast one player connected
	if (waitForPlayers)
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
	if (!level.matchstarted || level.in_strattime || level.mapended)
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

	level hq_removeall_hudelems(self);

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
	self.dead_origin = self.origin;
	self.dead_angles = self.angles;

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

	defendingBeforeDeath = true;
	if((isdefined(self.pers["team"])) && (level.DefendingRadioTeam != self.pers["team"]))
		defendingBeforeDeath = false;

	defendingAfterDeath = false;
	if((isdefined(self.pers["team"])) && (level.DefendingRadioTeam == self.pers["team"]))
		defendingAfterDeath = true;

	allowInstantRespawn = false;
	if((!defendingBeforeDeath) && (defendingAfterDeath))
		allowInstantRespawn = true;

	//check if it was the last person to die on the defending team
	level updateTeamStatus();
	if((isdefined(self.pers["team"])) && (level.DefendingRadioTeam == self.pers["team"]) && (level.exist[self.pers["team"]] <= 0))
	{
		allowInstantRespawn = true;
		for(i = 0; i < level.radio.size; i++)
		{
			if(level.radio[i].hidden == true)
				continue;
			level hq_radio_capture(level.radio[i], "none");
			break;
		}
	}

	delay = level.fps_multiplier * 1.5;

	if((level.matchstarted) && (!allowInstantRespawn))
	{
		self thread respawn_timer(delay);
		self thread respawn_staydead(delay);
	}

	wait delay;

	// Handle respawn of player
	self thread respawn();

	// Do killcam - if enabled, wait here until killcam is done
	if(doKillcam && level.scr_killcam)
		self maps\mp\gametypes\_killcam::killcam(attackerNum, 4, 5, psOffsetTime, true);
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
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	self.statusicon = "";
	self.maxhealth = 100;
	self.health = self.maxhealth;
	self.dead_origin = undefined;
	self.dead_angles = undefined;

	spawnpointname = "mp_tdm_spawn";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam_AwayfromRadios(spawnpoints);

	if(isdefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");

	if(!isdefined(self.pers["savedmodel"]))
		maps\mp\gametypes\_teams::model();
	else
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);

	if(!isdefined(self))
		return;

	// Give weapon
	self setWeaponSlotWeapon("primary", self.pers["weapon"]);
	self giveMaxAmmo(self.pers["weapon"]);
	self setSpawnWeapon(self.pers["weapon"]);
	self.spawnedWeapon = self.pers["weapon"];

	if (level.in_readyup && !level.in_timeout)
	{
		maps\mp\gametypes\_weapons::giveSmokesFor(self.spawnedWeapon, 0);
		maps\mp\gametypes\_weapons::giveGrenadesFor(self.spawnedWeapon, 0); // grenades are handled in readyup now
	}
	else
	{
		smokes = undefined;
		if (level.restricted_smoke && !((self.pers["team"] == "allies" && level.allies_give_smoke) || (self.pers["team"] == "axis" && level.axis_give_smoke)))
			smokes = 0;

		maps\mp\gametypes\_weapons::giveGrenadesFor(self.spawnedWeapon);
		smokes = maps\mp\gametypes\_weapons::giveSmokesFor(self.spawnedWeapon, smokes);

		if (smokes > 0 && self.pers["team"] == "allies")
			level.allies_give_smoke = false;
		if (smokes > 0 && self.pers["team"] == "axis")
			level.axis_give_smoke = false;
		//if (smokes > 0) iprintln("^1 smoke given to spawned player in team " + self.pers["team"] + " " + self.name);
	}


	maps\mp\gametypes\_weapons::givePistol();
	maps\mp\gametypes\_weapons::giveBinoculars();



	self thread updateTimer();

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
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	else if(self.pers["team"] == "streamer")
		self.statusicon = "compassping_enemyfiring"; // recording icon
	else if (self.pers["team"] == "allies" || self.pers["team"] == "axis") // dead team spectartor
		self.statusicon = "hud_status_dead";


	maps\mp\gametypes\_spectating::setSpectatePermissions();

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
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}

	// Notify "spawned" notifications
	self notify("spawned");


	level hq_removeall_hudelems(self);
	self thread updateTimer();


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

	if(isdefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");

	level hq_removeall_hudelems(self);
	self thread updateTimer();

	// Notify "spawned" notifications
	self notify("spawned");
	self notify("spawned_intermission");
}

respawn()
{
	self endon("disconnect");

	if(!isdefined(self.pers["weapon"]))
		return;

	self.sessionteam = self.pers["team"];
	self.sessionstate = "spectator";

	if(isdefined(self.dead_origin) && isdefined(self.dead_angles))
	{
		origin = self.dead_origin + (0, 0, 16);
		angles = self.dead_angles;
	}
	else
	{
		origin = self.origin + (0, 0, 16);
		angles = self.angles;
	}

	self spawn(origin, angles);

	while(isdefined(self.WaitingOnTimer) || ((self.pers["team"] == level.DefendingRadioTeam) && isdefined(self.WaitingOnNeutralize)))
		wait level.frame;

	if(isDefined(self.pers["weapon"]))
		self thread spawnPlayer();
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



    // Notify Halftime not to end match until current HQ done
    level.radio_maxholdtime_reached = false;


	level thread hq_obj_think();


	// Set clock timer
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
		level.clock setTimer((level.timelimit * 60));

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

				level.clock setTimer(int(time_before_timeout - 0.1) + 0.9);	// setTimer adds 1 seconds, so for 1 client frame it shows one second up
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


		if(level.mapended) return;
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
		text = &"MP_THE_GAME_IS_A_TIE";
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
		player setClientCvar("cg_objectiveText", text);
	}


	wait (level.fps_multiplier * level.frame);


	level thread maps\mp\gametypes\_end_of_map::Do_Map_End();
}



hq_init_radios()
{
	for(i = 0; i < level.radio.size; i++)
	{
		level.radio[i] setmodel(game["radio_model"]);
		level.radio[i].team = "none";
		level.radio[i].holdtime_allies = 0;
		level.radio[i].holdtime_axis = 0;
		level.radio[i].hidden = true;
		level.radio[i] hide();

		if((!isdefined(level.radio[i].script_radius)) || (level.radio[i].script_radius <= 0))
			level.radio[i].radius = level.radioradius;
		else
			level.radio[i].radius = level.radio[i].script_radius;

		level thread hq_radio_think(level.radio[i]);
	}
}

hq_randomize_radioarray()
{
	for(i = 0; i < level.radio.size; i++)
	{
		rand = randomint(level.radio.size);
	    	temp = level.radio[i];
	    	level.radio[i] = level.radio[rand];
	    	level.radio[rand] = temp;
	}
}

hq_obj_think(radio)
{
	NeutralRadios = 0;
	for(i = 0; i < level.radio.size; i++)
	{
		if(level.radio[i].hidden == true)
			continue;
		NeutralRadios++;
	}
	if(NeutralRadios <= 0)
	{
		if(level.nextradio > level.radio.size - 1)
		{
			hq_randomize_radioarray();
			level.nextradio = 0;

			if(isdefined(radio))
			{
				// same radio twice in a row so go to the next radio
				if(radio == level.radio[level.nextradio])
					level.nextradio++;
			}
		}

		//find a fake radio position that isn't the last position or the next position
		randAorB = undefined;
		if(level.radio.size >= 4)
		{
			fakeposition = level.radio[randomint(level.radio.size)];
			if(isdefined(level.radio[(level.nextradio - 1)]))
			{
				while((fakeposition == level.radio[level.nextradio]) || (fakeposition == level.radio[level.nextradio - 1]))
					fakeposition = level.radio[randomint(level.radio.size)];
			}
			else
			{
				while(fakeposition == level.radio[level.nextradio])
					fakeposition = level.radio[randomint(level.radio.size)];
			}
			randAorB = randomint(2);

		}
		if(!isdefined(randAorB))
			otherAorB = 2; //use original icon since there is only one objective that will show
		else if(randAorB == 1)
			otherAorB = 0;
		else
			otherAorB = 1;


		wait level.fps_multiplier * 1;

		while (level.in_strattime || level.in_timeout)
			wait level.fps_multiplier * 1;


		iprintln(&"MP_RADIOS_SPAWN_IN_SECONDS", level.RadioSpawnDelay);

		// Wait a specific time and consider timeout and strat time pause
		time = 0;
		for(;;)
		{
			if (!level.in_timeout && !level.in_strattime)
				time += 1;
			if (time >= level.RadioSpawnDelay)
				break;

			wait level.fps_multiplier * 1;
		}

		level.radio[level.nextradio] show();
		level.radio[level.nextradio].hidden = false;

		// radio objective
		level.radio_obj show();
		level.radio_obj.origin = level.radio[level.nextradio].origin;
		level.radio_obj.angles = level.radio[level.nextradio].angles;
		level.radio_obj setModel(game["radio_model_obj"]);

		level thread playSoundOnPlayers("explo_plant_no_tick");
		objective_add(0, "current", level.radio[level.nextradio].origin, game["radio_prespawn"][2]);

		thread maps\mp\gametypes\_objpoints::removeObjpoints();
		thread maps\mp\gametypes\_objpoints::addObjpoint(level.radio[level.nextradio].origin, "0", "objpoint_radio");

		if((level.captured_radios["allies"] <= 0) && (level.captured_radios["axis"] > 0)) // AXIS HAVE A RADIO AND ALLIES DONT
			objective_team(0, "allies");
		else if((level.captured_radios["allies"] > 0) && (level.captured_radios["axis"] <= 0)) // ALLIES HAVE A RADIO AND AXIS DONT
			objective_team(0, "axis");
		else // NO TEAMS HAVE A RADIO
			objective_team(0, "none");

		level.nextradio++;

	}
}

// Is called for every radio script_model created on map
hq_radio_think(radio)
{
	level endon("intermission");

	while (!level.matchstarted)
		wait level.frame;

	while(!level.mapended)
	{
		wait level.frame;
		if(!radio.hidden)
		{
			if (level.in_timeout || level.in_strattime)
				continue;

			players = getentarray("player", "classname");
			radio.allies = 0;
			radio.axis = 0;
			for(i = 0; i < players.size; i++)
			{
				if(isdefined(players[i].pers["team"]) && (players[i].pers["team"] == "allies" || players[i].pers["team"] == "axis") && players[i].sessionstate == "playing")
				{
					if(((distance(players[i].origin,radio.origin)) <= radio.radius) && (distance((0,0,players[i].origin[2]),(0,0,radio.origin[2])) <= level.zradioradius))
					{
						if(players[i].pers["team"] == radio.team)
							continue;

						if((level.captured_radios[players[i].pers["team"]] > 0) && (radio.team == "none"))
							continue;

						if((!isdefined(players[i].radioicon)) || (!isdefined(players[i].radioicon[0])))
						{
							players[i].radioicon[0] = newClientHudElem(players[i]);
							players[i].radioicon[0].x = 30;
							players[i].radioicon[0].y = 95;
							players[i].radioicon[0].alignX = "center";
							players[i].radioicon[0].alignY = "middle";
							players[i].radioicon[0].horzAlign = "left";
							players[i].radioicon[0].vertAlign = "top";
							players[i].radioicon[0] setShader("field_radio", 40, 32);
						}

						if((level.captured_radios[players[i].pers["team"]] <= 0) && (radio.team == "none"))
						{
							if(!isdefined(players[i].progressbar_capture))
							{
								players[i].progressbar_capture = newClientHudElem(players[i]);
								players[i].progressbar_capture.x = 0;
								players[i].progressbar_capture.y = 104;
								players[i].progressbar_capture.alignX = "center";
								players[i].progressbar_capture.alignY = "middle";
								players[i].progressbar_capture.horzAlign = "center_safearea";
								players[i].progressbar_capture.vertAlign = "center_safearea";
								players[i].progressbar_capture.alpha = 0.5;
							}
							players[i].progressbar_capture setShader("black", level.progressBarWidth, level.progressBarHeight);
							if(!isdefined(players[i].progressbar_capture2))
							{
								players[i].progressbar_capture2 = newClientHudElem(players[i]);
								players[i].progressbar_capture2.x = ((level.progressBarWidth / (-2)) + 2);
								players[i].progressbar_capture2.y = 104;
								players[i].progressbar_capture2.alignX = "left";
								players[i].progressbar_capture2.alignY = "middle";
								players[i].progressbar_capture2.horzAlign = "center_safearea";
								players[i].progressbar_capture2.vertAlign = "center_safearea";
							}
							if(players[i].pers["team"] == "allies")
								players[i].progressbar_capture2 setShader("white", radio.holdtime_allies + 1, level.progressBarHeight - 4);
							else
								players[i].progressbar_capture2 setShader("white", radio.holdtime_axis + 1, level.progressBarHeight - 4);

							if(!isdefined(players[i].progressbar_capture3))
							{
								players[i].progressbar_capture3 = newClientHudElem(players[i]);
								players[i].progressbar_capture3.x = 0;
								players[i].progressbar_capture3.y = 50;
								players[i].progressbar_capture3.alignX = "center";
								players[i].progressbar_capture3.alignY = "middle";
								players[i].progressbar_capture3.horzAlign = "center_safearea";
								players[i].progressbar_capture3.vertAlign = "center_safearea";
								players[i].progressbar_capture3.archived = false;
								players[i].progressbar_capture3.font = "default";
								players[i].progressbar_capture3.fontscale = 2;
								players[i].progressbar_capture3 settext(&"MP_ESTABLISHING_HQ");
							}

                            // 	This will show your team whether enemies began establishing HQ
							if((players[i].pers["team"] == "allies") && (radio.team == "none") && level.radio_establishing_enemy)
							{
								level thread hq_radio_establish_enemy(radio, "axis", radio.holdtime_allies);
								level thread hq_radio_progressbar_enemy_establishing_failure();

							}
							else if((players[i].pers["team"] == "axis") && (radio.team == "none") && level.radio_establishing_enemy)
							{
								level thread hq_radio_establish_enemy(radio, "allies", radio.holdtime_axis);
								level thread hq_radio_progressbar_enemy_establishing_failure();
							}
						}
						else if(radio.team != "none")
						{
							if(!isdefined(players[i].progressbar_capture))
							{
								players[i].progressbar_capture = newClientHudElem(players[i]);
								players[i].progressbar_capture.x = 0;
								players[i].progressbar_capture.y = 104;
								players[i].progressbar_capture.alignX = "center";
								players[i].progressbar_capture.alignY = "middle";
								players[i].progressbar_capture.horzAlign = "center_safearea";
								players[i].progressbar_capture.vertAlign = "center_safearea";
								players[i].progressbar_capture.alpha = 0.5;
							}
							players[i].progressbar_capture setShader("black", level.progressBarWidth, level.progressBarHeight);

							if(!isdefined(players[i].progressbar_capture2))
							{
								players[i].progressbar_capture2 = newClientHudElem(players[i]);
								players[i].progressbar_capture2.x = ((level.progressBarWidth / (-2)) + 2);
								players[i].progressbar_capture2.y = 104;
								players[i].progressbar_capture2.alignX = "left";
								players[i].progressbar_capture2.alignY = "middle";
								players[i].progressbar_capture2.horzAlign = "center_safearea";
								players[i].progressbar_capture2.vertAlign = "center_safearea";
							}
							if(players[i].pers["team"] == "allies")
								players[i].progressbar_capture2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_allies), level.progressBarHeight - 4);
							else
								players[i].progressbar_capture2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_axis), level.progressBarHeight - 4);

							if(!isdefined(players[i].progressbar_capture3))
							{
								players[i].progressbar_capture3 = newClientHudElem(players[i]);
								players[i].progressbar_capture3.x = 0;
								players[i].progressbar_capture3.y = 50;
								players[i].progressbar_capture3.alignX = "center";
								players[i].progressbar_capture3.alignY = "middle";
								players[i].progressbar_capture3.horzAlign = "center_safearea";
								players[i].progressbar_capture3.vertAlign = "center_safearea";
								players[i].progressbar_capture3.archived = false;
								players[i].progressbar_capture3.font = "default";
								players[i].progressbar_capture3.fontscale = 2;
								players[i].progressbar_capture3 settext(&"MP_DESTROYING_HQ");
							}

							if(radio.team == "allies")
							{
								if(!isdefined(level.progressbar_axis_neutralize))
								{
									level.progressbar_axis_neutralize = newTeamHudElem("allies");
									level.progressbar_axis_neutralize.x = 0;
									level.progressbar_axis_neutralize.y = 104;
									level.progressbar_axis_neutralize.alignX = "center";
									level.progressbar_axis_neutralize.alignY = "middle";
									level.progressbar_axis_neutralize.horzAlign = "center_safearea";
									level.progressbar_axis_neutralize.vertAlign = "center_safearea";
									level.progressbar_axis_neutralize.alpha = 0.5;
								}
								level.progressbar_axis_neutralize setShader("black", level.progressBarWidth, level.progressBarHeight);

								if(!isdefined(level.progressbar_axis_neutralize2))
								{
									level.progressbar_axis_neutralize2 = newTeamHudElem("allies");
									level.progressbar_axis_neutralize2.x = ((level.progressBarWidth / (-2)) + 2);
									level.progressbar_axis_neutralize2.y = 104;
									level.progressbar_axis_neutralize2.alignX = "left";
									level.progressbar_axis_neutralize2.alignY = "middle";
									level.progressbar_axis_neutralize2.horzAlign = "center_safearea";
									level.progressbar_axis_neutralize2.vertAlign = "center_safearea";
									level.progressbar_axis_neutralize2.color = (.8,0,0);
								}
								if(players[i].pers["team"] == "allies")
									level.progressbar_axis_neutralize2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_allies), level.progressBarHeight - 4);
								else
									level.progressbar_axis_neutralize2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_axis), level.progressBarHeight - 4);

								if(!isdefined(level.progressbar_axis_neutralize3))
								{
									level.progressbar_axis_neutralize3 = newTeamHudElem("allies");
									level.progressbar_axis_neutralize3.x = 0;
									level.progressbar_axis_neutralize3.y = 50;
									level.progressbar_axis_neutralize3.alignX = "center";
									level.progressbar_axis_neutralize3.alignY = "middle";
									level.progressbar_axis_neutralize3.horzAlign = "center_safearea";
									level.progressbar_axis_neutralize3.vertAlign = "center_safearea";
									level.progressbar_axis_neutralize3.archived = false;
									level.progressbar_axis_neutralize3.font = "default";
									level.progressbar_axis_neutralize3.fontscale = 2;
									level.progressbar_axis_neutralize3 settext(&"MP_LOSING_HQ");
								}
							}
							else
							if(radio.team == "axis")
							{
								if(!isdefined(level.progressbar_allies_neutralize))
								{
									level.progressbar_allies_neutralize = newTeamHudElem("axis");
									level.progressbar_allies_neutralize.x = 0;
									level.progressbar_allies_neutralize.y = 104;
									level.progressbar_allies_neutralize.alignX = "center";
									level.progressbar_allies_neutralize.alignY = "middle";
									level.progressbar_allies_neutralize.horzAlign = "center_safearea";
									level.progressbar_allies_neutralize.vertAlign = "center_safearea";
									level.progressbar_allies_neutralize.alpha = 0.5;
								}
								level.progressbar_allies_neutralize setShader("black", level.progressBarWidth, level.progressBarHeight);

								if(!isdefined(level.progressbar_allies_neutralize2))
								{
									level.progressbar_allies_neutralize2 = newTeamHudElem("axis");
									level.progressbar_allies_neutralize2.x = ((level.progressBarWidth / (-2)) + 2);
									level.progressbar_allies_neutralize2.y = 104;
									level.progressbar_allies_neutralize2.alignX = "left";
									level.progressbar_allies_neutralize2.alignY = "middle";
									level.progressbar_allies_neutralize2.horzAlign = "center_safearea";
									level.progressbar_allies_neutralize2.vertAlign = "center_safearea";
									level.progressbar_allies_neutralize2.color = (.8,0,0);
								}
								if(players[i].pers["team"] == "allies")
									level.progressbar_allies_neutralize2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_allies), level.progressBarHeight - 4);
								else
									level.progressbar_allies_neutralize2 setShader("white", ((level.progressBarWidth - 4) - radio.holdtime_axis), level.progressBarHeight - 4);

								if(!isdefined(level.progressbar_allies_neutralize3))
								{
									level.progressbar_allies_neutralize3 = newTeamHudElem("axis");
									level.progressbar_allies_neutralize3.x = 0;
									level.progressbar_allies_neutralize3.y = 50;
									level.progressbar_allies_neutralize3.alignX = "center";
									level.progressbar_allies_neutralize3.alignY = "middle";
									level.progressbar_allies_neutralize3.horzAlign = "center_safearea";
									level.progressbar_allies_neutralize3.vertAlign = "center_safearea";
									level.progressbar_allies_neutralize3.archived = false;
									level.progressbar_allies_neutralize3.font = "default";
									level.progressbar_allies_neutralize3.fontscale = 2;
									level.progressbar_allies_neutralize3 settext(&"MP_LOSING_HQ");
								}
							}
						}

						if(players[i].pers["team"] == "allies")
							radio.allies++;
						else
							radio.axis++;

						players[i].inrange = true;
					}
					else if((isdefined(players[i].radioicon)) && (isdefined(players[i].radioicon[0])))
					{
						if((isdefined(players[i].radioicon)) || (isdefined(players[i].radioicon[0])))
							players[i].radioicon[0] destroy();

                        level notify("progressbar_enemy_establishing_destroy");

						if(isdefined(players[i].progressbar_capture))
							players[i].progressbar_capture destroy();
						if(isdefined(players[i].progressbar_capture2))
							players[i].progressbar_capture2 destroy();
						if(isdefined(players[i].progressbar_capture3))
							players[i].progressbar_capture3 destroy();

						players[i].inrange = undefined;
					}
				}
			}

			if (radio.holdtime_allies == 0)
				radio.collector_allies = 0;
			if (radio.holdtime_axis == 0)
				radio.collector_axis = 0;

			// On old pam it took 5.689sec to capture radio
			// On 207 it took 9.449sec to capture radio

			// Now if the thread will run every frame (instead of every 2 frames on 207), it will run every 33ms on sv_fps 30
			// If we want to wait 10sec to capture, we need to increment (0.033 / 10) * 190 (width) = 0.627
			holdtime = 10; // seconds
			multiplier = ((level.frame / holdtime) * (level.progressBarWidth - 4)) / 2;


			if(radio.team == "none") // Radio is captured if no enemies around
			{
				if((radio.allies > 0) && (radio.axis <= 0) && (radio.team != "allies"))
				{
					radio.collector_allies = (multiplier + radio.collector_allies + (radio.allies * multiplier));
					radio.holdtime_allies = 1 + int(radio.collector_allies);
					//radio.holdtime_allies = int( .667 + (radio.holdtime_allies + (radio.allies * level.MultipleCaptureBias)));

					if(radio.holdtime_allies >= (level.progressBarWidth - 4))
					{
						if((level.captured_radios["allies"] > 0) && (radio.team != "none"))
							level hq_radio_capture(radio, "none");
						else if(level.captured_radios["allies"] <= 0)
							level hq_radio_capture(radio, "allies");
					}
				}
				else if((radio.axis > 0) && (radio.allies <= 0) && (radio.team != "axis"))
				{
					radio.collector_axis = (multiplier + radio.collector_axis + (radio.axis * multiplier));
					radio.holdtime_axis = 1 + int(radio.collector_axis);
					//radio.holdtime_axis = int( .667 + (radio.holdtime_axis + (radio.axis * level.MultipleCaptureBias)));

					if(radio.holdtime_axis >= (level.progressBarWidth - 4))
					{
						if((level.captured_radios["axis"] > 0) && (radio.team != "none"))
							level hq_radio_capture(radio, "none");
						else if(level.captured_radios["axis"] <= 0)
							level hq_radio_capture(radio, "axis");
					}
				}
				else
				{
					radio.holdtime_allies = 0;
					radio.holdtime_axis = 0;

					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
					{
						if(isdefined(players[i].pers["team"]) && (players[i].pers["team"] == "allies" || players[i].pers["team"] == "axis") && players[i].sessionstate == "playing")
						{
							if(((distance(players[i].origin,radio.origin)) <= radio.radius) && (distance((0,0,players[i].origin[2]),(0,0,radio.origin[2])) <= level.zradioradius))
							{
 								level notify("progressbar_enemy_establishing_destroy");

								if(isdefined(players[i].progressbar_capture))
									players[i].progressbar_capture destroy();
								if(isdefined(players[i].progressbar_capture2))
									players[i].progressbar_capture2 destroy();
								if(isdefined(players[i].progressbar_capture3))
									players[i].progressbar_capture3 destroy();
							}
						}
					}
				}
			}
			else // Radio should go to neutral first
			{
				if((radio.team == "allies") && (radio.axis <= 0))
				{
					if(isdefined(level.progressbar_axis_neutralize))
						level.progressbar_axis_neutralize destroy();
					if(isdefined(level.progressbar_axis_neutralize2))
						level.progressbar_axis_neutralize2 destroy();
					if(isdefined(level.progressbar_axis_neutralize3))
						level.progressbar_axis_neutralize3 destroy();
				}
				else if((radio.team == "axis") && (radio.allies <= 0))
				{
					if(isdefined(level.progressbar_allies_neutralize))
						level.progressbar_allies_neutralize destroy();
					if(isdefined(level.progressbar_allies_neutralize2))
						level.progressbar_allies_neutralize2 destroy();
					if(isdefined(level.progressbar_allies_neutralize3))
						level.progressbar_allies_neutralize3 destroy();
				}

				if (radio.holdtime_allies == 0)
					radio.collector_allies = 0;
				if (radio.holdtime_axis == 0)
					radio.collector_axis = 0;



				// Timeout ended or defending team disconnects and there are no defending players -> kill radio
				if (hq_radio_defenders_alive() < 1)
				{
					wait level.frame; // to get OnPlayerKilled called first if last player was killed
					level thread hq_radio_disconnected_capture(radio);
				}



				if((radio.allies > 0) && (radio.team == "axis"))
				{
					radio.collector_allies = (multiplier + radio.collector_allies + (radio.allies * multiplier));
					radio.holdtime_allies = 1 + int(radio.collector_allies);
					//radio.holdtime_allies = int(.667 + (radio.holdtime_allies + (radio.allies * level.MultipleCaptureBias)));
					if(radio.holdtime_allies >= (level.progressBarWidth - 4))
						level hq_radio_capture(radio, "none");
				}
				else if((radio.axis > 0) && (radio.team == "allies"))
				{
					radio.collector_axis = (multiplier + radio.collector_axis + (radio.axis * multiplier));
					radio.holdtime_axis = 1 + int(radio.collector_axis);
					//radio.holdtime_axis = int(.667 + (radio.holdtime_axis + (radio.axis * level.MultipleCaptureBias)));
					if(radio.holdtime_axis >= (level.progressBarWidth - 4))
						level hq_radio_capture(radio, "none");
				}
				else
				{
					radio.holdtime_allies = 0;
					radio.holdtime_axis = 0;
				}
			}
		}
	}
}



hq_radio_establish_enemy(radio, team, holdtime)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == team && players[i].sessionstate == "playing")
		{
			if(!isdefined(players[i].progressbar_enemy_establishing))
			{
				players[i].progressbar_enemy_establishing = newClientHudElem(players[i]);
				players[i].progressbar_enemy_establishing.x = 0;
				players[i].progressbar_enemy_establishing.y = 104;
				players[i].progressbar_enemy_establishing.alignX = "center";
				players[i].progressbar_enemy_establishing.alignY = "middle";
				players[i].progressbar_enemy_establishing.horzAlign = "center_safearea";
				players[i].progressbar_enemy_establishing.vertAlign = "center_safearea";
				players[i].progressbar_enemy_establishing.alpha = 0.5;
			}
			players[i].progressbar_enemy_establishing setShader("black", level.progressBarWidth, level.progressBarHeight);

			if(!isdefined(players[i].progressbar_enemy_establishing2))
			{
				players[i].progressbar_enemy_establishing2 = newClientHudElem(players[i]);
				players[i].progressbar_enemy_establishing2.x = ((level.progressBarWidth / (-2)) + 2);
				players[i].progressbar_enemy_establishing2.y = 104;
				players[i].progressbar_enemy_establishing2.alignX = "left";
				players[i].progressbar_enemy_establishing2.alignY = "middle";
				players[i].progressbar_enemy_establishing2.horzAlign = "center_safearea";
				players[i].progressbar_enemy_establishing2.vertAlign = "center_safearea";
				players[i].progressbar_enemy_establishing2.color = (.8,0,0);
			}
			players[i].progressbar_enemy_establishing2 setShader("white", holdtime + 1, level.progressBarHeight - 4);

			if(!isdefined(players[i].progressbar_enemy_establishing3))
			{
				players[i].progressbar_enemy_establishing3 = newClientHudElem(players[i]);
				players[i].progressbar_enemy_establishing3.x = 0;
				players[i].progressbar_enemy_establishing3.y = 50;
				players[i].progressbar_enemy_establishing3.alignX = "center";
				players[i].progressbar_enemy_establishing3.alignY = "middle";
				players[i].progressbar_enemy_establishing3.horzAlign = "center_safearea";
				players[i].progressbar_enemy_establishing3.vertAlign = "center_safearea";
				players[i].progressbar_enemy_establishing3.archived = true;
				players[i].progressbar_enemy_establishing3.font = "default";
				players[i].progressbar_enemy_establishing3.fontscale = 2;

                if(players[i].pers["team"] == "allies")
                    players[i].progressbar_enemy_establishing3 setText(game["RADIO_ESTABLISHING_AXIS"]);
                else
                    players[i].progressbar_enemy_establishing3 setText(game["RADIO_ESTABLISHING_ALLIES"]);
			}
		}
	}
}

hq_radio_progressbar_enemy_establishing_failure()
{
	level endon("intermission");
	level endon("progressbar_radio_capture");

	players = getentarray("player", "classname");

	level waittill("progressbar_enemy_establishing_destroy");

	//iprintlnBold("^1destroying ...");

	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].progressbar_enemy_establishing))
			players[i].progressbar_enemy_establishing destroy();
		if(isdefined(players[i].progressbar_enemy_establishing2))
			players[i].progressbar_enemy_establishing2 destroy();
		if(isdefined(players[i].progressbar_enemy_establishing3))
			players[i].progressbar_enemy_establishing3 destroy();
	}

}


hq_radio_disconnected_capture(radio)
{
	level endon("intermission");

	wait level.fps_multiplier * 1.5;

	if(radio.team != "none" && level.DefendingRadioTeam != "none" && !level.in_timeout)
	{
		level hq_radio_capture(radio, "none");
		iprintlnBold(game["RADIO_RESET_NO_DEFENDERS"]);
	}
}


hq_radio_defenders_alive()
{
	allplayers = getentarray("player", "classname");
	alive = [];
	for(i = 0; i < allplayers.size; i++)
	{
		if(allplayers[i].sessionstate == "playing" && allplayers[i].sessionteam == level.DefendingRadioTeam)
			alive[alive.size] = allplayers[i];
	}
	return alive.size;
}








hq_radio_capture(radio, team)
{
	radio.holdtime_allies = 0;
	radio.holdtime_axis = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i].WaitingOnTimer = undefined;
		players[i].WaitingOnNeutralize = undefined;
		if(isdefined(players[i].pers["team"]) && (players[i].pers["team"] == "allies" || players[i].pers["team"] == "axis") && players[i].sessionstate == "playing")
		{
			if((isdefined(players[i].radioicon)) && (isdefined(players[i].radioicon[0])))
			{
				players[i].radioicon[0] destroy();

                level notify("progressbar_enemy_establishing_destroy");

				if(isdefined(players[i].progressbar_capture))
					players[i].progressbar_capture destroy();
				if(isdefined(players[i].progressbar_capture2))
					players[i].progressbar_capture2 destroy();
				if(isdefined(players[i].progressbar_capture3))
					players[i].progressbar_capture3 destroy();
			}
		}
	}

	if(radio.team != "none")
	{
		level.captured_radios[radio.team] = 0;
		playfx(level._effect["radioexplosion"], radio.origin);
		level.timesCaptured = 0;
		// Print some text
		if(radio.team == "allies")
		{
			iprintln(&"MP_SHUTDOWN_ALLIED_HQ");

			if(isdefined(level.progressbar_axis_neutralize))
				level.progressbar_axis_neutralize destroy();
			if(isdefined(level.progressbar_axis_neutralize2))
				level.progressbar_axis_neutralize2 destroy();
			if(isdefined(level.progressbar_axis_neutralize3))
				level.progressbar_axis_neutralize3 destroy();
		}
		else if(radio.team == "axis")
		{
			iprintln(&"MP_SHUTDOWN_AXIS_HQ");

			if(isdefined(level.progressbar_allies_neutralize))
				level.progressbar_allies_neutralize destroy();
			if(isdefined(level.progressbar_allies_neutralize2))
				level.progressbar_allies_neutralize2 destroy();
			if(isdefined(level.progressbar_allies_neutralize3))
				level.progressbar_allies_neutralize3 destroy();
		}
	}

	if(radio.team == "none")
		radio playsound("explo_plant_no_tick");

	NeutralizingTeam = undefined;
	if(radio.team == "allies")
		NeutralizingTeam = "axis";
	else if(radio.team == "axis")
		NeutralizingTeam = "allies";
	radio.team = team;

	level notify("Radio State Changed");

	if(team == "none")
	{
		// RADIO GOES NEUTRAL
		radio setmodel(game["radio_model"]);
		radio hide();
		radio.hidden = true;

		// radio objective
		level.radio_obj hide();
		level.radio_obj.origin = (0,0,0);
		level.radio_obj.angles = (0,0,0);


		radio playsound("explo_radio");
		if(isdefined(NeutralizingTeam))
		{
			if(NeutralizingTeam == "allies")
				level thread playSoundOnPlayers("mp_announcer_axishqdest");
			else if(NeutralizingTeam == "axis")
				level thread playSoundOnPlayers("mp_announcer_alliedhqdest");
		}

		objective_delete(0);
		thread maps\mp\gametypes\_objpoints::removeObjpoints();
		level.DefendingRadioTeam = "none";
		level notify("Radio Neutralized");

		//give some points to the neutralizing team
		if(isdefined(NeutralizingTeam))
		{
			if((NeutralizingTeam == "allies") || (NeutralizingTeam == "axis"))
			{
				if(getTeamCount(NeutralizingTeam))
				{
					HQ_Team_Scoring(NeutralizingTeam, level.NeutralizingPoints);

					if(NeutralizingTeam == "allies")
						iprintln(&"MP_SCORED_ALLIES", level.NeutralizingPoints);
					else
						iprintln(&"MP_SCORED_AXIS", level.NeutralizingPoints);
				}
			}
		}

		//give all the alive players that are alive full health
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if(isdefined(players[i].pers["team"]) && players[i].sessionstate == "playing")
			{
				players[i].maxhealth = 100;
				players[i].health = players[i].maxhealth;
			}
		}

		// Restricted smokes
		level.allies_give_smoke = false;
		level.axis_give_smoke = false;

		level thread hq_removhudelem_allplayers(radio);
	}
	else
	{
		// RADIO CAPTURED BY A TEAM
		level.captured_radios[team] = 1;
		level.DefendingRadioTeam = team;

		if(team == "allies")
		{
			iprintln(&"MP_SETUP_HQ_ALLIED");

			if(game["allies"] == "british")
				alliedsound = "UK_mp_hqsetup";
			else if(game["allies"] == "russian")
				alliedsound = "RU_mp_hqsetup";
			else
				alliedsound = "US_mp_hqsetup";

			level thread playSoundOnPlayers(alliedsound, "allies");
			level thread playSoundOnPlayers("GE_mp_enemyhqsetup", "axis");
		}
		else
		{
			iprintln(&"MP_SETUP_HQ_AXIS");

			if(game["allies"] == "british")
				alliedsound = "UK_mp_enemyhqsetup";
			else if(game["allies"] == "russian")
				alliedsound = "RU_mp_enemyhqsetup";
			else
				alliedsound = "US_mp_enemyhqsetup";

			level thread playSoundOnPlayers("GE_mp_hqsetup", "axis");
			level thread playSoundOnPlayers(alliedsound, "allies");
		}

		// Restricted smokes
		level.allies_give_smoke = true;
		level.axis_give_smoke = true;
		//iprintln("^1GIVE SMOKE");

		//give all the alive players that are now defending the radio full health
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == level.DefendingRadioTeam && players[i].sessionstate == "playing")
			{
				players[i].maxhealth = 100;
				players[i].health = players[i].maxhealth;
			}

			// Restricted smokes
			if (level.restricted_smoke && isdefined(players[i].pers["team"]) && isDefined(players[i].spawnedWeapon) && players[i].sessionstate == "playing" &&
			    ((players[i].pers["team"] == "allies" && level.allies_give_smoke) || (players[i].pers["team"] == "axis" && level.axis_give_smoke)))
			{
				smokes = players[i] maps\mp\gametypes\_weapons::giveSmokesFor(players[i].spawnedWeapon);
				if (smokes > 0 && players[i].pers["team"] == "allies")
					level.allies_give_smoke = false;
				if (smokes > 0 && players[i].pers["team"] == "axis")
					level.axis_give_smoke = false;
				//if (smokes > 0) iprintln("^1 smoke given to alive team " + players[i].pers["team"] + " " + players[i].name);
			}
		}

		level thread hq_maxholdtime_think();
	}

	objective_icon(0, (game["radio_" + team ]));
	objective_team(0, "none");

	objteam = "none";
	if((level.captured_radios["allies"] <= 0) && (level.captured_radios["axis"] > 0))
		objteam = "allies";
	else if((level.captured_radios["allies"] > 0) && (level.captured_radios["axis"] <= 0))
		objteam = "axis";

	// Make all neutral radio objectives go to the right team
	for(i = 0; i < level.radio.size; i++)
	{
		if(level.radio[i].hidden == true)
			continue;
		if(level.radio[i].team == "none")
			objective_team(0, objteam);
	}

	level notify("finish_staydead");

	level thread hq_obj_think(radio);
}


hq_maxholdtime_think()
{
	level endon("Radio State Changed");

	assert(level.RadioMaxHoldSeconds > 2);

	if(level.RadioMaxHoldSeconds > 0)
	{
		max_time = level.RadioMaxHoldSeconds;
		start_time = gettime() / 1000 - level.timeout_elapsedTime;
		next_point_time = start_time + 1;

		while (1)
		{
			wait level.fps_multiplier * level.frame;

			if (level.in_timeout)
				continue;

			current_time = (gettime() / 1000) - level.timeout_elapsedTime;

			if (current_time >= next_point_time)
			{
				if(getTeamCount(level.DefendingRadioTeam))
				{
					HQ_Team_Scoring(level.DefendingRadioTeam, 1);
				}

				next_point_time = next_point_time + 1;
			}

			if ( ((current_time - start_time)) >= max_time )
				break;
		}
		//wait (level.fps_multiplier * (level.RadioMaxHoldSeconds - level.frame));
	}

    level notify("RadioMaxHoldTime");
    level.radio_maxholdtime_reached = true;

	level thread hq_radio_resetall();
}

hq_radio_resetall()
{
	// Find the radio that is in play
	radio = undefined;
	for(i = 0; i < level.radio.size; i++)
	{
		if(level.radio[i].hidden == false)
			radio = level.radio[i];
	}

	if(!isdefined(radio))
		return;

	radio.holdtime_allies = 0;
	radio.holdtime_axis = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i].WaitingOnTimer = undefined;
		players[i].WaitingOnNeutralize = undefined;
		if(isdefined(players[i].pers["team"]) && (players[i].pers["team"] == "allies" || players[i].pers["team"] == "axis") && players[i].sessionstate == "playing")
		{
			if((isdefined(players[i].radioicon)) && (isdefined(players[i].radioicon[0])))
			{
				players[i].radioicon[0] destroy();
                level notify("progressbar_enemy_establishing_destroy");

				if(isdefined(players[i].progressbar_capture))
					players[i].progressbar_capture destroy();
				if(isdefined(players[i].progressbar_capture2))
					players[i].progressbar_capture2 destroy();
				if(isdefined(players[i].progressbar_capture3))
					players[i].progressbar_capture3 destroy();
			}
		}
	}

	if(radio.team != "none")
	{
		level.captured_radios[radio.team] = 0;

		playfx(level._effect["radioexplosion"], radio.origin);
		level.timesCaptured = 0;

		localizedTeam = undefined;
		if(radio.team == "allies")
		{
			localizedTeam = (&"MP_UPTEAM");
			if(isdefined(level.progressbar_axis_neutralize))
				level.progressbar_axis_neutralize destroy();
			if(isdefined(level.progressbar_axis_neutralize2))
				level.progressbar_axis_neutralize2 destroy();
			if(isdefined(level.progressbar_axis_neutralize3))
				level.progressbar_axis_neutralize3 destroy();
		}
		else if(radio.team == "axis")
		{
			localizedTeam = (&"MP_DOWNTEAM");
			if(isdefined(level.progressbar_allies_neutralize))
				level.progressbar_allies_neutralize destroy();
			if(isdefined(level.progressbar_allies_neutralize2))
				level.progressbar_allies_neutralize2 destroy();
			if(isdefined(level.progressbar_allies_neutralize3))
				level.progressbar_allies_neutralize3 destroy();
		}

		minutes = 0;
		maxTime = level.RadioMaxHoldSeconds;
		while(maxTime >= 60)
		{
			minutes++;
			maxTime -= 60;
		}
		seconds = maxTime;
		if((minutes > 0) && (seconds > 0))
			iprintlnbold(&"MP_MAXHOLDTIME_MINUTESANDSECONDS", localizedTeam, minutes, seconds);
		else
		if((minutes > 0) && (seconds <= 0))
			iprintlnbold(&"MP_MAXHOLDTIME_MINUTES", localizedTeam);
		else
		if((minutes <= 0) && (seconds > 0))
			iprintlnbold(&"MP_MAXHOLDTIME_SECONDS", localizedTeam, seconds);
	}

	radio.team = "none";
	level.DefendingRadioTeam = "none";
	objective_team(0, "none");

	radio setmodel(game["radio_model"]);
	radio hide();

	// radio objective
	level.radio_obj hide();
	level.radio_obj.origin = (0,0,0);
	level.radio_obj.angles = (0,0,0);

	if(!level.mapended)
	{
		radio playsound("explo_radio");
		level thread playSoundOnPlayers("mp_announcer_hqdefended");
	}

	radio.hidden = true;
	objective_delete(0);
	thread maps\mp\gametypes\_objpoints::removeObjpoints();


	level thread hq_obj_think(radio);
	level thread hq_removhudelem_allplayers(radio);

	// All dead people should now respawn
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i].WaitingOnTimer = undefined;
		players[i].WaitingOnNeutralize = undefined;
	}

	level notify("finish_staydead");
}

hq_removeall_hudelems(player)
{
	if(isdefined(self))
	{
		for(i = 0; i < level.radio.size; i++)
		{
			if((isdefined(player.radioicon)) && (isdefined(player.radioicon[0])))
				player.radioicon[0] destroy();

            level notify("progressbar_enemy_establishing_destroy");

			if(isdefined(player.progressbar_capture))
				player.progressbar_capture destroy();
			if(isdefined(player.progressbar_capture2))
				player.progressbar_capture2 destroy();
			if(isdefined(player.progressbar_capture3))
				player.progressbar_capture3 destroy();
		}
	}
}

hq_removhudelem_allplayers(radio)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i]))
			continue;
		if((isdefined(players[i].radioicon)) && (isdefined(players[i].radioicon[0])))
			players[i].radioicon[0] destroy();

        level notify("progressbar_enemy_establishing_destroy");

		if(isdefined(players[i].progressbar_capture))
			players[i].progressbar_capture destroy();
		if(isdefined(players[i].progressbar_capture2))
			players[i].progressbar_capture2 destroy();
		if(isdefined(players[i].progressbar_capture3))
			players[i].progressbar_capture3 destroy();
	}
}

hq_check_teams_exist()
{
	players = getentarray("player", "classname");
	level.alliesexist = false;
	level.axisexist = false;
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i].pers["team"]) || players[i].pers["team"] == "spectator")
			continue;
		if(players[i].pers["team"] == "allies")
			level.alliesexist = true;
		else if(players[i].pers["team"] == "axis")
			level.axisexist = true;

		if(level.alliesexist && level.axisexist)
			return;
	}
}

updateTeamStatus()
{
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].pers["team"]) && (players[i].pers["team"] == "allies" || players[i].pers["team"] == "axis") && players[i].sessionstate == "playing")
			level.exist[players[i].pers["team"]]++;
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

			// Respawn timer or dead untill neutralized are defined, just show them
			if(isdefined(self.WaitingOnTimer) || ((self.pers["team"] == level.DefendingRadioTeam) && isdefined(self.WaitingOnNeutralize)))
			{
				self thread respawn();
				self thread updateTimer();
			}
			// Dont spawn if choosen team is defending radio and in that team are alive players
			else if(level.DefendingRadioTeam != "none" && self.pers["team"] == level.DefendingRadioTeam && hq_radio_defenders_alive() >= 1)
			{
				self thread respawn_timer(level.fps_multiplier * .1);
				self thread respawn_staydead(level.fps_multiplier * .1);
				self thread respawn();
			}
			else
				spawnPlayer();
		}
	}


	// Used in wepoan_limiter
	self notify("weapon_changed", weapon, leavedWeapon, leavedWeaponFromTeam);
}




respawn_timer(delay)
{
	self endon("disconnect");

	if (isDefined(self.WaitingOnTimer)) return;
	self.WaitingOnTimer = true;

	if(level.respawndelay > 0)
	{
		if(!isdefined(self.respawntimer))
		{
			self.respawntimer = newClientHudElem(self);
			self.respawntimer.x = 0;
			self.respawntimer.y = -50;
			self.respawntimer.alignX = "center";
			self.respawntimer.alignY = "middle";
			self.respawntimer.horzAlign = "center_safearea";
			self.respawntimer.vertAlign = "center_safearea";
			self.respawntimer.alpha = 0;
			self.respawntimer.archived = false;
			self.respawntimer.font = "default";
			self.respawntimer.fontscale = 2;
			self.respawntimer.label = (&"MP_TIME_TILL_SPAWN");
			self.respawntimer setTimer(level.respawndelay + 1);
		}

		wait delay;
		self thread updateTimer();

		wait level.fps_multiplier * level.respawndelay;

		if(isdefined(self.respawntimer))
			self.respawntimer destroy();
	}

	self.WaitingOnTimer = undefined;
}

respawn_staydead(delay)
{
	self endon("disconnect");

	if(isdefined(self.WaitingOnNeutralize)) return;
	self.WaitingOnNeutralize = true;

	if(!isdefined(self.staydead))
	{
		self.staydead = newClientHudElem(self);
		self.staydead.x = 0;
		self.staydead.y = -50;
		self.staydead.alignX = "center";
		self.staydead.alignY = "middle";
		self.staydead.horzAlign = "center_safearea";
		self.staydead.vertAlign = "center_safearea";
		self.staydead.alpha = 0;
		self.staydead.archived = false;
		self.staydead.font = "default";
		self.staydead.fontscale = 2;
		self.staydead setText(&"MP_RESPAWN_WHEN_RADIO_NEUTRALIZED");
	}

	self thread delayUpdateTimer(delay);
	level waittill("finish_staydead");

	if(isdefined(self.staydead))
		self.staydead destroy();

	if(isdefined(self.respawntimer))
		self.respawntimer destroy();

	self.WaitingOnNeutralize = undefined;
}

delayUpdateTimer(delay)
{
	self endon("disconnect");

	wait delay;
	thread updateTimer();
}

updateTimer()
{
	if(isdefined(self.pers["team"]) && (self.pers["team"] == "allies" || self.pers["team"] == "axis") && isdefined(self.pers["weapon"]))
	{
		if((isdefined(self.pers["team"])) && (self.pers["team"] == level.DefendingRadioTeam))
		{
			if(isdefined(self.respawntimer))
				self.respawntimer.alpha = 0;

			if(isdefined(self.staydead))
				self.staydead.alpha = 1;
		}
		else
		{
			if(isdefined(self.respawntimer))
				self.respawntimer.alpha = 1;

			if(isdefined(self.staydead))
				self.staydead.alpha = 0;
		}
	}
	else
	{
		if(isdefined(self.respawntimer))
			self.respawntimer.alpha = 0;

		if(isdefined(self.staydead))
			self.staydead.alpha = 0;
	}
}


playSoundOnPlayers(sound, team)
{
	players = getentarray("player", "classname");

	if(isdefined(team))
	{
		for(i = 0; i < players.size; i++)
		{
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == team) || players[i].pers["team"] == "streamer")
				players[i] playLocalSound(sound);
		}
	}
	else
	{
		for(i = 0; i < players.size; i++)
			players[i] playLocalSound(sound);
	}
}

getTeamCount(team)
{
	count = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isdefined(player.pers["team"]) && (player.pers["team"] == team))
			count++;
	}

	return count;
}

HQ_Team_Scoring(team, score)
{
	if(level.mapended)
		return;

	if (team == "allies")
	{
		if (game["is_halftime"])
			game["half_2_allies_score"] += score;
		else
			game["half_1_allies_score"] += score;

		game["allies_score"] += score;
	}
	else if (team == "axis")
	{
		if (game["is_halftime"])
			game["half_2_axis_score"] += score;
		else
			game["half_1_axis_score"] += score;

		game["axis_score"] += score;
	}

	// Set Score
	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);

	// Update score
	level maps\mp\gametypes\_hud_teamscore::updateScore();

	checkScoreLimit();

}

hq_check_radio_defenders_alive()
{
	allplayers = getentarray("player", "classname");
	alive = [];
	for(i = 0; i < allplayers.size; i++)
	{
		if(allplayers[i].sessionstate == "playing" && allplayers[i].sessionteam == level.DefendingRadioTeam)
			alive[alive.size] = allplayers[i];
	}
	return alive.size;
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


	title +="Restricted smoke:\n";
	if (level.restricted_smoke)
		value += "Yes" + "\n";
	else
		value += "No" + "\n";


	level.serverinfo_left1 = title;
	level.serverinfo_left2 = value;
}
