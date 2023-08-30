#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_overtime", "BOOL", 0);

	if(game["firstInit"])
	{
		game["overtime_active"] = false;
		game["overtime_score"] = 0;

		precacheString2("STRING_GOING_TO_OVERTIME", &"Going to Over-time");
	}
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_overtime":	                level.scr_overtime = value; return true;
	}
	return false;
}

// Called at the end of the map if score is equal and overtime is enabled
Do_Overtime()
{
	HUD_GoingToOvertime();

	wait level.fps_multiplier * 5;

	// Wait for spectators in killcam
	level maps\mp\gametypes\_streamer::waitForSpectatorsInKillcam();

	// Activate overtime
	game["overtime_active"] = true;
	logPrint("OverTime;\n");


	// Use this variable to set new end score
	game["overtime_score"] = game["allies_score"]; // score of allies and axis should be the same when overtime is called


	// Reset score at halfs
	game["half_1_allies_score"] = 0;
	game["half_1_axis_score"] = 0;
	game["half_2_allies_score"] = 0;
	game["half_2_axis_score"] = 0;

	// Reset halftime
	game["is_halftime"] = false;

	// Reset called timeouts in this half
	game["axis_called_timeouts_half"] = 0;
	game["allies_called_timeouts_half"] = 0;

	// Other variables
	game["roundsplayed"] = 0;
	game["round"] = 0;


	// History score for spectators
	level maps\mp\gametypes\_streamer_hud::ScoreProgress_AddOvertime();


	// Drop saved weapons
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player.pers["weapon1"] = undefined;
		player.pers["weapon2"] = undefined;

		player unlink();
		player enableWeapon();
	}



	if (level.scr_readyup)
	{
		game["Do_Ready_up"] = true;
	}



    if (!level.pam_mode_change)
        map_restart(true);
}

/*
    Its a TIE
Going to overtime
*/
HUD_GoingToOvertime()
{
	x = -85;
	y = 240;

	// Its a TIE
	teamwin = addHUD(x, y, 1.2, (1,1,0), "center", "middle", "right");
	teamwin showHUDSmooth(1);
	teamwin setText(game["STRING_ITS_TIE"]);
	y += 20;

	// Going to overtime
	goingto = addHUD(x, y, 1.2, (1,1,0), "center", "middle", "right");
	goingto showHUDSmooth(1);
	goingto setText(game["STRING_GOING_TO_OVERTIME"]);
}
