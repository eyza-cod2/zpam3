#include maps\mp\gametypes\global\_global;

init()
{
	if (!level.streamerSystem)
		return;

	if(game["firstInit"])
	{
		precacheString2("STRING_STREAMERSYSTEM_PRESS_ATTACT_TO_ENABLE", &"Press ^3[{+attack}]^7 to open streamer menu");
		precacheString2("STRING_STREAMERSYSTEM_PRESS_ESC_WARNING", &"Press ^3[ESC]^7 to close streamer menu\n(binds are not working when streamer menu is opened)");
	}

	if (!isDefined(game["streamerSystem_scoreProgress"]))
		game["streamerSystem_scoreProgress"] = [];

	game["streamerSystem_playerProgress"] = [];

	level.streamerSystem_boxesLeft_players = [];
	level.streamerSystem_boxesRight_players = [];

	addEventListener("onConnected",  	::onConnected);
}

onConnected()
{
	if (!isDefined(self.pers["streamerSystem_keysVisible"]))
		self.pers["streamerSystem_keysVisible"] = false;
}

keys_toggle()
{
	// Already hided
	if (!self.pers["streamerSystem_keysVisible"])
		self keys_show();
	else
		self keys_hide();
}

keys_show()
{
	self.pers["streamerSystem_keysVisible"] = true;
	self setClientCvar2("ui_spectatorsystem_keys", "1");
	self notify("streamerSystem_keysVisible", 1);

	self thread settingsChangedForPlayer(""); // will show all
}

keys_hide()
{
	self.pers["streamerSystem_keysVisible"] = false;
	self setClientCvar2("ui_spectatorsystem_keys", "0");
	self notify("streamerSystem_keysVisible", 0);

	self thread settingsChangedForPlayer(""); // will hide all
}




HUD_KeysWelcome_show()
{
	self setClientCvar2("ui_spectatorsystem_keysWelcome", "1");
}

HUD_KeysWelcome_hide()
{
	self setClientCvar2("ui_spectatorsystem_keysWelcome", "0");
}




HUD_ActivateStreamerSystem_show()
{
	if (!isDefined(self.streamerSystem_HUD_enableBG))
	{
		self.streamerSystem_HUD_enableBG = addHUDClient(self, -100, 40, undefined, (1,1,1), "left", "top", "center", "middle");
	    	self.streamerSystem_HUD_enableBG setShader("black", 200, 20);
		self.streamerSystem_HUD_enableBG.archived = false;
		self.streamerSystem_HUD_enableBG.sort = -1000; // idk why sometimes the BG is in front of text...
	        self.streamerSystem_HUD_enableBG.alpha = 0.5;
	}
	if (!isDefined(self.streamerSystem_HUD_enable))
	{
	        self.streamerSystem_HUD_enable = addHUDClient(self, 0, 40+6, 0.8, (1,1,1), "center", "top", "center", "middle");
		self.streamerSystem_HUD_enable.archived = false;
		self.streamerSystem_HUD_enable setText(game["STRING_STREAMERSYSTEM_PRESS_ATTACT_TO_ENABLE"]);
	}

	self HUD_CloseMenuWarning_destroy();
}

HUD_ActivateStreamerSystem_hide()
{
	if (isDefined(self.streamerSystem_HUD_enableBG))
	{
		self.streamerSystem_HUD_enableBG destroy2();
		self.streamerSystem_HUD_enableBG = undefined;
	}
	if (isDefined(self.streamerSystem_HUD_enable))
	{
	        self.streamerSystem_HUD_enable destroy2();
		self.streamerSystem_HUD_enable = undefined;
	}
}




