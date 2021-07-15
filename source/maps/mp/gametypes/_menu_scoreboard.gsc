#include maps\mp\gametypes\global\_global;

/*
This script will generate scoreboard with players stats

To make this possible, we will generate 24 lines and text will be colums where lines are separated by new line
*/

init()
{
	addEventListener("onConnected",     ::onConnected);

	if (level.gametype != "sd")
		return;

	addEventListener("onMenuResponse",  ::onMenuResponse);
}

onConnected()
{
	if (level.gametype == "sd")
		self setClientCvar2("ui_scoreboard_show", "sd");
	else
		self setClientCvar2("ui_scoreboard_show", "");

	self.pers["scoreboard_lines_players"] = [];
}

/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu != "ingame")
		return;

	if (response == "scoreboard_refresh")
	{
		self thread generatePlayerList();
		return true;
	}

	if (startsWith(response, "scoreboard_setPlayer"))
	{
		substr = getSubstr(response, 20);

		if (!isDigitalNumber(substr))
			return true;

		line = int(substr);

		//self iprintln(line);

		if (!isDefined(self.pers["scoreboard_lines_players"][line]))
			return true;

		clickedPlayer = self.pers["scoreboard_lines_players"][line];

		if (!isPlayer(clickedPlayer))
			return true;

		//self iprintln(clickedPlayer.name);

		if (!self canBeColorChanged(clickedPlayer))
			return false;

		if (!isDefined(clickedPlayer.pers["scoreboard_color"]))
			clickedPlayer.pers["scoreboard_color"] = 1;
		else if (clickedPlayer.pers["scoreboard_color"] < 2)
			clickedPlayer.pers["scoreboard_color"]++;
		else
			clickedPlayer.pers["scoreboard_color"] = undefined;


		self thread updatePlayerLists();

		return true;
	}
}

updatePlayerLists()
{
	// Refresh changed color
	self thread generatePlayerList();

	i = 1;
	players = getentarray("player", "classname");
	for(p = 0; p < players.size; p++)
	{
		player = players[p];
		if (player.pers["team"] == self.pers["team"])
		{
			wait level.frame * i; // offset cvar sets

			if (!isDefined(player)) // in case player disconnects during wait
				continue;

			// Update enemy list for me and my players
			player thread maps\mp\gametypes\_players_left::updateEnemyList();

			i++;
		}
	}
}

sort(players)
{
	// Sort score from lowest to highest
	// Players with undefined stats will be lowest
	for(j = 1; j < players.size; j++)
	{
		for (
			jj = j;
			jj >= 1 && (
				!isDefined(players[jj].stats) || (isDefined(players[jj-1].stats) && isDefined(players[jj].stats) && (
					(players[jj-1].stats["score"] > players[jj].stats["score"]) ||
					(players[jj-1].stats["score"] == players[jj].stats["score"] && players[jj-1].stats["kills"] > players[jj].stats["kills"]) ||
					(players[jj-1].stats["score"] == players[jj].stats["score"] && players[jj-1].stats["kills"] == players[jj].stats["kills"] && players[jj-1].stats["deaths"] < players[jj].stats["deaths"])
				))
			);
			jj--)
		{
			temp = players[jj];
			players[jj] = players[jj-1];
			players[jj-1] = temp;
		}
	}
	return players;
}


sortPlayers(players)
{
	// Find stats
	for(p = 0; p < players.size; p++)
	{
		player = players[p];
		player.stats = player maps\mp\gametypes\_player_stat::getStats();
	}

	return sort(players);
}


sortTeamsByScore()
{
	teamplayers = [];
	teamplayers["allies"] = [];
	teamplayers["axis"] = [];
	teamplayers["spectator"] = [];
	teamplayers["none"] = [];

	players = getentarray("player", "classname");
	for(p = 0; p < players.size; p++)
	{
		player = players[p];
		switch(player.sessionteam)
		{
			case "allies": case "axis": case "spectator": case "none":
			teamplayers[player.sessionteam][teamplayers[player.sessionteam].size] = player;
		}
	}
	// find stats for players and sort them by score
	teamplayers["allies"] = sortPlayers(teamplayers["allies"]);
	teamplayers["axis"] = sortPlayers(teamplayers["axis"]);
	teamplayers["spectator"] = sortPlayers(teamplayers["spectator"]);
	teamplayers["none"] = sortPlayers(teamplayers["none"]);

	return teamplayers;
}

canBeColorChanged(player)
{
	// Enable color change only if we are not in first readyup, only for opponent team
	return !game["is_public_mode"] && !game["readyup_first_run"] && game["state"] != "intermission" &&
		self.pers["team"] != player.pers["team"] &&
		(self.pers["team"] == "allies" || self.pers["team"] == "axis") &&
		(player.pers["team"] == "allies" || player.pers["team"] == "axis");
}


