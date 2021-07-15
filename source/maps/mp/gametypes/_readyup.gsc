#include maps\mp\gametypes\global\_global;

// Ready up can be called from startRound, _halftime, _timeout, _overtime

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_readyup", "BOOL", 0);
	registerCvar("scr_readyup_autoresume", "FLOAT", 0, 0, 10);
	registerCvar("scr_readyup_nadetraining", "BOOL", 0);
	registerCvar("scr_half_start_timer", "FLOAT", 0, 0, 10);

	if(game["firstInit"])
	{
		// Ready-up
		precacheString2("STRING_READYUP_WAITING_ON", &"Waiting on");
		precacheString2("STRING_READYUP_PLAYERS", &"Players");
		precacheString2("STRING_READYUP_YOUR_STATUS", &"Your Status");
		precacheString2("STRING_READYUP_READY", &"Ready");
		precacheString2("STRING_READYUP_NOT_READY", &"Not Ready");
		precacheString2("STRING_READYUP_CLOCK", &"Clock");

		precacheString2("STRING_READYUP_MODE", &"Ready-Up Mode");
		precacheString2("STRING_READYUP_MODE_HALF", &"Half-Time Ready-Up Mode");
		precacheString2("STRING_READYUP_MODE_TIMEOUT", &"Time-Out Ready-Up Mode");
		precacheString2("STRING_READYUP_MODE_OVERTIME", &"Overtime Ready-Up Mode");

		// problem with precache...
		game["STRING_READYUP_ALL_PlAYERS_ARE_READY"] = "All players are ready.";

		// Readyup (problem with precache...)
		game["readyup_team_allies"] = 		"^7You are on ^3Team Allies";
		game["readyup_team_axis"] = 		"^7You are on ^3Team Axis";
		game["readyup_team_spectator"] = 	"^7You are on ^3Team Spectator";
		game["readyup_press_activate"] = 	"Press the ^3[{+activate}] ^7button to Ready-Up.";
		game["readyup_hold_melee"] = 		"Double press the ^3[{+melee_breath}] ^7button to disable killing.";

		game["readyup_timeExpired"] = 		"Time to ready-up is over.";
		game["readyup_skip"] = 			"Set your team as ready to skip the Ready-Up.";

		game["objective_readyup"] = game["readyup_press_activate"] + "\n" + game["readyup_hold_melee"];
		game["objective_timeout"] = game["readyup_press_activate"];


		precacheString2("STRING_READYUP_SELECT_TEAM", &"Select team!");

		precacheString2("STRING_READYUP_RESUMING_IN", &"Resuming In");
		precacheString2("STRING_READYUP_KILLING_DISABLED", &"Disabled");
		precacheString2("STRING_READYUP_KILLING_ENABLED", &"Enabled");
		precacheString2("STRING_READYUP_KILLING", &"Killing");

		// HUD: Half_Start
		precacheString2("STRING_READYUP_MATCH_BEGINS_IN", &"Match begins in:");
		precacheString2("STRING_READYUP_MATCH_CONTINUES_IN", &"Match continues in:");
		precacheString2("STRING_READYUP_MATCH_RESUMES_IN", &"Match resumes in:");

		// Time to readyup expired
		precacheString2("STRING_READYUP_SET_YOUR_TEAM_AS_READY", &"Time is over. Setting one team ready will skip the Ready-up.");

		// Readyup warnings
		precacheString2("STRING_WARNING_PASSWORD_IS_NOT_SET", &"Warning: Server password is not set");
		precacheString2("STRING_WARNING_CHEATS_ARE_ENABLED", &"Warning: Cheats are Enabled");
		precacheString2("STRING_WARNING_PUNKBUSTER_IS_DISABLED", &"Warning: PunkBuster is Disabled");
		precacheString2("STRING_WARNING_CVARS_ARE_CHANGED", &"Warning: Server CVAR values are not equal to league rules");
		precacheString2("STRING_WARNING_SERVER_IS_CRACKED", &"Info: Server is cracked");

		precacheStatusIcon("party_ready");
		precacheStatusIcon("party_notready");
	}




	// Define level default variables
	if (!isDefined(level.in_readyup))
	{
		level.in_readyup = false;
		level.playersready = false;
	}

	// Define default variables
	if (!isDefined(game["Do_Ready_up"]))
	{
		game["Do_Ready_up"] = false;		// request from other scripts to run readyup
		game["readyup_first_run"] = level.scr_readyup;
	}

	// Start readyup if is request (halftime, timeout, overtime) or is enabled by cvar on fresh start
	// and is not already running (called by timeout)
	if (game["Do_Ready_up"] || game["readyup_first_run"])
	{
		Start_Readyup_Mode(false);
	}

}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_readyup": 		level.scr_readyup = value; return true;
		case "scr_readyup_autoresume": 	level.scr_readyup_autoresume = value; return true;
		case "scr_readyup_nadetraining":level.scr_readyup_nadetraining = value; return true;
		case "scr_half_start_timer": 	level.scr_half_start_timer = value; return true;
	}
	return false;
}