HUD_CloseMenuWarning_show()
{
	self endon("disconnect");

	self notify("streamerSystem_HUD_closeMenuWarningBG");
	self endon("streamerSystem_HUD_closeMenuWarningBG");

	if (!isDefined(self.streamerSystem_HUD_closeMenuWarningBG))
	{
		self.streamerSystem_HUD_closeMenuWarningBG = addHUDClient(self, -150, 40, undefined, (1,1,1), "left", "top", "center", "middle");
	    	self.streamerSystem_HUD_closeMenuWarningBG setShader("black", 300, 23);
		self.streamerSystem_HUD_closeMenuWarningBG.archived = false;
		self.streamerSystem_HUD_closeMenuWarningBG.sort = -1000;
	}
	if (!isDefined(self.streamerSystem_HUD_closeMenuWarning))
	{
	        self.streamerSystem_HUD_closeMenuWarning = addHUDClient(self, 0, 40+2, 0.8, (1,1,1), "center", "top", "center", "middle");
		self.streamerSystem_HUD_closeMenuWarning.archived = false;
		self.streamerSystem_HUD_closeMenuWarning setText(game["STRING_STREAMERSYSTEM_PRESS_ESC_WARNING"]);
	}

	self.streamerSystem_HUD_closeMenuWarning.alpha = 1;

	for (i = 0; i < 3; i++)
	{
		self.streamerSystem_HUD_closeMenuWarningBG.alpha = 0.75;

		wait level.fps_multiplier * 0.1;
		if (!isDefined(self.streamerSystem_HUD_closeMenuWarningBG) || !isDefined(self.streamerSystem_HUD_closeMenuWarning)) return;

		self.streamerSystem_HUD_closeMenuWarningBG.alpha = 0.5;

		wait level.fps_multiplier * 0.1;
		if (!isDefined(self.streamerSystem_HUD_closeMenuWarningBG) || !isDefined(self.streamerSystem_HUD_closeMenuWarning)) return;
	}

	self.streamerSystem_HUD_closeMenuWarningBG.alpha = 0.75;
	self.streamerSystem_HUD_closeMenuWarning.alpha = 1;

	wait level.fps_multiplier * 0.5;
	if (!isDefined(self.streamerSystem_HUD_closeMenuWarningBG) || !isDefined(self.streamerSystem_HUD_closeMenuWarning)) return;

	self.streamerSystem_HUD_closeMenuWarningBG FadeOverTime(.5);
	self.streamerSystem_HUD_closeMenuWarning FadeOverTime(.5);
	self.streamerSystem_HUD_closeMenuWarningBG.alpha = 0;
	self.streamerSystem_HUD_closeMenuWarning.alpha = 0;

	wait level.fps_multiplier * .5;

	self HUD_CloseMenuWarning_destroy();
}

HUD_CloseMenuWarning_destroy()
{
	if (isDefined(self.streamerSystem_HUD_closeMenuWarningBG))
	{
		self.streamerSystem_HUD_closeMenuWarningBG destroy2();
		self.streamerSystem_HUD_closeMenuWarningBG = undefined;
	}
	if (isDefined(self.streamerSystem_HUD_closeMenuWarning))
	{
	        self.streamerSystem_HUD_closeMenuWarning destroy2();
		self.streamerSystem_HUD_closeMenuWarning = undefined;
	}

}


hide_all()
{
	self hide_player_boxes();
	self hide_matchinfo();
	self hide_player_progress();
	self hide_messages();

	self setClientCvarIfChanged("ui_streamersystem_settings", "");
}

hide_player_boxes()
{
	for (i = 4; i >= 0; i--)
	{
		self setClientCvarIfChanged("ui_streamersystem_team1_player"+i+"_health", "");
		self setClientCvarIfChanged("ui_streamersystem_team2_player"+i+"_health", "");

		//self setClientCvarIfChanged("ui_streamersystem_team1_player"+i+"_name", "");		// these cvars are hided anyway via _health cvar
		//self setClientCvarIfChanged("ui_streamersystem_team2_player"+i+"_name", "");		// save sending these cvars

		//self setClientCvarIfChanged("ui_streamersystem_team1_player"+i+"_score", "");
		//self setClientCvarIfChanged("ui_streamersystem_team2_player"+i+"_score", "");

		//self setClientCvarIfChanged("ui_streamersystem_team1_player"+i+"_weapon", "");
		//self setClientCvarIfChanged("ui_streamersystem_team2_player"+i+"_weapon", "");

		//self setClientCvarIfChanged("ui_streamersystem_team1_player"+i+"_round_kills", "");
		//self setClientCvarIfChanged("ui_streamersystem_team2_player"+i+"_round_kills", "");

		self setClientCvarIfChanged("ui_streamersystem_team1_player"+i+"_icons", "");
		self setClientCvarIfChanged("ui_streamersystem_team2_player"+i+"_icons", "");
	}
}

