#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvarEx("C", "scr_timeouts", "INT", 0, 0, 10);
	registerCvarEx("C", "scr_timeouts_half", "INT", 0, 0, 10);
	registerCvarEx("C", "scr_timeout_length", "FLOAT", 5, 0, 1440);


	if(game["firstInit"])
	{
		precacheString2("STRING_TIMEOUT", &"Time-out");
		precacheString2("STRING_GOING_TO_TIMEOUT", &"Going to Time-out");
		precacheString2("STRING_GOING_TO_TIMEOUT_IN", &"Going to time-out in");


		game["timeout_called_team"] = "";
		game["allies_called_timeouts"] = 0;
		game["axis_called_timeouts"] = 0;
		game["allies_called_timeouts_half"] = 0;
		game["axis_called_timeouts_half"] = 0;
		game["do_timeout"] = false;
	}

	level.in_timeout = false;
	level.timeout_elapsedTime = 0; // in seconds

	// If this flag is set to true, we know timeout will be runned
	if (game["do_timeout"])
	{
		level.in_timeout = true;
		game["do_timeout"] = false;	// reset request flag
	}

	// Register notifications catchup
	addEventListener("onStartGameType", ::onStartGameType);
	addEventListener("onConnected",     ::onConnected);
	addEventListener("onJoinedTeam",    ::onJoinedTeam);
	addEventListener("onSpawned",     ::onSpawned);
	addEventListener("onMenuResponse",  ::onMenuResponse);
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_timeouts": 			level.scr_timeouts = value; return true;
		case "scr_timeouts_half": 		level.scr_timeouts_half = value; return true;
		case "scr_timeout_length": 		level.scr_timeout_length = value; return true;
	}
	return false;
}

// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	// Run timeout
	if (level.in_timeout)
	{
		level thread Start_Timeout_Mode(false); // runned_in_middle_of_game = false
	}
}


onConnected()
{
    // Set actual timeout status on player connect + when round restart in SD
    self Update_Player_HUD_Cvar();
}

onJoinedTeam(teamName)
{
	// Set actual timeout status on player connect + when round restart in SD
        self Update_Player_HUD_Cvar();
}

onSpawned()
{
    // Set actual timeout status on player connect + when round restart in SD
    self Update_Player_HUD_Cvar();

    // Disable weapons
    if (level.in_timeout)
    {
	    self disableWeapon();
    }
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


	// Timeout called, so print message to all players
	if (action == "run_now" || action == "run_next_round" || action == "run_in_time")
	{
		game["timeout_called_team"] = self.pers["team"];

		iprintln(self.name + " ^7called a time-out for team " + self.pers["team"]);

		if (level.gametype == "sd" || level.gametype == "re")
		{
			if (level.in_timeout)
				iprintln("Going to time-out mode now.");
			else if(game["do_timeout"])
				iprintln("Going to time-out mode in the next round.");
		}

		logPrint("TO_CALL;" + self.pers["team"] + ";" + self.name + "\n");
	}


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

	        if ((level.gametype == "sd" || level.gametype == "re") && level.roundended)
		{
	            thread HUD_Timeout(); // Show timeout message
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

		Cancel();

		iprintln(self.name + " ^7canceled time-out for team " + self.pers["team"]);

		logPrint("TO_CANCEL;" + self.pers["team"] + ";" + self.name + "\n");
	}



	// Update timeout status for all other players in their menus
	if (action != "notallowed")
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			 players[i] Update_Player_HUD_Cvar();
		}
	}

}

// Called also from do_halftime and do_mapend
Cancel()
{
	game["do_timeout"] = false;

	game["timeout_called_team"] = "";
}