// Runs readyup mode
// in_middle_of_game is useful when timeout needs to be called in middle of game
// if is set, threads needs to be runned on existing players
Start_Readyup_Mode(runned_in_middle_of_game)
{
	level.in_readyup = true;
	game["Do_Ready_up"] = 0;	// reset request flag

	// HUD offsets
	level.hud_readyup_offsetX = -50;
	level.hud_readyup_offsetY = 20;

	// Because readyup can be called in middle of game (timeout),
	// attach readyup threads on existing players
	if (runned_in_middle_of_game)
	{
		// Run readyup thread to all existing players
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			player onConnected();
			player PrintTeamAndHowToUse();
		}
	}

	// Attach event for new players
	addEventListener("onConnected",     ::onConnected);
	addEventListener("onDisconnect",    ::onDisconnect);
	addEventListener("onSpawned",    ::onSpawned);
    addEventListener("onJoinedTeam",      ::onJoinedTeam);

	addEventListener("onPlayerDamaging",  ::onPlayerDamaging);
	addEventListener("onPlayerKilling",   ::onPlayerKilling);

	// Wait here untill there is atleast one player connected
	if (game["readyup_first_run"])
	{
		wait level.fps_multiplier * 0.1;
		for(;;)
		{
			players = getentarray("player", "classname");
			if (players.size > 0)
				break;
			wait level.fps_multiplier * 1;
		}
	}

	// Create "Ready-up Mode", "Waiting On X Players", "Clock", "Waring: PB is off.." atd...
    createLevelHUD();

	// Enable online renaming
	wait level.frame;
	setClientNameMode("auto_change");

	// Wait here until level.playersready is false
	Update_Players_Count();

	End_Readyup_Mode();
}

onConnected()
{
    // Main thread for player (monitoring F press)
    self thread playerReadyUpThread();

    // Check if all players are ready
    level thread Check_All_Ready(); // Sets level.playersready = true if all players are ready

    self.flying = false;
    self.flaying_enabled = true;
    self.readyupLastGrenadeThrowTime = 0;
}

onDisconnect()
{
    // Check if all players are ready
    level thread Check_All_Ready();
}

onSpawned()
{
	// We are in readyup, so change icons in scoreboard table
	if (self.isReady) 	self.statusicon = "party_ready";
	else				self.statusicon = "party_notready";

	self PrintTeamAndHowToUse();

	// Warning to select team if player is team none
	self HUD_SelectTeam();


        if (level.scr_readyup_nadetraining)
        {
		if (!level.in_timeout)
		{
			if (!maps\mp\gametypes\_bots::isBot())
				self thread maps\mp\gametypes\strat::Watch_Grenade_Throw(false);

	                // Keep adding grenades in readyup
	                thread giveGrenadesInReadyup();
		}
        }
}

onJoinedTeam(teamName)
{
	// We are in readyup, so change icons in scoreboard table
	if (self.isReady) 	self.statusicon = "party_ready";
	else				self.statusicon = "party_notready";
}

/*
Called when player is about to take a damage.
self is the player that took damage.
Return true to prevent the damage.
*/
onPlayerDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// Prevent damage in timeout or if players are ready
	if (level.in_timeout || level.playersready)
		return true;

	if (self.flying)
		return true;

	if (isPlayer(eAttacker) && self != eAttacker)
	{
		if (eAttacker.flying)
			return true;

		eAttacker enableKilling();
	}

	if (!self.pers["killer"])
		return true; // prevent_damage
}

/*
Called when player is about to be killed.
self is the player that was killed.
Return true to prevent the kill.
*/
onPlayerKilling(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Prevent kill in timeout, unless player is switching team
	if(level.in_timeout && !isdefined(self.switching_teams))
		return true;

	// In readyup simulate own kill function (kills are always prevented in readyup)
	if (self.pers["killer"] || (isPlayer(eAttacker) && self == eAttacker))
	{
		// Send out an obituary message to all clients about the kill
		obituary(self, eAttacker, sWeapon, sMeansOfDeath);

		self.sessionstate = "dead";

		self thread respawnOnKilled(sWeapon, deathAnimDuration);
	}

	// Always prevent kill in readyup
	return true;
}

respawnOnKilled(sWeapon, deathAnimDuration)
{
	self endon("disconnect");
	self endon("spawned");

	// Wait before dead body is spawned to allow double kills (bullets may stop in this dead body)
	// Ignore this for shotgun, because it create a smoke effect on dead body (for good feeling)
	if (sWeapon != "shotgun_mp")
		waittillframeend;

	// Clone players model for death animations
	body = undefined;
	if(!isdefined(self.switching_teams))
		body = self cloneplayer(deathAnimDuration);

	// Reset flag that means that this kill was executed while player is chaging sides via menu (suicide() was called)
	self.switching_teams = undefined;

	wait level.fps_multiplier * 2;

	// Delete dead body in readyup
	if(isDefined(body))
		body delete();

	// If player is not changing team, spawn them again
	if (isDefined(self.pers["weapon"]))
		self thread [[level.spawnPlayer]](); // run in thread because this func uses endon(spawned);
}



