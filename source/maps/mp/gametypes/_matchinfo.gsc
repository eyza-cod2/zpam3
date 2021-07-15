#include maps\mp\gametypes\global\_global;
/*
First we need to determine wich team will be first
 - do this by saving information who connect to this server first - his team will be first
 - we will save time when player connect to the server

Procces is splited to 2 parts
 - 1. Readyup - in this period team names are not fixed and info may be refrshed according to connecting players
 - 2. Match start - in this part team names will be saved and will not refresh

Player names cannot be changed too much during match, othervise match info will reset

*/
Init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_matchinfo", "INT", 0, 0, 2);					// level.scr_matchinfo
	registerCvarEx("I", "scr_matchinfo_reset", "BOOL", 0);

	addEventListener("onConnected",     ::onConnected);

	// Save value of scr_matchinfo for entire map (if cvar scr_matchinfo is changed during match, it makes no effect until map change)
	if (!isDefined(game["scr_matchinfo"]))
		game["scr_matchinfo"] = level.scr_matchinfo;

	if (game["scr_matchinfo"] == 0)
		return;

	// Matchinfo cannot working without readyup...
	if (!level.scr_readyup)
		return;


	if (!isDefined(game["match_teams_set"]))
	{
		game["match_exists"] = false;
		game["match_teams_set"] = false;

		game["match_team1_name"] = "";
		game["match_team1_score"] = "";
		game["match_team1_side"] = "";
		game["match_team2_name"] = "";
		game["match_team2_score"] = "";
		game["match_team2_side"] = "";

		game["match_totaltime_text"] = "";

		game["match_round"] = "";
	}

	// Once match start, save teams
	if (!level.in_readyup)
	{
		game["match_exists"] = true;
		game["match_teams_set"] = true;
	}


	addEventListener("onJoinedTeam",        ::onJoinedTeam);

	level thread refresh();
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_matchinfo": level.scr_matchinfo = value; return true;
		case "scr_matchinfo_reset":
		{
			if (value == 1)
			{
				clear();
				iprintln("Info about teams was cleared via rcon.");

				changeCvarQuiet(cvar, 0);
			}

			return true;
		}

	}
	return false;
}


onConnected()
{
	self endon("disconnect");

	// Ingame match info bar
	if (!isDefined(self.pers["matchinfo_ingame"]))
	{
		// By default show match info ingame
		self.pers["matchinfo_ingame"] = false;
		self.pers["matchinfo_ingame_visible"] = false;
		self.pers["matchinfo_showedForSpectator"] = false;

		// always hide ingame bar on first connect - if is enabled by settings, it will be showed later
		self setClientCvarIfChanged("ui_matchinfo_ingame_show", "0");
		self setClientCvarIfChanged("ui_matchinfo_ingame_team1_sideColor", 	""); // bg elements cannot be dependend on _show cvar, needs to be set separately
		self setClientCvarIfChanged("ui_matchinfo_ingame_team2_sideColor", 	"");
	}


	if (game["scr_matchinfo"] > 0)
	{
		self setClientCvar2("ui_matchinfo_show", "1");

		if (!isDefined(self.pers["timeConnected"]))
		{
			self.pers["timeConnected"] = getTime();
		}

		if (game["scr_matchinfo"] == 2)
		{
			//waittillframeend;
			// Update team names in scoreboard
			self updateTeamNames();
		}
	}
	else
	{
		wait level.fps_multiplier * 0.2;
		self setClientCvar2("ui_matchinfo_show", "0");
	}

}

onJoinedTeam(teamName)
{
	// Always show for spectator, even if its not enabled in settings
	if (teamName == "spectator")
	{
		self ingame_show();
		self.pers["matchinfo_showedForSpectator"] = true;
	}
	else
	{
		if (self.pers["matchinfo_showedForSpectator"])
		{
			if (!ingame_isEnabled())
				ingame_hide();
			self.pers["matchinfo_showedForSpectator"] = false;
		}
	}
}





// Settings
ingame_isEnabled()
{
  return isDefined(self.pers["matchinfo_ingame"]) && self.pers["matchinfo_ingame"];
}

ingame_enable()
{
	self.pers["matchinfo_ingame"] = true;
	ingame_show();
}

ingame_disable()
{
	self.pers["matchinfo_ingame"] = false;
	ingame_hide();
}

