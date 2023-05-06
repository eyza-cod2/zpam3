#include maps\mp\gametypes\global\_global;

init()
{
	if(game["firstInit"])
	{
		game["is_halftime"] = false;

		precacheString2("STRING_HALFTIME", &"Halftime");
		precacheString2("STRING_TEAM_AUTO_SWITCH", &"Team Auto-Switch");
	}
}


// called at the end of last half-round (after last player is killed)
Do_Half_Time()
{
	// Show pam header, scoreboard + info about halftime
	HUD_TeamSwap();

	// Cancel timeout if called
	level maps\mp\gametypes\_timeout::Cancel();

	// Switch score progress For spectators
	level maps\mp\gametypes\_spectating_system_hud::ScoreProgress_AddHalftime();


	wait level.fps_multiplier * 4;


	// Wait for spectators in killcam
	level maps\mp\gametypes\_spectating_system::waitForSpectatorsInKillcam();

	// Activate half-time
	game["is_halftime"] = true;
	logPrint("HalfTime;\n");

	// Switch scores
	axis_score = game["axis_score"];
	game["axis_score"] = game["allies_score"];
	game["allies_score"] = axis_score;
	setTeamScore("axis", game["allies_score"]);
	setTeamScore("allies", game["allies_score"]);

	// Switch total called time-outs
	axis_called_timeouts = game["axis_called_timeouts"];
	game["axis_called_timeouts"] = game["allies_called_timeouts"];
	game["allies_called_timeouts"] = axis_called_timeouts;

	// Reset called timeouts in this half
	game["allies_called_timeouts_half"] = 0;
	game["axis_called_timeouts_half"] = 0;


	// Switch team for match info
	if (game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2)
	{
		match_team1_side = game["match_team1_side"];
		game["match_team1_side"] = game["match_team2_side"];
		game["match_team2_side"] = match_team1_side;
	}


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

/*
        Halftime
    Team auto switch
*/
// Called when halftime is called at the end of the round
HUD_TeamSwap()
{
	x = -85;
	y = 240;

	// Halftime
	halftime = addHUD(x, y, 1.2, (1,1,0), "center", "middle", "right");
	halftime showHUDSmooth(.5);
	halftime setText(game["STRING_HALFTIME"]);
	y += 20;

	// Team auto switch
	switching = addHUD(x, y, 1.2, (1,1,0), "center", "middle", "right");
	switching showHUDSmooth(.5);
	switching setText(game["STRING_TEAM_AUTO_SWITCH"]);
}
