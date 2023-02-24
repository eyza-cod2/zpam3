#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onStartGameType", ::onStartGameType);
	addEventListener("onConnected",     ::onConnected);
	addEventListener("onMenuResponse",  ::onMenuResponse);
	addEventListener("onJoinedTeam",    ::onJoinedTeam);
}

// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	if (!isDefined(game["menuPrecached"]))
	{
		game["menu_moddownload"] = "moddownload";
		game["menu_language"] = "language";
		game["menu_ingame"] = "ingame";
		game["menu_team"] = "team_" + game["allies"] + game["axis"];	// team_britishgerman
		game["menu_weapon_allies"] = "weapon_" + game["allies"];
		game["menu_weapon_axis"] = "weapon_" + game["axis"];
		game["menu_weapon_rifles"] = "weapon_rifles";
		game["menu_serverinfo"] = "serverinfo_" + level.gametype;
		game["menu_callvote"] = "callvote";
		game["menu_exec_cmd"] = "exec_cmd";
		game["menu_quickcommands"] = "quickcommands";
		game["menu_quickstatements"] = "quickstatements";
		game["menu_quickresponses"] = "quickresponses";
		game["menu_quicksettings"] = "quicksettings";
		game["menu_mousesettings"] = "mousesettings";
		game["menu_scoreboard"] = "scoreboard_sd";
		game["menu_spectatingsystem"] = "spectatingsystem";
		game["menu_strat_records"] = "strat_records";

		precacheMenu(game["menu_moddownload"]);
		precacheMenu(game["menu_language"]);
		precacheMenu(game["menu_ingame"]);
		precacheMenu(game["menu_team"]);
		precacheMenu(game["menu_weapon_allies"]);
		precacheMenu(game["menu_weapon_axis"]);
		precacheMenu(game["menu_weapon_rifles"]);
		precacheMenu(game["menu_serverinfo"]);
		precacheMenu(game["menu_callvote"]);
		precacheMenu(game["menu_exec_cmd"]);
		precacheMenu(game["menu_quickcommands"]);
		precacheMenu(game["menu_quickstatements"]);
		precacheMenu(game["menu_quickresponses"]);
		precacheMenu(game["menu_quicksettings"]);
		precacheMenu(game["menu_mousesettings"]);
		precacheMenu(game["menu_scoreboard"]);
		precacheMenu(game["menu_spectatingsystem"]);
		precacheMenu(game["menu_strat_records"]);

		// Rifle mode use different menu for allies and axis
		if (level.scr_rifle_mode)
		{
			game["menu_weapon_allies"] = game["menu_weapon_rifles"];
			game["menu_weapon_axis"] = game["menu_weapon_rifles"];
		}

		/#
		game["menu_debugString"] = "debugString";
		precacheMenu(game["menu_debugString"]);
		#/

		game["menuPrecached"] = true;
	}
}

