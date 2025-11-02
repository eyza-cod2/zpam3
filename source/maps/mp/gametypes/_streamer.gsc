#include maps\mp\gametypes\global\_global;

init()
{
	level.streamerSystem_playerID = -1;		// spectated player
	level.streamerSystem_player = undefined;
	level.streamerSystem_lastChange = 0;

	if (!isDefined(game["streamerSystem_recommandedPlayerMode_teamLeft_player"]) || level.gametype != "sd" || game["round"] == 0) // round in case of bash
		game["streamerSystem_recommandedPlayerMode_teamLeft_player"] = undefined;
	if (!isDefined(game["streamerSystem_recommandedPlayerMode_teamRight_player"]) || level.gametype != "sd" || game["round"] == 0) // round in case of bash
		game["streamerSystem_recommandedPlayerMode_teamRight_player"] = undefined;


	addEventListener("onConnected",  	::onConnected);
	addEventListener("onSpawnedPlayer",  	::onSpawnedPlayer);
	addEventListener("onSpawnedSpectator",  ::onSpawnedSpectator);

	if (!level.streamerSystem)
	{
		return;
	}

	addEventListener("onSpawnedStreamer",  ::onSpawnedStreamer);
	addEventListener("onConnectedAll",    	::onConnectedAll);
	addEventListener("onMenuResponse",  	::onMenuResponse);
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_vmix", "INT", 0, 0, 2);

	//setCvar("debug_spectator", 1);
}

// Called even is streamer system is disabled
onConnected()
{
	self endon("disconnect");

	if (!isDefined(self.pers["streamerSystem_menu_opened"]))
	{
		self.pers["streamerSystem_menu_opened"] = false;
		self.pers["streamerSystem_menu_open_confirmed"] = false;
		self.pers["streamerSystem_keysConfirmed"] = false;
		self.pers["streamerSystem_autoJoinSpectatorTeam"] = false;
		self.pers["streamerSystem_scoreboardOpenedAutomatically"] = false;
		self.pers["streamerSystem_colorMode"] = 1;
	}
	self.pers["streamerSystem_bypassMouseInput"] = undefined;

	self.streamerSystem_turnedOn = false;		// menu is opened
	self.streamerSystem_freeSpectating = true; 	// free spectating, not following any player
	self.streamerSystem_inCinematic = false;
	self.streamerSystem_inBirdView = false;

	// Switched to readyup (halft, timeout..) -> imidietly hide bars
	if (level.streamerSystem && level.in_readyup)
	{
		wait level.fps_multiplier * 0.41337;
		self thread maps\mp\gametypes\_streamer_hud::hide_player_boxes();
		self thread maps\mp\gametypes\_streamer_hud::hide_player_progress();
	}
}

onConnectedAll()
{
	level thread spectating_loop();
}

// Called even if streamer system is disabled
onSpawnedPlayer()
{
	self exit();
}

// Called even if streamer system is disabled
onSpawnedSpectator()
{
	self exit();
}


onSpawnedStreamer()
{
	self endon("disconnect");

	if (self.pers["team"] == "streamer")
	{
		// Open menu
		self thread openStreamerMenu(); // force menu cursor

		// Watch for keys and force following a player
		self thread player_loop();
		self streamerSystemTurnOn();

		// Show autospectator status HUD
		self thread maps\mp\gametypes\_streamer_auto::HUD_loop();
		// Create and update boxes with players name
		self thread maps\mp\gametypes\_streamer_hud::HUD_PlayerBoxes_Loop();
		// XRAY
		self thread maps\mp\gametypes\_streamer_xray::XRAY_Loop();

		self thread cinematicMove();
	}
}



// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_vmix":
			level.scr_vmix = value;
			return true;
	}
	return false;
}



exit()
{
	// We have to make sure that this cvar is 0 to open standart quickmessage menu
	self setClientCvar2("ui_quickmessage_streamer", "0");

	// Disable auto spectator team join
	self join_streamer_disable();

	// Hide black background for animation
	if (isDefined(self.spectator_blackbg))
	{
		self.spectator_blackbg destroy2();
		self.spectator_blackbg = undefined;
	}
}


join_streamer_isEnabled()
{
	return self.pers["streamerSystem_autoJoinSpectatorTeam"];
}

join_streamer_quicksettings()
{
	// We need to set this cvar in order to make the streamer menu work
	// This function is called after player settings are loaded (or writed default)
	self setClientCvar2("ui_streamer_color", self.pers["streamerSystem_colorMode"]);

	if (self join_streamer_isEnabled())
		return self.pers["streamerSystem_colorMode"]; // 1 = blue red, 2 = cyan purple
	else
		return 0;
}

// Is called from quicksettings on player connect, after settings are loaded + when player joined streamers and confirmed keys
join_streamer_enable(loaded_from_settings, color_mode)
{
	if (!isDefined(loaded_from_settings)) loaded_from_settings = false;
	if (!isDefined(color_mode)) color_mode = 1;

	// Conditions to apply		(in server info)				(waiting for key confirm)
	if (level.streamerSystem && (!isDefined(self.pers["firstTeamSelected"]) || self.pers["team"] == "streamer") && self.pers["streamerSystem_autoJoinSpectatorTeam"] == false)
	{
		self.pers["streamerSystem_autoJoinSpectatorTeam"] = true;
		//self iprintln("Automatically join spectator team ^2Enabled");

		// Enabled when manually joined streamers, save this setting into server16
		if (loaded_from_settings == false)
			self maps\mp\gametypes\_quicksettings::updateClientSettings("streamer_enabled");

		// Loaded from settings, move to streamer team
		if (loaded_from_settings && !isDefined(self.pers["firstTeamSelected"]))
		{
			// Set color mode
			self.pers["streamerSystem_colorMode"] = 1; //color_mode;

			self thread move_to_streamers();
		}
	}
}

// Is called from quicksettings on player connect, after settings are loaded + when player exit streamers team
join_streamer_disable(loaded_from_settings)
{
	if (!isDefined(loaded_from_settings)) loaded_from_settings = false;

	//if (self.pers["streamerSystem_autoJoinSpectatorTeam"])
		//self iprintln("Automatically join spectator team ^1Disabled");

	self.pers["streamerSystem_autoJoinSpectatorTeam"] = false;

	// Save this setting into server16
	if (loaded_from_settings == false)
		self maps\mp\gametypes\_quicksettings::updateClientSettings("streamer_disabled");
}


join_streamer_toggle()
{
	if (self join_streamer_isEnabled())
		self join_streamer_disable();
	else
		self join_streamer_enable();
}


// 1 = blue red (default)
// 2 = cyan purple
/*toggle_color_mode()
{
	self endon("disconnect");

	if (self.pers["streamerSystem_colorMode"] == 1)
		self.pers["streamerSystem_colorMode"] = 2;
	else if (self.pers["streamerSystem_colorMode"] == 2)
		self.pers["streamerSystem_colorMode"] = 1;
	else
		self.pers["streamerSystem_colorMode"] = 1;

	self maps\mp\gametypes\_quicksettings::updateClientSettings("streamer_color");
}*/



