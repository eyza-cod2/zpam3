#include maps\mp\gametypes\_callbacksetup;

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
	InitCallbacks();

	addEventListener("onStartGameType", ::onStartGameType);
	addEventListener("onConnecting", ::onConnecting);
	addEventListener("onConnected", ::onConnected);
	addEventListener("onDisconnect", ::onDisconnect);
	addEventListener("onPlayerDamaging", ::onPlayerDamaging);
	addEventListener("onPlayerDamaged", ::onPlayerDamaged);
	addEventListener("onPlayerKilling", ::onPlayerKilling);
	addEventListener("onPlayerKilled", ::onPlayerKilled);

	// Same functions across gametypes
	level.autoassign = ::menuAutoAssign;
	level.allies = ::menuAllies;
	level.axis = ::menuAxis;
	level.spectator = ::menuSpectator;
	level.weapon = ::menuWeapon;

	level.spawnPlayer = ::spawnPlayer;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;
}

/*================
Called by code after the level's main script function has run.

Called again for every round in round-based gameplay
================*/
onStartGameType()
{
	if(!isDefined(game["gametypeStarted"]))
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

		maps\mp\gametypes\_precache::Precache();
	}

	// Main scores
	if(!isdefined(game["allies_score"]))
		game["allies_score"] = 0;
	setTeamScore("allies", game["allies_score"]);

	if(!isdefined(game["axis_score"]))
		game["axis_score"] = 0;
	setTeamScore("axis", game["axis_score"]);

	// Half-separed scoresg
	if(!isdefined(game["half_1_allies_score"]))
		game["half_1_allies_score"] = 0;
	if(!isdefined(game["half_1_axis_score"]))
		game["half_1_axis_score"] = 0;
	if(!isdefined(game["half_2_allies_score"]))
		game["half_2_allies_score"] = 0;
	if(!isdefined(game["half_2_axis_score"]))
		game["half_2_axis_score"] = 0;

	// Total score for clan
	if(!isdefined(game["Team_1_Score"]))
		game["Team_1_Score"] = 0;				// Team_1 is: game["half_1_axis_score"] + game["half_2_allies_score"] ---- team who was as axis in first half
	if(!isdefined(game["Team_2_Score"]))
		game["Team_2_Score"] = 0;				// Team_2 is: game["half_2_axis_score"] + game["half_1_allies_score"] ----	team who was as allies in first half

	// Other variables
	if(!isdefined(game["state"]))
		game["state"] = "playing";
	if(!isdefined(game["roundsplayed"]))
		game["roundsplayed"] = 0;

	// Counts length of all rounds (used for scr_sd_timelimit)
	if(!isdefined(game["timepassed"]))
		game["timepassed"] = 0;



	// Gametype specific variables
	level.matchStarted = false;
	level.in_strattime = 0;
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



	// Inicialize all of the script files functions
	maps\mp\gametypes\_init::initAllFunctions();


	thread maps\mp\gametypes\_hud_teamscore::init();


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


	serverInfo();

/*
	    game["state"] = "intermission";
		level notify("intermission");
*/

	// Wait here untill there is atleast one player connected
	if (!isDefined(game["gametypeStarted"]))
	{
		for(;;)
		{
			players = getentarray("player", "classname");
			if (players.size > 0)
				break;
			wait level.fps_multiplier * 1;
		}

		// For public mode, wait untill most of player connect
		if (level.pam_mode == "pub")
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
	level.matchStarted = true;


	if (!level.in_readyup)
	{
		thread deadchat();

		thread startRound();
	}


	game["gametypeStarted"] = true;
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

/*
	if (0) // TODO spawn virtual player?
	{
		if (level.roundstarted && isAlive(self))
		{
			body = self ClonePlayer(300000);
			body setcontents(1);

			body.name = self.name;
			body.health = 100;
			body.sessionstate = self.sessionstate;
			body.sessionteam = self.sessionteam;

			body thread virtualPlayer();

			players = getentarray("player", "classname");
			for(p = 0; p < players.size; p++)
			{
				player = players[i];
				if (isAlive(player) && player != self)
				{
					player lookForVirtualPlayer(body);
				}
			}
		}
	}*/
}