ingame_toggle()
{
	// Toggle settings
	if (ingame_isEnabled() || self.pers["matchinfo_ingame_visible"]) // If is visible for spectator and "Hide in game" is clicked
		ingame_disable();
	else
		ingame_enable();
}

// Show match info ingame menu elements in hud menu
ingame_show()
{
	if (!self.pers["matchinfo_ingame_visible"])
	{
		self.pers["matchinfo_ingame_visible"] = true;
		if (game["scr_matchinfo"] > 0)
		{
			self setClientCvarIfChanged("ui_matchinfo_ingame_show", "1");
			self thread UpdatePlayerCvars();
		}
	}
}

// Hide match info ingame menu elements in hud menu
ingame_hide()
{
	if (self.pers["matchinfo_ingame_visible"])
	{
		self.pers["matchinfo_ingame_visible"] = false;
		self setClientCvarIfChanged("ui_matchinfo_ingame_show", "0");
		self setClientCvarIfChanged("ui_matchinfo_ingame_team1_sideColor", 	""); // bg elements cannot be dependend on _show cvar, needs to be set separately
		self setClientCvarIfChanged("ui_matchinfo_ingame_team2_sideColor", 	"");
		if (game["scr_matchinfo"] > 0)
			self thread UpdatePlayerCvars();
	}
}



updateTeamNames()
{
	//println("##updateTeamNames:"+game["match_team1_name"]);

	teamname_allies = game["match_team1_name"];
	teamname_axis = game["match_team2_name"];
	if (game["match_team1_side"] == "axis")
	{
		teamname_allies = game["match_team2_name"];
		teamname_axis = game["match_team1_name"];
	}


	if (teamname_allies != "")
		self setClientCvar2("g_TeamName_Allies", teamname_allies);
	else
	{
		alliesDef = "";
		switch(game["allies"])
		{
			case "american": alliesDef = "MPUI_AMERICAN"; break;
			case "british":  alliesDef = "MPUI_BRITISH"; break;
			case "russian":  alliesDef = "MPUI_RUSSIAN"; break;
		}
		self setClientCvar2("g_TeamName_Allies", alliesDef);
	}

	if (teamname_axis != "")
		self setClientCvar2("g_TeamName_Axis", teamname_axis);
	else
		self setClientCvar2("g_TeamName_Axis", "MPUI_GERMAN");

}



processPreviousMapToHistory()
{
	prevMap_map = getCvar("sv_map_name");

	// If prev map is defined, it means match started and this score needs to be saved
	if (prevMap_map != "")
	{
		// Move 1. saved map to 2. (removing the second)
		setCvar("sv_map2_name", 	getCvar("sv_map1_name"));
		setCvar("sv_map2_team1", 	getCvar("sv_map1_team1"));
		setCvar("sv_map2_team2", 	getCvar("sv_map1_team2"));
		setCvar("sv_map2_score", 	getCvar("sv_map1_score"));

		// Save previous map to history at first location
		setCvar("sv_map1_name", prevMap_map);
		setCvar("sv_map1_team1", getCvar("sv_map_team1"));
		setCvar("sv_map1_team2", getCvar("sv_map_team2"));
		setCvar("sv_map1_score", getCvar("sv_map_score"));

		// remove prev map info
		setCvar("sv_map_name", "");
		setCvar("sv_map_team1", "");
		setCvar("sv_map_team2", "");
		setCvar("sv_map_score", "");
	}
}


refreshTeamNames()
{
	// Generate allies and axis team names
	// Generate team names according to player names
	wait level.fps_multiplier * 0.1;
	maps\mp\gametypes\_teamname::refreshTeamName("allies"); // will update level.teamname_allies
	wait level.fps_multiplier * 0.1;
	maps\mp\gametypes\_teamname::refreshTeamName("axis"); // will update level.teamname_axis
	wait level.frame;
}


determineTeamByHistoryCvars()
{
	refreshTeamNames();

	// Fill team names
	game["match_team1_name"] = getCvar("sv_map1_team1");
	game["match_team2_name"] = getCvar("sv_map1_team2");

	// Find that side that team is now
	// Atleast one team must stay unrenamed or this will not work
	if (game["match_team1_name"] == level.teamname_allies || game["match_team2_name"] == level.teamname_axis)
	{
		game["match_team1_side"] = "allies";
		game["match_team2_side"] = "axis";
	}
	else if (game["match_team2_name"] == level.teamname_allies || game["match_team1_name"] == level.teamname_axis)
	{
		game["match_team1_side"] = "axis";
		game["match_team2_side"] = "allies";
	}
	else
	{
		game["match_team1_side"] = "";
		game["match_team2_side"] = "";
	}
}