onConnected()
{
	scriptMainMenu = "";	// If ESC is pressed, open Main menu

	// If pam is not installed correctly
	if (level.pam_installation_error)
	{
		// dont open any menu
	}

	// Open first menu that inform mod is downloaded
	else if (self maps\mp\gametypes\_force_download::waitingForResponse())
	{
		self thread maps\mp\gametypes\_force_download::checkDownload();
		// Open menu that invoke cmd scriptmenuresponse
		self openMenu(game["menu_moddownload"]);
		scriptMainMenu = game["menu_moddownload"];
	}

	// Mod is not downloaded for sure
	else if (self maps\mp\gametypes\_force_download::modIsNotDownloadedForSure())
	{
		// dont open any menu
	}

	// Server info wasnt skiped yet - player didnt click "continue"
	else if(!isDefined(self.pers["skipserverinfo"]))
	{
		scriptMainMenu = game["menu_serverinfo"];
		self openMenu(game["menu_serverinfo"]);
		self maps\mp\gametypes\_menu_serverinfo::updateServerInfo();
	}

	// Menu with language was not opened yet
	else if (!isDefined(self.pers["languageLoaded"]))
	{
		scriptMainMenu = game["menu_language"];
		self openMenu(game["menu_language"]);
	}

	else if (game["state"] == "intermission")
	{
		self setClientCvar2("ui_allow_weaponchange", 0);
		self setClientCvar2("ui_allow_changeteam", 0);
		scriptMainMenu = game["menu_ingame"];	// default
	}

	// Player did not choose team yet after connect
	else if (!isDefined(self.pers["firstTeamSelected"]))
	{
		self setClientCvar2("ui_allow_changeteam", 1);
		scriptMainMenu = game["menu_team"]; // when esc is pressed, show menu with teams
		self openMenu(game["menu_team"]); // else open team menu
	}

	// If team is selected
	else if (self.pers["team"] == "allies" || self.pers["team"] == "axis")
	{
		self setClientCvar2("ui_allow_weaponchange", 1);

		// If player have team, but not choozen weapon
		if(!isDefined(self.pers["weapon"]))
		{
			if(self.pers["team"] == "allies")
			{
				scriptMainMenu = game["menu_weapon_allies"];
				self openMenu(game["menu_weapon_allies"]);
			}
			else if(self.pers["team"] == "axis")
			{
				scriptMainMenu = game["menu_weapon_axis"];
				self openMenu(game["menu_weapon_axis"]);
			}
		}
		else // in team and with weapon
		{
			scriptMainMenu = game["menu_ingame"];
		}
	}
	else // spectator
	{
		self setClientCvar2("ui_allow_weaponchange", 0);
		scriptMainMenu = game["menu_ingame"];	// default
	}

	self setClientCvar2("g_scriptMainMenu", scriptMainMenu);

	self setClientCvar2("ui_allowVote", level.allowvote);
}

onJoinedTeam(team)
{
	self.pers["firstTeamSelected"] = true;


	if (team == "allies" || team == "axis")
	{
		self setClientCvar2("ui_allow_weaponchange", "1");
	}
	else
		self setClientCvar2("ui_allow_weaponchange", "0");



	if(team == "allies")
	{
		self openMenu(game["menu_weapon_allies"]);
		self setClientCvar2("g_scriptMainMenu", game["menu_weapon_allies"]);
	}
	else if (team == "axis")
	{
		self openMenu(game["menu_weapon_axis"]);
		self setClientCvar2("g_scriptMainMenu", game["menu_weapon_axis"]);
	}
	else if (team == "spectator")
	{
		self setClientCvar2("g_scriptMainMenu", game["menu_ingame"]);
	}

}