// Called when settings are loaded from serverinfo
move_to_streamers()
{
	self endon("disconnect");
	self endon("menuresponse"); // any input from user will cause stop joining

	// Simulate joining streamer team
	// It needs to be distributed like this because a lot of cvars for scoreboard and spectator bars are beeing sent to players (command overflow fix)

	wait level.fps_multiplier * 0.5;

	// Serverinfo menu close
	self closeMenu();
	self closeInGameMenu();
	self.pers["skipserverinfo"] = true;

	// Streamers have visible scoreboard from previous map (intermission scoreboard)
	// This will make sure it will be hided
	self thread maps\mp\gametypes\_menu_scoreboard::hide_scoreboard(true); // true = distributed

	self iprintlnbold("Streamer team auto-join...");
	self iprintlnbold(" ");
	self iprintlnbold(" ");

	wait level.fps_multiplier * 1.5;

	self iprintlnbold(" ");
	self iprintlnbold(" ");
	self iprintlnbold(" ");
	self iprintlnbold(" ");
	self iprintlnbold(" ");

	self notify("menuresponse", game["menu_team"], "streamer");
	waittillframeend;
}



/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (self.pers["team"] != "streamer")
		return;

	if (menu == game["menu_streamersystem"])
	{
		if (response == "menu_open")
		{
			self.pers["streamerSystem_menu_open_confirmed"] = true;

			self thread maps\mp\gametypes\_streamer_hud::HUD_ActivateStreamerSystem_hide();

			// Enable auto spectator team join when keys were confirmed
			if (join_streamer_isEnabled() == false && self.pers["streamerSystem_keysConfirmed"])
				self join_streamer_enable();

			// Automatically confirm keys welcoming message if auto spectator join team is enabled
			if (self.pers["streamerSystem_autoJoinSpectatorTeam"])
				self.pers["streamerSystem_keysConfirmed"] = true;

			// Show welcoming keys
			if (self.pers["streamerSystem_keysConfirmed"] == false)
			{
				self thread maps\mp\gametypes\_streamer_hud::keys_show();
				self thread maps\mp\gametypes\_streamer_hud::HUD_KeysWelcome_show();
			}

			// Hide scoreboard from ingame menu
			self.pers["scoreboard_keepRefreshing"] = 0;
			self.pers["streamerSystem_scoreboardOpenedAutomatically"] = false;

			return true;
		}
		else if (response == "menu_close")
		{
			self.pers["streamerSystem_menu_opened"] = false;
			self thread maps\mp\gametypes\_streamer_hud::keys_hide();
			self thread maps\mp\gametypes\_streamer_hud::HUD_ActivateStreamerSystem_show();

			// Hide scoreboard from ingame menu
			self.pers["scoreboard_keepRefreshing"] = 0;
			self.pers["streamerSystem_scoreboardOpenedAutomatically"] = false;

			return true;
		}

		else if (response == "shift")
		{
			if (level.debug_spectator) self iprintln("MENU_SHIFT");

			// We were in cinematic move, cancel it
			if (self.streamerSystem_inCinematic)
				self.streamerSystem_inCinematic = false;
			if (self.streamerSystem_inBirdView)
				self.streamerSystem_inBirdView = false;

			// Shift is automatically closing the menu to hide cursor
			self.pers["streamerSystem_menu_opened"] = false;
			self thread maps\mp\gametypes\_streamer_hud::keys_hide();
			self thread maps\mp\gametypes\_streamer_hud::HUD_ActivateStreamerSystem_show();

			// In killcam the shift melee key does not work, so we closed the menu but we cannot continue untill killcam ends
			if (isDefined(self.killcam))
				return true;

			// Disable streamer system to be able to register player's shift key to stop following player
			if (self.streamerSystem_turnedOn)
			{
				self streamerSystemTurnOff();
				if (level.debug_spectator) self iprintln("MENU_SHIFT> ^1streamer system turned OFF");
			}

			// In menu file bypass is set to 1 to disable cursor movement and enable ingame movement => remember last value
			self.pers["streamerSystem_bypassMouseInput"] = 1;

			// Force leaving followed player by simulation SHIFT key press on client
			// Exec command on client side
			// If some menu is already opened:
			//	- by player (main menu / quick messages) -> NOT WORKING - command will not be executed
			//	- by player (by ESC key) -> that menu will be closed
			//  	- by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
			//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
			self setClientCvar2("exec_cmd", "+melee; -melee");
			self openMenu(game["menu_exec_cmd"]);		// open menu via script
			self closeMenu();				// will only close menu opened by script

			// Show black background for animation
			if (isDefined(self.spectator_blackbg))
			{
				self.spectator_blackbg destroy2();
				self.spectator_blackbg = undefined;
			}
			self.spectator_blackbg = addHUDClient(self, 0, 0, undefined, undefined, "left", "top", "fullscreen", "fullscreen");
			self.spectator_blackbg.alpha = 1;
			self.spectator_blackbg.sort = -3;
			self.spectator_blackbg.foreground = true;
			self.spectator_blackbg.archived = false;
			self.spectator_blackbg SetShader("black", 640, 480);

			return true;
		}

		// C
		else if (response == "camera")
		{
			if (self.streamerSystem_inCinematic)
				self.streamerSystem_inCinematic = false;

			// Shift is automatically closing the menu to hide cursor
			self.pers["streamerSystem_menu_opened"] = false;
			self thread maps\mp\gametypes\_streamer_hud::keys_hide();
			self thread maps\mp\gametypes\_streamer_hud::HUD_ActivateStreamerSystem_show();

			// In killcam the shift melee key does not work, so we closed the menu but we cannot continue untill killcam ends
			if (isDefined(self.killcam))
				return true;

			// Disable streamer system to be able to register player's shift key to stop following player
			if (self.streamerSystem_turnedOn)
			{
				self streamerSystemTurnOff();
				if (level.debug_spectator) self iprintln("MENU_SHIFT> ^1streamer system turned OFF");
			}

			// Force leaving followed player by simulation SHIFT key press on client
			// Exec command on client side
			// If some menu is already opened:
			//	- by player (main menu / quick messages) -> NOT WORKING - command will not be executed
			//	- by player (by ESC key) -> that menu will be closed
			//  	- by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
			//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
			self setClientCvar2("exec_cmd", "+melee; -melee");
			self openMenu(game["menu_exec_cmd"]);		// open menu via script
			self closeMenu();				// will only close menu opened by script

			self thread birdMove();
		}

		// Left mause | Right mouse
		// not received in free spectating, because menu mouse is not working
		else if (response == "mouse1" || response == "mouse2")
		{
			//self iprintln("mouse1");

			// We were in cinematic move, just cancel it
			if (self.streamerSystem_inCinematic)
			{
				self.streamerSystem_inCinematic = false;
				return true;
			}
			if (self.streamerSystem_inBirdView)
			{
				self.streamerSystem_inBirdView = false;
				return true;
			}

			selectedPlayer = undefined;
			if (response == "mouse1") selectedPlayer = level getNextPlayerFrom(level.streamerSystem_player);
			if (response == "mouse2") selectedPlayer = level getPreviousPlayerFrom(level.streamerSystem_player);


			if (isDefined(selectedPlayer))
			{
				if (self.streamerSystem_turnedOn == false)
				{
					self streamerSystemTurnOn();
					if (level.debug_spectator) self iprintln("MENU_MOUSE> ^2streamer system turned ON");
				}

				self.streamerSystem_freeSpectating = false; // free spectating ended, now following a player
				if (level.debug_spectator) self iprintln("MENU_MOUSE> self.streamerSystem_freeSpectating = ^1false");

				level followPlayer(selectedPlayer);
				level maps\mp\gametypes\_streamer_auto::lockFor(15000); // Lock selected player for 15 secods
			}
			else
			{
				if (level.debug_spectator) self iprintln("MENU_MOUSE> ^1NO ONE TO FOLLOW");
			}



			return true;
		}

		// Middle button
		else if (response == "mouse3")
		{
			level maps\mp\gametypes\_streamer_auto::autoSpectatorToggle();
			return true;
		}

		// X
		else if (response == "xray")
		{
			self thread maps\mp\gametypes\_streamer_xray::toggle();
			return true;
		}

		// H
		else if (response == "hit")
		{
			self thread maps\mp\gametypes\_streamer_damage::toggle();
			return true;
		}

		// C
		/*else if (response == "color")
		{
			// Ignore in killcam or if menu is closed
			if (isDefined(self.killcam) || self.pers["streamerSystem_menu_opened"] == false)
				return true;

			self.pers["streamerSystem_menu_opened"] = false;

			self thread toggle_color_mode();

			// Open menu again
			self thread openStreamerMenu();

			return true;
		}*/

		// Space button
		else if (response == "help")
		{
			self thread maps\mp\gametypes\_streamer_hud::keys_toggle();
			self thread maps\mp\gametypes\_streamer_hud::HUD_KeysWelcome_hide();

			if (self.pers["streamerSystem_keysConfirmed"] == false)
			{
				// Enable auto spectator team join
				self join_streamer_enable();
			}

			self.pers["streamerSystem_keysConfirmed"] = true; // dont open keys again

			return true;
		}

		// TAB
		else if (response == "score")
		{
			if (level.gametype == "sd")
			{
				if (self.pers["scoreboard_keepRefreshing"] == 0)
					self thread maps\mp\gametypes\_menu_scoreboard::generatePlayerList(true); // toggle
				else
					self.pers["scoreboard_keepRefreshing"] = 0;

				self.pers["streamerSystem_scoreboardOpenedAutomatically"] = false;
			}
			else
				self thread maps\mp\gametypes\_streamer_hud::HUD_CloseMenuWarning_show();

			return true;
		}


		// unexpcted bind
		else if (response == "warning")
		{
			self thread maps\mp\gametypes\_streamer_hud::HUD_CloseMenuWarning_show();

			return true;
		}

		else
		{
			i = -1;
	    		switch(response)
			{
				case "follow_1": i = 1; break;
				case "follow_2": i = 2; break;
				case "follow_3": i = 3; break;
				case "follow_4": i = 4; break;
				case "follow_5": i = 5; break;
				case "follow_6": i = 6; break;
				case "follow_7": i = 7; break;
				case "follow_8": i = 8; break;
				case "follow_9": i = 9; break;
				case "follow_10": i = 10; break;
			}

			if (i > -1)
			{
				// We were in cinematic move, cancel it
				if (self.streamerSystem_inCinematic)
					self.streamerSystem_inCinematic = false;
				if (self.streamerSystem_inBirdView)
					self.streamerSystem_inBirdView = false;

				if (self.streamerSystem_turnedOn == false)
				{
					self streamerSystemTurnOn();
					if (level.debug_spectator) self iprintln("FOLLOW_KEY> ^2streamer system turned ON");
				}

				self maps\mp\gametypes\_streamer_hud::followPlayerByNum(i);

				return true;
			}
		}
	}
}