// Give grenades after a few seconds!
giveGrenadesInReadyup()
{
	self endon("disconnect");

	// Make sure only 1 thred is running
	self notify("end_giveGrenadesInReadyup");
	self endon("end_giveGrenadesInReadyup");

	grenadesLast = 0;
	for(;;)
	{
		wait level.fps_multiplier * 0.5;

		if (!isAlive(self) || !isDefined(self.pers["weapon"]))
			continue;

		// Give new grenade only after 5 sec!
		grenades = self maps\mp\gametypes\_weapons::getFragGrenadeCount();

		if (grenadesLast > 0 && grenades == 0)
		{
			self.readyupLastGrenadeThrowTime = gettime();
		}

		grenadesLast = grenades;

		if (grenades == 0 && (self.readyupLastGrenadeThrowTime + 3500) < gettime())
		{
			maps\mp\gametypes\_weapons::giveGrenadesFor(self.pers["weapon"]);
		}
	}
}


// Main thread for player (monitoring F press)
playerReadyUpThread()
{
	self endon("disconnect");

	// Default variables
	self.pers["killer"] = 0;
	self.isReady = false;
	self.lastMan = false;

    // When player connects while the readyup ends (server is counting down timer to match start) show readyicon and exit
    if (level.playersready)
    {
        self.statusicon = "party_ready";
        return;
    }

    // Change status icon
	self.statusicon = "party_notready";


	//Set ready for bots
	if (isDefined(self.pers["isTestClient"]))
	{
		self.isReady = true;
		self.statusicon = "party_ready";
        level thread Check_All_Ready(); // Check if all players are ready
		return;
	}

	// Dont show readyup for just connected players
	while(self.pers["team"] == "none")
		wait level.fps_multiplier * 0.1;

	// Dont show readyup if player is in team, but is in spectator mode
	// This happends when players are swaped at halftime and player has to select weapon
	while((self.pers["team"] == "allies" || self.pers["team"] == "axis") && self.sessionstate == "spectator")
		wait level.fps_multiplier * 0.1;

    self thread HUD_Player_Status();

	if (!level.in_timeout)
		self thread HUD_Player_Killing_Status();


	while(!level.playersready)
	{
		// Checking if player (self) is still defined
		if (!isdefined(self) || !isPlayer(self))
		{
			assertMsg("Readyup error: self is undefined or is not player!");
			return;
		}


		if(self useButtonPressed() && !self.flying)
		{
			if (!self.isReady)
				setReady();
			else
				unsetReady();


            // Check if all players are ready
			level thread Check_All_Ready();


			wait level.fps_multiplier * 0.25;
			while (self useButtonPressed())
				wait level.frame;
		}

		// Disable killing
		else if (self MeleeButtonPressed() && !level.in_timeout && (self.pers["team"] == "allies" || self.pers["team"] == "axis"))
		{
			catch_next = false;
			for(i=0; i<=10; i++)
			{
				if(catch_next && self meleeButtonPressed())
				{
					// Disable killing
					self disableKilling();

					self iprintln("Killing was disabled");

					wait level.fps_multiplier * 1;
					break;
				}
				else if(!(self meleeButtonPressed()))
					catch_next = true;

				wait level.fps_multiplier * 0.01;
			}

		}
		else
			wait level.fps_multiplier * 0.1;


	}

	//self iprintlnbold("Playing ^2"+level.pam_mode+"^7 mode");
    	self iprintlnbold(game["STRING_READYUP_ALL_PlAYERS_ARE_READY"]);


	//self.statusicon = "party_ready";
}

setReady()
{
	self.isReady = true;
	self.statusicon = "party_ready";

	if (isDefined(self.readyhud))
	{
		self.readyhud.color = (.73, .99, .73);
		self.readyhud setText(game["STRING_READYUP_READY"]);
	}
}

unsetReady()
{
	self.isReady = false;
	self.statusicon = "party_notready";

	if (isDefined(self.readyhud))
	{
		self.readyhud.color = (1, .66, .66);
		self.readyhud setText(game["STRING_READYUP_NOT_READY"]);
	}
}

enableKilling()
{
	self.pers["killer"] = true;

	// Update killing statuses
	if (isDefined(self.ru_killing_status)) // may be deleted when readyup is ending
	{
		self.ru_killing_status.color = (.73, .99, .73);
		self.ru_killing_status SetText(game["STRING_READYUP_KILLING_ENABLED"]);
	}
}

disableKilling()
{
	self.pers["killer"] = false;

	if (isDefined(self.ru_killing_status)) // may be deleted when readyup is ending
	{
		self.ru_killing_status.color = (1, .66, .66);
		self.ru_killing_status SetText(game["STRING_READYUP_KILLING_DISABLED"]);
	}
}


// Called every onPlayerConnect, onPlayerDisconnect or on player ready-state changed
// Set level.playersready to true if all player is ready
Check_All_Ready()
{
	waittillframeend; // wait untill player is fully connected / disconnected

	if (level.playersready)
		return;


	if (areAllPlayersReady())
	{
		// Give players a few time to change their status if he was tle last one even if all players are ready
		wait level.fps_multiplier * 1;

		if (areAllPlayersReady())
			level.playersready = true;
	}
}

