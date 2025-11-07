#include maps\mp\gametypes\global\_global;

init()
{
	if(game["firstInit"])
	{
		precacheString2("STRING_VERSION_INFO", &"zPAM 4.04"); // ZPAM_RENAME
		//precacheString2("STRING_VERSION_INFO", &"^1zPAM 4.00 TEST 6"); // ZPAM_RENAME
		//precacheString2("STRING_VERSION_INFO", &"zPAM 3.34 ^3BETA 1"); // ZPAM_RENAME
	}

	maps\mp\gametypes\global\_global::addEventListener("onConnected",     ::onConnected);
}

onConnected()
{
	if (isDefined(level.pam_header_visible)) {
		self thread PAM_ClientThread(false);
	}
}


// Info about PAM, league name
// Is removed at readyup after all players are ready
PAM_Header(fadein)
{
	// Another thread is running..
	if (isDefined(level.pam_header_visible))
		return;
	level.pam_header_visible = true;

	if (!isDefined(fadein))
		fadein = false;

	// Show global warnings
	thread maps\mp\gametypes\_warnings::update();

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player thread PAM_ClientThread(fadein);
	}

	level waittill("pam_hud_delete");

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player thread PAM_HidePamHUD();
	}

	// Hide global warnings
	thread maps\mp\gametypes\_warnings::hide();

	level.pam_header_visible = undefined;
}

PAM_ClientThread(fadein) {
	self endon("disconnect");
	level endon("pam_hud_delete");

	// Make sure only one thread is running
	self notify("PAM_ClientThread");
	self endon("PAM_ClientThread");

	lastTeam = "";
	for(;;)
	{
		if (self.pers["team"] != lastTeam)
		{
			//self iPrintLn("Current team: " + self.pers["team"]);
			lastTeam = self.pers["team"];
			if (lastTeam == "streamer")
				self thread PAM_HidePamHUD();
			else
				self thread PAM_ShowPamHUD(fadein);
		}

		wait level.fps_multiplier * 0.25;
	}
}

// Show PAM HUD
PAM_ShowPamHUD(fadein)
{
	if (isDefined(self.pam_hud_visible)) return;
	self.pam_hud_visible = true;

	self.pam_mode = addHUDClient(self, 10, 3, 1.1, game["rules_stringColor"], "left", "top", "left");
	if (fadein) self.pam_mode showHUDSmooth(.5);
	self.pam_mode setText(game["rules_leagueString"]);
	self.pam_mode.archived = false;

	self.pam_mode2 = addHUDClient(self, 10, 17, 0.8, game["rules_stringColor"], "left", "top", "left");
	if (fadein) self.pam_mode2 showHUDSmooth(.5);
	self.pam_mode2 setText(game["rules_formatString"]);
	self.pam_mode2.archived = false;

	self.pam_mode3 = addHUDClient(self, 50, 17, 0.8, game["rules_stringColor"], "left", "top", "left");
	if (fadein) self.pam_mode3 showHUDSmooth(.5);
	self.pam_mode3 setText(game["leagueOptionsString"]);
	self.pam_mode3.archived = false;

	self.pam_version = addHUDClient(self, -20, 25, 1.2, (0.8,1,1), "right", "top", "right");
	if (fadein) self.pam_version showHUDSmooth(.5);
	self.pam_version setText(game["STRING_VERSION_INFO"]);
	self.pam_version.archived = false;
}

// Hide PAM HUD
PAM_HidePamHUD()
{
	self.pam_hud_visible = undefined;

	if (isDefined(self.pam_mode)) self.pam_mode thread destroyHUDSmooth(0.5);
	if (isDefined(self.pam_mode2)) self.pam_mode2 thread destroyHUDSmooth(0.5);
	if (isDefined(self.pam_mode3)) self.pam_mode3 thread destroyHUDSmooth(0.5);
	if (isDefined(self.pam_version)) self.pam_version thread destroyHUDSmooth(0.5);
}


PAM_Header_Delete()
{
	level notify("pam_hud_delete");
}