/*
virtualPlayer()
{

}

lookForVirtualPlayer(body)
{
	forward = anglestoforward(self getplayerangles());
	forwardTrace = Bullettrace(self getEye(),self getEye()+(forward[0]*100000, forward[1]*100000, forward[2]*100000),true,self);

	if (isDefined(forwardTrace["entity"]) && forwardTrace["entity"] == body)
	{
	}
}
*/

/*
Called when player is about to take a damage.
self is the player that took damage.
Return true to prevent the damage.
*/
onPlayerDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// Prevent damage when:
	if (!level.matchStarted || level.in_strattime || level.roundended)
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
				// PAM
				self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
				self playrumble("damage_heavy");
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
				// PAM
				self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
				self playrumble("damage_heavy");

				isFriendlyFire = true;
			}
		}
		else
		{
			// Make sure at least one point of damage is done
			if(iDamage < 1)
				iDamage = 1;


			// Player's stats - increase damage points (_player_stat.gsc)
			if (isDefined(eAttacker) && eAttacker != self && !level.in_readyup && level.roundstarted && !level.roundended)
			{
				if (iDamage >= self.health)
					dmg = self.health / 100;
				else
					dmg = iDamage / 100;
				eAttacker maps\mp\gametypes\_player_stat::AddDamage(dmg);
				eAttacker maps\mp\gametypes\_player_stat::AddScore(dmg);
			}


			self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			self notify("damaged_player", iDamage);

			// Shellshock/Rumble
			// PAM
			self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
			self playrumble("damage_heavy");
		}
	}


	if(self.sessionstate != "dead" && !level.in_readyup)
		level notify("log_damage", self, eAttacker, sWeapon, iDamage, sMeansOfDeath, sHitLoc, isFriendlyFire);
}

/*
Called when player is about to be killed.
self is the player that was killed.
Return true to prevent the kill.
*/
onPlayerKilling(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Prevent kill if round didnt start
	if (!level.matchStarted)
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
	self endon("disconnect");
	self endon("spawned");

	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	self notify("killed_player");

	// Send out an obituary message to all clients about the kill
	obituary(self, attacker, sWeapon, sMeansOfDeath);


	// Weapon/Nade Drops
	if (level.roundstarted && !level.roundended && !isDefined(self.switching_teams))
		self thread maps\mp\gametypes\_weapons::dropWeapons();


	// Show as dead
	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";

	// Add score to Deaths
	if(!isdefined(self.switching_teams))
	{
		self.pers["deaths"]++;
		self.deaths = self.pers["deaths"];

		// Player's stats - increase kill points (_player_stat.gsc)
		if (!level.in_readyup && level.roundstarted && !level.roundended)
			self maps\mp\gametypes\_player_stat::AddDeath();
	}

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

				// Player's stats - decrease score points (_player_stat.gsc)
				if (!level.in_readyup && level.roundstarted && !level.roundended)
					attacker maps\mp\gametypes\_player_stat::AddScore(-1);
			}
			else
			{
				attacker.pers["score"]++;
				attacker.score = attacker.pers["score"];

				// Player's stats - increase kill points (_player_stat.gsc)
				if (!level.in_readyup && level.roundstarted && !level.roundended)
				{
					attacker maps\mp\gametypes\_player_stat::AddKill();
					attacker maps\mp\gametypes\_player_stat::AddScore(1);
				}
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

	// If the last player on a team was just killed
	if(!level.exist[self.pers["team"]])
	{
		// Dont do killcam
		doKillcam = false;
	}


	// Do killcam - if enabled, wait here until killcam is done
	if(doKillcam && level.scr_killcam && !level.roundended)
		self maps\mp\gametypes\_killcam::killcam(attackerNum, delay, psOffsetTime);

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
	}
	else
	{
		self setWeaponSlotWeapon("primary", self.pers["weapon"]);
		self giveMaxAmmo(self.pers["weapon"]);

		self setSpawnWeapon(self.pers["weapon"]);
	}

	// Give grenades only if we are in readyup
	if(level.in_readyup)
	{
		maps\mp\gametypes\_weapons::giveSmoke(0);
		maps\mp\gametypes\_weapons::giveGrenade();
	}
	else
	{
		maps\mp\gametypes\_weapons::giveSmoke(0);
		maps\mp\gametypes\_weapons::giveGrenade(0);	// grenades will be added after start time
	}
	maps\mp\gametypes\_weapons::givePistol();
	maps\mp\gametypes\_weapons::giveBinoculars();

	// Switch to pistol in bash mode
	if (level.in_bash)
	{
		self setSpawnWeapon(self getweaponslotweapon("primaryb"));
	}


	self.spawnedWeapon = self.pers["weapon"]; // to determine is weapon was changed during round


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
	self setClientCvar("g_scriptMainMenu", game["menu_ingame"]);

	// Notify "spawned" notifications
	self notify("spawned");
	self notify("spawned_intermission");
}


