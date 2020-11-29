#include maps\mp\gametypes\_callbacksetup;
#include maps\mp\gametypes\_cvar_system;
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
	addEventListener("onConnected",     ::onConnected);

	// Save value of scr_matchinfo for entire map (if cvar scr_matchinfo is changed during match, it makes no effect until map change)
	if (!isDefined(game["matchinfo"]))
		game["matchinfo"] = level.scr_matchinfo;

	if (game["matchinfo"] == 0)
		return;

	// Matchinfo cannot working without readyup...
	if (!level.scr_readyup)
		return;


	if (game["matchinfo"] == 2)
	{
		addEventListener("onConnectedAll",  ::onConnectedAll);
	}

	if (!isDefined(game["match_teams_set"]))
	{
		game["match_teams_set"] = false;

		game["match_team1_name"] = "";
		game["match_team1_score"] = "";
		game["match_team1_side"] = "";
		game["match_team2_name"] = "";
		game["match_team2_score"] = "";
		game["match_team2_side"] = "";

		game["match_totaltime_text"] = "";
	}

	// Once match start, save teams
	if (!level.in_readyup)
		game["match_teams_set"] = true;


	addEventListener("onJoinedTeam",        ::onJoinedTeam);

	level thread refresh();
}


onConnected()
{
	self endon("disconnect");

	// Ingame match info bar
	if (!isDefined(self.pers["matchinfo_ingame"]))
	{
			self.pers["matchinfo_ingame"] = false;
			self.pers["matchinfo_ingame_visible"] = false;
			self.pers["matchinfo_showedForSpectator"] = false;

			// always hide ingame bar on first connect - if is enabled by settings, it will be showed later
			self setClientCvar("ui_matchinfo_ingame_show", "0");
	}


	if (game["matchinfo"] > 0)
	{
		self setClientCvar("ui_matchinfo_show", "1");

		if (!isDefined(self.pers["timeConnected"]))
		{
			self.pers["timeConnected"] = getTime();

			// Update all team name only once
			waittillframeend;
			maps\mp\gametypes\_teamname::refreshTeamNameForAll(); // will update level.teamname_all

			// Reset client cvars
			self UpdatePlayerCvars();
		}
	}
	else
	{
		wait level.fps_multiplier * 0.2;
		self setClientCvar("ui_matchinfo_show", "0");
	}

}

onConnectedAll()
{
	waittillframeend;

	updateTeamNamesForPlayers();

	//maps\mp\gametypes\_teamname::refreshTeamNameForAll(); // will update level.teamname_all
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
		if (game["matchinfo"] > 0)
		{
			self setClientCvar("ui_matchinfo_ingame_show", 1);
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
		self setClientCvar("ui_matchinfo_ingame_show", 0);
		if (game["matchinfo"] > 0)
			self thread UpdatePlayerCvars();
	}
}





updateTeamNamesForPlayers()
{
	// Generate team names according to player names
	maps\mp\gametypes\_teamname::refreshTeamName("allies"); // will update level.teamname_allies
	maps\mp\gametypes\_teamname::refreshTeamName("axis"); // will update level.teamname_axis

	alliesDef = "";
	switch(game["allies"])
	{
		case "american": alliesDef = "MPUI_AMERICAN"; break;
		case "british":  alliesDef = "MPUI_BRITISH"; break;
		case "russian":  alliesDef = "MPUI_RUSSIAN"; break;
	}
	axisDef = "MPUI_GERMAN";

	// for all players change team name in scoreboard
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (level.teamname_allies != "")
			player setClientCvarIfChanged("g_TeamName_Allies", level.teamname_allies);
		else
			player setClientCvarIfChanged("g_TeamName_Allies", alliesDef);

		if (level.teamname_axis != "")
			player setClientCvarIfChanged("g_TeamName_Axis", level.teamname_axis);
		else
			player setClientCvarIfChanged("g_TeamName_Axis", axisDef);
	}
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


determineTeamByHistoryCvars()
{
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


	// Handle empty teams
	if (teamname1 == "" && teamname2 == "")
	{
		teamname1 = level.teamname_all;
		teamname2 = "?";
	}
	else if (teamname1 == "")
		teamname1 = "?";
	else if (teamname2 == "")
		teamname2 = "?";


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

	game["match_starttime"] = undefined;
	game["match_timeprev"] = 0;

	resetTeamInfo();
}