Validate_Timeout(print)
{
	//  0:disabled 1:enabled 2:disabled 3:already called 4:in timeout 5:cancel

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
		if (!(level.gametype == "sd" || level.gametype == "ctf" || level.gametype == "tdm" || level.gametype == "dm" || level.gametype == "hq" || level.gametype == "htf" || level.gametype == "re"))
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

		// If is bash mode
		if (level.in_bash)
		{
			if (print) { self iprintln("Time-out can not be called in bash mode"); return "notallowed"; }
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
		if (level.gametype == "sd" || level.gametype == "re")
		{
			// Timeout can be always called in strat time
			if (level.in_strattime)
			{
				// We are in strat time, run timeout now
				if (print) return "run_now";
				else return 1; // Call timeout
			}

			// Last half round
			if (level.halfround > 0 && !game["is_halftime"] && game["round"] >= level.halfround)
			{
				if (print) { self iprintln("Time-out can not be called before half-time"); return "notallowed"; }
				else return 2; // Call timeout (disabled)
			}

			// Last match round
			if (level.matchround > 0 && game["is_halftime"] && game["round"] >= level.matchround)
			{
				if (print) { self iprintln("Time-out can not be called in last round"); return "notallowed"; }
				else return 2; // Call timeout (disabled)
			}

			// We are in middle of round
			if (print) return "run_next_round";
			else return 1; // Call timeout
		}

		// Time based gametypes
		else if (level.gametype == "ctf" || level.gametype == "tdm" || level.gametype == "dm" || level.gametype == "hq" || level.gametype == "htf")
		{
			// Timeout can be always called in strat time
			if (level.in_strattime)
			{
				// We are in strat time, run timeout now
				if (print) return "run_now";
				else return 1; // Call timeout
			}
			if (level.mapended)
			{
				if (print) { self iprintln("Time-out can not be called"); return "notallowed"; }
				else return 2; // Call timeout (disabled)
			}

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
	game["do_timeout"] = false;

	// Hide players left, change objectives, ...
	level notify("running_timeout");

	// Increase number of calls
	if (game["timeout_called_team"] == "allies" || game["timeout_called_team"] == "axis")
	{
		game[game["timeout_called_team"] + "_called_timeouts"]++;
		game[game["timeout_called_team"] + "_called_timeouts_half"]++;
	}

	// Player movement
	if (level.gametype != "sd" && level.gametype != "re")
		maps\mp\gametypes\global\cvar_system::setCvarQuiet("g_speed", 0);

	// Disable weapons
	if (runned_in_middle_of_game)
	{
		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			player = players[i];
			player disableWeapon();
			player Update_Player_HUD_Cvar();
		}
	}

	time_start = gettime();

	// Run readyup mode and wait here untill is finished
	maps\mp\gametypes\_readyup::Start_Readyup_Mode(runned_in_middle_of_game);

	time_elapsed = gettime() - time_start;
	level.timeout_elapsedTime += time_elapsed / 1000;



	level notify("timeoutover");

	game["timeout_called_team"] = "";
	level.in_timeout = 0;

	logPrint("TOO;\n");

	if (level.gametype != "sd" && level.gametype != "re")
		maps\mp\gametypes\global\cvar_system::restoreCvarQuiet("g_speed");

	// Enable weapons
	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		player = players[i];
		player enableWeapon();
		player Update_Player_HUD_Cvar();
	}

	if (level.gametype == "sd" || level.gametype == "re")
	{
		// Reset map and start round again
		map_restart(true);
	}
}


Update_Player_HUD_Cvar()
{
	//  0:disabled 1:enabled 2:disabled 3:already called 4:in timeout 5:cancel
	number = self Validate_Timeout(false);

	self setClientCvarIfChanged("ui_allow_timeout", number);



	if (number == 1 && (self.pers["team"] == "axis" || self.pers["team"] == "allies"))
	{
		if (game[self.pers["team"] + "_called_timeouts"] < level.scr_timeouts)
			str = "(" + (level.scr_timeouts_half - game[self.pers["team"] + "_called_timeouts_half"]) + ")";
		else
			str = "(0)";

		self setClientCvarIfChanged("ui_timeout_info", str);
	}
	else
		self setClientCvarIfChanged("ui_timeout_info", "");
}




/*
        Time-out
    Going to Time-out
*/
HUD_Timeout()
{
	x = -85;
	y = 240;

	// Time-out
	timeout = addHUD(x, y, 1.2, (1,1,0), "center", "middle", "right");
	timeout showHUDSmooth(.5);
	timeout setText(game["STRING_TIMEOUT"]);
	y += 20;

	// Going to Time-out
	going_timeout = addHUD(x, y, 1.2, (1,1,0), "center", "middle", "right");
	going_timeout showHUDSmooth(.5);
	going_timeout setText(game["STRING_GOING_TO_TIMEOUT"]);
}




TO_Time_Based_GoingToTimeOutIN()
{
	waittime = 12;

	goingtoo = newHudElem2();
	goingtoo.x = 320;
	goingtoo.y = 75; //220
	goingtoo.alignX = "center";
	goingtoo.alignY = "top";
	goingtoo.fontScale = 1.3;
	goingtoo.color = (.8, 1, 1);
	goingtoo SetText(game["STRING_GOING_TO_TIMEOUT_IN"]);

	ttb = newHudElem2();
	ttb.x = 320;
	ttb.y = 90; //220
	ttb.alignX = "center";
	ttb.alignY = "top";
	ttb.fontScale = 1.2;
	ttb.color = (1, 1, 0);
	ttb SetTimer(waittime);

	time = 0;
	while (game["do_timeout"]) {

		if (time >= waittime)
		{
			level thread Start_Timeout_Mode(true); // runned_in_middle_of_game = true
			break;
		}

		wait level.fps_multiplier * 0.5;
		time += 0.5;
	}

	if (isDefined(ttb))
		ttb destroy2();
	if (isDefined(goingtoo))
		goingtoo destroy2();
}