determineTeamByFirstConnected()
{
	refreshTeamNames();

	// Find first team by looking wich player connect
	players = getentarray("player", "classname");
	firstPlayer = undefined;
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (isDefined(player.pers["team"]) && (player.pers["team"] == "allies" || player.pers["team"] == "axis") &&
			(!isDefined(firstPlayer) || player.pers["timeConnected"] < firstPlayer.pers["timeConnected"]))
			firstPlayer = player;
	}

	// Fill team 1
	teamname1 = "";
	team1 = "allies";
	if (isDefined(firstPlayer))
	{
		teamname1 = level.teamname[firstPlayer.pers["team"]];
		team1 = firstPlayer.pers["team"];
	}
	// Fill team 2
	team2 = "axis";
	if (team1 == "axis")
		team2 = "allies";
	teamname2 = level.teamname[team2];


	game["match_team1_name"] = teamname1;
	game["match_team1_side"] = team1;
	game["match_team2_name"] = teamname2;
	game["match_team2_side"] = team2;
}

resetAll()
{
	setCvar("sv_map_name", "");
	setCvar("sv_map_team1", "");
	setCvar("sv_map_team2", "");
	setCvar("sv_map_score", "");

	setCvar("sv_map_totaltime", "");
	setCvar("sv_map_players", "");

	game["match_exists"] = false;
	game["match_starttime"] = undefined;
	game["match_totaltime_prev"] = 0;

	// Reset cvars
	for (i = 1; i <= 2; i++)
	{
		setCvar("sv_map" + i + "_name", 	"");
		setCvar("sv_map" + i + "_team1", 	"");
		setCvar("sv_map" + i + "_team2", 	"");
		setCvar("sv_map" + i + "_score", 	"");
	}

	game["match_team1_name"] = "";
	game["match_team1_score"] = "";
	game["match_team2_name"] = "";
	game["match_team2_score"] = "";

	// Generate team names again
	determineTeamByFirstConnected();
}

waitForPlayerOrClear(playersLast)
{
	wait level.fps_multiplier * 15;

	resetCount = 0;

	for(;;)
	{
		// Exit loop if teams are set
		if (game["match_teams_set"])
			return;

		// reset matchinfo if 30% of players disconnect or there are no players or there was no players last map
		players = getentarray("player", "classname");
		if (((players.size * 1.0) < (playersLast * 0.7)) || ((players.size * 1.0) > (playersLast * 1.2)) || players.size <= 1 || playersLast <= 1)
			resetCount++;
		else
			resetCount = 0;

		// We are sure to reset the match info
		if (resetCount >= 4)
		{
			clear();
			iprintln("Info about teams was cleared.");
			return;
		}

		wait level.fps_multiplier * 5;
	}
}

clear()
{
	resetAll();

	if (level.in_readyup)
	{
		// Stop demo recording if enabled
		maps\mp\gametypes\_record::stopRecordingForAll();

		//Reset Remaing Time in readyup to Clock
		maps\mp\gametypes\_readyup::HUD_ReadyUp_ResumingIn_Delete();
	}
}


// Well, COD2 dont have this function, so create it manually
ToUpper(char)
{
	switch (char)
	{
		case "a": char = "A"; break;
		case "b": char = "B"; break;
		case "c": char = "C"; break;
		case "d": char = "D"; break;
		case "e": char = "E"; break;
		case "f": char = "F"; break;
		case "g": char = "G"; break;
		case "h": char = "H"; break;
		case "i": char = "I"; break;
		case "j": char = "J"; break;
		case "k": char = "K"; break;
		case "l": char = "L"; break;
		case "m": char = "M"; break;
		case "n": char = "N"; break;
		case "o": char = "O"; break;
		case "p": char = "P"; break;
		case "q": char = "Q"; break;
		case "r": char = "R"; break;
		case "s": char = "S"; break;
		case "t": char = "T"; break;
		case "u": char = "U"; break;
		case "v": char = "V"; break;
		case "w": char = "W"; break;
		case "x": char = "X"; break;
		case "y": char = "Y"; break;
		case "z": char = "Z"; break;
	}
	return char;
}