startRound()
{
	// Stop round-timer if bomb is planted or round ends another way
	level endon("bomb_planted");
	level endon("round_ended");


	// Used in scoreboard info at the end of the round
	if (!isDefined(game["matchStartTime"]))
		game["matchStartTime"] = getTime();




	logPrint("RoundStart;\n");


	level.clock = newHudElem();
	level.clock.font = "default";
	level.clock.fontscale = 2;
	level.clock.horzAlign = "center_safearea";
	level.clock.vertAlign = "top";
	level.clock.color = (1, 1, 1);
	level.clock.x = -25;
	level.clock.y = 445;
	level.clock setTimer(level.roundlength * 60 + level.strat_time);



	level.in_strattime = true;

	if (level.strat_time > 0)
	{
		// Strat Time HUD
		thread maps\mp\gametypes\_hud::StratTime(level.strat_time);

		// Hide clock while strattime
		level.clock.alpha = 0;

		// Disable players movement
		level thread stratTime_g_speed();

		wait level.fps_multiplier * level.strat_time;

		level.in_strattime = false;

		// During a strat time may be called timeout, so if timeaut is active, dont continue more
		if (level.in_timeout)
			return;


		level.clock FadeOverTime(0.5);
		level.clock.alpha = 1;

		level.clock.x = 20;
		level.clock moveovertime(0.5);
		level.clock.x = -25;
	}
	else
		level.in_strattime = false;



	level.roundstarted = true;




	// Hide score if it may be hidden
	level maps\mp\gametypes\_hud_teamscore::hideScore(0.5);


	thread sayObjective();




	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player.pers["team"] == "none")
			continue;

		// Players on a team but without a weapon or dead show as dead since they can not get in this round
		if(player.sessionstate != "playing")
			player.statusicon = "hud_status_dead";

		// To all living player give grenades
		if (isDefined(player.pers["weapon"]) && player.sessionstate == "playing" && (player.pers["team"] == "allies" || player.pers["team"] == "axis") && !level.in_bash)
		{
			player maps\mp\gametypes\_weapons::giveSmoke();
			player maps\mp\gametypes\_weapons::giveGrenade();
		}

	}


	// If is bash, there is no time-limit
	if(level.in_bash)
	{
		level.clock destroy();
		objective_delete(0);
		objective_delete(1);
		maps\mp\gametypes\_weapons::deletePlacedEntity("misc_turret");
		maps\mp\gametypes\_weapons::deletePlacedEntity("misc_mg42");
		return;
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


stratTime_g_speed()
{
	// Disable players movement
	maps\mp\gametypes\_cvar_system::restoreCvarQuiet("g_speed"); // - just to make sure cvar is not set quiet from last round
	maps\mp\gametypes\_cvar_system::setCvarQuiet("g_speed", 0);

	wait level.fps_multiplier * level.strat_time;

	maps\mp\gametypes\_cvar_system::restoreCvarQuiet("g_speed");
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
			player.progressbackground destroy();

		if(isdefined(player.progressbar))
			player.progressbar destroy();

		player unlink();
		player enableWeapon();
	}

	objective_delete(0);
	objective_delete(1);

	// Say: Axis/Allies Win   after 2 sec
	level thread announceWinner(roundwinner, 2);




	if(roundwinner == "allies")
	{
		if (game["is_halftime"])
			game["half_2_allies_score"]++;
		else
			game["half_1_allies_score"]++;
	}
	else if(roundwinner == "axis")
	{
		if (game["is_halftime"])
			game["half_2_axis_score"]++;
		else
			game["half_1_axis_score"]++;
	}

	// Team Scores:
	game["Team_1_Score"] = game["half_1_axis_score"] + game["half_2_allies_score"];
	game["Team_2_Score"] = game["half_2_axis_score"] + game["half_1_allies_score"];

	if (game["is_halftime"])
	{
		game["allies_score"] = game["Team_1_Score"];
		game["axis_score"] = game["Team_2_Score"];
	}
	else
	{
		game["allies_score"] = game["Team_2_Score"];
		game["axis_score"] = game["Team_1_Score"];
	}

	// Set Score
	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);

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



	// Show score even if is disabled
	level maps\mp\gametypes\_hud_teamscore::showScore(0.5);


	if (level.in_bash)
	{
		wait level.fps_multiplier * 3;
		if (!level.pam_mode_change)
        map_restart(false);
		return;
	}



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









	if(game["roundsplayed"] > 0)
	{
		thread maps\mp\gametypes\_hud::PAM_Header();
		thread maps\mp\gametypes\_hud::ScoreBoard(false); // false means is_halftime_or_mapend
	}





	if(level.round_endtime > 0 && game["roundsplayed"] > 0)
	{
		if (game["do_timeout"] == true)
			thread maps\mp\gametypes\_hud::Timeout(); // show at the end of the round we are going to timeout
		else
			thread maps\mp\gametypes\_hud::NextRound(level.round_endtime);


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

		Round start  | End of Round | Next round        | Case selected weapon is
		Spawned weap | Weapon slots | Spawned weap      | changed to thompson during round
		--------------------------------------------------------------------------------
		M1			| M1	-		| M1	-			| thomp	-
		M1			| -		M1		| M1	-			| thomp	-
		M1			| M1	KAR		| M1	KAR			| thomp	KAR
		M1			| KAR	M1		| KAR	M1		   +| thomp M1
		M1			| KAR	MP44	| KAR	MP44		| thomp	MP44
		M1			| KAR	-		| KAR	-			| thomp	-
		M1			| -		KAR		| KAR	-			| thomp	-
		M1			| M1	thomp	| M1	thomp		| thomp	-
		M1			| thomp	M1		| thomp M1		   +| thomp M1
		M1			| -		-		| M1	-			| thomp	-

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
			if (player.spawnedWeapon != player.pers["weapon"])
			{
				weapon1 = player.pers["weapon"];
				// In case we change to weapon, that is actually in slot, avoid duplicate
				if (weapon1 == weapon2)
					weapon2 = "none";
			}

			// Give player spawned weapon if there is no saveable weapons
			if (weapon1 == "none" && weapon2 == "none")
				weapon1 = player.pers["weapon"];

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

	// Used for balance team at the end of the round
	level notify("restarting");

	if (!level.pam_mode_change)
		map_restart(true);


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
					player.progressbackground = maps\mp\gametypes\_hud_system::addHUDClient(player, 0, 104, undefined, undefined, "center", "middle", "center_safearea", "center_safearea");
				player.progressbackground maps\mp\gametypes\_hud_system::showHUDSmooth(0.2, 0, 0.5); // show from 0 to 0.5
				player.progressbackground setShader("black", (level.barsize + 4), 12);

				// Bar - white bar progress
				if(!isdefined(player.progressbar))
					player.progressbar = maps\mp\gametypes\_hud_system::addHUDClient(player, int(level.barsize / (-2.0)), 104, undefined, undefined, "left", "middle", "center_safearea", "center_safearea");
				player.progressbar maps\mp\gametypes\_hud_system::showHUDSmooth(0.2, 0, 1); // show from 0 to 1
				player.progressbar setShader("white", 0, 10);
				player.progressbar scaleOverTime(level.planttime, level.barsize, 10);


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
					player.progressbackground destroy();
					player.progressbar destroy();
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
					player maps\mp\gametypes\_player_stat::AddScore(1);

					iprintln(&"MP_EXPLOSIVESPLANTED");

					level thread soundPlanted(player);

					bombtrigger thread bomb_think();
					bombtrigger thread bomb_countdown();

					level notify("bomb_planted");

					// Remove clock if bomb is planted
					if (isDefined(level.clock))
						level.clock maps\mp\gametypes\_hud_system::removeHUD();

					return;	//TEMP, script should stop after the wait level.frame
				}
				else
				{
					if(isdefined(player.progressbackground))
						player.progressbackground maps\mp\gametypes\_hud_system::removeHUD();

					if(isdefined(player.progressbar))
						player.progressbar maps\mp\gametypes\_hud_system::removeHUD();

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
					player.progressbackground = maps\mp\gametypes\_hud_system::addHUDClient(player, 0, 104, undefined, undefined, "center", "middle", "center_safearea", "center_safearea");
				player.progressbackground maps\mp\gametypes\_hud_system::showHUDSmooth(0.2, 0, 0.5); // show from 0 to 0.5
				player.progressbackground setShader("black", (level.barsize + 4), 12);

				// Bar - white bar progress
				if(!isdefined(player.progressbar))
					player.progressbar = maps\mp\gametypes\_hud_system::addHUDClient(player, int(level.barsize / (-2.0)), 104, undefined, undefined, "left", "middle", "center_safearea", "center_safearea");
				player.progressbar maps\mp\gametypes\_hud_system::showHUDSmooth(0.2, 0, 1); // show from 0 to 1
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
					player.progressbackground destroy();
					player.progressbar destroy();
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
					player maps\mp\gametypes\_player_stat::AddScore(1);

					level thread endRound(player.pers["team"]);

					return;	//TEMP, script should stop after the wait level.frame
				}
				else
				{
					if(isdefined(player.progressbackground))
						player.progressbackground destroy();

					if(isdefined(player.progressbar))
						player.progressbar destroy();

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

	wait level.fps_multiplier * 2;

	attacksounds["american"] = "US_mp_cmd_movein";
	attacksounds["british"] = "UK_mp_cmd_movein";
	attacksounds["russian"] = "RU_mp_cmd_movein";
	attacksounds["german"] = "GE_mp_cmd_movein";
	defendsounds["american"] = "US_mp_defendbomb";
	defendsounds["british"] = "UK_mp_defendbomb";
	defendsounds["russian"] = "RU_mp_defendbomb";
	defendsounds["german"] = "GE_mp_defendbomb";

	level playSoundOnPlayers(attacksounds[game[game["attackers"]]], game["attackers"]);
	level playSoundOnPlayers(defendsounds[game[game["defenders"]]], game["defenders"]);
}