/*
Open QuickMessage menu trick
- this menu is usefull because it does not hide HUD elements as standart menu does
- but this menu is openable only via command /mp_qucikmessage in client side
- also to open this menu player must be alive player (wich spectator is not)
- trick is is move spectator into "none" team and set him as "dead", in wich case the /mp_qucikmessage works
- only problem is that this game is quite bugged and there are some side effect:
	- if players in "allies" or "axis" team are all dead and they are in "spectator" state,
	  for some reason players with clientId lower then spectator clientId starts following this spectator
	- because spectator is spawned outside map and then imidietly back to spectating mode, players
	  with lower clientId stays outside map
	- we need to save current position of players with clientId lower then spectator clientId and
	  only if all players are dead in their team
*/
openStreamerMenu()
{
	self endon("disconnect");

	// Dont run multiple threads
	if (isDefined(self.spectatingMenuOpenRunning))
		return false;

	if (self.sessionteam != "spectator" || self.sessionstate != "spectator")
		return;

	// Menu is already opened, just set required cursor mode
	if (self.pers["streamerSystem_menu_opened"])
		return;

	self.spectatingMenuOpenRunning = true;

	// Before opening menu we need to wait, otherwise forcing self.spectatorclient wont work for some reason
	waittillframeend;

	// Handle none team bug
	level thread handleMenuSpectatingBug(self);

	// Hide scoreboard from ingame menu
	self.pers["scoreboard_keepRefreshing"] = 0;
	self.pers["streamerSystem_scoreboardOpenedAutomatically"] = false;


	spectatorclient = self.spectatorclient;
	origin = self getOrigin();
	angles = self getPlayerAngles();

	// Black fullscreen backgound with animation
	if (isDefined(self.spectator_blackbg))
	{
		self.spectator_blackbg destroy2();
		self.spectator_blackbg = undefined;
	}
	self.spectator_blackbg = addHUDClient(self, 0, 0, undefined, undefined, "left", "top", "fullscreen", "fullscreen");
	self.spectator_blackbg.alpha = 1;
	self.spectator_blackbg.sort = -3;
	self.spectator_blackbg.foreground = true;
	self.spectator_blackbg.archived = false;
	self.spectator_blackbg SetShader("black", 640, 480);


	// Try to execute the command every second untill its confirmed by openscriptmenu
	retry = 0;
	self.pers["streamerSystem_menu_open_confirmed"] = false;
	while(!self.pers["streamerSystem_menu_open_confirmed"] && self.pers["team"] == "streamer")
	{
		self.spectatorclient = -1;
		self.sessionteam = "none";
		self.sessionstate = "dead"; // enable quickmessage

		// In "dead" session state the angle of player is computed by game and cannot be changed with script
		// That will cause weird flickering, so rather show black screen instead by spawning outside map
		self spawn((-99999, -99999, -99999), (0,0,0));

		self setClientCvar2("ui_quickmessage_streamer", "1");

		// Exec command on client side
		// If some menu is already opened:
		//	- by player (main menu / quick messages) -> NOT WORKING - command will not be executed
		//	- by player (by ESC key) -> that menu will be closed
		//  	- by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
		//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
		self setClientCvar2("exec_cmd", "mp_quickmessage");
		self openMenu(game["menu_exec_cmd"]);		// open menu via script
		self closeMenu();				// will only close menu opened by script

		if (retry >= 3)
		{
			self iprintln("^1Cannot open streamer system menu. Please press ^3[ESC]^1 key");
			retry = 0;
		}
		if (level.debug_spectator) self iprintln("^3Opening mp_quickmessage with streamer mode...");

		// Wait a second before next menu opening
		for (i = 0; i < 9 && !self.pers["streamerSystem_menu_open_confirmed"]; i++)
			wait level.fps_multiplier * .1;

		retry++;
	}

	// Restore to previous state
	if (self.pers["team"] == "streamer")
	{
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";

		//if (self.spectatorclient == -1 && spectatorclient != -1)
		//	self.spectatorclient = spectatorclient;
		//else

		self spawn(origin, angles);

		self.pers["streamerSystem_menu_opened"] = true;
	}

	self.spectatingMenuOpenRunning = undefined;


	if (self.pers["team"] == "streamer" && isDefined(self.spectator_blackbg))
	{
		self.spectator_blackbg FadeOverTime(0.25);
		self.spectator_blackbg.alpha = 0;

		wait level.fps_multiplier * .25;

		if (isDefined(self.spectator_blackbg))
			self.spectator_blackbg destroy2();
	}
}