GetMapName(mapname)
{
	if (mapname == "mp_toujane" || mapname == "mp_toujane_fix_v2")		return "Toujane";
	if (mapname == "mp_burgundy" || mapname == "mp_burgundy_fix_v1")		return "Burgundy";
	if (mapname == "mp_dawnville" || mapname == "mp_dawnville_fix")		return "Dawnville";
	if (mapname == "mp_matmata" || mapname == "mp_matmata_fix")		return "Matmata";
	if (mapname == "mp_carentan" || mapname == "mp_carentan_fix")		return "Carentan";

	if (mapname == "" || mapname.size < 3)
		return mapname;

	if (ToLower(mapname[0]) == "m" && ToLower(mapname[1]) == "p" && ToLower(mapname[2]) == "_")
		mapname = ToUpper(mapname[3]) + getsubstr(mapname, 4, mapname.size);

	return mapname;
}


// May be called when
UpdatePlayerCvars()
{


	if (game["scr_matchinfo"] > 0)
	{
		side_left  = "";
		side_right = "";

		ui_name_left = "";
		ui_name_right = "";

		// Match info with team names
		if (game["scr_matchinfo"] == 2)
		{
			// Set player's team always on left
			team_left  = "team1";
			team_right = "team2";
			if (isDefined(self.pers["team"]) && self.pers["team"] == game["match_team2_side"])
			{
					team_left  = "team2";
					team_right = "team1";
			}
			side_left = game["match_"+team_left+"_side"];
			side_right = game["match_"+team_right+"_side"];

			name_left = game["match_"+team_left+"_name"];
			name_right = game["match_"+team_right+"_name"];
			// Handle empty teams
			if (name_left == "")  name_left = "?";
			if (name_right == "") name_right = "?";

			ui_name_left = game["match_"+team_left+"_score"] + "    " + name_left;
			ui_name_right = game["match_"+team_right+"_score"] + "    " + name_right;
		}

		// Match info with default allies axis
		else if (game["scr_matchinfo"] == 1)
		{
			// Set player's team always on left
			side_left  = "allies";
			side_right = "axis";
			name_left  = "Allies";
			name_right = "Axis";
			if (isDefined(self.pers["team"]))
			{
				if (self.pers["team"] == "axis")
				{
					side_left  = "axis";
					side_right = "allies";
				}
				if (self.pers["team"] == "allies" || self.pers["team"] == "axis")
				{
					name_left  = "My Team";
					name_right = "Enemy";
				}
			}

			ui_name_left = game[side_left+"_score"] + "    " + name_left;
			ui_name_right = game[side_right+"_score"] + "    " + name_right;
		}


		side_left_color = "0";
		side_right_color = "0";
		if (side_left == "allies")
		{
			if(game["allies"] == "american")
				side_left_color = "2"; // green
			else if(game["allies"] == "british")
				side_left_color = "3"; // blue
			else if(game["allies"] == "russian")
				side_left_color = "1"; // red

			side_right_color = "4"; // gray
		}
		else
		{
			if(game["allies"] == "american")
				side_right_color = "2"; // green
			else if(game["allies"] == "british")
				side_right_color = "3"; // blue
			else if(game["allies"] == "russian")
				side_right_color = "1"; // red

			side_left_color = "4"; // gray
		}

		// Background color according to team
		self setClientCvarIfChanged("ui_matchinfo_team1_sideColor", 	side_left_color);
		self setClientCvarIfChanged("ui_matchinfo_team2_sideColor", 	side_right_color);

		if (self.pers["matchinfo_ingame_visible"])
		{
			self setClientCvarIfChanged("ui_matchinfo_ingame_team1_sideColor", 	side_left_color);
			self setClientCvarIfChanged("ui_matchinfo_ingame_team2_sideColor", 	side_right_color);
		}

		// Team names
		self setClientCvarIfChanged("ui_matchinfo_team1_name", ui_name_left);
		self setClientCvarIfChanged("ui_matchinfo_team2_name", ui_name_right);





		matchtimetext = "";
		halfInfo = "";
		if (game["match_totaltime_text"] != "")
		{
			matchtimetext = "Match time:   " + game["match_totaltime_text"];

			if (!game["readyup_first_run"] && !level.in_bash)
			{
				if (!game["is_halftime"])
					halfInfo = "Rounds to half:   " + (level.halfround-game["round"]);
				else
					halfInfo = "First half score:   " + game["half_1_"+side_right+"_score"] + " : " + game["half_1_"+side_left+"_score"];
			}
		}

		// Round
		self setClientCvarIfChanged("ui_matchinfo_round", game["match_round"]);
		// Half
		self setClientCvarIfChanged("ui_matchinfo_halfInfo", halfInfo);
		// Play time
		self setClientCvarIfChanged("ui_matchinfo_matchtime", matchtimetext);

		// Map history
		for (j = 1; j <= 2; j++)
		{
			self setClientCvarIfChanged("ui_matchinfo_map" + j, GetMapName(getCvar("sv_map" + j + "_name")) + "  " + getCvar("sv_map" + j + "_score"));

			//self setClientCvarIfChanged("ui_matchinfo_map" + j, "Toujane  13:7");
		}
	}
	else
	{
		// Team names
		self setClientCvarIfChanged("ui_matchinfo_team1_name", "");
		self setClientCvarIfChanged("ui_matchinfo_team2_name", "");

		self setClientCvarIfChanged("ui_matchinfo_team1_sideColor", "");
		self setClientCvarIfChanged("ui_matchinfo_team2_sideColor", "");
		self setClientCvarIfChanged("ui_matchinfo_ingame_team1_sideColor", "");
		self setClientCvarIfChanged("ui_matchinfo_ingame_team2_sideColor", "");

		// Round
		self setClientCvarIfChanged("ui_matchinfo_round", "");
		// Half
		self setClientCvarIfChanged("ui_matchinfo_halfInfo", "");
		// Map history
		for (j = 1; j <= 2; j++)
		{
			self setClientCvarIfChanged("ui_matchinfo_map" + j, "");
		}
		// Play time
		self setClientCvarIfChanged("ui_matchinfo_matchtime", "");
	}
}


