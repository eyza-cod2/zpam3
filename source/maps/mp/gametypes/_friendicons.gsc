#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_drawfriend", "BOOL", 1); 	  // Draws a team icon over teammates // NOTE: restart needed

	if(!level.scr_drawfriend)
		return;

	// Register events
	addEventListener("onStartGameType", ::onStartGameType);
	addEventListener("onSpawnedPlayer", ::onSpawnedPlayer);
	addEventListener("onPlayerKilled",  ::onPlayerKilled);
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_drawfriend": level.scr_drawfriend = value; return true;
	}
	return false;
}



// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	if(game["firstInit"])
	{
		// Draws a team icon over teammates
		switch(game["allies"])
		{
			case "american":
				game["headicon_allies"] = "headicon_american";
				precacheHeadIcon(game["headicon_allies"]);
				break;

			case "british":
				game["headicon_allies"] = "headicon_british";
				precacheHeadIcon(game["headicon_allies"]);
				break;

			case "russian":
				game["headicon_allies"] = "headicon_russian";
				precacheHeadIcon(game["headicon_allies"]);
				break;
		}

		game["headicon_axis"] = "headicon_german";
		precacheHeadIcon(game["headicon_axis"]);
	}
}




onSpawnedPlayer()
{
	// Show friend icon
	if(self.pers["team"] == "allies")
	{
		self.headicon = game["headicon_allies"];
		self.headiconteam = "allies";
	}
	else
	{
		self.headicon = game["headicon_axis"];
		self.headiconteam = "axis";
	}
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self.headicon = "";
	self.headiconteam = "none";
}