hide_matchinfo()
{
	self setClientCvarIfChanged("ui_streamersystem_matchInfo", "");
}

hide_player_progress()
{
	self setClientCvarIfChanged("ui_streamersystem_playerProgress", "");
}

hide_messages()
{
	self setClientCvarIfChanged("ui_streamersystem_message_line1", "");
	self setClientCvarIfChanged("ui_streamersystem_message_line2", "");
}


ScoreProgress_AddWinner(winner)
{
	if (!level.streamerSystem) return;

	teamLeft = "allies";
	teamRight = "axis";

	// If match info is enabled, ensure teams are in correct sides
	if (game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2)
	{
		if (game["match_team1_side"] == "axis")
		{
			teamLeft = "axis";
			teamRight = "allies";
		}
	}

	team = 0; // draw
	if (winner == "allies" && teamLeft == "allies") team = 1; // team left
	if (winner == "allies" && teamRight == "allies") team = 2; // team right
	if (winner == "axis" && teamLeft == "axis") team = 1; // team left
	if (winner == "axis" && teamRight == "axis") team = 2; // team right

	game["streamerSystem_scoreProgress"][game["streamerSystem_scoreProgress"].size] = team;
}

ScoreProgress_AddHalftime()
{
	if (!level.streamerSystem) return;
	game["streamerSystem_scoreProgress"][game["streamerSystem_scoreProgress"].size] = 3; // halftime
}

ScoreProgress_AddOvertime()
{
	if (!level.streamerSystem) return;
	game["streamerSystem_scoreProgress"][game["streamerSystem_scoreProgress"].size] = 4; // overtime
}

ScoreProgress_AddTimeout(callerTeam)
{
	if (!level.streamerSystem) return;

	teamLeft = "allies";
	teamRight = "axis";

	// If match info is enabled, ensure teams are in correct sides
	if (game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2)
	{
		if (game["match_team1_side"] == "axis")
		{
			teamLeft = "axis";
			teamRight = "allies";
		}
	}

	team = 0; // unknown
	if (callerTeam == "allies" && teamLeft == "allies") team = 5; // team left
	if (callerTeam == "allies" && teamRight == "allies") team = 6; // team right
	if (callerTeam == "axis" && teamLeft == "axis") team = 5; // team left
	if (callerTeam == "axis" && teamRight == "axis") team = 6; // team right

	game["streamerSystem_scoreProgress"][game["streamerSystem_scoreProgress"].size] = team; // timeout
}





PlayerProgress_Add(allies_alive, axis_alive, winner)
{
	if (!level.streamerSystem) return;

	struct = spawnstruct();
	struct.allies_alive = allies_alive;
	struct.axis_alive = axis_alive;
	struct.winner = winner;	// "", "allies", "axis"

	game["streamerSystem_playerProgress"][game["streamerSystem_playerProgress"].size] = struct;
}


// self can be a player or level
settingsChanged(what)
{
	players = getPlayersByTeam("streamer");
	for (i = 0; i < players.size; i++)
	{
		players[i] thread settingsChangedForPlayer(what);
	}
}