addLine(player, name, score, kills, deaths, assists, damages, plants, defuses)
{
	if (isDefined(player))
		self.pers["scoreboard_lines_players"][self.scoreboard.i] = player;
	else
		self.pers["scoreboard_lines_players"][self.scoreboard.i] = undefined;

	if (isDefined(player) && isDefined(player.pers["scoreboard_color"]) && self canBeColorChanged(player))
	{
		if (player.pers["scoreboard_color"] == 1)
			self.scoreboard.names += "^1"; // red
		else if (player.pers["scoreboard_color"] == 2)
			self.scoreboard.names += "^4"; // blue
	}



	if (isDefined(name))
	{
		// In final scoreboard show name colors, otherwise dont
		if (game["state"] != "intermission")
			name = removeColorsFromString(name);
		self.scoreboard.names +=	name;
	}
	if (isDefined(score)) 	self.scoreboard.scores +=	score;
	if (isDefined(kills)) 	self.scoreboard.kills +=	kills;
	if (isDefined(deaths)) 	self.scoreboard.deaths +=	deaths;
	if (isDefined(assists)) self.scoreboard.assists +=	assists;
	if (isDefined(damages)) self.scoreboard.damages +=	damages;
	if (isDefined(plants)) 	self.scoreboard.plants +=	plants;
	if (isDefined(defuses)) self.scoreboard.defuses +=	defuses;

	self.scoreboard.names +=	"\n^7";
	self.scoreboard.scores +=	"\n^7";
	self.scoreboard.kills +=	"\n^7";
	self.scoreboard.deaths +=	"\n^7";
	self.scoreboard.assists +=	"\n^7";
	self.scoreboard.damages +=	"\n^7";
	self.scoreboard.plants +=	"\n^7";
	self.scoreboard.defuses +=	"\n^7";

	self.scoreboard.i++;
}

addEmptyLine()
{
	self setClientCvarIfChanged("ui_scoreboard_line_"+self.scoreboard.i, "0");
	addLine();
}

addTeamLine(teamname)
{
	// 0=hide; 1=show line odd; 2=show line even; 3=show line hightlighted; "string"=show team name
	self setClientCvarIfChanged("ui_scoreboard_line_"+self.scoreboard.i, teamname);
	addLine();

	// Space after heading (we must skip 2 lines)
	addEmptyLine();
	addEmptyLine();
}

addPlayerLine(team, player)
{
	// 0=hide; 1=show line odd; 2=show line even; 3=show line hightlighted; "string"=show team name
	value = "";
	if (self == player)
		value = "3"; // highlight
	else if ((self.scoreboard.i % 2) == 0)
		value = "2";
	else
		value = "1";

	//added _ means that line can be clicked
	if (self canBeColorChanged(player))
	{
		value = value + "_";
	}

	self setClientCvarIfChanged("ui_scoreboard_line_"+self.scoreboard.i, value);



	if (team == "allies" || team == "axis")
	{
		// Add line with player stats
		stats = player maps\mp\gametypes\_player_stat::getStats();
		if (isDefined(stats))
		{
			damage = int(stats["damage"] / 10) / 10;
			plants = "-";
			defuses = "-";
			if (self.sessionteam == team || self.sessionteam == "spectator" || game["state"] == "intermission") // dont show enemy's plants
			{
				plants = stats["plants"];
				defuses = stats["defuses"];
			}

			score = int(stats["score"] * 10) / 10;

			addLine(player, player.name, score, stats["kills"], stats["deaths"], stats["assists"], damage, plants, defuses);

			// Debug
			//addLine(player.name, 48, 32, 18, 4, 3.7, 2, 0);
		}
		else
		{
			addLine(player, player.name, player.score, "^1?", player.deaths, "^1?", "^1?", "^1?", "^1?");
		}
	}
	else
	{
		addLine(player, player.name, "", "", "", "", "", "", "");
	}

}