showBombTimers()
{
	timeleft = (level.bombtimer - (getTime() - level.bombtimerstart) / 1000);

	level.bombtimerhud = maps\mp\gametypes\_hud_system::addHUD(6, 76, undefined, undefined, "left", "top", "left", "top");
	level.bombtimerhud maps\mp\gametypes\_hud_system::showHUDSmooth(0.1);
	//level.bombtimerhud.foreground = true;  // visible if menu opened
	level.bombtimerhud setClock(timeleft, 60, "hudStopwatch", 48, 48);
}

deleteBombTimers()
{
	if (isDefined(level.bombtimerhud))
		level.bombtimerhud maps\mp\gametypes\_hud_system::removeHUD();
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

showDeadIconIfDead()
{

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
	self.pers["team"] = assignment;
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["savedmodel"] = undefined;

	// Players on a team but without a weapon or dead show as dead since they can not get in this round
	if(self.sessionstate != "playing")
		self.statusicon = "hud_status_dead";

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
	self.pers["team"] = "allies";
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["savedmodel"] = undefined;

	// Players on a team but without a weapon or dead show as dead since they can not get in this round
	if(self.sessionstate != "playing")
		self.statusicon = "hud_status_dead";

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
	self.pers["team"] = "axis";
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["savedmodel"] = undefined;

	// Players on a team but without a weapon or dead show as dead since they can not get in this round
	if(self.sessionstate != "playing")
		self.statusicon = "hud_status_dead";

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


	// After selecting a weapon, show "ingame" menu when ESC is pressed
	self setClientCvar("g_scriptMainMenu", game["menu_ingame"]);

	// If newly selected weapon is same as actualy selected weapon and is in player slot -> do nothing
	if(isdefined(self.pers["weapon"]))
	{
		primary = self getWeaponSlotWeapon("primary");
		primaryb = self getWeaponSlotWeapon("primaryb");

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
			self.spawnedWeapon = weapon; // to determine is weapon was changed during round

			// Remove weapon from slot (can be "none", takeWeapon() will take it)
			self takeWeapon(self getWeaponSlotWeapon("primary"));
			self takeWeapon(self getWeaponSlotWeapon("primaryb"));

			// Give weapon to primary slot
			self setWeaponSlotWeapon("primary", weapon);
			self giveMaxAmmo(weapon);

			// Give pistol to secondary slot + give grenades and smokes
			maps\mp\gametypes\_weapons::givePistol();
			maps\mp\gametypes\_weapons::giveSmoke(0);
			thread giveGrenadesInReadyup();

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
		// Free weapon chaging is allowed in strat-time - only if player didnt take/drop weapon
		if(!level.matchStarted || (level.in_strattime && self.dropped_weapons == 0 && self.taked_weapons == 0 && self.spawnsInStrattime < 2))
		{
			if(isDefined(self.pers["weapon"]))
			{
				self.pers["weapon"] = weapon;
				self.spawnedWeapon = weapon; // to determine is weapon was changed during round

				primary = self getWeaponSlotWeapon("primary");
				primaryb = self getWeaponSlotWeapon("primaryb");

				// Remove weapon from first slot
				self takeWeapon(primary);

				// If newly selected weapon is already in secondary slot, give pistol instead of duplicate weapon!
				// If I select the same weapon that is already in slot, it means I want to remove secondary weapon to pistol
				if (weapon == primaryb || (self.pers["weapon"] == weapon && (primary == weapon)))
				{
					self takeWeapon(primaryb);
					maps\mp\gametypes\_weapons::givePistol();
				}

				// Set new selected weapon into first slot
				self setWeaponSlotWeapon("primary", weapon);
				self giveMaxAmmo(weapon);

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


// Give grenades after a few seconds!
giveGrenadesInReadyup()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("spawned");
	self notify("kill_giveGrenadesInReadyup");
	self endon("kill_giveGrenadesInReadyup");

	if (!isDefined(self.lastWeaponChangeTime))
		self.lastWeaponChangeTime = 0;

	// Check timer
	timeNow = getTime();
	diffTime = timeNow - self.lastWeaponChangeTime;


	// Give new grenade only after 5 sec!
	grenades = self maps\mp\gametypes\_weapons::getFragGrenadeCount();

	if (grenades == 0 && diffTime < 5000)
		wait level.fps_multiplier * (diffTime / 1000);

	self.lastWeaponChangeTime = getTime();

	maps\mp\gametypes\_weapons::giveGrenade();
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
	}

}



serverInfo()
{

	title = "PAM mode:\n";
	value = level.pam_mode + "\n";


	if (level.timelimit > 0)
	{
		title +="Total time limit\n";
		value += level.timelimit + "\n";
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
		if (level.halfscore != 0)
		{
			title +="Score limit 1st half:\n";
			value += level.halfscore + "\n";
		}
		else
		{
			title +="Round limit 1st half:\n";
			value += level.halfround + "\n";
		}

		if (level.scorelimit != 0)
		{
			title +="Score limit 2nd half:\n";
			value += level.scorelimit + "\n";
		}
		else
		{
			title +="Round limit 2nd half:\n";
			value += level.matchround + "\n";
		}
	}

	title +="Count round draws:\n";
	if (level.countdraws == 0)
		value += "No" + "\n";
	else
		value += "Yes" + "\n";


	title +="Overtime:\n";
	if (level.scr_overtime)
		value += "Yes" + "\n";
	else
		value += "No" + "\n";



	setCvar("ui_serverinfo_left1", title);
	makeCvarServerInfo("ui_serverinfo_left1", title);

	setCvar("ui_serverinfo_left2", value);
	makeCvarServerInfo("ui_serverinfo_left2", value);







	title ="Strat time:\n";
	value = plural_s(level.strat_time, "second") + "\n";

	title +="Plant time:\n";
	value += plural_s(level.planttime, "second") + "\n";

	title +="Defuse time:\n";
	value += plural_s(level.defusetime, "second") + "\n";

	title +="Round length:\n";
	value += plural_s(level.roundlength, "minute") + "\n";




	setCvar("ui_serverinfo_right1", title);
	makeCvarServerInfo("ui_serverinfo_right1", title);

	setCvar("ui_serverinfo_right2", value);
	makeCvarServerInfo("ui_serverinfo_right2", value);




	motd = getCvar("scr_motd");
	motd_final = "";
	skipNextChar = false;
	for (i=0; i < motd.size; i++)
	{
		if (skipNextChar)
		{
			skipNextChar = false;
			continue;
		}

		if (motd[i] == "\\" && i < motd.size-1 && motd[i+1] == "n")
		{
			skipNextChar = true;
			motd_final += "\n";
		}
		else
			motd_final += "" + motd[i];

	}

	setCvar("ui_motd", motd_final);
	makeCvarServerInfo("ui_motd", "");
}

// Add char 's' to the end of the string if num is > 1
plural_s(num, text)
{
	if (num > 1)
		text += "s";
	return num + " " + text;
}



deadchat()
{

	//na 1 visible
	//na 0 not visible

	if (!level.scr_auto_deadchat)
		return;

	//

	for(;;)
	{
		dc = level.deadchat;

		if ( (level.in_readyup || level.in_timeout || level.roundended) && dc == 0)
		{
			maps\mp\gametypes\_cvar_system::restoreCvarQuiet("g_deadChat");
			maps\mp\gametypes\_cvar_system::setCvarQuiet("g_deadChat", 1); //setcvar("g_deadchat", 1);
		}


		if ((level.roundstarted || level.in_strattime) && !level.roundended && dc == 1)
		{
			maps\mp\gametypes\_cvar_system::restoreCvarQuiet("g_deadChat");
			maps\mp\gametypes\_cvar_system::setCvarQuiet("g_deadChat", 0); //setcvar("g_deadchat", 0);
		}

		wait level.fps_multiplier * 1;
	}
}