settingsChangedForPlayer(what) // "", auto, xray, damage
{
	self endon("disconnect");

	self notify("streamer_settingsChangedForPlayer");
	self endon("streamer_settingsChangedForPlayer");

	settingsStatus = "";
	if (self.pers["streamerSystem_keysVisible"] || what == "auto")
	{
		if (level.streamerSystem_auto_turnedOn)		settingsStatus += "Auto-spectator: ^2ON    ^7";
		else						settingsStatus += "Auto-spectator: ^1OFF   ^7";
	}
	if (self.pers["streamerSystem_keysVisible"] || what == "xray")
	{
		if (self.pers["streamerSystem_XRAY"])		settingsStatus += "XRAY: ^2ON    ^7";
		else						settingsStatus += "XRAY: ^1OFF   ^7";
	}
	if (self.pers["streamerSystem_keysVisible"] || what == "damage")
	{
		if (self.pers["streamerSystem_damageInfo"])	settingsStatus += "Hits: ^2ON    ^7";
		else						settingsStatus += "Hits: ^1OFF   ^7";
	}

	self setClientCvarIfChanged("ui_streamersystem_settings", settingsStatus);

	if (self.pers["streamerSystem_keysVisible"] == false && (what == "auto" || what == "xray" || what == "damage"))
	{
		wait level.fps_multiplier * 1;

		self setClientCvarIfChanged("ui_streamersystem_settings", "");
	}
}