areAllPlayersReady()
{
	players = getentarray("player", "classname");

	if (players.size == 0)
        return false;

	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (!player.isReady) {
			return false;
		}
	}

	return true;
}


PrintTeamAndHowToUse()
{
	if (self.pers["team"] == "none")
		return;

	if (isDefined(self.readyUp_HowToUse_Printed))
		return;

	//Show announce text when player is spawned as spectator, allies or axis
	if (self.pers["team"] == "allies")
		self iprintlnbold(game["readyup_team_allies"]);
	else if (self.pers["team"] == "axis")
		self iprintlnbold(game["readyup_team_axis"]);
	else if (self.pers["team"] == "spectator")
		self iprintlnbold(game["readyup_team_spectator"]);

	self iprintlnbold(game["readyup_press_activate"]);

	if (self.pers["team"] != "spectator" && level.in_timeout == false)
		self iprintlnbold(game["readyup_hold_melee"]);

	// Dont print again
	self.readyUp_HowToUse_Printed = true;
}


End_Readyup_Mode()
{
	level notify("rupover");

	// Black background, countdowntime, First half starting with timer
	thread HUD_Half_Start(level.scr_half_start_timer);

    // Coomon lets got that bastartdss blaballa
    thread playStartSound();


	wait level.fps_multiplier * level.scr_half_start_timer; // (10sec)

	level.in_readyup = 0;

	// reset flag as readyup was runned
	game["readyup_first_run"] = false;

	if (!level.in_timeout)
	{
		if (!level.pam_mode_change)
			map_restart(true);
	}

}


// Used in halftime and overtime
ReadyUp_AutoResume()
{
	level endon("rupover");
	level endon("readyup_removeAutoResume");

	level thread HUD_ReadyUp_ResumingIn();

	// Resume after scr_readyup_autoresume seconds (5 mins defaults)
	wait level.fps_multiplier * level.scr_readyup_autoresume * 60;


	level thread HUD_ReadyUp_ResumingIn_ExtraTime();


	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player maps\mp\gametypes\_bots::isBot())
			continue;

		player unsetReady();

	}

	wait level.fps_multiplier * 3;

	// If atleast one of the teams are ready, end readyup
	for(;;)
	{
		alliesReady = true;
		axisReady = true;
		alliesCount = 0;
		axisCount = 0;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (!player.isReady)
			{
				if (player.pers["team"] == "allies")
					alliesReady = false;
				if (player.pers["team"] == "axis")
					axisReady = false;
			}
			if (player.pers["team"] == "allies")
				alliesCount++;
			if (player.pers["team"] == "axis")
				axisCount++;
		}

		if (alliesCount > 0 && axisCount > 0 && (alliesReady || axisReady))
		{
			// After this time, set all player is ready
			level.playersready = true;
			break;
		}

		wait level.fps_multiplier * 1;
	}
}

Timeout_AutoResume()
{
	level endon("rupover");

    level thread HUD_Timeout_ResumingIn();

	// Resume after scr_timeout_length seconds (5 mins default)
	wait level.fps_multiplier * level.scr_timeout_length * 60;

	// After this time, set all player is ready
	level.playersready = true;
}

// keeps updates until level.playersready is false
Update_Players_Count()
{
	// Update Waiting On X Players - xxx number
	while(!level.playersready)
	{
		// Count player not ready up
		notready = 0;
		notReadyPlayer = undefined;
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (!player.isReady)
			{
				notready++;

				notReadyPlayer = player;
			}
		}

		// Last man
		if (players.size > 4)	// If its 3v3 or more
		{
			if (notready == 1 && notReadyPlayer.lastMan == false)
			{
				notReadyPlayer.lastMan = true;
				notReadyPlayer thread playLastManSound();
			}
		}

		level.notreadyhud setValue(notready);

		wait level.fps_multiplier * .1;
	}
}






check_Warnings()
{
    level endon("rupover");

    level thread HUD_Warnings();

    for(;;)
    {
    	line_offset = 0;

        level.warning1.alpha = 0;
    	if (getCvarInt("sv_punkbuster") != 1)
    	{
            level.warning1.y = 70 + line_offset;
            level.warning1.alpha = 1;
            level.warning1 setText(game["STRING_WARNING_PUNKBUSTER_IS_DISABLED"]);

    		line_offset += 16;
    	}

        level.warning2.alpha = 0;
    	if (getCvarInt("sv_cheats") != 0)
    	{
            level.warning2.y = 70 + line_offset;
            level.warning2.alpha = 1;
            level.warning2 setText(game["STRING_WARNING_CHEATS_ARE_ENABLED"]);

    		line_offset += 16;
    	}

        level.warning3.alpha = 0;
        if (maps\mp\gametypes\global\cvar_system::cvarsChangedFromRulesValues())
        {
            level.warning3.y = 70 + line_offset;
            level.warning3.alpha = 1;
            level.warning3 setText(game["STRING_WARNING_CVARS_ARE_CHANGED"]);

            line_offset += 16;
        }

        level.warning4.alpha = 0;
        if (getcvar("g_password") == "")
        {
            level.warning4.y = 70 + line_offset;
            level.warning4.alpha = 1;
            level.warning4 setText(game["STRING_WARNING_PASSWORD_IS_NOT_SET"]);

						line_offset += 16;
        }


        level.warning5.alpha = 0;
        if (game["is_cracked"])
        {
            level.warning5.y = 70 + line_offset;
            level.warning5.alpha = 1;
            level.warning5 setText(game["STRING_WARNING_SERVER_IS_CRACKED"]);
        }

        wait level.fps_multiplier * 1;
    }
}