/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	// Pam is not installed correctly, ignore other responses
	if (level.pam_installation_error)
		return true;

	// Mod is not downloaded, ignore other responses
	if (maps\mp\gametypes\_force_download::modIsNotDownloadedForSure())
		return true;

	// Not downloaded yet and still listening
	if(menu == game["menu_moddownload"] && response == "moddownloaded" && maps\mp\gametypes\_force_download::waitingForResponse())
	{
		maps\mp\gametypes\_force_download::modIsDownloaded();

		/*
		TODO LANG
		// Open language menu
		self closeMenu();
		self closeInGameMenu();
		self openMenu(game["menu_language"]);
		self setClientCvar2("g_scriptMainMenu", game["menu_language"]);

		return true;
	}

	else if (menu == game["menu_language"])
	{
		maps\mp\gametypes\_language::saveOriginalLanguage(response);
		TODO LANG
		*/

		self.pers["languageLoaded"] = true;

		// Open server info
		self closeMenu();
		self closeInGameMenu();
		self openMenu(game["menu_serverinfo"]);
		self setClientCvar2("g_scriptMainMenu", game["menu_serverinfo"]);
		self maps\mp\gametypes\_menu_serverinfo::updateServerInfo();
	}

	else if(menu == game["menu_serverinfo"] && response == "close")
	{
		self closeMenu();
		self closeInGameMenu();

		if (game["state"] != "intermission")
			self setClientCvar2("ui_allow_changeteam", 1);

		if (!isDefined(self.pers["skipserverinfo"]))	// first time
		{
			// After serverinfo is skipped, show menu with teams
			self setClientCvar2("g_scriptMainMenu", game["menu_team"]);
			self openMenu(game["menu_team"]);
		}
		else if (!isDefined(self.pers["firstTeamSelected"]))
			self openMenu(game["menu_team"]);
		else
			self openMenu(game["menu_ingame"]); // serverinfo may be opened and closed aditionally via menu

		self.pers["skipserverinfo"] = true;

		return true;
	}



	if(response == "back")
	{
		self closeMenu();
		self closeInGameMenu();

		if(menu == game["menu_team"])
			self openMenu(game["menu_ingame"]);
		else if(menu == game["menu_weapon_allies"] || menu == game["menu_weapon_axis"])
			self openMenu(game["menu_team"]);

		return true;
	}


	if(menu == game["menu_ingame"])
	{
		if (response == "changeweapon" && game["state"] != "intermission")
		{
			self closeMenu();
			self closeInGameMenu();
			if(self.pers["team"] == "allies")
				self openMenu(game["menu_weapon_allies"]);
			else if(self.pers["team"] == "axis")
				self openMenu(game["menu_weapon_axis"]);
			return true;
		}
		if (response == "changeteam" && game["state"] != "intermission")
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu(game["menu_team"]);
			return true;
		}
		if (response == "serverinfo")
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu(game["menu_serverinfo"]);
			self maps\mp\gametypes\_menu_serverinfo::updateServerInfo();
			return true;
		}
		if (response == "callvote")
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu(game["menu_callvote"]);
			return true;
		}
	}

	else if(menu == game["menu_team"] && game["state"] != "intermission")
	{
		teamBefore = self.pers["team"];
		switch(response)
		{
		case "allies":
			self closeMenu();
			self closeInGameMenu();
			self [[level.allies]]();
			if(self.pers["team"] != teamBefore)
				self thread printTeamChanged(&"MP_JOINED_ALLIES", self.name);
			break;

		case "axis":
			self closeMenu();
			self closeInGameMenu();
			self [[level.axis]]();
			if(self.pers["team"] != teamBefore)
				self thread printTeamChanged(&"MP_JOINED_AXIS", self.name);
			break;

		case "autoassign":
			self closeMenu();
			self closeInGameMenu();
			self [[level.autoassign]]();
			if(self.pers["team"] != teamBefore) {
				if(self.pers["team"] == "allies")
					self thread printTeamChanged(&"MP_JOINED_ALLIES", self.name);
				else if(self.pers["team"] == "axis")
					self thread printTeamChanged(&"MP_JOINED_AXIS", self.name);
			}
			break;

		case "spectator":
			self closeMenu();
			self closeInGameMenu();
			self [[level.spectator]]();
			if(self.pers["team"] != teamBefore)
				self thread printTeamChanged(self.name + " Joined Spectators", "");
			break;

		case "options":
			self closeMenu();
			self closeInGameMenu();
			self openMenu(game["menu_ingame"]);
			break;
		}
		return true;
	}
	else if(menu == game["menu_weapon_allies"] || menu == game["menu_weapon_axis"])
	{
		self closeMenu();
		self closeInGameMenu();
		self [[level.weapon]](response);
		return true;
	}
	else if(menu == game["menu_quickcommands"])
	{
		maps\mp\gametypes\_quickmessages::quickcommands(response);
		return true;
	}
	else if(menu == game["menu_quickstatements"])
	{
		maps\mp\gametypes\_quickmessages::quickstatements(response);
		return true;
	}
	else if(menu == game["menu_quickresponses"])
	{
		maps\mp\gametypes\_quickmessages::quickresponses(response);
		return true;
	}


}

printTeamChanged(text, name) {
	self endon("disconnect");

	wait level.frame;
	iprintln(text, name);
}
