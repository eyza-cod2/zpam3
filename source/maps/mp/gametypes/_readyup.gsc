#include maps\mp\gametypes\_callbacksetup;

// Ready up can be called from startRound, _halftime, _timeout, _overtime

init()
{
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

// Runs readyup mode
// in_middle_of_game is useful when timeout needs to be called in middle of game
// if is set, threads needs to be runned on existing players
Start_Readyup_Mode(runned_in_middle_of_game)
{
	level.in_readyup = true;
	game["Do_Ready_up"] = 0;	// reset request flag

	// Because readyup can be called in middle of game (timeout),
	// attach readyup threads on existing players
	if (runned_in_middle_of_game)
	{
		// Run readyup thread to all existing players
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			// Main thread for player (monitoring F press)
			player thread playerReadyUpThread();
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
		for(;;)
		{
			wait level.fps_multiplier * 1;
			players = getentarray("player", "classname");
			if (players.size > 0)
				break;
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

	if (isPlayer(eAttacker) && self != eAttacker)
	{
		eAttacker.pers["killer"] = 1;

		// Update killing statuses
		if (isDefined(eAttacker.ru_killing_status)) // may be deleted when readyup is ending
		{
			eAttacker.ru_killing_status.color = (.73, .99, .73);
			eAttacker.ru_killing_status SetText(game["kenabled"]);
		}
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



		if(self useButtonPressed())
		{
			if (!self.isReady)
			{
				self.isReady = true;
				self.statusicon = "party_ready";

				self.readyhud.color = (.73, .99, .73);
				self.readyhud setText(game["STRING_READYUP_READY"]);

				//logPrint(self.name + ";" + " is Ready Logfile;" + "\n");
			}
			else
			{
				self.isReady = false;
				self.statusicon = "party_notready";

				self.readyhud.color = (1, .66, .66);
				self.readyhud setText(game["STRING_READYUP_NOT_READY"]);

                //logPrint(self.name + ";" + " is Not Ready Logfile;" + "\n");
			}

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
					self.pers["killer"] = false;
					self.ru_killing_status.color = (1, .66, .66);
					self.ru_killing_status SetText(game["kdisabled"]);

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

		self iprintlnbold("Playing ^2"+level.pam_mode+"^7 mode");
    self iprintlnbold(game["STRING_READYUP_ALL_PlAYERS_ARE_READY"]);


	self.statusicon = "party_ready";
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
	thread maps\mp\gametypes\_hud::Half_Start(level.scr_half_start_timer);

    // Remove PAM header smoothly
    thread maps\mp\gametypes\_hud::PAM_Header_Kill();

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

    level thread HUD_ReadyUp_ResumingIn();

    // Resume after scr_readyup_autoresume seconds (5 mins defaults)
	wait level.fps_multiplier * level.scr_readyup_autoresume * 60;

	// After this time, set all player is ready
	level.playersready = true;
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


Shouldnt_this_match_start()
{
    level endon("rupover");

	while(!level.playersready)
	{
		wait (level.fps_multiplier * 300);
		iprintlnbold ("^7Shouldn't this match start?");
	}
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
        if (maps\mp\gametypes\_cvar_system::cvarsChangedFromRulesValues())
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
    thread maps\mp\gametypes\_hud::PAM_Header();

    // Shows top-left scores if disabled
	if(!level.scr_show_scoreboard)
		level.show_hud_scoreboard_anyway = true; // will show scoreboard anyway

    // Show warning messages in top center (sv_cheats, no password, ...)
    if (game["readyup_first_run"])
        thread check_Warnings();

    // Ready-Up Mode Text in center bottom position
    level thread HUD_ReadyUpMode();

    // Show Waiting on X Player on right side
    level thread HUD_WaitingOn_X_Players();


	// Add clock text and show "Sholdnt this match start?" every 5mins (only for first time)
	if (game["readyup_first_run"])
    {
		level thread HUD_Clock();
        level thread Shouldnt_this_match_start();
    }
    // Run auto-resume thread for second half and overtime
	else if(!level.in_timeout && (game["is_halftime"] || game["overtime_active"]) && level.scr_readyup_autoresume > 0)
		thread ReadyUp_AutoResume();

	// Run auto-resume thread for timeout
	else if (level.in_timeout && level.scr_timeout_length != 0)
		thread Timeout_AutoResume();

	// If nothink, show atleast elapsed time
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
    self.status = maps\mp\gametypes\_hud_system::addHUDClient(self, level.hud_readyup_offsetX, level.hud_readyup_offsetY + 120, 1.2, (0.8,1,1), "center", "middle", "right");
	self.status setText(game["STRING_READYUP_YOUR_STATUS"]);

	// Ready / Not ready
    self.readyhud = maps\mp\gametypes\_hud_system::addHUDClient(self, level.hud_readyup_offsetX, level.hud_readyup_offsetY + 135, 1.2, (1, .66, .66), "center", "middle", "right");
    self.readyhud.archived = false;         // show my status instead of spectating players status if im following another player
	self.readyhud setText(game["STRING_READYUP_NOT_READY"]);

    level waittill("rupover");

    // Remove hud when RUP is over
    self.status thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
    self.readyhud thread maps\mp\gametypes\_hud_system::removeHUDSmooth(1);
}

// Killing: Enabled
HUD_Player_Killing_Status()
{
    self endon("disconnect");

    self.ru_killing_text = maps\mp\gametypes\_hud_system::addHUDClient(self, level.hud_readyup_offsetX, level.hud_readyup_offsetY + 170, 1.2, (.7, 0.9, 0.9), "center", "middle", "right");
    self.ru_killing_text SetText(game["killingt"]);

    self.ru_killing_status = maps\mp\gametypes\_hud_system::addHUDClient(self, level.hud_readyup_offsetX, level.hud_readyup_offsetY + 185, 1.2, (1, .66, .66), "center", "middle", "right");
    self.ru_killing_status SetText(game["kdisabled"]);

    level waittill("rupover");

    self.ru_killing_text FadeOverTime(1);
    self.ru_killing_text.alpha = 0;
    self.ru_killing_status FadeOverTime(1);
    self.ru_killing_status.alpha = 0;

    wait level.fps_multiplier * 1;

    self.ru_killing_text destroy();
    self.ru_killing_status destroy();
}


HUD_Clock()
{
	// Clock
	level.timertext = newHudElem();
	level.timertext.x = level.hud_readyup_offsetX;
	level.timertext.y = level.hud_readyup_offsetY + 220; //170
	level.timertext.horzAlign = "right";
	level.timertext.alignX = "center";
	level.timertext.alignY = "middle";
	level.timertext.fontScale = 1.2;
	level.timertext.color = (.8, 1, 1);
	level.timertext SetText(game["STRING_READYUP_CLOCK"]);

	level.stim = newHudElem();
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

    level.timertext destroy();
	level.stim destroy();

}

// Ready-Uo Mode / Halft time Ready-Up Mode / Timeout Ready-Up Mode
HUD_ReadyUpMode()
{
    level.readyup_mode = newHudElem();
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

	level.readyup_mode destroy();
}

HUD_WaitingOn_X_Players()
{
    // Waiting on
	level.waitingon = newHudElem();
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
	level.notreadyhud = newHudElem();
	level.notreadyhud.x = level.hud_readyup_offsetX;
	level.notreadyhud.y = level.hud_readyup_offsetY + 65;
	level.notreadyhud.horzAlign = "right";
	level.notreadyhud.alignX = "center";
	level.notreadyhud.alignY = "middle";
	level.notreadyhud.fontScale = 1.2;
	level.notreadyhud.font = "default";
	level.notreadyhud.color = (.98, .98, .60);

	// Players
	level.playerstext = newHudElem();
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

	level.waitingon destroy();
    level.notreadyhud destroy();
	level.playerstext destroy();
}

// Punkbuster, Cheats, Password
HUD_Warnings()
{
    // Punkbuster
    level.warning1 = newHudElem();
    level.warning1.x = 320;
    level.warning1.y = 70 + 16;
    level.warning1.alignX = "center";
    level.warning1.alignY = "top";
    level.warning1.fontScale = 1.2;
    level.warning1.alpha = 0;
    level.warning1.color = (1, 0, 0);

    // cheats
    level.warning2 = newHudElem();
    level.warning2.x = 320;
    level.warning2.y = 70 + 32;
    level.warning2.alignX = "center";
    level.warning2.alignY = "top";
    level.warning2.fontScale = 1.2;
    level.warning2.alpha = 0;
    level.warning2.color = (1, 0, 0);

    // cvar changed
    level.warning3 = newHudElem();
    level.warning3.x = 320;
    level.warning3.y = 70 + 48;
    level.warning3.alignX = "center";
    level.warning3.alignY = "top";
    level.warning3.fontScale = 1.2;
    level.warning3.alpha = 0;
    level.warning3.color = (1, 0, 0);

    // password
    level.warning4 = newHudElem();
    level.warning4.x = 320;
    level.warning4.y = 70 + 64;
    level.warning4.alignX = "center";
    level.warning4.alignY = "top";
    level.warning4.fontScale = 1.2;
    level.warning4.alpha = 0;
    level.warning4.color = (1, 1, 0);

		// cracked server
    level.warning5 = newHudElem();
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

	level.warning1 destroy();
    level.warning2 destroy();
    level.warning3 destroy();
    level.warning4 destroy();
    level.warning5 destroy();
}

// Halftime auto resume timer
HUD_ReadyUp_ResumingIn()
{
    level.ht_resume = newHudElem();
	level.ht_resume.x = level.hud_readyup_offsetX;
	level.ht_resume.y = level.hud_readyup_offsetY + 220;
	level.ht_resume.horzAlign = "right";
	level.ht_resume.color = (0.8, 0.3, 0);
	level.ht_resume.alignX = "center";
	level.ht_resume.alignY = "middle";
	level.ht_resume.font = "default";
	level.ht_resume.fontscale = 1.2;
	level.ht_resume setText(game["resuming"]);

	level.ht_resume_clock = newHudElem();
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

	level.ht_resume destroy();
	level.ht_resume_clock destroy();
}


HUD_Timeout_ResumingIn()
{
    // Resuming in
	level.to_resume = newHudElem();
	level.to_resume.x = level.hud_readyup_offsetX;
	level.to_resume.y = level.hud_readyup_offsetY + 170;
	level.to_resume.horzAlign = "right";
	level.to_resume.color = (0.8, 0.3, 0);
	level.to_resume.alignX = "center";
	level.to_resume.alignY = "middle";
	level.to_resume.font = "default";
	level.to_resume.fontscale = 1.2;
	level.to_resume setText(game["resuming"]);

	// 2:50
	level.to_clock = newHudElem();
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

    level.to_resume destroy();
	level.to_clock destroy();

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
