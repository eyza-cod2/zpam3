#include maps\mp\gametypes\global\_global;

init()
{
	level.spectatingSystem_playerID = -1;		// spectated player
	level.spectatingSystem_player = undefined;
	level.spectatingSystem_lastChange = 0;

	if (!isDefined(game["spectatingSystem_recommandedPlayerMode_teamLeft_player"]) || level.gametype != "sd" || game["round"] == 0) // round in case of bash
		game["spectatingSystem_recommandedPlayerMode_teamLeft_player"] = undefined;
	if (!isDefined(game["spectatingSystem_recommandedPlayerMode_teamRight_player"]) || level.gametype != "sd" || game["round"] == 0) // round in case of bash
		game["spectatingSystem_recommandedPlayerMode_teamRight_player"] = undefined;


	addEventListener("onConnected",  	::onConnected);
	addEventListener("onSpawnedPlayer",  	::onSpawnedPlayer);
	addEventListener("onSpawnedSpectator",  ::onSpawnedSpectator);

	if (!level.spectatingSystem)
	{
		return;
	}

	addEventListener("onSpawnedStreamer",  ::onSpawnedStreamer);
	addEventListener("onConnectedAll",    	::onConnectedAll);
	addEventListener("onMenuResponse",  	::onMenuResponse);

	//setCvar("debug_spectator", 1);
}

// Called even is spectating system is disabled
onConnected()
{
	self endon("disconnect");

	if (!isDefined(self.pers["spectatingSystem_menu_opened"]))
		self.pers["spectatingSystem_menu_opened"] = false;

	if (!isDefined(self.pers["spectatingSystem_menu_open_confirmed"]))
		self.pers["spectatingSystem_menu_open_confirmed"] = false;

	if (!isDefined(self.pers["spectatingSystem_keysConfirmed"]))
		self.pers["spectatingSystem_keysConfirmed"] = false;

	if (!isDefined(self.pers["spectatingSystem_autoJoinSpectatorTeam"]))
		self.pers["spectatingSystem_autoJoinSpectatorTeam"] = false;


	self.spectatingSystem_turnedOn = false;		// menu is opened
	self.spectatingSystem_freeSpectating = true; 	// free spectating, not following any player
	self.spectatingSystem_inCinematic = false;

	// Switched to readyup (halft, timeout..) -> imidietly hide bars
	if (level.spectatingSystem && level.in_readyup)
	{
		wait level.fps_multiplier * 0.41337;
		self thread maps\mp\gametypes\_spectating_system_hud::hide_player_boxes();
	}
}

onConnectedAll()
{
	level thread spectating_loop();
}

// Called even is spectating system is disabled
onSpawnedPlayer()
{
	self exit();
}

// Called even is spectating system is disabled
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
		if (level.in_readyup)
			self thread openSpectMenu(false); // without cursor
		else
			self thread openSpectMenu(true); // with cursor


		// Watch for keys and force following a player
		self thread player_loop();
		self spectatingSystemTurnOn();

		// Show autospectator status HUD
		self thread maps\mp\gametypes\_spectating_system_auto::HUD_loop();
		// Create and update boxes with players name
		self thread maps\mp\gametypes\_spectating_system_hud::HUD_PlayerBoxes_Loop();
		// XRAY
		self thread maps\mp\gametypes\_spectating_system_xray::XRAY_Loop();

		self thread cinematicMove();
	}
}




exit()
{
	// We have to make sure that this cvar is defined, otherwise quickmessages menu will not work
	self setClientCvar2("ui_quickmessage_spectatormode", "0");

	// Disable auto spectator team join
	self join_spectator_disable();

	// Hide black background for animation
	if (isDefined(self.spectator_blackbg))
	{
		self.spectator_blackbg destroy2();
		self.spectator_blackbg = undefined;
	}
}


join_spectator_isEnabled()
{
	return self.pers["spectatingSystem_autoJoinSpectatorTeam"];
}

// Is called from quicksettings on player connect, after settings are loaded + when player joined streamers and confirmed keys
join_spectator_enable(loaded_from_settings)
{
	if (!isDefined(loaded_from_settings)) loaded_from_settings = false;

	// Conditions to apply		(in server info)				(waiting for key confirm)
	if (level.spectatingSystem && (!isDefined(self.pers["firstTeamSelected"]) || self.pers["team"] == "streamer") && self.pers["spectatingSystem_autoJoinSpectatorTeam"] == false)
	{
		self.pers["spectatingSystem_autoJoinSpectatorTeam"] = true;
		//self iprintln("Automatically join spectator team ^2Enabled");

		// Enabled when manually joined streamers, save this setting into server16
		if (loaded_from_settings == false)
			self maps\mp\gametypes\_quicksettings::updateClientSettings("streamer_enabled");

		// Loaded from settings, move to streamer team
		if (loaded_from_settings && !isDefined(self.pers["firstTeamSelected"]))
		{
			self thread move_to_streamers();
		}
	}
}

