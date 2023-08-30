#include maps\mp\gametypes\global\_global;

/*
This script will generate scoreboard with players stats

To make this possible, we will generate 26 lines and text will be colums where lines are separated by new line
*/

init()
{
	level.scoreboard_lines = 26;

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

	self.pers["scoreboard_lines_statIds"] = [];
	if (!isDefined(self.pers["scoreboard_keepRefreshing"]))
		self.pers["scoreboard_keepRefreshing"] = 0;

	// This will make sure menu is still responsible even if map is restarted (next round)
	if (self.pers["scoreboard_keepRefreshing"] > 0)
		self thread generatePlayerList();

	self thread UpdateStandartScoreboard();
}


UpdateStandartScoreboard()
{
	self endon("disconnect");

	wait level.fps_multiplier * 0.5;
	wait level.frame * (self getentitynumber());

	// This command update info inside standart scoreboard without showing it
	// Usefull when replaying demo since scoreboard is available only when was opened by player
	while (1)
	{
		self ShowScoreBoard();
		//self iprintln("updated");
		wait level.fps_multiplier * 1;
	}
}

// Called also from streamersystem after automatically joined streamer (intermission)
hide_scoreboard(distributed)
{
	self endon("disconnect");

	// Streamers have visible scoreboard from previous map (intermission scoreboard)
	self setClientCvarIfChanged("ui_scoreboard_names", "");
	self setClientCvarIfChanged("ui_scoreboard_scores", "");
	self setClientCvarIfChanged("ui_scoreboard_kills", "");
	self setClientCvarIfChanged("ui_scoreboard_assists", "");
	self setClientCvarIfChanged("ui_scoreboard_damages", "");
	self setClientCvarIfChanged("ui_scoreboard_deaths", "");
	self setClientCvarIfChanged("ui_scoreboard_grenades", "");
	self setClientCvarIfChanged("ui_scoreboard_plants", "");
	self setClientCvarIfChanged("ui_scoreboard_defuses", "");
	self setClientCvarIfChanged("ui_scoreboard_ping", "");
	self setClientCvarIfChanged("ui_scoreboard_visible", "0");

	if (isDefined(distributed) && distributed)
		wait level.fps_multiplier * 0.25;

	// Fill empty lines
	for(j = 1; j <= level.scoreboard_lines; j++)
	{
		// First line is always header and then empty space, skip
		if (j == 2 || j == 3) continue;

		self setClientCvarIfChanged("ui_scoreboard_line_" + j, "0");

		if (j == 14 && isDefined(distributed) && distributed)
			wait level.fps_multiplier * 0.25;
	}
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

		if (!isDefined(self.pers["scoreboard_lines_statIds"][line]))
			return true;

		statsId = self.pers["scoreboard_lines_statIds"][line];
		clickedPlayer = game["playerstats"][statsId]["player"];

		if (!isPlayer(clickedPlayer))
			return true;

		//self iprintln(clickedPlayer.name);

		if (!self canBeColorChanged(clickedPlayer))
			return true;

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
	self endon("disconnect");

	// Refresh changed color
	self thread generatePlayerList();

	i = 1;
	players = getentarray("player", "classname");
	for(p = 0; p < players.size; p++)
	{
		player = players[p];

		// Player may disconnect because of wait
		if (!isDefined(player)) continue;

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

sortByScore(stats)
{
	// Sort score from lowest to highest
	// Players with undefined stats will be lowest
	for(j = 1; j < stats.size; j++)
	{
		for (
			jj = j;
			jj >= 1 && (
				(stats[jj-1]["score"] > stats[jj]["score"]) ||
				(stats[jj-1]["score"] == stats[jj]["score"] && stats[jj-1]["kills"] > stats[jj]["kills"]) ||
				(stats[jj-1]["score"] == stats[jj]["score"] && stats[jj-1]["kills"] == stats[jj]["kills"] && stats[jj-1]["deaths"] < stats[jj]["deaths"])
			);
			jj--)
		{
			temp = stats[jj];
			stats[jj] = stats[jj-1];
			stats[jj-1] = temp;
		}
	}
	return stats;
}

getTeamPlayersArraySorted()
{
	teamplayers = [];
	teamplayers["allies"] = [];
	teamplayers["axis"] = [];
	teamplayers["spectator"] = [];
	teamplayers["none"] = [];

	// Loop statistics of players and save them into array according to team
	for(i = 0; i < game["playerstats"].size; i++)
	{
		stat = game["playerstats"][i];
		if (stat["deleted"] == false)
		{
			switch(stat["team"])
			{
				case "allies": case "axis": case "spectator": case "streamer": case "none":
				team = stat["team"];
				if (team == "streamer") team = "spectator";
				teamplayers[team][teamplayers[team].size] = stat;
			}
		}
	}

	// find stats for players and sort them by score
	teamplayers["allies"] = sortByScore(teamplayers["allies"]);
	teamplayers["axis"] = sortByScore(teamplayers["axis"]);
	teamplayers["spectator"] = sortByScore(teamplayers["spectator"]);
	teamplayers["none"] = sortByScore(teamplayers["none"]);

	return teamplayers;
}

getPlayerStats()
{
	// Loop statistics of players and save them into array according to team
	for(i = 0; i < game["playerstats"].size; i++)
	{
		stat = game["playerstats"][i];
		if (stat["deleted"] == false)
		{
			if (isDefined(stat["player"]) && stat["player"] == self)
			{
				return stat;
			}
		}
	}
	return undefined;
}

canBeColorChanged(player)
{
	// Enable color change only if we are not in first readyup, only for opponent team
	return !game["is_public_mode"] /*&& !game["readyup_first_run"]*/ && game["state"] != "intermission" &&
		isDefined(player) &&
		self.pers["team"] != player.pers["team"] &&
		(self.pers["team"] == "allies" || self.pers["team"] == "axis") &&
		(player.pers["team"] == "allies" || player.pers["team"] == "axis");
}


addLine(stats, name, score, kills, deaths, assists, damages, grenades, plants, defuses)
{
	// Lines limit reached
	if (self.scoreboard.i > level.scoreboard_lines)
		return;

	// If empty line (parameters of function are not set)
	if (!isDefined(stats))
	{
		self.pers["scoreboard_lines_statIds"][self.scoreboard.i] = undefined;
	}
	else
	{
		// Save id of current stat into array so when the player is clicked in menu we get the stat
		self.pers["scoreboard_lines_statIds"][self.scoreboard.i] = stats["id"];

		self.scoreboard.names +=	name;
		self.scoreboard.scores +=	score;
		self.scoreboard.kills +=	kills;
		self.scoreboard.deaths +=	deaths;
		self.scoreboard.assists +=	assists;
		self.scoreboard.damages +=	damages;
		self.scoreboard.grenades +=	grenades;
		self.scoreboard.plants +=	plants;
		self.scoreboard.defuses +=	defuses;
	}

	self.scoreboard.names +=	"\n^7";
	self.scoreboard.scores +=	"\n^7";
	self.scoreboard.kills +=	"\n^7";
	self.scoreboard.deaths +=	"\n^7";
	self.scoreboard.assists +=	"\n^7";
	self.scoreboard.damages +=	"\n^7";
	self.scoreboard.grenades +=	"\n^7";
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

addPlayerLine(team, stats)
{
	// 0=hide; 1=show line odd; 2=show line even; 3=show line hightlighted; "string"=show team name
	value = "";
	if (isPlayer(stats["player"]) && self == stats["player"])
		value = "3"; // highlight
	else if ((self.scoreboard.i % 2) == 0)
		value = "2";
	else
		value = "1";


	name = stats["name"];
	if (isPlayer(stats["player"]) && stats["isConnected"])
	{
		name = stats["player"].name;	// get actual player name with colors

		//added _ means that line can be clicked
		if (self canBeColorChanged(stats["player"]))
		{
			value = value + "_"; // player can be set
		}
	}
	else
	{
		value = value + "!"; // player is disconnected
	}


	self setClientCvarIfChanged("ui_scoreboard_line_"+self.scoreboard.i, value);


	// Final intermission scoreboard
	if (game["state"] == "intermission")
	{
		// use original player name with no changes
	}
	// Ingame menu scoreboard
	else
	{
		name = removeColorsFromString(name); // remove colors

		if (isPlayer(stats["player"]) && isDefined(stats["player"].pers["scoreboard_color"]) && self canBeColorChanged(stats["player"]))
		{
			if (stats["player"].pers["scoreboard_color"] == 1)
				name = "^1" + name; // red
			else if (stats["player"].pers["scoreboard_color"] == 2)
				name = "^4" + name; // blue
		}

		if (level.in_readyup && stats["isConnected"] && isPlayer(stats["player"]))
		{
			if (stats["player"].isReady) 	name = "^2o^7  " + name;
			else		 		name = "^1o^7  " + name;
		}
	}

	// PLayer is disconnected
	color = "";
	if (stats["isConnected"] == false)
	{
		name = "^9[-] ^7" + name;
		color = "^7";
	}





	if (team == "allies" || team == "axis")
	{
		// Add line with player stats
		score = "   -";
		assists = "-";
		damage = "   -";
		plants = "-";
		defuses = "-";
		grenades = "-";
		if (self.sessionteam == team || self.sessionteam == "spectator" || game["state"] == "intermission") // dont show enemy's info (it might say location of enemy)
		{
			score = format_fractional(stats["score"], 1, 1);
			assists = stats["assists"];

			damage = "";
			if (stats["damage"] >= 500) damage = "^3";  // yellow
			if (stats["damage"] >= 1000) damage = "^1"; // red
			damage += format_fractional(stats["damage"] / 100, 1, 1);

			plants = stats["plants"];
			defuses = stats["defuses"];
			grenades = stats["grenades"];
		}



		addLine(stats, name, color + score, color + stats["kills"], color + stats["deaths"], color + assists, color + damage, color + grenades, color + plants, color + defuses);

		// Debug
		//addLine(player.name, 48, 32, 18, 4, 3.7, 2, 0);
	}
	else
	{
		addLine(stats, name, "", "", "", "", "", "", "", "");
	}

}


generatePlayerList(toggle)
{
	self endon("disconnect");

	// Make sure onlny 1 thread is running
	self notify("scoreboard_lock");
	self endon("scoreboard_lock");

	if (!isDefined(toggle))
		toggle = false;

	waittillframeend;

	self setClientCvarIfChanged("ui_scoreboard_map", maps\mp\gametypes\_matchinfo::GetMapName(level.mapname));

	for (;;)
	{
		teamplayers = getTeamPlayersArraySorted();

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
		self.scoreboard.grenades = "";
		self.scoreboard.plants = "";
		self.scoreboard.defuses = "";

		self.pers["scoreboard_lines_statIds"] = [];


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
		self setClientCvarIfChanged("ui_scoreboard_grenades", self.scoreboard.grenades);
		self setClientCvarIfChanged("ui_scoreboard_plants", self.scoreboard.plants);
		self setClientCvarIfChanged("ui_scoreboard_defuses", self.scoreboard.defuses);
		self setClientCvarIfChanged("ui_scoreboard_ping", "");
		self setClientCvarIfChanged("ui_scoreboard_visible", "1");



		// Find top player
		topplayer = "";
		topplanter = "";
		topgrenader = "";
		if (game["state"] == "intermission")
		{
			if (teamplayers[team1].size > 0 && teamplayers[team2].size > 0)
			{
				// Get top player
				team1player = teamplayers[team1][ teamplayers[team1].size-1 ];
				team2player = teamplayers[team2][ teamplayers[team2].size-1 ];

				if (team1player["score"] >= team2player["score"])
				{
					topplayer = team1player["name"];
					if (isPlayer(team1player["player"]))
						topplayer = team1player["player"].name;	// get actual player name with colors
				}
				else
				{
					topplayer = team2player["name"];
					if (isPlayer(team2player["player"]))
						topplayer = team2player["player"].name;	// get actual player name with colors
				}

				// Find top planter and grenader in team 1
				team1PlantScore = 0;
				team1PlantPlayer = "";
				team1GrenadeScore = 0;
				team1GrenadePlayer = "";
				for(p = teamplayers[team1].size-1; p >= 0; p--)
				{
					stats = teamplayers[team1][p];
					name = stats["name"];
					if (isPlayer(stats["player"])) name = stats["player"].name;	// get actual player name with colors

					plantScore = stats["plants"] + stats["defuses"];
					if (plantScore > team1PlantScore)
					{
						team1PlantScore = plantScore;
						team1PlantPlayer = name;
					}
					if (stats["grenades"] > team1GrenadeScore)
					{
						team1GrenadeScore = stats["grenades"];
						team1GrenadePlayer = name;
					}
				}

				// Find top planter and grenader in team 2
				team2PlantScore = 0;
				team2PlantPlayer = "";
				team2GrenadeScore = 0;
				team2GrenadePlayer = "";
				for(p = teamplayers[team2].size-1; p >= 0; p--)
				{
					stats = teamplayers[team2][p];
					name = stats["name"];
					if (isPlayer(stats["player"])) name = stats["player"].name;	// get actual player name with colors

					plantScore = stats["plants"] + stats["defuses"];
					if (plantScore > team2PlantScore)
					{
						team2PlantScore = plantScore;
						team2PlantPlayer = name;
					}
					if (stats["grenades"] > team2GrenadeScore)
					{
						team2GrenadeScore = stats["grenades"];
						team2GrenadePlayer = name;
					}
				}

				if (team1PlantScore >= 4 || team2PlantScore >= 4)
				{
					if (team2PlantScore > team1PlantScore)	topplanter = team2PlantPlayer;
					else					topplanter = team1PlantPlayer;
				}

				if (team1GrenadeScore >= 4 || team2GrenadeScore >= 4)
				{
					if (team2GrenadeScore > team1GrenadeScore)	topgrenader = team2GrenadePlayer;
					else						topgrenader = team1GrenadePlayer;
				}
			}
		}


		toptext = "";
		if (topplayer != "")
			toptext = "^7Top player:        ^7" + topplayer + "\n^7";
		if (topplanter != "")
			toptext += "^7Bomb expert:      ^7" + topplanter + "\n^7";
		if (topgrenader != "")
			toptext += "^7Grenade expert:   ^7" + topgrenader;

		addEmptyLine();
		addEmptyLine();
		addTeamLine(toptext);


		// Fill empty lines
		for(; self.scoreboard.i <= level.scoreboard_lines; self.scoreboard.i++)
		{
			self setClientCvarIfChanged("ui_scoreboard_line_"+self.scoreboard.i, "0");
		}


		// Keep updating even in next round after map restart
		if (self.pers["scoreboard_keepRefreshing"] == 0)
		{
			self.pers["scoreboard_keepRefreshing"] = 1; // 1 = menu  2 = toggled
			if (toggle)
				self.pers["scoreboard_keepRefreshing"] = 2; // 1 = menu  2 = toggled
		}

		// Wait fot initial conditions
		while(self.pers["scoreboard_keepRefreshing"] == 1 && (self.isMoving || self attackbuttonpressed()))
			wait level.frame;

		i = 0;
		while(1)
		{
			wait level.frame;
			i++;

			// In intermission keep updating forever
			if (game["state"] == "intermission")
			{
				wait level.fps_multiplier * 1;
				break;
			}

			// Stop scoreboard when
			// - player is moving (so menu is closed)
			// - player left clicked
			// - scoreboard for streamer system is closed
			if (self.pers["scoreboard_keepRefreshing"] == 0 || (self.pers["scoreboard_keepRefreshing"] == 1 && (self.isMoving || self attackbuttonpressed())))
			{
				// Stop refreshing
				self.pers["scoreboard_keepRefreshing"] = 0;

				self thread hide_scoreboard();

				//self iprintln("^1CANCEL ^7updating scoreboard " + self.pers["scoreboard_keepRefreshing"] + " " + self.isMoving + " " + self attackbuttonpressed());

				return;
			}

			// 1 sec elapsed, keep updating
			if (i > level.sv_fps * 1)
				break;
		}

		//self iprintln("updating scoreboard...");
	}
}
