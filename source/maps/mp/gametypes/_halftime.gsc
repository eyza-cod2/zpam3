#include maps\mp\gametypes\_callbacksetup;

init()
{
	if (!isDefined(game["is_halftime"]))
		game["is_halftime"] = false;
}

// called at the end of last half-round (after last player is killed)
Do_Half_Time()
{
	// Show pam header, scoreboard + info about halftime
	thread maps\mp\gametypes\_hud::PAM_Header();
	thread maps\mp\gametypes\_hud::ScoreBoard(true); // call this before game["is_halftime"] is set to true
	thread maps\mp\gametypes\_hud::TeamSwap();

	wait level.fps_multiplier * 7;

	// Activate half-time
	game["is_halftime"] = true;
	logPrint("HalfTime;\n");


	// Switch scores
	axis_score = game["axis_score"];
	game["axis_score"] = game["allies_score"];
	game["allies_score"] = axis_score;
	setTeamScore("axis", game["allies_score"]);
	setTeamScore("allies", game["allies_score"]);

	// Switch time-outs
	axis_called_timeouts = game["axis_called_timeouts"];
	game["axis_called_timeouts"] = game["allies_called_timeouts"];
	game["allies_called_timeouts"] = axis_called_timeouts;

	// If game is in overtime, and halftime is called, called timeouts cannot be reseted!
	if (!game["overtime_active"])
	{
		game["allies_called_timeouts_half"] = 0;
		game["axis_called_timeouts_half"] = 0;
	}

	// Switch team for match info
	match_team1_side = game["match_team1_side"];
	game["match_team1_side"] = game["match_team2_side"];
	game["match_team2_side"] = match_team1_side;


	axissavedmodel = undefined;
	alliedsavedmodel = undefined;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		// Switch Teams
		if (player.pers["team"] == "axis")
		{
			player.pers["team"] = "allies";
			axissavedmodel = player.pers["savedmodel"];
		}
		else if (player.pers["team"] == "allies")
		{
			player.pers["team"] = "axis";
			alliedsavedmodel = player.pers["savedmodel"];
		}

		//Swap Models
		if (player.pers["team"] == "axis")
			 player.pers["savedmodel"] = axissavedmodel;
		else if (player.pers["team"] == "allies")
			player.pers["savedmodel"] = alliedsavedmodel;

		//drop weapons and make spec
		player.pers["weapon"] = undefined;
		player.pers["weapon1"] = undefined;
		player.pers["weapon2"] = undefined;
		player.archivetime = 0;
		player.reflectdamage = undefined;

		player unlink();
		player enableWeapon();

		//change headicons
		if(level.scr_drawfriend)
		{
			if(player.pers["team"] == "allies")
			{
				player.headicon = game["headicon_allies"];
				player.headiconteam = "allies";
			}
			else
			{
				player.headicon = game["headicon_axis"];
				player.headiconteam = "axis";
			}
		}
	}

	if (level.scr_readyup)
		game["Do_Ready_up"] = true;

	if (!level.pam_mode_change)
		map_restart(true);
}