// Is called from quicksettings on player connect, after settings are loaded + when player exit streamers team
join_spectator_disable(loaded_from_settings)
{
	if (!isDefined(loaded_from_settings)) loaded_from_settings = false;

	//if (self.pers["spectatingSystem_autoJoinSpectatorTeam"])
		//self iprintln("Automatically join spectator team ^1Disabled");

	self.pers["spectatingSystem_autoJoinSpectatorTeam"] = false;

	// Save this setting into server16
	if (loaded_from_settings == false)
		self maps\mp\gametypes\_quicksettings::updateClientSettings("streamer_disabled");
}


join_spectator_toggle()
{
	if (self join_spectator_isEnabled())
		self join_spectator_disable();
	else
		self join_spectator_enable();
}


// Called when settings are loaded from serverinfo
move_to_streamers()
{
	self endon("disconnect");

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

	self iprintlnbold("Streamer auto-join...");

	wait level.fps_multiplier * 2;

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

	if (menu == game["menu_spectatingsystem"])
	{
		if (response == "menu_open")
		{
			self.pers["spectatingSystem_menu_open_confirmed"] = true;

			self thread maps\mp\gametypes\_spectating_system_hud::HUD_ActivateSpectatingSystem_hide();

			// Enable auto spectator team join when keys were confirmed
			if (join_spectator_isEnabled() == false && self.pers["spectatingSystem_keysConfirmed"])
				self join_spectator_enable();

			// Automatically confirm keys welcoming message if auto spectator join team is enabled
			if (self.pers["spectatingSystem_autoJoinSpectatorTeam"])
				self.pers["spectatingSystem_keysConfirmed"] = true;

			// Show welcoming keys
			if (self.pers["spectatingSystem_keysConfirmed"] == false)
			{
				self thread maps\mp\gametypes\_spectating_system_hud::keys_show();
				self thread maps\mp\gametypes\_spectating_system_hud::HUD_KeysWelcome_show();
			}

			// Hide scoreboard from ingame menu
			self.pers["scoreboard_keepRefreshing"] = 0;

			return true;
		}
		else if (response == "menu_close")
		{
			self.pers["spectatingSystem_menu_opened"] = false;
			self thread maps\mp\gametypes\_spectating_system_hud::keys_hide();
			self thread maps\mp\gametypes\_spectating_system_hud::HUD_ActivateSpectatingSystem_show();

			// Hide scoreboard from ingame menu
			self.pers["scoreboard_keepRefreshing"] = 0;

			return true;
		}

		else if (response == "shift")
		{
			if (level.debug_spectator) self iprintln("MENU_SHIFT");

			// We were in cinematic move, cancel it
			if (self.spectatingSystem_inCinematic)
				self.spectatingSystem_inCinematic = false;

			// Shift is automatically closing the menu to hide cursor
			self.pers["spectatingSystem_menu_opened"] = false;
			self thread maps\mp\gametypes\_spectating_system_hud::keys_hide();
			self thread maps\mp\gametypes\_spectating_system_hud::HUD_ActivateSpectatingSystem_show();

			// In killcam the shift melee key does not work, so we closed the menu but we cannot continue untill killcam ends
			if (isDefined(self.killcam))
				return true;

			// Disable spectating system to be able to register player's shift key to stop following player
			if (self.spectatingSystem_turnedOn)
			{
				self spectatingSystemTurnOff();
				if (level.debug_spectator) self iprintln("MENU_SHIFT> ^1spectating system turned OFF");
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

		// Left mause | Right mouse
		// not received in free spectating, because menu mouse is not working
		else if (response == "mouse1" || response == "mouse2")
		{
			//self iprintln("mouse1");

			// We were in cinematic move, just cancel it
			if (self.spectatingSystem_inCinematic)
			{
				self.spectatingSystem_inCinematic = false;
				return true;
			}

			selectedPlayer = undefined;
			if (response == "mouse1") selectedPlayer = level getNextPlayerFrom(level.spectatingSystem_player);
			if (response == "mouse2") selectedPlayer = level getPreviousPlayerFrom(level.spectatingSystem_player);


			if (isDefined(selectedPlayer))
			{
				if (self.spectatingSystem_turnedOn == false)
				{
					self spectatingSystemTurnOn();
					if (level.debug_spectator) self iprintln("MENU_MOUSE> ^2spectating system turned ON");
				}

				self.spectatingSystem_freeSpectating = false; // free spectating ended, now following a player
				if (level.debug_spectator) self iprintln("MENU_MOUSE> self.spectatingSystem_freeSpectating = ^1false");

				level followPlayer(selectedPlayer);
				level maps\mp\gametypes\_spectating_system_auto::lockFor(15000); // Lock selected player for 15 secods
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
			level maps\mp\gametypes\_spectating_system_auto::autoSpectatorToggle();
			return true;
		}

		// Middle button
		else if (response == "xray")
		{
			self thread maps\mp\gametypes\_spectating_system_xray::toggle();
			return true;
		}

		// Middle button
		else if (response == "hit")
		{
			self thread maps\mp\gametypes\_spectating_system_damage::toggle();
			return true;
		}

		// Middle button
		else if (response == "help")
		{
			self thread maps\mp\gametypes\_spectating_system_hud::keys_toggle();
			self thread maps\mp\gametypes\_spectating_system_hud::HUD_KeysWelcome_hide();

			if (self.pers["spectatingSystem_keysConfirmed"] == false)
			{
				// Enable auto spectator team join
				self join_spectator_enable();
			}

			self.pers["spectatingSystem_keysConfirmed"] = true; // dont open keys again

			return true;
		}

		// scoreboard
		else if (response == "score")
		{
			if (level.gametype == "sd")
			{
				if (self.pers["scoreboard_keepRefreshing"] == 0)
					self thread maps\mp\gametypes\_menu_scoreboard::generatePlayerList(true); // toggle
				else
					self.pers["scoreboard_keepRefreshing"] = 0;
			}
			else
				self thread maps\mp\gametypes\_spectating_system_hud::HUD_CloseMenuWarning_show();

			return true;
		}


		// unexpcted bind
		else if (response == "warning")
		{
			self thread maps\mp\gametypes\_spectating_system_hud::HUD_CloseMenuWarning_show();

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
				if (self.spectatingSystem_inCinematic)
					self.spectatingSystem_inCinematic = false;

				if (self.spectatingSystem_turnedOn == false)
				{
					self spectatingSystemTurnOn();
					if (level.debug_spectator) self iprintln("FOLLOW_KEY> ^2spectating system turned ON");
				}

				self maps\mp\gametypes\_spectating_system_hud::followPlayerByNum(i);

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
openSpectMenu(enableCursor)
{
	self endon("disconnect");

	// Dont run multiple threads
	if (isDefined(self.spectatingMenuOpenRunning))
		return false;

	// Menu is already opened, just set required cursor mode
	if (self.pers["spectatingSystem_menu_opened"])
	{
		// Cursor
		if (enableCursor) 	self setClientCvar2("cl_bypassMouseInput", 0); // 0 = enable menu cursor moving, disable ingame mouse
		else 			self setClientCvar2("cl_bypassMouseInput", 1); // 1 = disable menu cursor moving, enable ingame mouse
		return;
	}

	if (self.sessionteam != "spectator" || self.sessionstate != "spectator")
		return;

	self.spectatingMenuOpenRunning = true;

	// Before opening menu we need to wait, otherwise forcing self.spectatorclient wont work for some reason
	waittillframeend;

	// Handle none team bug
	level thread handleMenuSpectatingBug(self);

	// Hide scoreboard from ingame menu
	self.pers["scoreboard_keepRefreshing"] = 0;


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
	self.pers["spectatingSystem_menu_open_confirmed"] = false;
	while(!self.pers["spectatingSystem_menu_open_confirmed"] && self.pers["team"] == "streamer")
	{
		self.spectatorclient = -1;
		self.sessionteam = "none";
		self.sessionstate = "dead"; // enable quickmessage

		// In "dead" session state the angle of player is computed by game and cannot be changed with script
		// That will cause weird flickering, so rather show black screen instead by spawning outside map
		self spawn((-99999, -99999, -99999), (0,0,0));

		self setClientCvar2("ui_quickmessage_spectatormode", "1");

		// Cursor
		if (enableCursor) 	self setClientCvar2("cl_bypassMouseInput", 0); // 0 = enable menu cursor moving, disable ingame mouse
		else 			self setClientCvar2("cl_bypassMouseInput", 1); // 1 = disable menu cursor moving, enable ingame mouse

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
			self iprintln("^1Cannot open spectating system menu. Please press ^3[ESC]^1 key");
			retry = 0;
		}
		if (level.debug_spectator) self iprintln("^3Opening mp_quickmessage with spectator mode...");

		// Wait a second before next menu opening
		for (i = 0; i < 9 && !self.pers["spectatingSystem_menu_open_confirmed"]; i++)
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

		self.pers["spectatingSystem_menu_opened"] = true;
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
	self.waitForAttackKeyRelease = false;
	self.waitForMeleeKeyRelease = false;
	self.waitForUseKeyRelease = false;

	for(;;)
	{
		wait level.frame;

		// End this thread if player join team
		if (self.pers["team"] != "streamer")
		{
			self spectatingSystemTurnOff();
			self spectatingSystemExit();
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
		if(self usebuttonpressed() && !self.waitForUseKeyRelease && !self.spectatingSystem_killcam_proposingVisible)	// Ignore F press is killcam proposing is visible
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
				if (level.debug_spectator) self iprintln("^1 UNABLE ^8to set self.spectatorclient="+level.spectatingSystem_playerID);

				wait level.fps_multiplier * 1;

				continue;
			}
			else
				self.spectatingSystem_freeSpectating = false; // free spectating ended, now following a player
		}

		// Make sure we always follow somebody
		if (self.spectatingSystem_turnedOn && !self.spectatingSystem_inCinematic && !isDefined(self.killcam) && self.sessionstate == "spectator" && level.spectatingSystem_playerID != self.spectatorclient)
		{
			self.spectatorclient = level.spectatingSystem_playerID;

			if (level.debug_spectator) self iprintln("^8 set self.spectatorclient="+level.spectatingSystem_playerID);

			playerChanged = true;
		}
	}
}



handleAttackButtonPress()
{
	self endon("disconnect");

	if (level.debug_spectator) self iprintln("attackBtn");

	player = level getNextPlayerFrom(level.spectatingSystem_player);
	withCursor = true;

	if (!isDefined(player))
	{
		self iprintln("No player to follow");
		withCursor = false;
	}

	// Start following nearby player
	if (isDefined(self.spectatingSystem_playerToFollow) && self.spectatingSystem_freeSpectating && !self.spectatingSystem_turnedOn)
	{
		if (level.debug_spectator) self iprintln("MENU_MOUSE> follow close by player");

		level followPlayer(self.spectatingSystem_playerToFollow);
		level maps\mp\gametypes\_spectating_system_auto::lockFor(15000); // Lock selected player for 15 secods
	}

	// Open menu overlay (with cursor)
	self thread openSpectMenu(withCursor);

	// Enable spectating
	if (self.spectatingSystem_turnedOn == false)
	{
		self spectatingSystemTurnOn();
		if (level.debug_spectator) self iprintln("attackBtn> ^2spectating system turned ON");
	}

	while(self attackbuttonpressed())
		wait level.frame;

	self.waitForAttackKeyRelease = false;
}


handleMeleeButtonPress()
{
	self endon("disconnect");

	if (level.debug_spectator) self iprintln("meleeBtn");

	// We are not in spectating system - what ever spectator state is, now we pressed shift for freespectating
	if (!self.spectatingSystem_turnedOn)
	{
		self.spectatingSystem_freeSpectating = true; // free spectating, not following any player
		if (level.debug_spectator) self iprintln("meleeBtn> self.spectatingSystem_freeSpectating = ^2true");
	}

	// Reopen menu overlay (without cursor)
	self.pers["spectatingSystem_menu_opened"] = false;
	self thread openSpectMenu(false);

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




spectatingSystemTurnOn()
{
	self.spectatingSystem_turnedOn = true;
}


spectatingSystemTurnOff()
{
	self.spectatingSystem_turnedOn = false;
	self.spectatorclient = -1;
}

spectatingSystemExit()
{
	self thread maps\mp\gametypes\_spectating_system_hud::keys_hide();
	self thread maps\mp\gametypes\_spectating_system_hud::HUD_ActivateSpectatingSystem_hide();
}


cinematicMove()
{
	self endon("disconnect");

	// Wait untill other players connect and we have player to follow
	waittillframeend;

	self.spectatingSystem_inCinematic = true;

	if (level.debug_spectator) self iprintln(gettime() + " cinematic> runned");

	// Wait till menu is opened
	for (i = 0; ; i++)
	{
		if (self.pers["team"] != "streamer") // leaved spectator
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because team != streamer");
			self.spectatingSystem_inCinematic = false;
		}
		// Alive player that was followed spawned to spectators
		if (level.spectatingSystem_playerID == self getEntityNumber())
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because this player is followed");
			self.spectatingSystem_inCinematic = false;
		}
		// Not in strattime
		if (!isDefined(level.in_strattime) || !level.in_strattime)
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because level.in_strattime = false");
			self.spectatingSystem_inCinematic = false;
		}
		// In bash
		if (isDefined(level.in_bash) && level.in_bash)
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because level.in_bash = true");
			self.spectatingSystem_inCinematic = false;
		}
		// Time elapsed
		if (i > 30)
		{
			if (level.debug_spectator) self iprintln("cinematic> canceled because conditions time 3s elapsed");
			self.spectatingSystem_inCinematic = false;
		}


		// All ready for cinematic move, exit
		if (self.spectatingSystem_inCinematic && level.spectatingSystem_playerID != -1 && self.spectatingSystem_turnedOn && self.pers["spectatingSystem_menu_opened"] && self.sessionstate == "spectator")
			break;


		// Cinematic was canceled, or this is second run
		if (i == 0 && self.origin == (0,0,0))
		{
			spawnpoints = getentarray("mp_global_intermission", "classname");
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
			if(isdefined(spawnpoint)) self spawn(spawnpoint.origin, spawnpoint.angles);
		}

		// Canceled
		if (self.spectatingSystem_inCinematic == false)
		{
			if (level.debug_spectator)
			{
				self iprintln("^1cinematic> canceled");

				if (!self.spectatingSystem_turnedOn) 		self iprintln("cinematic> ^1self.spectatingSystem_turnedOn = false");
				if (!self.pers["spectatingSystem_menu_opened"]) self iprintln("cinematic> ^1self.pers[spectatingSystem_menu_opened] = false");
				if (self.sessionstate != "spectator") 		self iprintln("cinematic> ^1self.sessionstate != spectator");
				if (level.spectatingSystem_playerID == -1) 	self iprintln("cinematic> ^1level.spectatingSystem_playerID = -1");
			}
			return;
		}

		wait level.fps_multiplier * 0.1;
	}


	if (level.debug_spectator) self iprintln(gettime() + " cinematic> doing cinematic for " + level.spectatingSystem_player.name);



	player = level.spectatingSystem_player;
	id = level.spectatingSystem_playerID;

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



	self.spectatingSystem_freeSpectating = false;


	self.spectatorLock moveTo(originEnd, length, acceleration, deceleration);

	startTime = getTime();
	for(;;)
	{
		// Cinematic canceled or some key was pressed
		if (!self.spectatingSystem_inCinematic)
		{
			if (level.debug_spectator) self iprintln("cinematic> DONE because it was canceled");
			break;
		}
		// Player changed team
		if (self.pers["team"] != "streamer")
		{
			if (level.debug_spectator) self iprintln("cinematic> DONE because team is not streamer");
			break;
		}
		// Spectated player changed
		if (level.spectatingSystem_playerID != id)
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

	self.spectatingSystem_inCinematic = false;
}


getRecommandedPlayer()
{
	if (level.gametype != "sd")
	{
		return findBestPlayer();
	}

	// If match info is enabled, ensure teams are in correct sides
	teamLeft = "allies";
	teamRight = "axis";
	if ((game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2) && game["match_team1_side"] == "axis")
	{
		teamLeft = "axis";
		teamRight = "allies";
	}

	/*
	Follow in this direction:
	Round	TEAM1	TEAM2
	1	sniper
	2		sniper
	3	best
	4		best
	5	p1
	6		p1
	7	p2
	8		p2
	9	best
	10		best
	11	p1
	12		p1
	13	p2
	14		p2
	15	...	...


	*/


	selectedPlayer = undefined;


	// Team left
	if (game["round"] % 2 != 0)
	{
		if (game["round"] == 1)
		{
			// Find sniper of first team
			selectedPlayer = findSniper(teamLeft);
			game["spectatingSystem_recommandedPlayerMode_teamLeft_player"] = selectedPlayer;

			if (isDefined(selectedPlayer)) printToSpectators("Spectating player with scope in team " + teamLeft + ": " + selectedPlayer.name);
		}
		if (game["round"] % 3 == 0) // every 3. rounds
		{
			// Find best player with the most kills
			selectedPlayer = findBestPlayer(teamLeft);

			if (isDefined(selectedPlayer)) printToSpectators("Spectating best player in team " + teamLeft + ": " + selectedPlayer.name);
		}
	}
	// Team right
	else
	{
		if (game["round"] == 2)
		{
			// Find sniper of first team
			selectedPlayer = findSniper(teamRight);
			game["spectatingSystem_recommandedPlayerMode_teamRight_player"] = selectedPlayer;

			if (isDefined(selectedPlayer)) printToSpectators("Spectating player with scope in team " + teamRight + ": " + selectedPlayer.name);
		}
		else if ((game["round"]-1) % 3 == 0) // every 3. rounds
		{
			// Find best player with the most kills
			selectedPlayer = findBestPlayer(teamRight);

			if (isDefined(selectedPlayer)) printToSpectators("Spectating best player in team " + teamRight + ": " + selectedPlayer.name);
		}

	}


	// Find next player in row as default
	if (!isDefined(selectedPlayer))
	{
		// Team left
		if (game["round"] % 2 != 0)
		{
			selectedPlayer = getNextPlayerFrom(game["spectatingSystem_recommandedPlayerMode_teamLeft_player"], teamLeft);
			game["spectatingSystem_recommandedPlayerMode_teamLeft_player"] = selectedPlayer;

			if (isDefined(selectedPlayer)) printToSpectators("Spectating next player in team " + teamLeft + ": " + selectedPlayer.name);
		}
		// Team right
		else
		{
			selectedPlayer = getNextPlayerFrom(game["spectatingSystem_recommandedPlayerMode_teamRight_player"], teamRight);
			game["spectatingSystem_recommandedPlayerMode_teamRight_player"] = selectedPlayer;

			if (isDefined(selectedPlayer)) printToSpectators("Spectating next player in team " + teamRight + ": " + selectedPlayer.name);
		}

	}

	return selectedPlayer;
}

findSniper(team)
{
	selectedPlayer = undefined;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if ((player.pers["team"] == team) && player.sessionstate == "playing" && isDefined(player.pers["weapon"]))
		{
			weaponData = level.weapons[player.pers["weapon"]];

			if (isDefined(weaponData) && weaponData.classname == "sniper")
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
	players = maps\mp\gametypes\_spectating_system_hud::getPlayersByTeam();
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
		if (level.debug_spectator) printToSpectators(">selecting next player "+teamStr+": " + selectedPlayer.name);
	}

	return selectedPlayer;
}



followPlayer(selectedPlayer)
{
	level.spectatingSystem_playerID = selectedPlayer getEntityNumber();
	level.spectatingSystem_player = selectedPlayer;
	level.spectatingSystem_lastChange = getTime();

	//if (level.debug_spectator) printToSpectators("Spect: set followed player: " + selectedPlayer.name);
}


stopFollowing()
{
	level.spectatingSystem_playerID = -1;
	level.spectatingSystem_player = undefined;
	level.spectatingSystem_lastChange = getTime();

	//if (level.debug_spectator) printToSpectators("Spect: set followed player: " + selectedPlayer.name);
}


followNextPlayer()
{
	selectedPlayer = undefined;

	// First try to find player from the same team
	if (isDefined(level.spectatingSystem_player))
	{
		selectedPlayer = getNextPlayerFrom(level.spectatingSystem_player, level.spectatingSystem_player.pers["team"]);
	}

	// If not found, select from both teams
	if (!isDefined(selectedPlayer))
	{
		selectedPlayer = getNextPlayerFrom(level.spectatingSystem_player);
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
	else if (level.debug_spectator) printToSpectators("> no recommanded player");


	no_one = false;
	for(;;)
	{
		wait level.fps_multiplier * 0.1;


		id = level.spectatingSystem_playerID;
		spectated_player = level.spectatingSystem_player;

		// If noone is followed, follow next player no matter what
		if (id == -1 || !isDefined(spectated_player) || !isPlayer(spectated_player))
		{
			level followNextPlayer();

			if (level.spectatingSystem_playerID != -1)
				if (level.debug_spectator) printToSpectators("(no one was followed)");
			else
			{
				if (level.debug_spectator && no_one == false) printToSpectators("(there is no one to follow)");
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
			if (level.debug_spectator) printToSpectators("(followed player died)");
			continue;
		}
	}
}



printToSpectators(text)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player.pers["team"] == "streamer" /*&& player.spectatingSystem_turnedOn*/)
		{
			player iprintln(text);
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
		hud setText(game["STRING_SPECTATINGSYSTEM_KILLCAM_REPLAY"]);

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
