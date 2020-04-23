#include maps\mp\gametypes\_callbacksetup;

init()
{
    level.in_timeout = false;


    if (!isDefined(game["timeout_called_team"]))
        game["timeout_called_team"] = "default";
    if (!isDefined(game["timeout_call_count"]))
        game["timeout_call_count"] = 0;
    if (!isDefined(game["timeout_cancel_count"]))
        game["timeout_cancel_count"] = 0;

    if (!isDefined(game["allies_called_timeouts"]))
        game["allies_called_timeouts"] = 0;
    if (!isDefined(game["axis_called_timeouts"]))
        game["axis_called_timeouts"] = 0;
    if (!isDefined(game["allies_called_timeouts_half"]))
        game["allies_called_timeouts_half"] = 0;
    if (!isDefined(game["axis_called_timeouts_half"]))
        game["axis_called_timeouts_half"] = 0;


    // Define game default variables
    if (!isDefined(game["do_timeout"]))
        game["do_timeout"] = false;

    // If this flag is set to true, we know timeout will be runned
    if (game["do_timeout"])
    {
        Start_Timeout_Mode(false); // runned_in_middle_of_game = false
    }


    // Register notifications catchup
    addEventListener("onConnected",     ::onConnected);
    addEventListener("onSpawned",     ::onSpawned);
	addEventListener("onMenuResponse",  ::onMenuResponse);
}

onConnected()
{
    // Set actual timeout status on player connect + when round restart in SD
    self setClientCvar("ui_allow_timeout", self Validate_Timeout(false));
}

onSpawned()
{
    // Set actual timeout status on player connect + when round restart in SD
    self setClientCvar("ui_allow_timeout", self Validate_Timeout(false));
}

/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu == game["menu_ingame"] && response == "timeout")
	{
		self closeMenu();
		self closeInGameMenu();
		self callTimeout();
		return true;
	}
}


callTimeout()
{

	// Return "notallowed", "cancel", "run_now", "run_next_round", "run_in_time"
	action = self Validate_Timeout(true);



	// Called in SD in strattime
	if (action == "run_now")
	{
		level thread Start_Timeout_Mode(true); // runned_in_middle_of_game = true
	}

	// Called in SD in middle of the round
	else if (action == "run_next_round")
	{
		// Flag is set, timeout will be executed after restart
		game["do_timeout"] = true;

        if (level.gametype == "sd" && level.roundended)
		{
            maps\mp\gametypes\_hud::NextRound_Kill(); // Kill timer with "Round - 8 - Starting + Timer"
            thread maps\mp\gametypes\_hud::Timeout(); // Show timeout message
        }
	}

	// Called in time based gametypes
	else if (action == "run_in_time")
	{
		game["do_timeout"] = true;

		level thread TO_Time_Based_GoingToTimeOutIN();
	}

	// Timeout is called, so cancel it
	else if (action == "cancel")
	{
		game["do_timeout"] = false;
		game["timeout_cancel_count"]++;

		// game["allies_called_timeouts"]    game["axis_called_timeouts"]
		game[game["timeout_called_team"] + "_called_timeouts"]--;
		game[game["timeout_called_team"] + "_called_timeouts_half"]--;

		iprintln(self.name + " ^7canceled time-out for team " + self.pers["team"]);

		logPrint("TO_CANCEL;" + self.pers["team"] + ";" + self.name + "\n");
	}



	// Timeout called, so print message to all players
	if (action == "run_now" || action == "run_next_round" || action == "run_in_time")
	{
		// Increase number of calls
		game[self.pers["team"] + "_called_timeouts"]++;
		game[self.pers["team"] + "_called_timeouts_half"]++;

		game["timeout_called_team"] = self.pers["team"];
		game["timeout_call_count"]++;

		iprintln(self.name + " ^7called a time-out for team " + self.pers["team"]);

		if (level.gametype == "sd")
		{
			if (level.in_timeout)
				iprintln("Going to time-out mode now.");
			else if(game["do_timeout"])
				iprintln("Going to time-out mode in the next round.");
		}

		logPrint("TO_CALL;" + self.pers["team"] + ";" + self.name + "\n");
	}


	// Update timeout status for all other players in their menus
	if (action != "notallowed")
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			 players[i] setClientCvar("ui_allow_timeout", players[i] Validate_Timeout(false));
		}
	}

}