handleMenuSpectatingBug(player)
{
	allies = 0;
	axis = 0;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{	// Count alive players in teams
		if (players[i].sessionteam == "allies" && players[i].sessionstate != "spectator")	allies++;
		if (players[i].sessionteam == "axis"   && players[i].sessionstate != "spectator")	axis++;
	}
	for(i = 0; i < players.size; i++)
	{	// clientId is lower then spectator and not player are alive in team
		if (players[i] GetEntityNumber() < player GetEntityNumber() &&
		   ((allies == 0 && players[i].sessionteam == "allies") || (axis == 0 && players[i].sessionteam == "axis")))
		{
			players[i].spectating_killcam_origin = players[i].origin;
			players[i].spectating_killcam_angles = players[i].angles;
		}
	}

	// Wait till player disconnect or is back from none team
	while(isDefined(player) && player.sessionteam == "none")
		wait level.frame;

	// Spawn to previous location
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if (isDefined(players[i].spectating_killcam_origin))
		{
			players[i] spawn(players[i].spectating_killcam_origin, players[i].spectating_killcam_angles);
			players[i].spectating_killcam_origin = undefined;
			players[i].spectating_killcam_angles = undefined;
			if (level.debug_spectator) iprintln("^1 APPLIED SPECTATE BUG FIX for " + players[i].name);
		}
	}
}






// self.spectatorclient is used to force spectating player
// By default is -1 - dont force
// Other number represents spectated client id
// If is set, player is not able to change spectated player
// self.spectatorclient does not show actually spectated player
player_loop()
{
	self endon("disconnect");

	inKillcam = false;
	playerChanged = false;
	scoreboardShouldBeVisible_last = false;
	self.waitForAttackKeyRelease = false;
	self.waitForMeleeKeyRelease = false;
	self.waitForUseKeyRelease = false;

	for(;;)
	{
		wait level.frame;

		// End this thread if player join team
		if (self.pers["team"] != "streamer")
		{
			self streamerSystemTurnOff();
			self streamerSystemExit();
			break;
		}

		// Use own variable to suppress double F press
		if (isDefined(self.killcam))
			inKillcam = true;
		else if (!(self usebuttonpressed()))
			inKillcam = false;


		// Skip these key checks if we are in killcam
		if (inKillcam)
			continue;

		// Key attack
		if(self attackbuttonpressed() && !self.waitForAttackKeyRelease)
		{
			self.waitForAttackKeyRelease = true;
			self thread handleAttackButtonPress();
		}

		// Key Shift
		if(self meleebuttonpressed() && !self.waitForMeleeKeyRelease)
		{
			self.waitForMeleeKeyRelease = true;
			self thread handleMeleeButtonPress();
		}

		// Key F
		if(self usebuttonpressed() && !self.waitForUseKeyRelease && !self.streamerSystem_killcam_proposingVisible)	// Ignore F press is killcam proposing is visible
		{
			self.waitForUseKeyRelease = true;
			self thread handleUseButtonPress();
		}

		// Unable to change player
		if (playerChanged)
		{
			playerChanged = false;

			if (self.spectatorclient == -1)
			{
				if (level.debug_spectator) self iprintln("^1 UNABLE ^8to set self.spectatorclient="+level.streamerSystem_playerID);

				wait level.fps_multiplier * 1;

				continue;
			}
			else
				self.streamerSystem_freeSpectating = false; // free spectating ended, now following a player
		}

		// Make sure we always follow somebody
		if (self.streamerSystem_turnedOn && !self.streamerSystem_inCinematic && !self.streamerSystem_inBirdView && !isDefined(self.killcam) && self.sessionstate == "spectator" && level.streamerSystem_playerID != self.spectatorclient)
		{
			self.spectatorclient = level.streamerSystem_playerID;

			if (level.debug_spectator) self iprintln("^8 set self.spectatorclient="+level.streamerSystem_playerID);

			playerChanged = true;
		}


/*
		// Show scoreboard beween halfs and map changes
	    	in_timeout = level.in_timeout;
		in_halftime = !in_timeout && (game["is_halftime"] || game["overtime_active"]);
		in_mapswitch = !in_halftime && (game["scr_matchinfo"] == 2 && game["match_exists"]);
		scoreboardShouldBeVisible = level.in_readyup && (in_timeout || in_halftime || in_mapswitch);
		scoreboard_toggleOn = scoreboardShouldBeVisible && scoreboardShouldBeVisible_last != scoreboardShouldBeVisible;
		scoreboardShouldBeVisible_last = scoreboardShouldBeVisible;

		if (scoreboard_toggleOn)
		{
			if (level.gametype == "sd" && self.pers["scoreboard_keepRefreshing"] == 0)
				self thread maps\mp\gametypes\_menu_scoreboard::generatePlayerList(true); // toggle
			self.pers["streamerSystem_scoreboardOpenedAutomatically"] = true;
		}

		// Hide scoreboard if we are not in readyup and it was opened automatically
		if (scoreboardShouldBeVisible == false && self.pers["streamerSystem_scoreboardOpenedAutomatically"])
		{
			if (self.pers["scoreboard_keepRefreshing"] != 0)
				self.pers["scoreboard_keepRefreshing"] = 0;
			self.pers["streamerSystem_scoreboardOpenedAutomatically"] = false;
		}
*/


		// Handle menu cursor bypass
		if (self.pers["streamerSystem_menu_opened"])
		{
			// Cursor settins need to be set according to if player is following player or is free spectating
			// - following player => cursor must be enabled in menu to catch mouse key presses via menu
			// - free spectating => cursor must be disabled to enable ingame mouse movement and catch ingame +attack, +melee key presses
			cl_bypassMouseInput = 0; // 0 = enable menu cursor moving, disable ingame mouse
			if (self.streamerSystem_freeSpectating)
				cl_bypassMouseInput = 1; // 1 = disable menu cursor moving, enable ingame mouse

			if (!isDefined(self.pers["streamerSystem_bypassMouseInput"]) || cl_bypassMouseInput != self.pers["streamerSystem_bypassMouseInput"])
			{
				self setClientCvar2("cl_bypassMouseInput", cl_bypassMouseInput);
				self.pers["streamerSystem_bypassMouseInput"] = cl_bypassMouseInput;

			}

		}

		self setClientCvarIfChanged("m_enable", !self.pers["streamerSystem_menu_opened"] || (self.streamerSystem_freeSpectating && !self.streamerSystem_inBirdView)); // CoD2x cvar to disable cursor movement, but keep system cursor ingame
	}
}



