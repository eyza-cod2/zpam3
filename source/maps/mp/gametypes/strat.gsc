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

	// Precache gametype specific stuff
	if (game["firstInit"])
		precache();

	// Init all shared modules in this pam (scripts with underscore)
	InitModules();
}

// Precache specific stuff for this gametype
// Is called only once per map
precache()
{
	precacheString2("STRING_FLY_ENABLED", &"Enabled");
	precacheString2("STRING_FLY_DISABLED", &"Disabled");
	precacheString2("STRING_ENABLE_HOLD_SHIFT", &"Enable: Hold ^3Bash");
	precacheString2("STRING_DISABLE_HOLD_SHIFT", &"Disable: Hold ^3Bash");
	precacheString2("STRING_GRENADE_EXPLODES_IN", &"Grenade explodes in");
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
		setTeamScore("allies", game["allies_score"]);

		game["axis_score"] = 0;
		setTeamScore("axis", game["axis_score"]);


		// Other variables
		game["state"] = "playing";
	}




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


	allowed[0] = "sd";
	allowed[1] = "bombzone";
	maps\mp\gametypes\_gameobjects::main(allowed);



	thread maps\mp\gametypes\_pam::PAM_Header();
	level Show_HUD_Global();

	setClientNameMode("auto_change");

	serverInfo();

	thread sv_cheats();
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
	wait level.frame; // wait untill all functions are inicializes
	self thread Run_Strat();
}

// This function is called as last after all events are processed
onAfterConnected()
{
	// Spectator team
	if (self.pers["team"] == "none" || self.pers["team"] == "spectator")
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

	if (isDefined(self.bot))
	{
		kick(self.bot getEntityNumber());
	}

	if (isDefined(self.botLockPosition))
	{
		self.botLockPosition delete();
	}
}


onPlayerDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// Print damage
	if(isDefined(eAttacker) && isPlayer(eAttacker))
	{
		if (eAttacker == self)
		{
			// You inflicted 28 damage to yourself
			self iprintln("^7You inflicted ^1" + iDamage + "^7 damage to yourself");
			//self iprintln("^1Hit by-self for ^3" + iDamage + " ^1 damage^7"); // Hit Player damage notice
		}
		else
		{
			// You inflicted 28 damage to BOT1
			eAttacker iprintln("^7You inflicted ^2" + iDamage + "^7 damage to " + self.name + " (hitLoc: " + sHitLoc + ")");
			//eAttacker iprintln("^2Hit ^7" + self.name + "^2 for ^1" + iDamage + " ^2 damage^7"); // Attacker damage notice

			// Bot1 inflicted 12 damage to you
			self iprintln(eAttacker.name + "^7 inflicted ^1" + iDamage + "^7 damage to you (hitLoc: " + sHitLoc + ")");
			//self iprintln("^1Hit by ^7" + eAttacker.name + "^1 for ^3" + iDamage + " ^1 damage^7"); // Hit Player damage notice
		}
	}

	// Prevent damage if flaying is enabled
	if (self.flaying_enabled)
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

	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";

	// Used to spawn player in same location he dies
	// Spawn on same location only if was killed by bullet, bash or grenade
	if ((sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_MELEE" || sMeansOfDeath == "MOD_GRENADE_SPLASH"))
	{
		self.spawnOrigin = self.origin;
		self.spawnAngles = self.angles;
	}
	else
	{
		self.spawnOrigin = undefined;
		self.spawnAngles = undefined;
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

	wait level.fps_multiplier * 1.5;

	if(isDefined(body))
		body delete();

	if(isDefined(self.pers["weapon"]))
		self thread spawnPlayer();
}



sv_cheats()
{
	wait level.fps_multiplier * 0.2;

	setCvar("sv_cheats", 1);
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

	maps\mp\gametypes\_weapons::givePistol();
	maps\mp\gametypes\_weapons::giveBinoculars();

	self setSpawnWeapon(self.pers["weapon"]);

	if (!maps\mp\gametypes\_bots::isBot())
		self thread Watch_Grenade_Throw(true);

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
	assertMsg("Not needed");
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

	self.sessionteam = assignment;
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
	if(self.pers["team"] == "allies" || !maps\mp\gametypes\_teams::getJoinTeamPermissions("allies"))
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
	if(self.pers["team"] == "axis" || !maps\mp\gametypes\_teams::getJoinTeamPermissions("axis"))
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

		// Remove weapon from slot (can be "none", takeWeapon() will take it)
		self takeWeapon(self getWeaponSlotWeapon("primary"));
		self takeWeapon(self getWeaponSlotWeapon("primaryb"));

		// Give weapon to primary slot
		self setWeaponSlotWeapon("primary", weapon);
		self giveMaxAmmo(weapon);

		// Give pistol to secondary slot + give grenades and smokes
		maps\mp\gametypes\_weapons::givePistol();

		// Switch to main weapon
		self switchToWeapon(weapon);;
	}
	else
	{
		self.pers["weapon"] = weapon;

		spawnPlayer();
	}


	// Used in wepoan_limiter
	self notify("weapon_changed", weapon, leavedWeapon, leavedWeaponFromTeam);
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







// * Training Nade Script by Matthias lorenz * (_slightly_ modified by zar & z0d)


Run_Strat()
{
	self.flying = false;
	self.flaying_enabled = true;
	self.recording = false;

	// Ignore bots
	if (maps\mp\gametypes\_bots::isBot())
		return;

	self thread Show_HUD_Player();

	self thread Key_Toggle_FlyMode();
	self thread Key_SavePosition();
	self thread Key_LoadPosition();

	if (getCvarInt("sv_punkbuster") == 0)
	{
		self thread Key_AddBot();
		self thread Key_RecordBot();
		self thread Key_PlayRecord();
	}
}

// Hold Shift to enable / disable fly mode
Key_Toggle_FlyMode()
{
	self endon("disconnect");

	for(;;)
	{
		waittime = 0;
		while (self meleebuttonpressed() && !self useButtonPressed() && self playerAds() == 0)
		{
			waittime += level.frame;

			if (waittime > 1.0)
			{
				if (!self.flaying_enabled) {
					self iprintln("^3Training nade fly mode turned ^1on");
					self.flaying_enabled = 1;
				} else {
					self iprintln("^3Training nade fly mode turned ^1off");
					self.flaying_enabled = 0;
				}
				break;
			}
			wait level.frame;
		}
		wait level.fps_multiplier * 0.2;
	}
}

// Double press Shift
Key_SavePosition()
{
	self endon("disconnect");

	for(;;)
	{
		if(self meleeButtonPressed())
		{
			catch_next = false;

			for(i=0; i<=0.10; i+=0.01)
			{
				if(catch_next && self meleeButtonPressed())
				{
					self thread savePos();
					wait level.fps_multiplier * 1;
					break;
				}
				else if(!(self meleeButtonPressed()))
					catch_next = true;

				wait level.fps_multiplier * 0.01;
			}
		}
		wait level.frame;
	}
}

// Double press F key
Key_LoadPosition()
{
	self endon("disconnect");

	for(;;)
	{
		if(self useButtonPressed())
		{
			catch_next = false;

			for(i=0; i<=0.10; i+=0.01)
			{
				if(catch_next && self useButtonPressed())
				{
					self thread loadPos();
					wait level.fps_multiplier * 1;
					break;
				}
				else if(!(self useButtonPressed()))
					catch_next = true;

				wait level.fps_multiplier * 0.01;
			}
		}

		wait level.frame;
	}
}

// Hold Shift to enable / disable fly mode
Key_AddBot()
{
	self endon("disconnect");

	for(;;)
	{
		waittime = 0;
		while (self meleebuttonpressed() && self useButtonPressed())
		{
			waittime += level.frame;

			if (waittime > 1.0)
			{
				self add_bot();
				break;
			}
			wait level.frame;
		}
		wait level.fps_multiplier * 0.2;
	}
}

Key_RecordBot()
{
	self endon("disconnect");

	for(;;)
	{
		waittime = 0;
		while (self attackbuttonpressed() && self useButtonPressed() && !self meleebuttonpressed())
		{
			waittime += level.frame;

			if (waittime > 1.0)
			{
				if (self.recording)
				{
					self.recording = false;
				}
				else
				{
					self.recording = true;
					self thread record();
				}
				// Wait untill keys are released
				while (self attackbuttonpressed() && self useButtonPressed() && !self meleebuttonpressed())
					wait level.fps_multiplier * 0.2;

				break;
			}
			wait level.frame;
		}
		wait level.fps_multiplier * 0.2;
	}
}

// Hold Shift to enable / disable fly mode
Key_PlayRecord()
{
	self endon("disconnect");
	for(;;)
	{
		waittime = 0;
		while (self useButtonPressed() && !self attackbuttonpressed() && !self meleebuttonpressed())
		{
			waittime += level.frame;

			if (waittime > 1.0)
			{
				self thread playRecord();
				break;
			}
			wait level.frame;
		}
		wait level.fps_multiplier * 0.2;
	}
}



// This is called when player spawns
Watch_Grenade_Throw(is_strat)
{
	self endon("disconnect");

	// Make sure only 1 thred is running
	self notify("end_Watch_Grenade_Throw");
	self endon("end_Watch_Grenade_Throw");

	nadename = self maps\mp\gametypes\_weapons::GetGrenadeTypeName();
	smokename = self maps\mp\gametypes\_weapons::GetSmokeTypeName();

	if (is_strat)
	{
		self giveWeapon(nadename);
		self giveWeapon(smokename);

		self setWeaponClipAmmo(nadename, 1);
		self setWeaponClipAmmo(smokename, 1);
	}

	grenade_count_old	 = self maps\mp\gametypes\_weapons::getFragGrenadeCount();
	smokegrenade_count_old = self maps\mp\gametypes\_weapons::getSmokeGrenadeCount();

	for(;;)
	{
		grenade_count 	= self maps\mp\gametypes\_weapons::getFragGrenadeCount();
		smokegrenade_count 	= self maps\mp\gametypes\_weapons::getSmokeGrenadeCount();

		if(grenade_count != grenade_count_old || smokegrenade_count != smokegrenade_count_old) {


			if (is_strat)
			{
				// Refill grenades
				self setWeaponClipAmmo(self maps\mp\gametypes\_weapons::GetGrenadeTypeName(), 1);
				self setWeaponClipAmmo(self maps\mp\gametypes\_weapons::GetSmokeTypeName(), 1);

				// Show explode in timer text
				if (grenade_count != grenade_count_old)
					self thread HUD_Grenade_Releases_In();
			}

			// Follow nade if enabled
			if (self.flaying_enabled)
			{
				// Loop grenades in map
				grenades = getentarray("grenade","classname");
				for(i=0;i<grenades.size;i++) {
					if(isDefined(grenades[i].origin) && !isDefined(grenades[i].running)) {
						// Only if it's your own nade (close to the player)
						if(distance(grenades[i].origin, self.origin) < 160) {
							grenades[i].running = true;
							grenades[i] thread Fly(self);
						}
					}
				}
			}
		}

		grenade_count_old	 = grenade_count;
		smokegrenade_count_old = smokegrenade_count;

		wait level.fps_multiplier * 0.1;
	}
}

Fly(player)
{
	player notify("flying_ende");
	player endon("flying_ende");
	player endon("disconnect");

	player.flying = true;

	old_player_origin = player.origin;

	// Link script_model to grenade from players position offset
	player.hilfsObjekt = spawn("script_model", player.origin);
	player.hilfsObjekt.angles = player.angles;
	player.hilfsObjekt linkto(self);

	// Wait untill greande is fully throwed to avoid interrupted jump
	wait level.fps_multiplier * 0.13;

	// Link player to that script_model
	player setOrigin(player.hilfsObjekt.origin);
	player linkto(player.hilfsObjekt);



	old_origin = (0,0,0);

	attack_button_pressed = false;
	use_button_pressed = false;

	while(isDefined(self))
	{
		// If grenade stops moving - break loop
		if(self.origin == old_origin)
			break;

		old_origin = self.origin;

		// Stop moving
		if(player attackButtonPressed()) {
			attack_button_pressed = true;
			break;
		}

		// Restore position
		if(player useButtonPressed()) {
			use_button_pressed = true;
			break;
		}

		wait level.frame;
	}

	player.hilfsObjekt unlink();


	if(!use_button_pressed)
	{
		if(attack_button_pressed)
		{
			for(i=0;i<3.5;i+=0.1) {

				wait level.fps_multiplier * 0.1;
				if(player useButtonPressed()) break;
			}
		}
		else
		{
			player.hilfsObjekt moveto(player.origin+(0,0,20),0.1);
			wait level.fps_multiplier * 0.2;

			for(i=0;i<2;i+=0.1)
			{
				wait level.fps_multiplier * 0.1;
				if(player useButtonPressed()) break;
			}
		}
	}

	player.hilfsObjekt moveto(old_player_origin,0.1);
	wait level.fps_multiplier * 0.2;

	player unlink();
	if(isDefined(player.hilfsObjekt)) player.hilfsObjekt delete();

	player.flying = false;
}


loadPos()
{
	if(!isDefined(self.saved_origin))
		{
			self iprintln("^1There is no previous ^3position ^1to load");
			return;
		}
	else
		{
			self setPlayerAngles(self.saved_angles);
			self setOrigin(self.saved_origin);
			self iprintln("^3Position ^1loaded");
		}

}


savePos()
{
	self.saved_origin = self.origin;
	self.saved_angles = self.angles;
	self iprintln("^3Position ^1saved");
}


Show_HUD_Global()
{
	level.granade1 = addHUD(-35, 80, 1.2, (.8,1,1), "right", "top", "right");
	level.granade1 setText(&"Grenade flying");

	// Enabled / Disabled
	// Disable: Hold Shift / Enable: Hold Shift

	level.granade2 = addHUD(-35, 130, .9, (.8,1,1), "right", "top", "right");
	level.granade2 setText(&"Stop: Press ^3Left mouse");

	level.granade3 = addHUD(-35, 140, .9, (.8,1,1), "right", "top", "right");
	level.granade3 setText(&"Return: Press ^3Use");



	level.positionlogo = addHUD(-35, 180, 1.2, (.8,1,1), "right", "top", "right");
	level.positionlogo setText(&"Position");

	level.savelogo = addHUD(-35, 200, .9, (.8,1,1), "right", "top", "right");
	level.savelogo setText(&"Save: Press ^3Bash ^7twice");

	level.loadlogo = addHUD(-35, 210, .9, (.8,1,1), "right", "top", "right");
	level.loadlogo setText(&"Load: Press ^3Use ^7twice");




	level.trainingdummy = addHUD(-35, 250, 1.2, (.8,1,1), "right", "top", "right");
	level.trainingdummy setText(&"Training Bot");

	if (getCvarInt("sv_punkbuster") == 0)
	{
		level.trainingdummykey = addHUD(-35, 270, .9, (.8,1,1), "right", "top", "right");
		level.trainingdummykey setText(&"Spawn: Hold ^3Bash ^7+ ^3Use");

		level.trainingdummyrecord = addHUD(-35, 280, .9, (.8,1,1), "right", "top", "right");
		level.trainingdummyrecord setText(&"Record: Hold ^3Left mouse ^7+ ^3Use");

		level.trainingdummyplay = addHUD(-35, 290, .9, (.8,1,1), "right", "top", "right");
		level.trainingdummyplay setText(&"Play: Hold ^3Use");
	}
	else
	{
		level.trainingdummywarn = addHUD(-35, 270, .9, (1,1,0), "right", "top", "right");
		level.trainingdummywarn setText(&"Disable Punkbuster!");
	}
}


Show_HUD_Player()
{
	self endon("disconnect");

	// Enabled / Disabled
	self.nadelogo = addHUDClient(self, -35, 100, 1.2, (1,1,1), "right", "top", "right");

	// Disable: Hold Shift
	// Enable: Hold Shift
	self.pressad = addHUDClient(self, -35, 120, .9, (0.8,1,1), "right", "top", "right");

	for(;;)
	{
		if (self.flaying_enabled)
		{
			self.nadelogo.color = (.73, .99, .73);
			self.nadelogo setText(game["STRING_FLY_ENABLED"]);
			self.pressad setText(game["STRING_DISABLE_HOLD_SHIFT"]);
		}
		else
		{
			self.nadelogo.color = (1, .66, .66);
			self.nadelogo setText(game["STRING_FLY_DISABLED"]);
			self.pressad setText(game["STRING_ENABLE_HOLD_SHIFT"]);
		}
		wait level.frame * 3;
	}
}

HUD_Grenade_Releases_In()
{
	self endon("disconnect");

	// This make sure only 1 thread will run
	self notify("end_hud_grenade_explode");
	self endon("end_hud_grenade_explode");

	if (isdefined(self.c))
		self.c removeHUD();
	if(isdefined(self.exin))
		self.exin removeHUD();

	self.exin = addHUDClient(self, -80, 310, 1.2, (.8,1,1), "right", "top", "right");
	self.exin setText(game["STRING_GRENADE_EXPLODES_IN"]);

	self.c = addHUDClient(self, -35, 310, 1.2, (.8,1,1), "right", "top", "right");
	self.c settenthsTimer(3.5);

	wait level.fps_multiplier * 3.5;

	self.c removeHUD();
	self.exin removeHUD();
}








add_bot()
{
	if (!isDefined(self.bot))
	{
		iprintln(self.name + " is spawning bot.");

		self.bot = maps\mp\gametypes\_bots::addBot();

		if (!isDefined(self.bot))
		{
			self iprintln("^1Bot adding failed");
			return;
		}
	}
	self.bot thread handle_bot(self);
}

handle_bot(player)
{
	self endon("disconnect");
	player endon("disconnect");

	// Wait untill player move from spawn position
	pos = player.origin;
	angle = player.angles;
	player iprintlnbold("Move away to spawn a bot.");
	while (distance(pos, player.origin) < 50)
		wait level.fps_multiplier * 1;


	// This make sure only one thread is running on bot
	self notify("end_bot_brain");
	self endon("end_bot_brain");

	self.pers["team"] = player.pers["team"];
	self.pers["weapon"] = player.pers["weapon"];
	self.spawnOrigin = pos;
	self.spawnAngles = angle;
	self.flaying_enabled = false;

	self spawnPlayer(); // will be spawned at specified position above

	if (!isDefined(self.botLockPosition))
	{
		self.botLockPosition = spawn("script_model", pos);
		self.botLockPosition.angles = angle;
		self.botLockPosition thread obj();
	}
	else
	{
		self.botLockPosition.origin = pos;
		self.botLockPosition.angles = angle;
	}

	wait level.fps_multiplier * .25;

	for (;;)
	{
		self unlink();
		while(!isAlive(self))	wait level.fps_multiplier * 1;

		self setOrigin(self.botLockPosition.origin); // make sure player is always centered with script_model (for proper playing)
		self linkto(self.botLockPosition);
		self disableWeapon();

		while(isAlive(self))	wait level.fps_multiplier * 1;
	}
}


obj()
{
	newobjpoint = newHudElem2();
	newobjpoint.name = "A";
	newobjpoint.x = self.origin[0];
	newobjpoint.y = self.origin[1];
	newobjpoint.z = self.origin[2];
	newobjpoint.alpha = 1;
	newobjpoint.archived = true;
	newobjpoint setShader("objpoint_default", 2, 2);
	newobjpoint setwaypoint(true);

	for(;;)
	{
		wait level.frame;

		if (!isDefined(self)) // obj was deleted
		{
			newobjpoint destroy();
			break;
		}

		newobjpoint.x = self.origin[0];
		newobjpoint.y = self.origin[1];
		newobjpoint.z = self.origin[2];
	}
}


record()
{
	self endon("disconnect");

	// Show black bar
	self.kc_topbar = newClientHudElem2(self);
	self.kc_topbar.archived = false;
	self.kc_topbar.x = 0;
	self.kc_topbar.y = 0;
	self.kc_topbar.horzAlign = "fullscreen";
	self.kc_topbar.vertAlign = "fullscreen";
	self.kc_topbar.alpha = 0.5;
	self.kc_topbar.sort = 99;
	self.kc_topbar setShader("black", 640, 80);

	self.kc_bottombar = newClientHudElem2(self);
	self.kc_bottombar.archived = false;
	self.kc_bottombar.x = 0;
	self.kc_bottombar.y = 400;
	self.kc_bottombar.horzAlign = "fullscreen";
	self.kc_bottombar.vertAlign = "fullscreen";
	self.kc_bottombar.alpha = 0.5;
	self.kc_bottombar.sort = 99;
	self.kc_bottombar setShader("black", 640, 80);


	self iprintlnbold("Recording in");

	origin_old = self.origin;
	for (i = 3; i > 0; i--)
	{
		self iprintlnbold(i);
		wait level.fps_multiplier;

		if (distance(self.origin, origin_old) > 20)
		{
			self.kc_topbar destroy2();
			self.kc_bottombar destroy2();

			self iprintlnbold("^3Record canceled. You moved!");

			return;
		}
	}

	self iprintlnbold("Recording...");
	self iprintlnbold("^2Go Go Go!");

	self iprintlnbold(" ");
	self iprintlnbold(" ");
	self iprintlnbold(" ");


	self.recordsPos = [];
	self.recordsAngle = [];

	time_not_moving = 0;
	while(self.recording)
	{
		self.recordsPos[self.recordsPos.size] = self.origin;
		self.recordsAngle[self.recordsAngle.size] = self.angles;
		origin_old = self.origin;

		wait level.fps_multiplier * 0.25;

		if (origin_old == self.origin)
			time_not_moving++;
		else
			time_not_moving = 0;

		if (time_not_moving == 3)
			self iprintlnbold("Dont move to stop recording");

		if (time_not_moving >= 8)
			self.recording = false;
	}

	self iprintlnbold("^2Recording saved");

	self.kc_topbar destroy2();
	self.kc_bottombar destroy2();
}

playRecord()
{
	self endon("disconnect");

	// Make sure only 1 thread is running
	self notify("end_playRecord");
	self endon("end_playRecord");

	if (!isDefined(self.recordsPos) || self.recordsPos.size == 0)
	{
		self iprintlnbold("^1No record to play");
		return;
	}

	if (!isDefined(self.bot))
	{
		self iprintlnbold("^1Spawn a bot to play record");
		return;
	}

	if (self.recording)
	{
		self iprintlnbold("^1Cannot play record while recording!");
		return;
	}

	self iprintlnbold("Playing record...");
	self iprintlnbold(" ");
	self iprintlnbold(" ");
	self iprintlnbold(" ");
	self iprintlnbold(" ");

	if (isDefined(self.clock))
		self.clock destroy2();

	self.clock = newClientHudElem2(self);
	self.clock.font = "default";
	self.clock.fontscale = 2;
	self.clock.horzAlign = "center_safearea";
	self.clock.vertAlign = "top";
	self.clock.color = (1, 1, 1);
	self.clock.x = -25;
	self.clock.y = 445;
	self.clock setTimer(2 * 60);


	bot = self.bot;
	for (i = 0; i < self.recordsPos.size; i++)
	{
		// Cancel playing if bot is killed
		if (!isDefined(self.bot) || !isAlive(bot))
			break;

		// MoveTo( <point>, <time>, <acceleration time>, <deceleration time> )
		bot.botLockPosition moveto(self.recordsPos[i], 0.25);
		bot SetPlayerAngles(self.recordsAngle[i]);

		wait level.fps_multiplier * 0.25;
	}

	self.clock destroy2();
}
