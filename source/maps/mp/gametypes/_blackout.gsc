#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_blackout", "BOOL", 0);


	if (game["firstInit"])
	{
		precacheString2("STRING_BLACKOUT_PROTECTION", &"Blackout Protection");
		precacheString2("STRING_BLACKOUT_INFO", &"You see this map background because match is in progress.");

		//precacheStatusIcon("icon_blackout"); // removed due to max 8 precached status icons for streamers icon
	}

	addEventListener("onConnected",     ::onConnected);
	addEventListener("onJoinedTeam",    ::onJoinedTeam);
}


// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_blackout": level.scr_blackout = value; return true;
	}
	return false;
}


onConnected()
{
    // Default variables for each player
    self.in_blackout = false;

	// Make sure cvar is on 0 as default
	self setClientCvar2("ui_blackout", "0");
}


onJoinedTeam(teamName)
{
    // Player selects team, remove blackout
    if (self.in_blackout)
        self removeBlackout();
}


isBlackoutNeeded()
{
    // Specify situatins when blackout is not needed
    // Not needed in:   Readyup (without timeout)                  In timeout when SD
    no_blackout =       (level.in_readyup && !level.in_timeout) || (level.in_timeout && level.gametype == "sd");

    return level.scr_blackout && !no_blackout;
}

spawnBlackout()
{
	// Spawn spectator outside map
    [[level.spawnSpectator]]((999999, 999999, -999999), (90, 0, 0));

	// Special icon for player in "none" team
	//self.statusicon = "icon_blackout";

	// Shows map background
    self setClientCvar2("ui_blackout", "1");

	// Show player in none team
	self showWarningMessage();

	self.in_blackout = true;
}


showWarningMessage()
{
    if (!isDefined(self.blackout_bg))
    {
		self.blackout_bg = newClientHudElem2(self);
		self.blackout_bg.horzAlign = "center_safearea"; //
		self.blackout_bg.vertAlign = "center_safearea"; // subtop top middle bottom fullscreen noscale alignto480 center_safearea
		self.blackout_bg.alignx = "center";
		self.blackout_bg.aligny = "middle";
		self.blackout_bg.alpha = 1.0;
		self.blackout_bg.color = (1, 1, 1);
		self.blackout_bg.sort = -9999999;
		self.blackout_bg.foreground = false;
		self.blackout_bg setShader("$levelBriefing", 896, 480);

		self.blackout_info1 = newClientHudElem2(self);
		self.blackout_info1.alignx = "center";
		self.blackout_info1.aligny = "top";
		self.blackout_info1.x = 320;
		self.blackout_info1.y = 150;
		self.blackout_info1.fontscale = 1.8;
		self.blackout_info1.alpha = 1;
		self.blackout_info1.sort = -2;
		self.blackout_info1.color = (1, 1, 0);
		self.blackout_info1.foreground = true;
		self.blackout_info1 SetText(game["STRING_BLACKOUT_PROTECTION"]);

		self.blackout_info2 = newClientHudElem2(self);
		self.blackout_info2.alignx = "center";
		self.blackout_info2.aligny = "top";
		self.blackout_info2.x = 320;
		self.blackout_info2.y = 172;
		self.blackout_info2.fontscale = 1.4;
		self.blackout_info2.alpha = 1;
		self.blackout_info2.sort = -1;
		self.blackout_info2.color = (1, 1, 0);
		self.blackout_info2.foreground = true;
		self.blackout_info2 SetText(game["STRING_BLACKOUT_INFO"]);
    }
}

removeBlackout()
{
	//if (self.statusicon == "icon_blackout")
		//self.statusicon = "";

    self setClientCvar2("ui_blackout", "0");

	self.in_blackout = false;

    if (isDefined(self.blackout_bg))
        self.blackout_bg destroy2();
    if (isDefined(self.blackout_info1))
        self.blackout_info1 destroy2();
    if (isDefined(self.blackout_info2))
        self.blackout_info2 destroy2();
}