/////////////////////////////////////////////////////////////////////////////
//                                                                          /
//                                                              Waiting On  /
// 	                                                                3       /
//                                                               Players    /
//                                                                          /
//                                                                          /
//                                                                          /
//                                                                          /
//                                                                Clock     /
//                                                                00:00     /
//                                                                          /
//                                                                          /
//                                                                          /
//                            Ready Up Mode                                 /
//                                                                          /
/////////////////////////////////////////////////////////////////////////////

createLevelHUD()
{
	level.playersready = false;

    // Show name of league + pam version
    thread maps\mp\gametypes\_pam::PAM_Header();

    // Show warning messages in top center (sv_cheats, no password, ...)
    if (game["readyup_first_run"])
        thread check_Warnings();

    // Ready-Up Mode Text in center bottom position
    level thread HUD_ReadyUpMode();

    // Show Waiting on X Player on right side
    level thread HUD_WaitingOn_X_Players();


	if (level.in_timeout && level.scr_timeout_length != 0)
		thread Timeout_AutoResume();

	else if (!level.in_timeout && (game["is_halftime"] || game["overtime_active"] || (game["scr_matchinfo"] == 2 && game["match_exists"])) && level.scr_readyup_autoresume > 0)
		thread ReadyUp_AutoResume();

	else
		level thread HUD_Clock();

	//Remove MG nests (if is timeout remove only in sd)
    if (!level.in_timeout || (level.in_timeout && level.gametype == "sd"))
    {
        deletePlacedEntity("misc_turret");
    	deletePlacedEntity("misc_mg42");
    }
}




// Your Status: Ready
HUD_Player_Status()
{
    self endon("disconnect");

    // Your status
    self.status = addHUDClient(self, level.hud_readyup_offsetX, level.hud_readyup_offsetY + 120, 1.2, (0.8,1,1), "center", "middle", "right");
	self.status setText(game["STRING_READYUP_YOUR_STATUS"]);

	// Ready / Not ready
    self.readyhud = addHUDClient(self, level.hud_readyup_offsetX, level.hud_readyup_offsetY + 135, 1.2, (1, .66, .66), "center", "middle", "right");
    self.readyhud.archived = false;         // show my status instead of spectating players status if im following another player
	self.readyhud setText(game["STRING_READYUP_NOT_READY"]);

    level waittill("rupover");

    // Remove hud when RUP is over
    self.status thread removeHUDSmooth(1);
    self.readyhud thread removeHUDSmooth(1);
}

// Killing: Enabled
HUD_Player_Killing_Status()
{
    self endon("disconnect");

    self.ru_killing_text = addHUDClient(self, level.hud_readyup_offsetX, level.hud_readyup_offsetY + 170, 1.2, (.7, 0.9, 0.9), "center", "middle", "right");
    self.ru_killing_text SetText(game["STRING_READYUP_KILLING"]);

    self.ru_killing_status = addHUDClient(self, level.hud_readyup_offsetX, level.hud_readyup_offsetY + 185, 1.2, (1, .66, .66), "center", "middle", "right");
    self.ru_killing_status SetText(game["STRING_READYUP_KILLING_DISABLED"]);

    level waittill("rupover");

    self.ru_killing_text FadeOverTime(1);
    self.ru_killing_text.alpha = 0;
    self.ru_killing_status FadeOverTime(1);
    self.ru_killing_status.alpha = 0;

    wait level.fps_multiplier * 1;

    self.ru_killing_text destroy2();
    self.ru_killing_status destroy2();
}


HUD_Clock()
{
	// Clock
	level.timertext = newHudElem2();
	level.timertext.x = level.hud_readyup_offsetX;
	level.timertext.y = level.hud_readyup_offsetY + 220; //170
	level.timertext.horzAlign = "right";
	level.timertext.alignX = "center";
	level.timertext.alignY = "middle";
	level.timertext.fontScale = 1.2;
	level.timertext.color = (.8, 1, 1);
	level.timertext SetText(game["STRING_READYUP_CLOCK"]);

	level.stim = newHudElem2();
	level.stim.x = level.hud_readyup_offsetX;
	level.stim.y = level.hud_readyup_offsetY + 235; // 185
	level.stim.horzAlign = "right";
	level.stim.alignX = "center";
	level.stim.alignY = "middle";
	level.stim.fontScale = 1.2;
	level.stim.color = (.98, .98, .60);
	level.stim SetTimerUp(0.1);

    level waittill("rupover");

    level.timertext FadeOverTime(1);
    level.timertext.alpha = 0;
    level.stim FadeOverTime(1);
    level.stim.alpha = 0;

    wait level.fps_multiplier * 1;

    level.timertext destroy2();
	level.stim destroy2();

}