handleAttackButtonPress()
{
	self endon("disconnect");

	if (level.debug_spectator) self iprintln("attackBtn");

	if (self.streamerSystem_inCinematic)
	{
		self.streamerSystem_inCinematic = false;
		if (level.debug_spectator) self iprintln("attackBtn> cinematic move canceled");
	}
	if (self.streamerSystem_inBirdView)
	{
		self.streamerSystem_inBirdView = false;
		if (level.debug_spectator) self iprintln("attackBtn> bird view canceled");
	}

	player = level getNextPlayerFrom(level.streamerSystem_player);

	if (!isDefined(player))
	{
		self iprintln("No player to follow");
		self.streamerSystem_freeSpectating = true;
	}

	// Start following nearby player
	if (isDefined(self.streamerSystem_playerToFollow) && self.streamerSystem_freeSpectating && !self.streamerSystem_turnedOn)
	{
		if (level.debug_spectator) self iprintln("MENU_MOUSE> follow close by player");

		level followPlayer(self.streamerSystem_playerToFollow);
		level maps\mp\gametypes\_streamer_auto::lockFor(15000); // Lock selected player for 15 secods
	}

	// Open menu overlay (with cursor)
	self thread openStreamerMenu();

	// Enable spectating
	if (self.streamerSystem_turnedOn == false)
	{
		self streamerSystemTurnOn();
		if (level.debug_spectator) self iprintln("attackBtn> ^2streamer system turned ON");
	}

	while(self attackbuttonpressed())
		wait level.frame;

	self.waitForAttackKeyRelease = false;
}


handleMeleeButtonPress()
{
	self endon("disconnect");

	if (level.debug_spectator) self iprintln("meleeBtn");

	// We are not in streamer system - what ever spectator state is, now we pressed shift for freespectating
	if (!self.streamerSystem_turnedOn)
	{
		self.streamerSystem_freeSpectating = true; // free spectating, not following any player
		if (level.debug_spectator) self iprintln("meleeBtn> self.streamerSystem_freeSpectating = ^2true");
	}

	// Reopen menu overlay
	self.pers["streamerSystem_menu_opened"] = false;
	self thread openStreamerMenu();

	while(self meleeButtonPressed())
		wait level.frame;

	self.waitForMeleeKeyRelease = false;
}

handleUseButtonPress()
{
	self endon("disconnect");

	if (level.debug_spectator) self iprintln("useBtn");

	while(self useButtonPressed())
		wait level.frame;

	self.waitForUseKeyRelease = false;
}




streamerSystemTurnOn()
{
	self.streamerSystem_turnedOn = true;
}


streamerSystemTurnOff()
{
	self.streamerSystem_turnedOn = false;
	self.spectatorclient = -1;
}

streamerSystemExit()
{
	self thread maps\mp\gametypes\_streamer_hud::keys_hide();
	self thread maps\mp\gametypes\_streamer_hud::HUD_ActivateStreamerSystem_hide();
}


cinematicMove()
{
	self endon("disconnect");

	// Wait untill other players connect and we have player to follow
	waittillframeend;

	self.streamerSystem_inCinematic = true;

	if (level.debug_spectator) self iprintln(gettime() + " cinematic> runned");

	// Wait till menu is opened
	for (i = 0; ; i++)
	{
		if (self.pers["team"] != "streamer") // leaved spectator
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because team != streamer");
			self.streamerSystem_inCinematic = false;
		}
		// Bird view turned on
		if (self.streamerSystem_inBirdView)
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because bird view is ON");
			self.streamerSystem_inCinematic = false;
		}
		// Alive player that was followed spawned to spectators
		if (level.streamerSystem_playerID == self getEntityNumber())
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because this player is followed");
			self.streamerSystem_inCinematic = false;
		}
		// Not in strattime
		if (!isDefined(level.in_strattime) || !level.in_strattime)
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because level.in_strattime = false");
			self.streamerSystem_inCinematic = false;
		}
		// In bash
		if (isDefined(level.in_bash) && level.in_bash)
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because level.in_bash = true");
			self.streamerSystem_inCinematic = false;
		}
		// Time elapsed
		if (i > 30)
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because conditions time 3s elapsed");
			self.streamerSystem_inCinematic = false;
		}


		// All ready for cinematic move, exit
		if (self.streamerSystem_inCinematic && level.streamerSystem_playerID != -1 && self.streamerSystem_turnedOn && self.pers["streamerSystem_menu_opened"] && self.sessionstate == "spectator")
			break;


		// Cinematic was canceled, or this is second run
		if (i == 0 && self.origin == (0,0,0))
		{
			spawnpoints = getentarray("mp_global_intermission", "classname");
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
			if(isdefined(spawnpoint)) self spawn(spawnpoint.origin, spawnpoint.angles);
		}

		// Canceled
		if (self.streamerSystem_inCinematic == false)
		{
			if (level.debug_spectator)
			{
				self iprintln("^1cinematic> canceled");

				if (!self.streamerSystem_turnedOn) 		self iprintln("cinematic> ^1self.streamerSystem_turnedOn = false");
				if (!self.streamerSystem_inBirdView) 	self iprintln("cinematic> ^1self.streamerSystem_inBirdView = false");
				if (!self.pers["streamerSystem_menu_opened"]) 	self iprintln("cinematic> ^1self.pers[streamerSystem_menu_opened] = false");
				if (self.sessionstate != "spectator") 		self iprintln("cinematic> ^1self.sessionstate != spectator");
				if (level.streamerSystem_playerID == -1) 	self iprintln("cinematic> ^1level.streamerSystem_playerID = -1");
			}
			return;
		}

		wait level.fps_multiplier * 0.1;
	}


	if (level.debug_spectator) self iprintln(gettime() + " cinematic> doing cinematic for " + level.streamerSystem_player.name);



	player = level.streamerSystem_player;
	id = level.streamerSystem_playerID;

	stratime = 6; // 6
	if (isDefined(level.strat_time)) stratime = level.strat_time;
	length = stratime * 0.83333; // 5
	acceleration = stratime * 0.5; // 3
	deceleration = length - acceleration; // 2


	origin = player.origin - (0, 0, 15);
	angles = (25, player.angles[1] + 180, 0);
	forward = AnglesToForward(angles); // 1.0 scale

	dist = -50 + (-120 * (stratime / 6)); // how far
	originStart = origin + (forward[0] * dist, forward[1] * dist, forward[2] * dist); // new pos

	dist = -55; // how far
	originEnd = origin + (forward[0] * dist, forward[1] * dist, forward[2] * dist); // new pos

	//self iprintln(originStart);
	//self iprintln(originEnd);


	self spawn(originStart, angles);

	if (self.classname != "player")
	{
		// For some reason, sometimes classname of spectator is not player and linkto() func does not work
		// Error: entity (classname: 'noclass') does not currently support linkTo:
		// Its propably caused when spawn() was not called yet
		// this should avoid error
		self iprintln("cinematic> ^1self.classname != player");
		return;
	}


	//self setOrigin(originStart);
	//self setPlayerAngles(angles);

	self.spectatorLock = spawn("script_model", originStart);
	self.spectatorLock.angles = angles;

	self linkto(self.spectatorLock);



	self.streamerSystem_freeSpectating = false;


	self.spectatorLock moveTo(originEnd, length, acceleration, deceleration);

	startTime = getTime();
	for(;;)
	{
		// Cinematic canceled or some key was pressed
		if (!self.streamerSystem_inCinematic)
		{
			if (level.debug_spectator) self iprintln("cinematic> DONE because it was canceled");
			break;
		}
		// Bird view was activated
		if (self.streamerSystem_inBirdView)
		{
			if (level.debug_spectator) self iprintln("cinematic> DONE because bird view is ON");
			break;
		}
		// Player changed team
		if (self.pers["team"] != "streamer")
		{
			if (level.debug_spectator) self iprintln("cinematic> DONE because team is not streamer");
			break;
		}
		// Spectated player changed
		if (level.streamerSystem_playerID != id)
		{
			if (level.debug_spectator) self iprintln("cinematic> DONE because followed player was changed");
			break;
		}
		// Strattime is over
		if (isDefined(level.in_strattime) && !level.in_strattime)
		{
			if (level.debug_spectator) self iprintln("cinematic> DONE because strattime is over");
			break;
		}

		// Time elapsed
		if ((gettime() - startTime) > (length * 1000))
		{
			if (level.debug_spectator) self iprintln("cinematic> DONE becuase time elapsed");
			break;
		}

		self setPlayerAngles(angles);

		wait level.frame;
	}

	self unlink();

	self.streamerSystem_inCinematic = false;
}