HUD_PlayerBoxes_Loop()
{
	self endon("disconnect");

	wait level.frame;



	round_kills_printed = false;
	for(;;)
	{
		wait level.fps_multiplier * 0.1;

		if (self.pers["team"] != "streamer")
		{
			// Player left spectators, hide hud elements
			self thread hide_all();
			return;
		}

		// If match info is enabled, ensure teams are in correct sides
		teamLeft = "allies";
		teamRight = "axis";
		if (game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2)
		{
			if (game["match_team1_side"] == "axis" || game["match_team2_side"] == "allies")
			{
				teamLeft = "axis";
				teamRight = "allies";
			}
		}

		allies_color = "^4"; // blue
		axis_color = "^1"; // red
		if (self.pers["streamerSystem_colorMode"] == 2)
		{
			allies_color = "^8"; // allies
			axis_color = "^9"; // axis
		}

		//allies_color = "^8"; // allies color
		//axis_color = "^9"; // axis color


		// Up to 9 lines can be filled with data
		matchInfo = "";
		matchInfoLines = 0;


		// Custom text from cvars
		streamerSystem_file_lines = [];
		for (i = 1; i <= 4; i++)
		{
			s = getCvar("scr_streamer_text" + i);
			if (s != "")
			{
				streamerSystem_file_lines[streamerSystem_file_lines.size] = s;
			}
		}
/*
		streamerSystem_file_lines[0] = "NEWERA vs ARMIA";
		streamerSystem_file_lines[1] = "0:0  Ready-Up  Toujane  (Burgundy 13:10)";
		streamerSystem_file_lines[2] = "ENTROPIQ vs d O G z";
		streamerSystem_file_lines[3] = "3:3  Round 7/24  Dawnville";
*/
/*
		streamerSystem_file_lines[0] = "game[scr_matchinfo] = " + game["scr_matchinfo"];
		streamerSystem_file_lines[1] = "game[match_team1_side] = " + game["match_team1_side"] + "  (game[match_team1_name] = "+game["match_team1_name"]+")";
		streamerSystem_file_lines[2] = "game[match_team2_side] = " + game["match_team2_side"] + "  (game[match_team2_name] = "+game["match_team2_name"]+")";;
		streamerSystem_file_lines[3] = "teamLeft = " + teamLeft;
		streamerSystem_file_lines[4] = "teamRight = " + teamRight;
*/


		if (streamerSystem_file_lines.size > 0)
		{
			for (i = 0; i < streamerSystem_file_lines.size; i++)
			{
				matchInfo += streamerSystem_file_lines[i] + "\n";
				matchInfoLines++;
			}
			matchInfo += "\n";
			matchInfoLines++;
		}

		// Map history
		mapsCount = 0;
		for (j = 3; j >= 1; j--)
		{
			map = maps\mp\gametypes\_matchinfo::GetMapName(getCvar("sv_map" + j + "_name")); // set sv_map1_name
			if (map != "")
			{
				mapsCount++;
				score1 = getCvarInt("sv_map" + j + "_score1"); // set sv_map1_score1
				score2 = getCvarInt("sv_map" + j + "_score2");

				str = "Map " + mapsCount + ":  " + map + " ";

				if (score1 > score2) {
					if (teamLeft == "allies") str += allies_color; // blue
					if (teamLeft == "axis") str += axis_color; // red
				}
				if (score2 > score1) {
					if (teamRight == "allies") str += allies_color; // blue
					if (teamRight == "axis") str += axis_color; // red
				}
				str += score1 + ":" + score2;

				matchInfo += str + "^7\n";
				matchInfoLines++;
			}
		}


		if (game["match_totaltime_text"] != "")
		{
			matchInfo += "Match time:   " + game["match_totaltime_text"] + "\n";
			matchInfoLines++;
		}


		// Score progress
		if (game["streamerSystem_scoreProgress"].size > 0)
		{
			str = "";
			for (i = 0; i < game["streamerSystem_scoreProgress"].size; i++)
			{
				code = game["streamerSystem_scoreProgress"][i];
				if (code == 0) // Draw
					str += "^7-";
				else if (code == 1) // team left winner
				{
					if (teamLeft == "allies") str += "" + allies_color + "#"; // blue
					if (teamLeft == "axis") str += "" + axis_color + "#"; // red
				}
				else if (code == 2) // team right winner
				{
					if (teamRight == "allies") str += "" + allies_color + "#"; // blue
					if (teamRight == "axis") str += "" + axis_color + "#"; // red
				}
				else if (code == 3) // halftime
				{
					str += "^7|";
				}
				else if (code == 4) // overtime
				{
					str += "^7 [O] ";
				}
				else if (code == 5) // timeout team left
				{
					if (teamLeft == "allies") str += "^7[" + allies_color + "T^7]"; // blue
					if (teamLeft == "axis") str += "^7[" + axis_color + "T^7]"; // red
				}
				else if (code == 6) // timeout team right
				{
					if (teamRight == "allies") str += "^7[" + allies_color + "T^7]"; // blue
					if (teamRight == "axis") str += "^7[" + axis_color + "T^7]"; // red
				}

			}

			matchInfo += "Score progress:\n";
			matchInfoLines++;
			matchInfo += str + "\n";
			matchInfoLines++;
		}

		// Fill with new lines at top
		for (i = matchInfoLines; i < 11; i++)
		{
			matchInfo = "\n" + matchInfo;
		}


		self setClientCvarIfChanged("ui_streamersystem_matchInfo", matchInfo);


		// Hide player progress and boxes in readyup and intermission
		if (game["state"] == "intermission") // readyup in case timeout is called
		{
			self thread hide_player_boxes();
			self thread hide_player_progress();
			self thread hide_messages();
			continue;
		}


		// Hide while in killcam, but not in the final killcam
		if (isDefined(self.killcam) && !(level.gametype == "sd" && level.roundended))
		{
			self thread hide_player_boxes();
			self thread hide_messages();
			continue;
		}

		level.streamerSystem_boxesLeft_players = getPlayersByTeam(teamLeft);
		level.streamerSystem_boxesRight_players = getPlayersByTeam(teamRight);

		// Fill bars
		for(r = 0; r < 5; r++)
		{
			if (r < level.streamerSystem_boxesLeft_players.size)
				self fill_box(r, "left", teamLeft, level.streamerSystem_boxesLeft_players[r]);
			else
				self unfill_box(r, "left");

			if (r < level.streamerSystem_boxesRight_players.size)
				self fill_box(r, "right", teamRight, level.streamerSystem_boxesRight_players[r]);
			else
				self unfill_box(r, "right");
		}



		// Hide player progress and boxes in readyup and intermission
		if (level.in_readyup) // readyup in case timeout is called
		{
			self thread hide_player_progress();
			self thread hide_messages();
			continue;
		}


		// Player progress
		playerProgress = "";
		for (i = 0; i < game["streamerSystem_playerProgress"].size; i++)
		{
			data = game["streamerSystem_playerProgress"][i];

			// If match info is enabled, ensure teams are in correct sides
			alive_text = data.allies_alive + "v" + data.axis_alive;
			if (teamLeft == "axis")
				alive_text = data.axis_alive + "v" + data.allies_alive;

			color = "^7";
			if (data.winner == "allies") 	color = allies_color;
			else if (data.winner == "axis") color = axis_color;

			playerProgress += color + alive_text + "  ";
		}
		self setClientCvarIfChanged("ui_streamersystem_playerProgress", playerProgress);




		message1 = "";
		message2 = "";
		if (level.gametype == "sd" && !level.roundended)
		{
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				if (players[i].bombinteraction)
				{
					message1 = removeColorsFromString(players[i].name);
					if (level.bombplanted)
						message2 = "^1is defusing the bomb"; // red
					else
						message2 = "^3is planting the bomb"; // yellow
					break;
				}
			}
		}
		self setClientCvarIfChanged("ui_streamersystem_message_line1", message1);
		self setClientCvarIfChanged("ui_streamersystem_message_line2", message2);




		// Printing player at the end of the round with the most kills
		if (level.gametype == "sd" &&
			level.roundended &&
			isDefined(level.roundwinner) && (level.roundwinner == "allies" || level.roundwinner == "axis") &&
			round_kills_printed == false)
		{
			players = getPlayersByTeam(level.roundwinner);

			playerMaxKills = undefined;
			for (i = 0; i < players.size; i++)
			{
				if (isDefined(players[i].pers["round_kills"]) && players[i].pers["round_kills"] >= 1)
				{
					if (!isDefined(playerMaxKills) || players[i].pers["round_kills"] > playerMaxKills.pers["round_kills"])
						playerMaxKills = players[i];
				}
			}

			if (isDefined(playerMaxKills) && playerMaxKills.pers["round_kills"] >= 4)
			{
				self iprintlnbold(playerMaxKills.name + "^7 with ^2" + playerMaxKills.pers["round_kills"] + "^7 kills in this round!");
			}

			round_kills_printed = true;
		}
	}
}