// Ready-Uo Mode / Halft time Ready-Up Mode / Timeout Ready-Up Mode
HUD_ReadyUpMode()
{
    level.readyup_mode = newHudElem2();
	level.readyup_mode.alignX = "center";
	level.readyup_mode.alignY = "top";
	level.readyup_mode.color = (.8, 1, 1);
	level.readyup_mode.x = 320;
	level.readyup_mode.y = 374;
	level.readyup_mode.fontScale = 1.4;
	level.readyup_mode.font = "default";
    if (level.in_timeout)
        level.readyup_mode SetText(game["STRING_READYUP_MODE_TIMEOUT"]);
    else if (game["is_halftime"])
		level.readyup_mode SetText(game["STRING_READYUP_MODE_HALF"]);
	else if (game["overtime_active"])
		level.readyup_mode SetText(game["STRING_READYUP_MODE_OVERTIME"]);
	else
		level.readyup_mode SetText(game["STRING_READYUP_MODE"]);

    level waittill("rupover");

    level.readyup_mode FadeOverTime(1);
    level.readyup_mode.alpha = 0;

    wait level.fps_multiplier * 1;

	level.readyup_mode destroy2();
}

HUD_WaitingOn_X_Players()
{
    // Waiting on
	level.waitingon = newHudElem2();
	level.waitingon.x = level.hud_readyup_offsetX;
	level.waitingon.y = level.hud_readyup_offsetY + 45;
	level.waitingon.horzAlign = "right";
	level.waitingon.alignX = "center";
	level.waitingon.alignY = "middle";
	level.waitingon.fontScale = 1.2;
	level.waitingon.font = "default";
	level.waitingon.color = (.8, 1, 1);
	level.waitingon setText(game["STRING_READYUP_WAITING_ON"]);

	// Number
	level.notreadyhud = newHudElem2();
	level.notreadyhud.x = level.hud_readyup_offsetX;
	level.notreadyhud.y = level.hud_readyup_offsetY + 65;
	level.notreadyhud.horzAlign = "right";
	level.notreadyhud.alignX = "center";
	level.notreadyhud.alignY = "middle";
	level.notreadyhud.fontScale = 1.2;
	level.notreadyhud.font = "default";
	level.notreadyhud.color = (.98, .98, .60);

	// Players
	level.playerstext = newHudElem2();
	level.playerstext.x = level.hud_readyup_offsetX;
	level.playerstext.y = level.hud_readyup_offsetY + 85;
	level.playerstext.horzAlign = "right";
	level.playerstext.alignX = "center";
	level.playerstext.alignY = "middle";
	level.playerstext.fontScale = 1.2;
	level.playerstext.font = "default";
	level.playerstext.color = (.8, 1, 1);
	level.playerstext setText(game["STRING_READYUP_PLAYERS"]);

    level waittill("rupover");

    level.waitingon FadeOverTime(1);
    level.waitingon.alpha = 0;
    level.notreadyhud FadeOverTime(1);
    level.notreadyhud.alpha = 0;
    level.playerstext FadeOverTime(1);
    level.playerstext.alpha = 0;

    wait level.fps_multiplier * 1;

	level.waitingon destroy2();
    level.notreadyhud destroy2();
	level.playerstext destroy2();
}

// Punkbuster, Cheats, Password
HUD_Warnings()
{
    // Punkbuster
    level.warning1 = newHudElem2();
    level.warning1.x = 320;
    level.warning1.y = 70 + 16;
    level.warning1.alignX = "center";
    level.warning1.alignY = "top";
    level.warning1.fontScale = 1.2;
    level.warning1.alpha = 0;
    level.warning1.color = (1, 0, 0);

    // cheats
    level.warning2 = newHudElem2();
    level.warning2.x = 320;
    level.warning2.y = 70 + 32;
    level.warning2.alignX = "center";
    level.warning2.alignY = "top";
    level.warning2.fontScale = 1.2;
    level.warning2.alpha = 0;
    level.warning2.color = (1, 0, 0);

    // cvar changed
    level.warning3 = newHudElem2();
    level.warning3.x = 320;
    level.warning3.y = 70 + 48;
    level.warning3.alignX = "center";
    level.warning3.alignY = "top";
    level.warning3.fontScale = 1.2;
    level.warning3.alpha = 0;
    level.warning3.color = (1, 0, 0);

    // password
    level.warning4 = newHudElem2();
    level.warning4.x = 320;
    level.warning4.y = 70 + 64;
    level.warning4.alignX = "center";
    level.warning4.alignY = "top";
    level.warning4.fontScale = 1.2;
    level.warning4.alpha = 0;
    level.warning4.color = (1, 1, 0);

		// cracked server
    level.warning5 = newHudElem2();
    level.warning5.x = 320;
    level.warning5.y = 70 + 80;
    level.warning5.alignX = "center";
    level.warning5.alignY = "top";
    level.warning5.fontScale = 1.2;
    level.warning5.alpha = 0;
    level.warning5.color = (1, 1, 0);

    level waittill("rupover");

    level.warning1 FadeOverTime(1);
    level.warning1.alpha = 0;
    level.warning2 FadeOverTime(1);
    level.warning2.alpha = 0;
    level.warning3 FadeOverTime(1);
    level.warning3.alpha = 0;
    level.warning4 FadeOverTime(1);
    level.warning4.alpha = 0;
		level.warning5 FadeOverTime(1);
    level.warning5.alpha = 0;

    wait level.fps_multiplier * 1;

	level.warning1 destroy2();
    level.warning2 destroy2();
    level.warning3 destroy2();
    level.warning4 destroy2();
    level.warning5 destroy2();
}