generatePlayerList()
{
	  self endon("disconnect");

		// Make sure onlny 1 thread is running
		self notify("matchinfo_lock");
		self endon("matchinfo_lock");


		self setClientCvarIfChanged("ui_scoreboard_map", maps\mp\gametypes\_matchinfo::GetMapName(level.mapname));


		for (;;)
		{
				teamplayers = sortTeamsByScore();

				/*
				type
				0 = nothink
				1 = player line
				2 = player line highlighted
				3 = team heading
				*/

				// Temp variables
				self.scoreboard = spawnstruct();
				self.scoreboard.i = 1;
				self.scoreboard.names = "";
				self.scoreboard.scores = "";
				self.scoreboard.kills = "";
				self.scoreboard.deaths = "";
				self.scoreboard.assists = "";
				self.scoreboard.damages = "";
				self.scoreboard.plants = "";
				self.scoreboard.defuses = "";

				self.pers["scoreboard_lines_players"] = [];


				teamname_allies = "";
				teamname_axis = "";
				if (game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2)
				{
					teamname_allies = game["match_team1_name"];
					teamname_axis = game["match_team2_name"];
					if (game["match_team1_side"] == "axis")
					{
						teamname_allies = game["match_team2_name"];
						teamname_axis = game["match_team1_name"];
					}
				}

				// Generate team names
				if (!isDefined(game["allies_score"]))
					teamname["allies"] = "^8Allies";
				else if (teamname_allies != "")
					teamname["allies"] = "^8" + teamname_allies+"  ("+game["allies_score"]+")";
				else
					teamname["allies"] = "^8Allies  ("+game["allies_score"]+")";

				if (!isDefined(game["axis_score"]))
					teamname["axis"] = "^9Axis";
				else if (teamname_axis != "")
					teamname["axis"] = "^9" + teamname_axis+"  ("+game["axis_score"]+")";
				else
					teamname["axis"] = "^9Axis  ("+game["axis_score"]+")";

				// Swap teams according to score
				team1 = "allies";
				team2 = "axis";
				if (game["axis_score"] > game["allies_score"])
				{
					team1 = "axis";
					team2 = "allies";
				}

				// Fill allies and axis team
				addTeamLine(teamname[team1]);
				for(p = teamplayers[team1].size-1; p >= 0; p--)
				{
					self addPlayerLine(team1, teamplayers[team1][p]);
				}
				addTeamLine(teamname[team2]);
				for(p = teamplayers[team2].size-1; p >= 0; p--)
				{
					self addPlayerLine(team2, teamplayers[team2][p]);
				}

				// Spectator
				if (teamplayers["spectator"].size > 0)
				{
					addTeamLine("Spectators");
					for(p = teamplayers["spectator"].size-1; p >= 0; p--)
					{
						self addPlayerLine("spectator", teamplayers["spectator"][p]);
					}
				}

				// None
				if (teamplayers["none"].size > 0)
				{
					addTeamLine("None team");
					for(p = teamplayers["none"].size-1; p >= 0; p--)
					{
						self addPlayerLine("none", teamplayers["none"][p]);
					}
				}

				// Text separed by new lines
				self setClientCvarIfChanged("ui_scoreboard_names", self.scoreboard.names);
				self setClientCvarIfChanged("ui_scoreboard_scores", self.scoreboard.scores);
				self setClientCvarIfChanged("ui_scoreboard_kills", self.scoreboard.kills);
				self setClientCvarIfChanged("ui_scoreboard_assists", self.scoreboard.assists);
				self setClientCvarIfChanged("ui_scoreboard_damages", self.scoreboard.damages);
				self setClientCvarIfChanged("ui_scoreboard_deaths", self.scoreboard.deaths);
				self setClientCvarIfChanged("ui_scoreboard_plants", self.scoreboard.plants);
				self setClientCvarIfChanged("ui_scoreboard_defuses", self.scoreboard.defuses);




				// Find top player
				topplayer = "";
				topplanter = "";
				if (!game["readyup_first_run"])
				{
					if (teamplayers[team1].size > 0 && teamplayers[team2].size > 0)
					{
							team1player = teamplayers[team1][ teamplayers[team1].size-1 ];
							team2player = teamplayers[team2][ teamplayers[team2].size-1 ];

							if (team1player.stats["score"] >= team2player.stats["score"])
								topplayer = team1player.name;
							else
								topplayer = team2player.name;

							// Find top planter team 1
							team1PlantScore = 0;
							team1PlantPlayer = "";
							for(p = teamplayers[team1].size-1; p >= 0; p--)
							{
								player = teamplayers[team1][p];

								if (isDefined(player.stats))
								{
									plantScore = player.stats["plants"] + player.stats["defuses"];

									if (plantScore > team1PlantScore)
									{
										team1PlantScore = plantScore;
										team1PlantPlayer = player.name;
									}
								}
							}

							// Find top planter team 2
							team2PlantScore = 0;
							team2PlantPlayer = "";
							for(p = teamplayers[team2].size-1; p >= 0; p--)
							{
								player = teamplayers[team2][p];

								if (isDefined(player.stats))
								{
									plantScore = player.stats["plants"] + player.stats["defuses"];

									if (plantScore > team2PlantScore)
									{
										team2PlantScore = plantScore;
										team2PlantPlayer = player.name;
									}
								}
							}

							if (team2PlantScore > team1PlantScore)
								topplanter = team2PlantPlayer;
							else
								topplanter = team1PlantPlayer;
					}
				}


				toptext = "";
				if (topplayer != "")
					toptext = "^9Top player:   ^7" + topplayer + "\n^7";
				if (topplanter != "")
					toptext += "^9Bomb expert:   ^7" + topplanter;


				addEmptyLine();
				addEmptyLine();
				addTeamLine(toptext);


				// Fill empty lines
				for(; self.scoreboard.i <= 24; self.scoreboard.i++)
				{
					self setClientCvarIfChanged("ui_scoreboard_line_"+self.scoreboard.i, "0");
				}


				// Keep updating untill we start moving in readyup
				if (self.isMoving || !level.in_readyup)
					break;
				else
					wait level.fps_multiplier * 1;

				//self iprintln("updating scoreboard...");
		}
}