followPlayerByNum(num)
{
	if (num < 1 || num > 10) return;

	player = undefined;
	if (num >= 1 && num <= 5)
	{
		if ((num - 1) < level.streamerSystem_boxesLeft_players.size)
			player = level.streamerSystem_boxesLeft_players[num - 1];
	}

	if (num >= 6 && num <= 10)
	{
		if ((num - 6) < level.streamerSystem_boxesRight_players.size)
			player = level.streamerSystem_boxesRight_players[num - 6];
	}

	if (isDefined(player))
	{
		if (player.sessionstate == "playing")
		{
			level maps\mp\gametypes\_streamer::followPlayer(player);
			level maps\mp\gametypes\_streamer_auto::lockFor(30000); // Lock selected player for 30 secods
			//self iprintln("Follow player " + num/* + ": " + player.name*/);
		}
		else
			self iprintln("^3Player " + num + " is not alive");
	}
	else
		self iprintln("^3Player " + num + " does not exists");
}


getPlayersByTeam(teamname)
{
	playersFiltered = [];
	index = 0;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (!isDefined(teamname) || player.pers["team"] == teamname)
		{
			playersFiltered[index] = player;
			index++;
		}
	}

	// Sort and return
	return playersFiltered;
}


fill_box(index, barSide, teamname, player)
{
	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";

	health = "";
	// Because health is showed via menu elements, the health bar is splited only into a few sizes
	// So according to helth we select most corresponding size
	if (player.health <= 0)
		health =  "0";

	else if (player.health < 20)
		health =  "10";

	else if (player.health < 70)
		health =  "50";

	else if (player.health < 99)
		health =  "80";

	else
		health =  "100";

	// Health also contains apended info about color
	if (player.health > 0)
	{
	      	if (teamname == "allies")
			health = health + "_allies";
		else
			health = health + "_axis";
	}


	if (self.streamerSystem_turnedOn && isDefined(level.streamerSystem_player) && player == level.streamerSystem_player)
	{
		health = health + "_"; // underscore means this player is followed and rectangle around player box is showed
	}



	// anytime in future readyups show player statistics instead of weapon
	inStatsMode = level.in_readyup && game["readyup_first_run"] == false && level.gametype == "sd" && game["roundsplayed"] >= 1;



	// Weapon names
	weapon1 = player getweaponslotweapon("primary");
    	weapon2 = player getweaponslotweapon("primaryb");
	weapon1 = maps\mp\gametypes\_weapons::getWeaponName2(weapon1);
	weapon2 = maps\mp\gametypes\_weapons::getWeaponName2(weapon2);
	weapon_text = "";
	if (inStatsMode)
	{
		stats = player maps\mp\gametypes\_menu_scoreboard::getPlayerStats();
		if (isDefined(stats))
		{
			weapon_text = "Assists: " + stats["assists"] + "   Plants: " + stats["plants"] + "   Defuses: " + stats["defuses"];
		}
	}
	else if (player.health > 0)
	{
		if (weapon2 == "none" || weapon2 == "Pistol")
			weapon_text = weapon1;
		else
			weapon_text = weapon1 + " / " + weapon2;
	}




	/* Icons
	Combinations:
		"" 		- no icons
		"grenade" 	- show grenade icon
		"grenade2" 	- show multi-grenade icons
		"smoke" 	- show smoke icon
		"grenade_smoke" - show grenade and smoke icons
		"grenade2_smoke" - show multi-grenade and smoke icons
	*/
	icons = "";
	if (player.health > 0 && inStatsMode == false)
	{
		grenades = player maps\mp\gametypes\_weapons::getFragGrenadeCount();
		smokes = player maps\mp\gametypes\_weapons::getSmokeGrenadeCount();

		if (grenades >= 2)
			icons += "grenade2";
		else if (grenades == 1)
			icons += "grenade";

		if (smokes > 0)
		{
			if (icons != "")
				icons += "_";
			icons += "smoke";
		}
	}

	// Kills in round
	kills_added = "";
	if (isDefined(player.pers["round_kills"]) && player.pers["round_kills"] != 0 && inStatsMode == false)
	{
		if (player.pers["round_kills"] > 0) 	kills_added = "^2+" + player.pers["round_kills"] + "^7";
		else					kills_added = "^1" + player.pers["round_kills"] + "^7";
	}



	// Player name
	name = "";
	if (self.pers["streamerSystem_keysVisible"])
	{
		if (barSide == "left")	name += "" + (index + 1) + ":  ";
		else if (index == 4)	name += "0:  "; // 10
		else			name += "" + (index + 6) + ":  ";
	}
	if (level.in_readyup)
	{
		if (player.isReady) 	name += "^2o^7  ";
		else		 	name += "^1o^7  ";
	}
	name += removeColorsFromString(player.name);




	self setClientCvarIfChanged("ui_streamersystem_team"+teamNum+"_player"+index+"_health",		health);
	self setClientCvarIfChanged("ui_streamersystem_team"+teamNum+"_player"+index+"_name",		name);
	self setClientCvarIfChanged("ui_streamersystem_team"+teamNum+"_player"+index+"_score",		player.score + " / " + player.deaths);
	self setClientCvarIfChanged("ui_streamersystem_team"+teamNum+"_player"+index+"_weapon",		weapon_text);
	self setClientCvarIfChanged("ui_streamersystem_team"+teamNum+"_player"+index+"_round_kills",	kills_added);
	self setClientCvarIfChanged("ui_streamersystem_team"+teamNum+"_player"+index+"_icons",		icons);
}


unfill_box(index, barSide)
{
	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";

	// Text does not need to be updated, because is hided automatically if healht is empty
	//setClientCvarIfChanged("ui_streamersystem_team"+teamNum+"_player"+index+"_text", "");

	self setClientCvarIfChanged("ui_streamersystem_team"+teamNum+"_player"+index+"_health", "");
	self setClientCvarIfChanged("ui_streamersystem_team"+teamNum+"_player"+index+"_icons", "");
}