// Halftime auto resume timer
HUD_ReadyUp_ResumingIn()
{
	level endon("readyup_removeAutoResume");

    	level.ht_resume = newHudElem2();
	level.ht_resume.x = level.hud_readyup_offsetX;
	level.ht_resume.y = level.hud_readyup_offsetY + 220;
	level.ht_resume.horzAlign = "right";
	level.ht_resume.color = (0.8, 0.3, 0);
	level.ht_resume.alignX = "center";
	level.ht_resume.alignY = "middle";
	level.ht_resume.font = "default";
	level.ht_resume.fontscale = 1.2;
	level.ht_resume setText(game["STRING_READYUP_RESUMING_IN"]);

	level.ht_resume_clock = newHudElem2();
	level.ht_resume_clock.x = level.hud_readyup_offsetX;
	level.ht_resume_clock.y = level.hud_readyup_offsetY + 235;
	level.ht_resume_clock.horzAlign = "right";
	level.ht_resume_clock.color = (.98, .98, .60);
	level.ht_resume_clock.alignX = "center";
	level.ht_resume_clock.alignY = "middle";
	level.ht_resume_clock.font = "default";
	level.ht_resume_clock.fontscale = 1.2;
	level.ht_resume_clock setTimer(level.scr_readyup_autoresume * 60);

	level waittill("rupover");

	level.ht_resume FadeOverTime(1);
	level.ht_resume.alpha = 0;
	level.ht_resume_clock FadeOverTime(1);
	level.ht_resume_clock.alpha = 0;

	wait level.fps_multiplier * 1;

	level.ht_resume destroy2();
	level.ht_resume_clock destroy2();
}

// Halftime auto resume timer
HUD_ReadyUp_ResumingIn_ExtraTime()
{
	level endon("readyup_removeAutoResume");

	// Set your team as ready to skip readyup
	level.setYourTeamAsReadyBG = addHUD(-160, 347, undefined, (1,1,1), "left", "top", "center", "top");
    	level.setYourTeamAsReadyBG setShader("black", 320, 20);
        level.setYourTeamAsReadyBG.alpha = 0.75;

        level.setYourTeamAsReady = newHudElem2();
        level.setYourTeamAsReady.x = 320;
        level.setYourTeamAsReady.y = 350;
        level.setYourTeamAsReady.alignX = "center";
        level.setYourTeamAsReady.alignY = "top";
        level.setYourTeamAsReady.fontScale = 1.1;
        level.setYourTeamAsReady.color = (1, 0, 0);
	level.setYourTeamAsReady setText(game["STRING_READYUP_SET_YOUR_TEAM_AS_READY"]);

	iprintlnbold(game["readyup_timeExpired"]);
	iprintlnbold(game["readyup_skip"]);

	// Red extra time
	level.ht_resume_clock_extra = newHudElem2();
	level.ht_resume_clock_extra.x = level.hud_readyup_offsetX;
	level.ht_resume_clock_extra.y = level.hud_readyup_offsetY + 248;
	level.ht_resume_clock_extra.horzAlign = "right";
	level.ht_resume_clock_extra.color = (.98, .2, .2);
	level.ht_resume_clock_extra.alignX = "center";
	level.ht_resume_clock_extra.alignY = "middle";
	level.ht_resume_clock_extra.font = "default";
	level.ht_resume_clock_extra.fontscale = 1.2;
	level.ht_resume_clock_extra setTimerUp(0.1);

    	level waittill("rupover");

	level.ht_resume_clock_extra FadeOverTime(1);
	level.ht_resume_clock_extra.alpha = 0;

	wait level.fps_multiplier * 1;

	level.ht_resume_clock_extra destroy2();

}

// Called from matchingo if teams info is cleared
HUD_ReadyUp_ResumingIn_Delete()
{
	// Remove auto resume threads
	level notify("readyup_removeAutoResume");

	// Remove HUDS
	if (isDefined(level.ht_resume))
	{
		level.ht_resume destroy2();
		level.ht_resume_clock destroy2();

		level.ht_resume = undefined;
		level.ht_resume_clock = undefined;

		// Show clock
		level thread HUD_Clock();
	}

	if (isDefined(level.ht_resume_clock_extra))
	{
		level.ht_resume_clock_extra destroy2();
		level.ht_resume_clock_extra = undefined;
	}

	if (isDefined(level.setYourTeamAsReadyBG))
	{
		level.setYourTeamAsReadyBG destroy2();
		level.setYourTeamAsReadyBG = undefined;
		level.setYourTeamAsReady destroy2();
		level.setYourTeamAsReady = undefined;
	}
}


