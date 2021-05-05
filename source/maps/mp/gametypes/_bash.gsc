#include maps\mp\gametypes\global\_global;

// Bash mode can be called only in first readyup
// Every team can call bash mode only twice
// Team can cancel bash mode called by opposite team

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_bash", "BOOL", 0);

	if(game["firstInit"])
	{
		precacheString2("STRING_BASH_MODE", &"Pistol bash");
	}

	if(game["firstInit"])
	{
		game["do_bash"] = false;
	}

	game["allies_called_bashes"] = 0;
	game["axis_called_bashes"] = 0;
	level.in_bash = false;
	level.lastCallTime = 0;

	// If this flag is set to true, we know bash will be runned
	if (game["do_bash"])
	{
		level.in_bash = true;
		game["do_bash"] = false;	// reset request flag
	}

	// Register notifications catchup
	addEventListener("onConnected",     ::onConnected);
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
		case "scr_bash": 		level.scr_bash = value; return true;
	}
	return false;
}

onConnected()
{
    // Set actual bash mode status on player connect + when round restart in SD
    self setClientCvar2("ui_allow_bash", self Validate_bash(false));
}

onSpawned()
{
	// Set actual bash mode status on player connect + when round restart in SD
	self setClientCvar2("ui_allow_bash", self Validate_bash(false));

	if (level.in_bash)
	{
		if (isDefined(self.bashPrinted))
			return;

		self iprintlnbold("^3Pistol bash");
		self iprintlnbold("^7 ");
		self iprintlnbold("^7 ");

		// Awoid again print if spectator is spawned after player is killed
		self.bashPrinted = true;
	}
}

/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu == game["menu_ingame"] && response == "bash")
	{
		time = gettime();
		if (level.lastCallTime + 3000 < time) // allow next action after 3 sec to avoid unwanted cancellation if 2 players call bash mode at once
		{
			self closeMenu();
			self closeInGameMenu();
			self callbash();
			level.lastCallTime = time;
			return true;
		}
	}
}


callbash()
{

	// Return "notallowed", "cancel", "ok"
	action = self Validate_bash(true);


	if (action == "cancel")
	{
		game["do_bash"] = false;

		iprintlnbold(self.name + " ^7canceled a bash mode.");

		HUD_Bash();
	}


	// bash called, so print message to all players
	if (action == "ok")
	{
    		game["do_bash"] = true;

		// Increase number of calls
		game[self.pers["team"] + "_called_bashes"]++;

		iprintln(self.name + " ^7called a bash mode.");
		iprintln("Going to bash mode after the ready-up mode.");

		iprintlnbold(self.name + " ^7called a bash mode.");

		logPrint("BASH_CALL;" + self.pers["team"] + ";" + self.name + "\n");

		HUD_Bash();
	}


	// Update bash status for all other players in their menus
	if (action != "notallowed")
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			 players[i] setClientCvar2("ui_allow_bash", players[i] Validate_bash(false));
		}
	}

}


HUD_Bash()
{
	// Bash info
	if (!isDefined(level.bash_hud_info))
	{
		level.bash_hud_info = addHUD(-20, 39, 1, (1,1,0), "right", "top", "right");
		level.bash_hud_info setText(game["STRING_BASH_MODE"]);
	}
	else
	{
		level.bash_hud_info removeHUD();
		level.bash_hud_info = undefined;
	}
}


Validate_bash(print)
{
  // 0 = "" (invisible)
  // 1 = "Call bash"
  // 2 = "Call bash" (disabled)
  // 3 = "In bash" (disabled)
  // 4 = "Cancel bash"

	// Only for Allies and Axis
	if (self.pers["team"] != "axis" && self.pers["team"] != "allies")
	{
		if (print) { self iprintln("Bash mode can be called only for team allies or axis"); return "notallowed"; }
		else return 0; // 0 - invisible
	}

	// We are in bash
	if (level.in_bash == true)
	{
		if (print) { self iprintln("Already in bash mode"); return "notallowed"; }
		else return 3; // In bash (disabled)
	}

	// bash was NOT called
	if (game["do_bash"] == false)
	{
		// Is is supported game type
		if (!(level.gametype == "sd"))
		{
			if (print) { self iprintln("Bash mode is not supported in this gametype"); return "notallowed"; }
			else return 0; // Invisible
		}

		// Is allowed by rules?
		if(!level.scr_bash)
		{
			if (print) { self iprintln("Bash mode is not supported by the rules"); return "notallowed"; }
			else return 0; // Invisible
		}

		// If is readyup
		if (!level.in_readyup)
		{
			if (print) { self iprintln("Bash mode can be called only in Ready-Up mode"); return "notallowed"; }
			else return 2; // Call bash (disabled)
		}

		// If is first readyup
		if (!game["readyup_first_run"])
		{
			if (print) { self iprintln("Bash mode can be called only in first Ready-Up mode"); return "notallowed"; }
			else return 2; // Call bash (disabled)
		}

		// Check calls
		if (game[self.pers["team"] + "_called_bashes"] >= 2) // team can call bash mode only twice to avoid spam
		{
      if (print) { self iprintln("No more bash mode calls allowed for team "+self.pers["team"]); return "notallowed"; }
			else return 2; // Call bash (disabled)
		}

    // All ok
		if (print) return "ok";
		else return 1; // Call bash
	}

	// bash was called by enemy team
	else
	{
		if (print) { iprintln(self.name + " ^7canceled bash mode."); return "cancel"; }
		else return 4; // Cancel bash
	}

}