UpdateCvarsForPlayers()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		wait level.frame;	// spread commands send to player to multiple frames
		player = players[i];
		if (!isDefined(player)) // Because we wait a frame, next frame player may be disconnected
			continue;

		player UpdatePlayerCvars();
	}
}



refresh()
{
	// Save previous map score to map history
	if (!isDefined(game["match_previous_map_processed"]))
	{
		// Process cvars from previous map - load it into history cvars
		processPreviousMapToHistory();

		// Run timer - untill 1min the same number of player must connect
		// Othervise considere this as team left and we need to reset match info
		playersLast = getCvar("sv_map_players");
		if (playersLast != "")
		{
			level thread waitForPlayerOrClear(int(playersLast));
			//setcvar("sv_map_players", "");
		}

		// Save previous time left
		if (getCvar("sv_map_totaltime") != "")
		{
			game["match_totaltime_prev"] = getCvarInt("sv_map_totaltime");

			// Via this cvar we determinate if match is set from previous map
			game["match_exists"] = true;
		}
		else
			game["match_totaltime_prev"] = 0;

		game["match_previous_map_processed"] = true;
	}


	// On first run, offset thread from ther thread and this also make sure game["allies_score"] is defined
	wait level.frame * 8; // offset thread from other threads


	for (;;)
	{
		/***********************************************************************************************************************************
		*** Determinate team names, side, score
		/***********************************************************************************************************************************/
		// Full team info
		if (game["scr_matchinfo"] == 2)
		{
			// Keep updating data about team names, played maps,.. untill match start
			// Called in every first readyup on every map
			if (!game["match_teams_set"])
			{
				// If match exists, load teams from cvars. Othervise load team by first connected player
				if (game["match_exists"])
					determineTeamByHistoryCvars();
				else
					determineTeamByFirstConnected();

				// for all players change team name in scoreboard
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					players[i] updateTeamNames();
				}
			}

			// If game started and teams was not recognised, reset team info and do it it from scratch
			// This may happend if player in both teams gets renamed
			else
			{
				if (game["match_team1_side"] == "" || game["match_team2_side"] == "")
				{
					resetAll(); // reset map history and select team again
				}
			}

			// Main score update
			if (game["match_team1_side"] == "") 	game["match_team1_score"] = "?";
			else 					game["match_team1_score"] = game[game["match_team1_side"] + "_score"];
			if (game["match_team2_side"] == "") 	game["match_team2_score"] = "?";
			else 					game["match_team2_score"] = game[game["match_team2_side"] + "_score"];
		}

		else if (game["scr_matchinfo"] == 1) // basic info (no team names)
		{
			game["match_team1_name"] = "Allies";
			game["match_team2_name"] = "Axis";

			game["match_team1_side"] = "allies";
			game["match_team2_side"] = "axis";

			game["match_team1_score"] = game["allies_score"];
			game["match_team2_score"] = game["axis_score"];
		}



		/***********************************************************************************************************************************
		*** Determinate match time, status, ...
		/***********************************************************************************************************************************/

		// Total time measuring
		if (game["match_totaltime_prev"] == 0 && !game["match_teams_set"])
			game["match_totaltime"] = 0;
		else
		{
			if (!isDefined(game["match_starttime"]))
				game["match_starttime"] = getTime();

			game["match_totaltime"] = game["match_totaltime_prev"] + (getTime() - game["match_starttime"]);
		}

		if (game["match_exists"])
			setCvarIfChanged("sv_map_totaltime", game["match_totaltime"]);


		// Update number of players in first round (and second update only of its higher due to missing player in first round)
		// If number of players change, matchinfo is reseted next map due to different number of players
		if (game["match_teams_set"])
		{
			savedPlayers = GetCvarInt("sv_map_players"); // GetCvarInt return 0 if cvar is empty string
			players = getentarray("player", "classname");

			if (savedPlayers == 0 || (game["round"] == 2 && players.size > savedPlayers))
				setCvarIfChanged("sv_map_players", players.size);
		}


		// Total time
		if (game["match_totaltime"] > 0)
		{
			game["match_totaltime_text"] = formatTime(int(game["match_totaltime"] / 1000));
		}
		else
		{
			game["match_totaltime_text"] = "";
		}


		// Round
		if (level.in_timeout)
			game["match_round"] = "Timeout";
		else if (level.in_readyup)
			game["match_round"] = "Ready-up";
		else if (level.in_bash)
			game["match_round"] = "Bash";
		else
		{
			game["match_round"] = "Round " + game["round"];

			if (level.matchround > 0)
				game["match_round"] += " / " + level.matchround;
		}

		if (game["overtime_active"])
			game["match_round"] += " (OT)"; // overtime



		/***********************************************************************************************************************************
		*** Update history cvars to be able load info in next map
		/***********************************************************************************************************************************/

		// Save data from this map for next map
		if ((game["match_teams_set"] || game["scr_matchinfo"] == 1) && (game["round"] >= 3)) // save map into hostory in 3. round
		{
			setCvarIfChanged("sv_map_name", level.mapname);
			setCvarIfChanged("sv_map_team1", game["match_team1_name"]);
			setCvarIfChanged("sv_map_team2", game["match_team2_name"]);

			// Dont update score if we are in overtime
			if (!game["overtime_active"])
			{
				setCvarIfChanged("sv_map_score", game["match_team1_score"] + " : " + game["match_team2_score"]);

				game["match_team1_score_beforeOvertime"] = game["match_team1_score"];
				game["match_team2_score_beforeOvertime"] = game["match_team2_score"];
			}
			else
			{
				team1add = int(game["match_team1_score"] > game["match_team2_score"]);
				team2add = int(game["match_team1_score"] < game["match_team2_score"]);

				setCvarIfChanged("sv_map_score", (game["match_team1_score_beforeOvertime"] + team1add) + " : " + (game["match_team2_score_beforeOvertime"] + team2add) + "  OT");
			}
		}

		// Global server cvars visible via HLSW
		if (game["match_team1_name"] != "") 	setCvarIfChanged("_match_team1", game["match_team1_name"]);
		else					setCvarIfChanged("_match_team1", "-");
		if (game["match_team2_name"] != "") 	setCvarIfChanged("_match_team2", game["match_team2_name"]);
		else					setCvarIfChanged("_match_team2", "-");

		if (getcvar("sv_map_score") != "") 	setCvarIfChanged("_match_score", getcvar("sv_map_score"));
		else					setCvarIfChanged("_match_score", "-");

		if (game["match_round"] != "") 		setCvarIfChanged("_match_round", game["match_round"]);
		else					setCvarIfChanged("_match_round", "-");


		thread UpdateCvarsForPlayers();



		wait level.fps_multiplier * 1;
	}


}