HUD_Timeout_ResumingIn()
{
    // Resuming in
	level.to_resume = newHudElem2();
	level.to_resume.x = level.hud_readyup_offsetX;
	level.to_resume.y = level.hud_readyup_offsetY + 170;
	level.to_resume.horzAlign = "right";
	level.to_resume.color = (0.8, 0.3, 0);
	level.to_resume.alignX = "center";
	level.to_resume.alignY = "middle";
	level.to_resume.font = "default";
	level.to_resume.fontscale = 1.2;
	level.to_resume setText(game["STRING_READYUP_RESUMING_IN"]);

	// 2:50
	level.to_clock = newHudElem2();
	level.to_clock.x = level.hud_readyup_offsetX;
	level.to_clock.y = level.hud_readyup_offsetY + 185;
	level.to_clock.horzAlign = "right";
	level.to_clock.color = (.98, .98, .60);
	level.to_clock.alignX = "center";
	level.to_clock.alignY = "middle";
	level.to_clock.font = "default";
	level.to_clock.fontscale = 1.2;
	level.to_clock setTimer(level.scr_timeout_length * 60);

    level waittill("rupover");

    level.to_resume FadeOverTime(1);
    level.to_resume.alpha = 0;
    level.to_clock FadeOverTime(1);
    level.to_clock.alpha = 0;

    wait level.fps_multiplier * 1;

    level.to_resume destroy2();
	level.to_clock destroy2();

}


// Called each time player is spawned
HUD_SelectTeam()
{
	if (self.pers["team"] == "none")
	{
		if (!isDefined(self.selectTeamInfoBG))
		{
			// Set your team as ready to skip readyup
			self.selectTeamInfoBG = addHUDClient(self, -50, -23, undefined, (1,1,1), "left", "top", "center", "middle");
		    	self.selectTeamInfoBG setShader("black", 100, 20);
		        self.selectTeamInfoBG.alpha = 0.75;

		        self.selectTeamInfo = addHUDClient(self, 0, -20, 1.1, (1,1,1), "center", "top", "center", "middle");
			self.selectTeamInfo setText(game["STRING_READYUP_SELECT_TEAM"]);
		}

	}
	else if (isDefined(self.selectTeamInfo))
	{
		self.selectTeamInfoBG destroy2();
		self.selectTeamInfoBG = undefined;
		self.selectTeamInfo destroy2();
		self.selectTeamInfo = undefined;
	}
}


// Black scren + timer countdown
HUD_Half_Start(time)
{
	if ( time < 3 )
		time = 3;

	// Black fullscreen backgound with animation
	blackbg = addHUD(0, 0, undefined, undefined, "left", "top", "fullscreen", "fullscreen");
	blackbg.alpha = 0;
	blackbg FadeOverTime(2);
	blackbg.alpha = 0.75;
	blackbg.sort = -3;
	blackbg.foreground = true;
	blackbg SetShader("black", 640, 480);

	// Match begins in
	blackbgtimertext = addHUD(0, 183, 1.35, (1,1,1), "center", "top", "center");
	blackbgtimertext showHUDSmooth(1.5);
	blackbgtimertext.sort = -2;
	blackbgtimertext.foreground = true;
	if (level.in_timeout)
		blackbgtimertext SetText(game["STRING_READYUP_MATCH_RESUMES_IN"]);
	else if (game["is_halftime"])
		blackbgtimertext SetText(game["STRING_READYUP_MATCH_CONTINUES_IN"]);
	else
		blackbgtimertext SetText(game["STRING_READYUP_MATCH_BEGINS_IN"]);

	// Count down timer
	blackbgtimer = addHUD(0, 200, 1.35, (1,1,1), "center", "top", "center");
	blackbgtimer showHUDSmooth(1.5);
	blackbgtimer.sort = -1;
	blackbgtimer.foreground = true;
	blackbgtimer settimer(time-0.5);
}


deletePlacedEntity(entity)
{
	entities = getentarray(entity, "classname");
	for(i = 0; i < entities.size; i++)
	{
		//println("DELETED: ", entities[i].classname);
		entities[i] delete();
	}
}


playStartSound()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if (players[i].sessionteam == "allies" || players[i].sessionteam == "axis" || (level.gametype == "dm" && players[i].sessionteam == "none"))
			players[i] playLocalSound("hill400_assault_gr5_letsgoget");
	}
}


playLastManSound()
{
	self endon("disconnect");

	wait level.fps_multiplier * 3;

	if (self.isReady == false)
	{
		self playLocalSound("US_0_order_move_generic_05");
	}

	// Next sound after 30 sec
	wait level.fps_multiplier * 30;

	self.lastMan = false;
}
