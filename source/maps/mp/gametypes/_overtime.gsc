init()
{
    if (!isDefined(game["overtime_active"]))
        game["overtime_active"] = false;
}

// Called at the end of the map if score is equal and overtime is enabled
Do_Overtime()
{
    thread maps\mp\gametypes\_hud::PAM_Header();
    thread maps\mp\gametypes\_hud::Matchover(true); // true means its overtime
	thread maps\mp\gametypes\_hud::ScoreBoard(true);

	wait level.fps_multiplier * 7;

    // Activate overtime
    game["overtime_active"] = true;
    logPrint("OverTime;\n");



	// Reset main scores
	game["allies_score"] = 0;
	game["axis_score"] = 0;
	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);

	// Reset score at halfs
	game["half_1_allies_score"] = 0;
	game["half_1_axis_score"] = 0;
	game["half_2_allies_score"] = 0;
	game["half_2_axis_score"] = 0;

	// Total score for clan
	game["Team_1_Score"] = 0;				// Team_1 is: game["half_1_axis_score"] + game["half_2_allies_score"] ---- team who was as axis in first half
	game["Team_2_Score"] = 0;				// Team_2 is: game["half_2_axis_score"] + game["half_1_allies_score"] ----	team who was as allies in first half

	// Reset halftime
	game["is_halftime"] = false;

	// Reset called timeouts in this half
	game["axis_called_timeouts_half"] = 0;
	game["allies_called_timeouts_half"] = 0;

	// Other variables
	game["roundsplayed"] = 0;


	if (level.scr_readyup)
	{
		game["Do_Ready_up"] = true;
	}




    // Rules load - overide cvars with values for defined league mode
	maps\pam\rules\rules::load();
	// Save rule sets values as default so we are able to check if some of the cvar was changed from original
	maps\mp\gametypes\_cvar_system::saveRuleValues();



    if (!level.pam_mode_change)
        map_restart(true);
}