resetTeamInfo()
{
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

waitForPlayerOrReset(playersLast)
{
	wait level.fps_multiplier * 30;

	for(;;)
	{
		// Exit loop if teams are set
		if (game["match_teams_set"])
			return;

		// reset matchinfo if 30% of players disconnect or there are no players or there was no players last map
		players = getentarray("player", "classname");
		if (((players.size * 1.0) < (playersLast * 0.7)) || ((players.size * 1.0) > (playersLast * 1.2)) || players.size == 0 || playersLast == 0)
		{
			iprintln("Info about teams was cleared.");
			resetAll();
			return;
		}

		wait level.fps_multiplier * 10;
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
	if (mapname == "" || mapname.size < 3)
		return mapname;

	if (ToLower(mapname[0]) == "m" && ToLower(mapname[1]) == "p" && ToLower(mapname[2]) == "_")
		mapname = ToUpper(mapname[3]) + getsubstr(mapname, 4, mapname.size);

	return mapname;
}


// May be called when
UpdatePlayerCvars()
{

	// Ingame match info bar
	if (game["matchinfo"] == 2)
	{
		// Set player's team always on left
		team_left  = "team1";
		team_right = "team2";
		if (isDefined(self.pers["team"]) && self.pers["team"] == game["match_team2_side"])
		{
				team_left  = "team2";
				team_right = "team1";
		}
		matchtimetext = "Match time";
		if (game["match_totaltime_text"] == "")
			matchtimetext = "";

		// Team names
		self setClientCvarIfChanged("ui_matchinfo_team1_name", game["match_"+team_left+"_name"]);
		self setClientCvarIfChanged("ui_matchinfo_team2_name", game["match_"+team_right+"_name"]);
		// scores
		self setClientCvarIfChanged("ui_matchinfo_team1_score", game["match_"+team_left+"_score"]);
		self setClientCvarIfChanged("ui_matchinfo_team2_score", game["match_"+team_right+"_score"]);
		// Round
		self setClientCvarIfChanged("ui_matchinfo_round", game["match_round"]);
		// Map history
		for (j = 1; j <= 2; j++)
		{
			self setClientCvarIfChanged("ui_matchinfo_map" + j + "_name", GetMapName(getCvar("sv_map" + j + "_name")));
			self setClientCvarIfChanged("ui_matchinfo_map" + j + "_score", getCvar("sv_map" + j + "_score"));

			//self setClientCvarIfChanged("ui_matchinfo_map" + j + "_name", "Toujane");
			//self setClientCvarIfChanged("ui_matchinfo_map" + j + "_score", "13:7");
		}
		// Play time
		self setClientCvarIfChanged("ui_matchinfo_matchtime_text", matchtimetext);
		self setClientCvarIfChanged("ui_matchinfo_matchtime_value", game["match_totaltime_text"]);


	}
	else if (game["matchinfo"] == 1)
	{
		// Set player's team always on left
		team_left  = "allies";
		team_right = "axis";
		team_left_name  = "Allies";
		team_right_name = "Axis";
		if (isDefined(self.pers["team"]))
		{
			if (self.pers["team"] == "axis")
			{
				team_left  = "axis";
				team_right = "allies";
			}
			if (self.pers["team"] == "allies" || self.pers["team"] == "axis")
			{
				team_left_name  = "My Team";
				team_right_name = "Enemy";
			}
		}
		matchtimetext = "Match time";
		if (game["match_totaltime_text"] == "")
			matchtimetext = "";

		// Team names
		self setClientCvarIfChanged("ui_matchinfo_team1_name", team_left_name);
		self setClientCvarIfChanged("ui_matchinfo_team2_name", team_right_name);
		// scores
		self setClientCvarIfChanged("ui_matchinfo_team1_score", game[team_left+"_score"]);
		self setClientCvarIfChanged("ui_matchinfo_team2_score", game[team_right+"_score"]);
		// Round
		self setClientCvarIfChanged("ui_matchinfo_round", game["match_round"]);

		// Map history
		for (j = 1; j <= 2; j++)
		{
			self setClientCvarIfChanged("ui_matchinfo_map" + j + "_name", GetMapName(getCvar("sv_map" + j + "_name")));
			self setClientCvarIfChanged("ui_matchinfo_map" + j + "_score", getCvar("sv_map" + j + "_score"));

			//self setClientCvarIfChanged("ui_matchinfo_map" + j + "_name", "Toujane");
			//self setClientCvarIfChanged("ui_matchinfo_map" + j + "_score", "13:7");
		}
		// Play time
		self setClientCvarIfChanged("ui_matchinfo_matchtime_text", matchtimetext);
		self setClientCvarIfChanged("ui_matchinfo_matchtime_value", game["match_totaltime_text"]);

	}
	else
	{
		// Team names
		self setClientCvarIfChanged("ui_matchinfo_team1_name", "");
		self setClientCvarIfChanged("ui_matchinfo_team2_name", "");
		// scores
		self setClientCvarIfChanged("ui_matchinfo_team1_score", "");
		self setClientCvarIfChanged("ui_matchinfo_team2_score", "");
		// Round
		self setClientCvarIfChanged("ui_matchinfo_round", "");
		// Map history
		for (j = 1; j <= 2; j++)
		{
			self setClientCvarIfChanged("ui_matchinfo_map" + j + "_name", "");
			self setClientCvarIfChanged("ui_matchinfo_map" + j + "_score", "");
		}
		// Play time
		self setClientCvarIfChanged("ui_matchinfo_matchtime_text", "");
		self setClientCvarIfChanged("ui_matchinfo_matchtime_value", "");
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
			level thread waitForPlayerOrReset(int(playersLast));
			setcvar("sv_map_players", "");
		}

		// Save previous time left
		if (getCvar("sv_map_totaltime") != "")
			game["match_timeprev"] = getCvarInt("sv_map_totaltime");
		else
			game["match_timeprev"] = 0;

		game["match_previous_map_processed"] = true;
	}

	wait level.frame * 2; // offset this thread from other threads

	for (;;)
	{
			wait level.fps_multiplier * 1;

			// Total time measuring
			if (game["match_timeprev"] == 0 && !game["match_teams_set"])
				game["match_totaltime"] = 0;
			else
			{
				if (!isDefined(game["match_starttime"]))
					game["match_starttime"] = getTime();

				game["match_totaltime"] = game["match_timeprev"] + (getTime() - game["match_starttime"]);
			}
			setCvar("sv_map_totaltime", game["match_totaltime"]);



			// Total time
			if (game["match_totaltime"] > 0)
			{
				secTotal = int(game["match_totaltime"] / 1000);
				min = int(secTotal / 60);
				sec = secTotal % 60;

				if (min < 10) min = "0" + min;
				if (sec < 10) sec = "0" + sec;

				game["match_totaltime_text"] = min + ":" + sec;
			}
			else
			{
				game["match_totaltime_text"] = "";
			}


			// Round
			if (!isDefined(game["match_round"]))
				game["match_round"] = "";
			if (level.in_readyup)
				game["match_round"] = "Ready-up";
			else if (level.in_bash)
				game["match_round"] = "Bash";
			else if (!level.roundended) // to avoid increasing rounds player
				game["match_round"] = "Round " + (game["roundsplayed"] + 1) + " / " + level.matchround;



			// Full team info
			if (game["matchinfo"] == 2)
			{
					// Keep updating data about team names, played maps,.. untill match start
					if (!game["match_teams_set"])
					{
						// Generate allies and axis team names
						updateTeamNamesForPlayers();

						// If there is defined map, load teams from cvars. Othervise load team by first connected player
						prevMap_map =   getCvar("sv_map1_name");
						if (prevMap_map != "")
							determineTeamByHistoryCvars();
						else
							determineTeamByFirstConnected();
					}

					// If game started and teams was not recognised, reset team info and do it it from scratch
					// This may happend if player in both teams gets renamed
					else
					{
						if (game["match_team1_side"] == "" || game["match_team2_side"] == "")
						{
							resetTeamInfo(); // reset map history

							determineTeamByFirstConnected();
						}
					}

					// Main score update
					if (game["match_team1_side"] == "") 	game["match_team1_score"] = "?";
					else 																	game["match_team1_score"] = game[game["match_team1_side"] + "_score"];
					if (game["match_team2_side"] == "") 	game["match_team2_score"] = "?";
					else 																	game["match_team2_score"] = game[game["match_team2_side"] + "_score"];
			}

			else if (game["matchinfo"] == 1) // basic info (no team names)
			{
				game["match_team1_name"] = "Allies";
				game["match_team2_name"] = "Axis";

				game["match_team1_side"] = "allies";
				game["match_team2_side"] = "axis";

				game["match_team1_score"] = game["allies_score"];
				game["match_team2_score"] = game["axis_score"];
			}


			// Save data from this map for next map
			if (game["match_teams_set"] || (game["matchinfo"] == 1 && (game["allies_score"] > 0 || game["axis_score"] > 0)))
			{
				setCvarIfChanged("sv_map_name", level.mapname);
				setCvarIfChanged("sv_map_team1", game["match_team1_name"]);
				setCvarIfChanged("sv_map_team2", game["match_team2_name"]);

				// Dont update score if we are in overtime
				if (!game["overtime_active"])
				{
					setCvarIfChanged("sv_map_score", game["match_team1_score"] + " : " + game["match_team2_score"]);
				}
				else
				{
					// TODO: set +1 score to winner of overtime
				}

				// Update number of player in this match
				// Update this value only if it increases - avoid decreasing it for case when players disconnect in the middle of the match
				// so next time map restart the info about match is properly reseted due to low number of players
				players = getentarray("player", "classname");
				if (players.size > GetCvarInt("sv_map_players"))
					setCvarIfChanged("sv_map_players", players.size);
			}

			// Global server cvars visible via HLSW
			if (game["match_team1_name"] != "") 	setCvarIfChanged("_match_team1", game["match_team1_name"]);
			else																	setCvarIfChanged("_match_team1", "-");
			if (game["match_team1_name"] != "") 	setCvarIfChanged("_match_team2", game["match_team2_name"]);
			else																	setCvarIfChanged("_match_team2", "-");

			if (getcvar("sv_map_score") != "") 		setCvarIfChanged("_match_score", getcvar("sv_map_score"));
			else																	setCvarIfChanged("_match_score", "-");

			if (game["match_round"] != "") 				setCvarIfChanged("_match_round", game["match_round"]);
			else																	setCvarIfChanged("_match_round", "-");


			thread UpdateCvarsForPlayers();

	} // end 1 sec loop


}
