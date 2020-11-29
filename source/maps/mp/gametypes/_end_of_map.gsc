#include maps\mp\gametypes\_callbacksetup;

init()
{
}

// Called at the end of the last round
Do_Map_End()
{
    thread maps\mp\gametypes\_hud::PAM_Header();
	thread maps\mp\gametypes\_hud::Matchover();
	thread maps\mp\gametypes\_hud::ScoreBoard(true);


	wait level.fps_multiplier * 2;



	maps\mp\gametypes\_mapvote::Initialize();


    // If overtime was active match before, reset them
    game["overtime_active"] = false;



    game["state"] = "intermission";
	level notify("intermission");

    // Spawn each player into intermission
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player closeMenu();
		player closeInGameMenu();

		player [[level.spawnIntermission]]();
	}

	wait level.fps_multiplier * 12;


    if (game["is_public_mode"])
    {
        logPrint("MapEnd;\n");
        if (!level.pam_mode_change)
            exitLevel(false); // load next map in map_rotation
    }

    // In match-mode just do fast_restart
    else
	{
		logPrint("MatchEnd;\n");
        if (!level.pam_mode_change)
		      map_restart(false); // fast_restart
	}
}
