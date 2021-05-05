#include maps\mp\gametypes\global\_global;

init()
{
	level.spectatingSystem = false;

	addEventListener("onConnected",  ::onConnected);

	if (game["is_public_mode"])
		return;
	if (level.gametype != "sd")
		return;

	level.spectatingSystem = true;

	addEventListener("onSpawnedSpectator",  ::onSpawnedSpectator);
}

onConnected()
{
	// Hide all HUD from previous map
	if (!level.spectatingSystem || level.in_readyup || self.pers["team"] != "spectator")
		HUD_hideUI();
}

onSpawnedSpectator()
{
	if (self.pers["team"] == "spectator" && !level.in_readyup)
	{
		// Create and update boxes with players name
		self thread filling_boxes();
	}
}





HUD_hideUI()
{

	setClientCvarIfChanged("ui_spectatingsystem_team1_sideColor", 	"");
	setClientCvarIfChanged("ui_spectatingsystem_team1_name", 	"");
	setClientCvarIfChanged("ui_spectatingsystem_team1_scoreProgress", "");

	setClientCvarIfChanged("ui_spectatingsystem_team2_sideColor", 	"");
	setClientCvarIfChanged("ui_spectatingsystem_team2_name", 	"");
	setClientCvarIfChanged("ui_spectatingsystem_team2_scoreProgress", "");

	setClientCvarIfChanged("ui_spectatingsystem_playerProgress", "");

	for (i = 0; i < 5; i++)
	{
		setClientCvarIfChanged("ui_spectatingsystem_team1_player"+i+"_health", "");
		setClientCvarIfChanged("ui_spectatingsystem_team1_player"+i+"_text", "");
		setClientCvarIfChanged("ui_spectatingsystem_team2_player"+i+"_health", "");
		setClientCvarIfChanged("ui_spectatingsystem_team2_player"+i+"_text", "");
	}

}


filling_boxes()
{
	self endon("disconnect");

	wait level.frame;

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


	for(;;)
	{
		wait level.fps_multiplier * 0.1;

		if (self.pers["team"] == "spectator" && !level.in_readyup) // readyup in case timeout is called
		{
			if (isDefined(self.killcam))
			{
				HUD_hideUI();
				continue;
			}


			scoreProgress = "";
			if (isDefined(game["allies_score_history"]) && isDefined(game["axis_score_history"]) && game["allies_score_history"] != "" && game["axis_score_history"] != "")
			{
				scoreProgress = "Team 1: ";
				if (teamLeft == "axis") scoreProgress += game["axis_score_history"];
				else scoreProgress += game["allies_score_history"];
			}
			setClientCvarIfChanged("ui_spectatingsystem_team1_scoreProgress", scoreProgress);

			scoreProgress = "";
			if (isDefined(game["allies_score_history"]) && isDefined(game["axis_score_history"]) && game["allies_score_history"] != "" && game["axis_score_history"] != "")
			{
				scoreProgress = "Team 2: ";
				if (teamRight == "axis") scoreProgress += game["axis_score_history"];
				else scoreProgress += game["allies_score_history"];
			}

			setClientCvarIfChanged("ui_spectatingsystem_team2_scoreProgress", scoreProgress);




			playerProgress = "";
			if (isDefined(level.player_alive_history) && level.player_alive_history != "")
				playerProgress = "Players:" + level.player_alive_history;

			setClientCvarIfChanged("ui_spectatingsystem_playerProgress", playerProgress);





			playersLeft = getPlayersSortedByScore(teamLeft);
			playersRight = getPlayersSortedByScore(teamRight);

			// Fill bars
			for(r = 0; r < 5; r++)
			{
				if (r < playersLeft.size)
					self fill_box(r, "left", teamLeft, playersLeft[r]);
				else
					self unfill_box(r, "left");

				if (r < playersRight.size)
					self fill_box(r, "right", teamRight, playersRight[r]);
				else
					self unfill_box(r, "right");
			}

		}
		else
		{
			// Player left spectators
			// Hide hud elements
			HUD_hideUI();
			return;
		}
	}
}

getPlayersSortedByScore(teamname)
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

	sorted = sort(playersFiltered);

	// Sort and return
	return sorted;
}

sort(players)
{
	// Sort score from highest to Vlowest
	for(j = 1; j < players.size; j++)
	{
		for (
			jj = j;
			jj >= 1 && (
				(players[jj-1].score < players[jj].score) ||
				(players[jj-1].score == players[jj].score && players[jj-1].deaths > players[jj].deaths)
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



fill_box(index, barSide, teamname, player)
{
	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";

	value = "";
	// Because health is showed via menu elements, the health bar is splited only into a few sizes
	// So according to helth we select most corresponding size
	if (player.health <= 0)
		value =  "0";

	else if (player.health < 20)
		value =  "10";

	else if (player.health < 70)
		value =  "50";

	else if (player.health < 99)
		value =  "80";

	else
		value =  "100";


	if (player.health > 0)
	{
	      	if (teamname == "allies")
		{
			if(game["allies"] == "american")
				value = value + "_green";
			else if(game["allies"] == "british")
				value = value + "_blue";
			else if(game["allies"] == "russian")
				value = value + "_red";
		}
		else
			value = value + "_gray";
	}


	if (self.pers["autoSpectating"] && player getEntityNumber() == self.pers["autoSpectatingID"])
	{
		value = value + "_"; // underscore means this player is followed and rectangle next player box is showed
	}

	setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_health", value);



	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";
	setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_text", player.score + " / " + player.deaths + "    " + player.name);
}


unfill_box(index, barSide)
{
	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";

	// Text does not need to be updated, because is hided automatically if healht is empty
	//setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_text", "");

	setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_health", "");
}