computeBirdOrigin() {

	data = [];
	data["origin"] = (0, 0, 0);
	data["angle"] = (0, 0, 0);
	data["distance"] = 0;
	data["status"] = false;

	alliesPlayers = [];
	axisPlayers = [];
	players = getentarray("player", "classname");

	// Separate players by team
	for (i = 0; i < players.size; i++) {
		player = players[i];
		if (player.sessionstate == "playing") {
			if (player.pers["team"] == "allies") {
				alliesPlayers[alliesPlayers.size] = player;
			} else if (player.pers["team"] == "axis") {
				axisPlayers[axisPlayers.size] = player;
			}
		}
	}

	if (alliesPlayers.size == 0 || axisPlayers.size == 0) {
		if (alliesPlayers.size == 0 && axisPlayers.size > 0) {
			alliesPlayers = axisPlayers;
		} else if (axisPlayers.size == 0 && alliesPlayers.size > 0) {
			axisPlayers = alliesPlayers;
		} else {
			return data; // Return default if no players in either team
		}
	}

	// Calculate center of gravity for all players
	firstOrigin = alliesPlayers[0] getOrigin();
	minBounds[0] = firstOrigin[0];
	minBounds[1] = firstOrigin[1];
	minBounds[2] = firstOrigin[2];
	maxBounds[0] = firstOrigin[0];
	maxBounds[1] = firstOrigin[1];
	maxBounds[2] = firstOrigin[2];

	for (i = 0; i < players.size; i++) {
		if (players[i].sessionstate == "playing") {
			playerOrigin = players[i] getOrigin();
			if (playerOrigin[0] < minBounds[0]) minBounds[0] = playerOrigin[0];
			if (playerOrigin[1] < minBounds[1]) minBounds[1] = playerOrigin[1];
			if (playerOrigin[2] < minBounds[2]) minBounds[2] = playerOrigin[2];

			if (playerOrigin[0] > maxBounds[0]) maxBounds[0] = playerOrigin[0];
			if (playerOrigin[1] > maxBounds[1]) maxBounds[1] = playerOrigin[1];
			if (playerOrigin[2] > maxBounds[2]) maxBounds[2] = playerOrigin[2];
		}
	}

	// Compute the middle point of the bounding box
	overallCenter = ((minBounds[0] + maxBounds[0]) / 2, (minBounds[1] + maxBounds[1]) / 2, (minBounds[2] + maxBounds[2]) / 2);

	// Compute the longest distance from the center to the farthest player
	longestDistance = 0;
	for (i = 0; i < players.size; i++) {
		if (players[i].sessionstate == "playing") {
			distanceToCenter = distance(overallCenter, players[i] getOrigin());
			if (distanceToCenter > longestDistance) {
				longestDistance = distanceToCenter;
			}
		}
	}


	// Calculate center position of allies team
	alliesCenter = (0, 0, 0);
	for (i = 0; i < alliesPlayers.size; i++) {
		alliesCenter = alliesCenter + alliesPlayers[i] getOrigin();
	}
	alliesCenter = (alliesCenter[0] / alliesPlayers.size, alliesCenter[1] / alliesPlayers.size, alliesCenter[2] / alliesPlayers.size);

	// Calculate center position of axis team
	axisCenter = (0, 0, 0);
	for (i = 0; i < axisPlayers.size; i++) {
		axisCenter = axisCenter + axisPlayers[i] getOrigin();
	}
	axisCenter = (axisCenter[0] / axisPlayers.size, axisCenter[1] / axisPlayers.size, axisCenter[2] / axisPlayers.size);

	directionVector = axisCenter - alliesCenter;
	yawAngle = vectortoangles(directionVector);
	data["angle"] = (85, yawAngle[1] + 90, 0);

	// Adjust Z height based on the longest distance and add some elevation
	zHeight = overallCenter[2] + (longestDistance * 1.8) + 200; // Base height + dynamic height + minimum elevation

	// Return computed origin
	data["origin"] = (overallCenter[0], overallCenter[1], zHeight);
	data["distance"] = longestDistance;
	data["status"] = true;

	return data;
}



