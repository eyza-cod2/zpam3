#include maps\mp\gametypes\_callbacksetup;

init()
{
    addEventListener("onConnected",     ::onConnected);
}


// This function is called as last from all onConnected functions
onConnected()
{

	// Here deal with spawns when new round starts or player connect


	// If pam is not installed correctly, spawn outside
	if (!maps\mp\gametypes\_pam::isInstalledCorrectly() || game["pbsv_not_loaded"])
		[[level.spawnSpectator]]((999999, 999999, -999999), (90, 0, 0)); // Spawn spectator outside map

	// Mod is not downloaded
	else if (self maps\mp\gametypes\_force_download::modIsNotDownloadedForSure())
		self maps\mp\gametypes\_force_download::spawnModNotDownloaded();

	// If the game is at the post game state (scoreboard) the connecting player should spawn into intermission
	else if (game["state"] == "intermission")
		[[level.spawnIntermission]]();

	// If player is just connected and blackout needs to be activated
	else if (self.pers["team"] == "none")
	{
		if (self maps\mp\gametypes\_blackout::isBlackoutNeeded())
			self maps\mp\gametypes\_blackout::spawnBlackout();
		else
			[[level.spawnSpectator]](); // spawn spec but no movement
	}

	// Spectator team
	else if (self.pers["team"] == "spectator")
		[[level.spawnSpectator]]();

	// If team is selected
	else if (self.pers["team"] == "allies" || self.pers["team"] == "axis")
	{
		// If player have choozen weapon
		if(isDefined(self.pers["weapon"]))
			[[level.spawnPlayer]]();
		// If player have choosen team, but have not choosen weapon (he is selecting from weapons menu)
		else
			[[level.spawnSpectator]]();
	}

	else
		assertMsg("Unknown team");

		//[[level.spawnSpectator]]((999999, 999999, -999999), (90, 0, 0)); // Spawn spectator outside map








}
