#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_spectatefree", "BOOL", 0);
	registerCvar("scr_spectateenemy", "BOOL", 0);
	registerCvar("scr_spectatingsystem", "BOOL", 0);

	addEventListener("onJoinedTeam",    ::onJoinedTeam);
	addEventListener("onSpawned",    ::onSpawned);
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_spectatefree":
			level.scr_spectatefree = value;
			if (!isRegisterTime)
				level thread setSpectatePermissionsToAll();
			return true;

		case "scr_spectateenemy":
			level.scr_spectateenemy = value;
			if (!isRegisterTime)
				level thread setSpectatePermissionsToAll();
			return true;

		case "scr_spectatingsystem":
			if (isRegisterTime)
				level.spectatingSystem = value;
			else
				iprintln("Map needs to be restarted to apply the changes.");
			return true;

	}
	return false;
}

// On player join a team
onJoinedTeam(teamName)
{
	// If new team is selected, update permisions
	self thread setSpectatePermissions();
}

// On player or spectator is spawned
onSpawned(teamName)
{
	// If new team is selected, update permisions
	self thread setSpectatePermissions();
}

// Called when cvar changed
setSpectatePermissionsToAll()
{
	players = getentarray("player", "classname");

	for(i = 0; i < players.size; i++)
		players[i] thread setSpectatePermissions();
}

setSpectatePermissions()
{
	//self iprintln("^5IN setSpectatePermissions() + " + self.sessionteam);

	// Defined on SD if last player is killed and in killcam
	if(isdefined(self.skip_setspectatepermissions) && self.skip_setspectatepermissions == true)
		return;


	if ((self.sessionteam == "none" && level.gametype != "dm") || game["state"] == "intermission") // in dm player is in none team
	{
		self allowSpectateTeam("allies", false);
		self allowSpectateTeam("axis", false);
		self allowSpectateTeam("freelook", false);
		self allowSpectateTeam("none", false);
	}
	else if (self.sessionteam == "allies")
	{
		self allowSpectateTeam("allies", true);
		self allowSpectateTeam("axis", level.scr_spectateenemy);
		self allowSpectateTeam("freelook", level.scr_spectatefree);
		self allowSpectateTeam("none", false);
	}
	else if (self.sessionteam == "axis")
	{
		self allowSpectateTeam("allies", level.scr_spectateenemy);
		self allowSpectateTeam("axis", true);
		self allowSpectateTeam("freelook", level.scr_spectatefree);
		self allowSpectateTeam("none", false);
	}
	else
	{
		// Spectator
		self allowSpectateTeam("allies", true);
		self allowSpectateTeam("axis", true);
		self allowSpectateTeam("freelook", true);
		self allowSpectateTeam("none", true);
	}



}