birdMove()
{
	self endon("disconnect");

	// Wait untill other players connect and we have player to follow
	waittillframeend;

	// Already in bird view
	if (self.streamerSystem_inBirdView) {
		self.streamerSystem_inBirdView = false;
		self.streamerSystem_freeSpectating = false;
		if (level.debug_spectator) self iprintln("cbirdMove> canceled because bird view is already ON");
		return;
	}

	self.streamerSystem_inBirdView = true;

	if (level.debug_spectator) self iprintln(gettime() + " birdMove> runned");

	// Wait till menu is opened
	for (i = 0; ; i++)
	{
		if (self.pers["team"] != "streamer") // leaved spectator
		{
			if (level.debug_spectator) self iprintln("birdMove> canceled because team != streamer");
			self.streamerSystem_inBirdView = false;
		}
		// Alive player that was followed spawned to spectators
		if (level.streamerSystem_playerID == self getEntityNumber())
		{
			if (level.debug_spectator) self iprintln("birdMove> canceled because this player is followed");
			self.streamerSystem_inBirdView = false;
		}
		// Time elapsed
		if (i > 30)
		{
			if (level.debug_spectator) self iprintln("birdMove> canceled because conditions time 3s elapsed");
			self.streamerSystem_inBirdView = false;
		}


		// All ready for cinematic move, exit
		if (self.streamerSystem_inBirdView && /*self.streamerSystem_turnedOn &&*/ self.pers["streamerSystem_menu_opened"] && self.sessionstate == "spectator")
			break;


		// Canceled
		if (self.streamerSystem_inBirdView == false) {
			return;
		}

		wait level.fps_multiplier * 0.1;
	}

	if (level.debug_spectator) self iprintln(gettime() + " birdMove> doing cinematic for " + level.streamerSystem_player.name);



	bird = computeBirdOrigin();

	if (bird["status"] == false)
	{
		if (level.debug_spectator) self iprintln("cinematic2> cannot compute bird origin, aborting");
		self.streamerSystem_inBirdView = false;
		return;
	}

	self spawn(bird["origin"], bird["angle"]);

	if (self.classname != "player")
	{
		// For some reason, sometimes classname of spectator is not player and linkto() func does not work
		// Error: entity (classname: 'noclass') does not currently support linkTo:
		// Its propably caused when spawn() was not called yet
		// this should avoid error
		self iprintln("birdMove> ^1self.classname != player");
		return;
	}

	self setOrigin(bird["origin"]);
	self setPlayerAngles(bird["angle"]);

	self.spectatorLock = spawn("script_model", bird["origin"]);
	self.spectatorLock.angles = bird["angle"];

	self linkto(self.spectatorLock);

	self.streamerSystem_freeSpectating = true;

	time = getTime();
	repositionTime = getTime();
	reangleTime = getTime();

	for(;;)
	{
		// Cinematic canceled or some key was pressed
		if (!self.streamerSystem_inBirdView)
		{
			if (level.debug_spectator) self iprintln("birdMove> DONE because it was canceled");
			break;
		}
		// Player changed team
		if (self.pers["team"] != "streamer")
		{
			if (level.debug_spectator) self iprintln("birdMove> DONE because team is not streamer");
			break;
		}

		bird = computeBirdOrigin();

		if (bird["status"] == false)
		{
			if (level.debug_spectator) self iprintln("cinematic2> cannot compute bird origin, aborting");
			break;
		}

		// Define hysteresis thresholds
		if (bird["distance"] <= 50)
			bird["distance"] = 50;
		yawHysteresis = (50000) / bird["distance"];       // Offset for yaw changes


		// Time elapsed for position update
		if ((gettime() - time) > 1000)
		{
			//self iPrintLn("positionHysteresis: " + positionHysteresis + " yawHysteresis: " + yawHysteresis);

			time = getTime();
		}


		// Time elapsed for position update
		if ((gettime() - repositionTime) > 100)
		{
			//self iPrintLn("distance: " + bird["distance"] + " origin: " + bird["origin"] + " angle: " + bird["angle"]);

			time = .1;
			accel = time * 0;
			self.spectatorLock moveTo(bird["origin"], time, accel, accel);
			repositionTime = getTime();	
		}

		// Time elapsed for angle update
		if ((gettime() - reangleTime) > 1000)
		{
			// Calculate the difference between current and target yaw
			currentYaw = self.spectatorLock.angles[1];
			targetYaw = bird["angle"][1];
			yawDelta = currentYaw - targetYaw;
			if (yawDelta < 0) yawDelta *= -1;

			// Apply hysteresis for yaw
			if (yawDelta > yawHysteresis)
			{
				time = 1;
				accel = time * 0.25;
				self.spectatorLock rotateTo(bird["angle"], time, accel, accel);
				reangleTime = getTime();
			}
		}

		//self setOrigin(self.spectatorLock.origin);
		self setPlayerAngles(self.spectatorLock.angles);

		wait level.frame;
	}

	self unlink();

	self.streamerSystem_freeSpectating = false;

	self.streamerSystem_inBirdView = false;
}










getRecommandedPlayer()
{
	if (level.gametype != "sd")
	{
		return findBestPlayer();
	}

	/*
	Follow in this direction:
	Round	Allies	Axis
	1	sniper
	2		sniper
	3	sniper
	4		sniper
	5	SG
	6		SG
	7	best
	8		best
	9	sniper
	10		sniper
	11	best
	12		best
	13	sniper
	14		sniper
	15	best
	16		best
	17	sniper
	18		sniper
	19	...	...
	*/

	selectedPlayer = undefined;

	// Follow snipers
	if (game["round"] % 2 != 0) // 1, 3, 5, 7, 9, 11, ...
	{
		if (game["round"] == 5)
			selectedPlayer = findPlayerWithWeaponClass("allies", "shotgun");
		else if (game["round"] >= 7 && (game["round"]+1) % 4 == 0) // every 4. rounds - 7, 11, 15, ...
			selectedPlayer = findBestPlayer("allies");
		else
			selectedPlayer = findPlayerWithWeaponClass("allies", "sniper");

		if (!isDefined(selectedPlayer) && isPlayer(game["spectatingSystem_recommandedPlayerAllies"]))
		{
			selectedPlayer = getNextPlayerFrom(game["spectatingSystem_recommandedPlayerAllies"], "allies");
		}
		game["spectatingSystem_recommandedPlayerAllies"] = selectedPlayer;
	}

	else // 2, 4, 6, 8, 10, 12, 14 ...
	{
		if (game["round"] == 6)
			selectedPlayer = findPlayerWithWeaponClass("axis", "shotgun");
		else if (game["round"] >= 8 && (game["round"]) % 4 == 0) // every 4. rounds - 8, 12, 16, ...
			selectedPlayer = findBestPlayer("axis");
		else
			selectedPlayer = findPlayerWithWeaponClass("axis", "sniper");

		if (!isDefined(selectedPlayer) && isPlayer(game["spectatingSystem_recommandedPlayerAxis"]))
		{
			selectedPlayer = getNextPlayerFrom(game["spectatingSystem_recommandedPlayerAxis"], "axis");
		}
		game["spectatingSystem_recommandedPlayerAxis"] = selectedPlayer;
	}

	// may return undefined if there is no sniper
	return selectedPlayer;
}

findPlayerWithWeaponClass(team, classname)
{
	selectedPlayer = undefined;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if ((player.pers["team"] == team) && player.sessionstate == "playing" && isDefined(player.pers["weapon"]))
		{
			weaponData = level.weapons[player.pers["weapon"]];

			if (isDefined(weaponData) && weaponData.classname == classname)
			{
				selectedPlayer = player;
				break;
			}
		}
	}
	return selectedPlayer;
}