Validate_Timeout(print)
{
	// Only for Allies and Axis
	if (self.pers["team"] != "axis" && self.pers["team"] != "allies")
	{
		if (print) { self iprintln("Time-out can be called only for team allies or axis"); return "notallowed"; }
		else return 0; // 0 - invisible
	}

	// We are in timeout
	if (level.in_timeout == true)
	{
		if (print) { self iprintln("Already in time-out"); return "notallowed"; }
		else return 4; // In timeout (disabled)
	}

	// Timeout was NOT called
	if (game["do_timeout"] == false)
	{
		// Is is supported game type
		if (!(level.gametype == "sd" || level.gametype == "ctf" || level.gametype == "tdm" || level.gametype == "dm"))
		{
			if (print) { self iprintln("Time-out is not supported in this gametype"); return "notallowed"; }
			else return 0; // Invisible
		}

		// Is allowed by rules?
		if(level.scr_timeouts < 1)
		{
			if (print) { self iprintln("Time-out is not supported by the rules"); return "notallowed"; }
			else return 0; // Invisible
		}

		// If is readyup
		if (level.in_readyup)
		{
			if (print) { self iprintln("Time-out can not be called in Ready-Up mode"); return "notallowed"; }
			else return 2; // Call timeout (disabled)
		}

		// Check calls
		if (game[self.pers["team"] + "_called_timeouts"] < level.scr_timeouts)
		{
			if (game[self.pers["team"] + "_called_timeouts_half"] >= level.scr_timeouts_half)
			{
				if (print) { self iprintln("No more time-outs permitted for "+self.pers["team"]+" in this half"); return "notallowed"; }
				else return 2; // Call timeout (disabled)
			}
		}
		else
		{
			if (print) { self iprintln("No more time-outs permitted for "+self.pers["team"]); return "notallowed"; }
			else return 2; // Call timeout (disabled)
		}


		// SD
		if (level.gametype == "sd")
		{
			// Last half round
			if (!game["is_halftime"] && game["roundsplayed"] >= (level.halfround - 1) && level.halfround != 0)
			{
				if (print) { self iprintln("Time-out can not be called before half-time"); return "notallowed"; }
				else return 2; // Call timeout (disabled)
			}

			// Last match round
			if (game["is_halftime"] && game["roundsplayed"] >= (level.matchround - 1) && level.matchround != 0)
			{
				if (print) { self iprintln("Time-out can not be called in last round"); return "notallowed"; }
				else return 2; // Call timeout (disabled)
			}


			// Timeout can be also called in strat time
			if (isDefined(level.in_strattime) && level.in_strattime == true)
			{
				// We are in strat time, run timeout now
				if (print) return "run_now";
				else return 1; // Call timeout
			}
			else
			{
				// We are in middle of round
				if (print) return "run_next_round";
				else return 1; // Call timeout
			}

		}

		// Time based gametypes
		else if (level.gametype == "ctf" || level.gametype == "tdm" || level.gametype == "dm")
		{

			if (print) return "run_in_time";
			else return 1; // Call timeout
		}




	}

	// Timeout was already called, so check if i can cancel it
	else if (game["timeout_called_team"] == self.pers["team"])
	{
		if (print) { /*iprintln(self.name + " ^7canceled time-out for team " + self.pers["team"]);*/ return "cancel"; }
		else return 5; // Cancel timeout
	}

	// Timeout called, but we are not able to cancel it
	else {
		if (print) { self iprintln("Time-out already called."); return "notallowed"; }
		else return 3; // Timeout called (disabled)
	}

}


Start_Timeout_Mode(runned_in_middle_of_game)
{
	level.in_timeout = true;
	game["do_timeout"] = false;	// reset request flag

	// Hide players left, change objectives, ...
	level notify("running_timeout");

	// Player movement
	if (level.gametype != "sd")
		maps\mp\gametypes\_cvar_system::setCvarQuiet("g_speed", 0);

	// remove clock
	if(isDefined(level.clock))
		level.clock destroy();

	// Disable weapons
	thread Handle_Weapons();

	// Run readyup mode and wait here untill is finished
	maps\mp\gametypes\_readyup::Start_Readyup_Mode(runned_in_middle_of_game);

	Match_Resume();
}


Match_Resume()
{
	level notify("timeoutover");

	level.in_timeout = 0;

	logPrint("TOO;\n");

	if (level.gametype != "sd")
		maps\mp\gametypes\_cvar_system::restoreCvarQuiet("g_speed");

	switch (level.gametype)
	{
	case "ctf":
    /*
		thread maps\mp\gametypes\ctf::startGame();
		thread maps\mp\gametypes\ctf::updateGametypeCvars();
		if (isDefined(level.rogueflag["axis"]) && level.rogueflag["axis"])
		{
			axis_flag = getent("axis_flag", "targetname");
			axis_flag thread maps\mp\gametypes\ctf::autoReturn();
		}
		if (isDefined(level.rogueflag["allies"]) && level.rogueflag["allies"])
		{
			allied_flag = getent("allied_flag", "targetname");
			allied_flag thread maps\mp\gametypes\ctf::autoReturn();
		}*/

		break;
	case "dm":/*
		thread maps\mp\gametypes\dm::startGame();
		//wait 1;
		thread maps\mp\gametypes\dm::updateGametypeCvars();
*/
		break;
	case "tdm":/*
		thread maps\mp\gametypes\tdm::startGame();
		//wait 1;
		thread maps\mp\gametypes\tdm::updateGametypeCvars();
*/
		break;
	case "sd":

		// Reset map and start round again
		map_restart(true);

		break;
	}



}

TO_Time_Based_GoingToTimeOutIN()
{

	goingtoo = newHudElem();
	goingtoo.x = 320;
	goingtoo.y = 15; //220
	goingtoo.alignX = "center";
	goingtoo.alignY = "top";
	goingtoo.fontScale = 1.3;
	goingtoo.color = (.8, 1, 1);
	goingtoo SetText(game["goingtoo"]);

	ttb = newHudElem();
	ttb.x = 320;
	ttb.y = 35; //220
	ttb.alignX = "center";
	ttb.alignY = "top";
	ttb.fontScale = 1.2;
	ttb.color = (1, 1, 0);
	ttb SetTimer(20);

	time = 0;
	while (game["do_timeout"]) {

		if (time >= 20)
		{
			level thread Start_Timeout_Mode(true); // runned_in_middle_of_game = true
			break;
		}

		wait level.fps_multiplier * 0.5;
		time += 0.5;
	}

	if (isDefined(ttb))
		ttb destroy();
	if (isDefined(goingtoo))
		goingtoo destroy();
}

Handle_Weapons()
{
	players = getentarray("player", "classname");
	while(level.in_timeout)
	{
		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			player = players[i];
			player disableWeapon();
		}
		wait level.fps_multiplier * 0.5;
	}



	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		player = players[i];
		player enableWeapon();
	}
}
