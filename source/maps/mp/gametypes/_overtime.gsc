init()
{
    if (!isDefined(game["overtime_active"]))
        game["overtime_active"] = false;
}

// Called at the end of the map if score is equal and overtime is enabled
Do_Overtime(gametypeOvertimeFunction)
{
    thread maps\mp\gametypes\_hud::PAM_Header();
    thread maps\mp\gametypes\_hud::Matchover(true); // true means its overtime
	thread maps\mp\gametypes\_hud::ScoreBoard(true);

	wait level.fps_multiplier * 7;

    // Activate overtime
    game["overtime_active"] = true;
    logPrint("OverTime;\n");


	// Switch time-outs
	axis_called_timeouts = game["axis_called_timeouts"];
	game["axis_called_timeouts"] = game["allies_called_timeouts"];
	game["allies_called_timeouts"] = axis_called_timeouts;

    axis_called_timeouts_half = game["axis_called_timeouts_half"];
	game["axis_called_timeouts_half"] = game["allies_called_timeouts_half"];
	game["allies_called_timeouts_half"] = axis_called_timeouts_half;


    // Switch teams
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

    // Call gametype specific function
    [[gametypeOvertimeFunction]]();




    // Rules load - overide cvars with values for defined league mode
	maps\pam\rules\rules::load();
	// Save rule sets values as default so we are able to check if some of the cvar was changed from original
	maps\mp\gametypes\_cvar_system::saveRuleValues();



	reset_Match_Score();


    if (!level.pam_mode_change)
        map_restart(true);

            /*
    }
    else
    {
        // If scr_overtime_active is set to 1, next map_restart(false) will be game["overtime_active"] set to true
        setCvar("scr_overtime_active", 1);

        if (!level.pam_mode_change)
            map_restart(false); // fast_restart
    }*/
}

reset_Match_Score()
{
	game["allies_score"] = 0;
	setTeamScore("allies", game["allies_score"]);
	game["axis_score"] = 0;
	setTeamScore("axis", game["axis_score"]);

	game["half_1_allies_score"] = 0;
	game["half_1_axis_score"] = 0;
	game["half_2_allies_score"] = 0;
	game["half_2_axis_score"] = 0;
	game["Team_1_Score"] = 0;
	game["Team_2_Score"] = 0;
}
