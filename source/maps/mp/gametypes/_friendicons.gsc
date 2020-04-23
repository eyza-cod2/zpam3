#include maps\mp\gametypes\_callbacksetup;

init()
{
	if(!level.scr_drawfriend)
		return;

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

	// Register events
    addEventListener("onSpawnedPlayer", ::onSpawnedPlayer);
    addEventListener("onPlayerKilled",   		::onPlayerKilled);
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
