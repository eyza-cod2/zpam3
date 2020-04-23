#include maps\mp\gametypes\_callbacksetup;

init()
{
	addEventListener("onJoinedTeam",    ::onJoinedTeam);
    addEventListener("onSpawned",    ::onSpawned);
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


	if (self.sessionteam == "none")
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