findBestPlayer(team)
{
	lastPlayer = undefined;

	if (!isDefined(team))
		team = "all";

	// Select player to watch by score and time
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if ((team == "all" || player.pers["team"] == team) && player.sessionstate == "playing")
		{
			if (!isDefined(lastPlayer) ||
			  player.score > lastPlayer.score ||
			  (player.score == lastPlayer.score && player.deaths < lastPlayer.deaths))
				lastPlayer = player;
		}
	}

	if (isDefined(lastPlayer))
		return lastPlayer;
	else
		return undefined;
}

getPreviousPlayerFrom(actualSpectatedPlayer, team)
{
	return getPlayerFrom(actualSpectatedPlayer, team, true);
}

getNextPlayerFrom(actualSpectatedPlayer, team)
{
	return getPlayerFrom(actualSpectatedPlayer, team, false);
}


getPlayerFrom(actualSpectatedPlayer, team, reverse)
{
	selectedPlayer = undefined;
	useNextId = false;

	// Join teams
	players = maps\mp\gametypes\_streamer_hud::getPlayersByTeam();
	playersFinal = [];
	if (!isDefined(team) || team == "allies")
	{
		for (i = 0; i < players.size; i++)
		{
			if (players[i].pers["team"] == "allies")
				playersFinal[playersFinal.size] = players[i];
		}
	}
	// PLayers from allies should be selected, but the team is empty -> follow from both teams
	if (isDefined(team) && team == "allies" && playersFinal.size == 0)
		return getPlayerFrom(actualSpectatedPlayer, undefined, reverse);


	if (!isDefined(team) || team == "axis")
	{
		for (i = 0; i < players.size; i++)
		{
			if (players[i].pers["team"] == "axis")
				playersFinal[playersFinal.size] = players[i];
		}
	}
	// PLayers from allies should be selected, but the team is empty -> follow from both teams
	if (isDefined(team) && team == "axis" && playersFinal.size == 0)
		return getPlayerFrom(actualSpectatedPlayer, undefined, reverse);


	for(i = 0; i < playersFinal.size; i++)
	{
		player = playersFinal[i];

		//iprintln("--" + player.name);

		// Skip dead players
		if (player.sessionstate != "playing")
			continue;


		if (reverse)
		{
			// Previous player is saved in selectedPlayer
			if (isDefined(selectedPlayer) && isDefined(actualSpectatedPlayer) && actualSpectatedPlayer == player)
				break;

			selectedPlayer = player;
		}
		else
		{
			// Save first player in case actually folowed player is the last one
			if (!isDefined(selectedPlayer))
				selectedPlayer = player;

			if (useNextId)
			{
				selectedPlayer = player;
				break;
			}

			// If this player is actually followed, next player is the one we will follow next
			if (isDefined(actualSpectatedPlayer) && actualSpectatedPlayer == player)
				useNextId = true;
		}




	}

	// Debug print
	if (isDefined(selectedPlayer))
	{
		teamStr = "from both teams"; if (isDefined(team)) teamStr = "in team " + team;
		if (level.debug_spectator) printToStreamers(">selecting next player "+teamStr+": " + selectedPlayer.name);
	}

	return selectedPlayer;
}



followPlayer(selectedPlayer)
{
	level.streamerSystem_playerID = selectedPlayer getEntityNumber();
	level.streamerSystem_player = selectedPlayer;
	level.streamerSystem_lastChange = getTime();

	//if (level.debug_spectator) printToStreamers("Spect: set followed player: " + selectedPlayer.name);
}


stopFollowing()
{
	level.streamerSystem_playerID = -1;
	level.streamerSystem_player = undefined;
	level.streamerSystem_lastChange = getTime();

	//if (level.debug_spectator) printToStreamers("Spect: set followed player: " + selectedPlayer.name);
}


followNextPlayer()
{
	selectedPlayer = undefined;

	// First try to find player from the same team
	if (isDefined(level.streamerSystem_player))
	{
		selectedPlayer = getNextPlayerFrom(level.streamerSystem_player, level.streamerSystem_player.pers["team"]);
	}

	// If not found, select from both teams
	if (!isDefined(selectedPlayer))
	{
		selectedPlayer = getNextPlayerFrom(level.streamerSystem_player);
	}

	if (isDefined(selectedPlayer))
		followPlayer(selectedPlayer);
	else
		stopFollowing();
}




spectating_loop()
{
	selectedPlayer = getRecommandedPlayer();

	// Follow recomanded player as first for some time before first switch
	if (isDefined(selectedPlayer))
	{
		level followPlayer(selectedPlayer);
	}
	else if (level.debug_spectator) printToStreamers("> no recommanded player");


	no_one = false;
	for(;;)
	{
		wait level.fps_multiplier * 0.1;


		id = level.streamerSystem_playerID;
		spectated_player = level.streamerSystem_player;

		// If noone is followed, follow next player no matter what
		if (id == -1 || !isDefined(spectated_player) || !isPlayer(spectated_player))
		{
			level followNextPlayer();

			if (level.streamerSystem_playerID != -1)
				if (level.debug_spectator) printToStreamers("(no one was followed)");
			else
			{
				if (level.debug_spectator && no_one == false) printToStreamers("(there is no one to follow)");
				no_one = true;
			}
			continue;
		}
		no_one = false;

		// If followed player is dead, follow next no matter what
		if (spectated_player.sessionstate != "playing")
		{
			wait level.fps_multiplier * 1;

			level followNextPlayer();
			if (level.debug_spectator) printToStreamers("(followed player died)");
			continue;
		}
	}
}



printToStreamers(text)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player.pers["team"] == "streamer" /*&& player.streamerSystem_turnedOn*/)
		{
			player iprintln(text);
			break;
		}
	}
}


printBoldToStreamers(text)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player.pers["team"] == "streamer" /*&& player.streamerSystem_turnedOn*/)
		{
			player iprintlnbold(text);
			break;
		}
	}
}


isSpectatorInKillcam()
{
	in_killcam = false;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player.pers["team"] == "streamer" && player.sessionstate == "spectator" && isDefined(player.killcam) && player.killcam == true)
		{
			in_killcam = true;
			break;
		}
	}

	return in_killcam;
}


waitForSpectatorsInKillcam()
{
	// Check if some spectator is in killcam
	in_killcam = level isSpectatorInKillcam();
	if (in_killcam)
	{
		// HUD
		hud = addHUD(-85, 280, 1.2, (1,1,0), "center", "middle", "right");
		hud showHUDSmooth(.5);
		hud setText(game["STRING_STREAMERSYSTEM_KILLCAM_REPLAY"]);

		// Disable players weapons
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.sessionstate == "playing")
				player disableWeapon();
		}

		// Delete weapons in map
		for (i = 0; i < level.weaponnames.size; i++)
		{
			weapon = level.weaponnames[i];
			weapons = getentarray("weapon_" + weapon, "classname");
			for(j = 0; j < weapons.size; j++)
				weapons[j] delete();
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

	return true;
}
