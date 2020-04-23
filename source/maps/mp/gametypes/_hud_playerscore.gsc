#include maps\mp\gametypes\_callbacksetup;

// Used for deathmatch

init()
{
	switch(game["allies"])
	{
	case "american":
		game["hudicon_allies"] = "hudicon_american";
		break;

	case "british":
		game["hudicon_allies"] = "hudicon_british";
		break;

	case "russian":
		game["hudicon_allies"] = "hudicon_russian";
		break;
	}

	assert(game["axis"] == "german");
	game["hudicon_axis"] = "hudicon_german";

	precacheShader(game["hudicon_allies"]);
	precacheShader(game["hudicon_axis"]);
	precacheString(&"MP_SLASH");


    addEventListener("onConnected",     	::onConnected);
    addEventListener("onJoinedAlliesAxis",  ::onJoinedAlliesAxis);
    addEventListener("onJoinedSpectator",   ::onJoinedSpectator);

	level thread onUpdateAllHUD();
}

onConnected()
{
	self.hud_playericon = newClientHudElem(self);
    self.hud_playericon.horzAlign = "left";
    self.hud_playericon.vertAlign = "top";
    self.hud_playericon.x = 6;
    self.hud_playericon.y = 28;
    self.hud_playericon.archived = false;
    self.hud_playericon.alpha = 0;

    self.hud_playerscore = newClientHudElem(self);
    self.hud_playerscore.horzAlign = "left";
    self.hud_playerscore.vertAlign = "top";
    self.hud_playerscore.x = 36;
    self.hud_playerscore.y = 26;
    self.hud_playerscore.font = "default";
    self.hud_playerscore.fontscale = 2;
    self.hud_playerscore.archived = false;
    self.hud_playerscore.alpha = 0;

    self.hud_playerscorelimit = newClientHudElem(self);
    self.hud_playerscorelimit.horzAlign = "left";
    self.hud_playerscorelimit.vertAlign = "top";
	self.hud_playerscorelimit.x = 49;
    self.hud_playerscorelimit.y = 26;
    self.hud_playerscorelimit.font = "default";
    self.hud_playerscorelimit.fontscale = 2;
    self.hud_playerscorelimit.archived = false;
    self.hud_playerscorelimit.alpha = 0;

	//WORM
	if (level.scr_show_scoreboard_limit)
		self.hud_playerscorelimit.label = (&"MP_SLASH");

	self.hidescore = true;

	self thread onUpdatePlayerHUD();
}

onJoinedAlliesAxis()
{
	self thread updatePlayerHUD();
}

onJoinedSpectator()
{
	self thread updatePlayerHUD();
}

onUpdatePlayerHUD()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("update_playerhud_score");

		self thread updatePlayerHUD();
	}
}

onUpdateAllHUD()
{
	for(;;)
	{
		self waittill("update_allhud_score");

		level thread updateAllHUD();
	}
}

updatePlayerHUD()
{
	if(isdefined(self.pers["team"]))
	{
		hudicon["allies"] = game["hudicon_allies"];
		hudicon["axis"] = game["hudicon_axis"];

		if(self.pers["team"] == "allies" || self.pers["team"] == "axis")
		{
			self.hud_playericon setShader(hudicon[self.pers["team"]], 24, 24);
		    self.hud_playericon.alpha = 1;
			self.hud_playerscore setValue(self.score);
		    self.hud_playerscore.alpha = 1;

			if(level.scorelimit > 0 && level.scr_show_scoreboard_limit)
			{
				self.hud_playerscorelimit setValue(level.scorelimit);
				self.hud_playerscorelimit.x = getScoreLimitPosition(self.score);
				self.hud_playerscorelimit.alpha = 1;
			}
			else if (level.scr_show_scoreboard_limit)
				self.hud_playerscorelimit.alpha = 0;
		}
		else if(self.pers["team"] == "spectator")
		{
		    self.hud_playericon.alpha = 0;
		    self.hud_playerscore.alpha = 0;
		    self.hud_playerscorelimit.alpha = 0;
		}
	}
}

updateAllHUD()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] thread updatePlayerHUD();
}

getScoreLimitPosition(score)
{
	offset = 0;

	if(score < 0)
	{
		score = score * -1;
		offset = 7;
	}

	if(score >= 10000)
		offset += 48;
	else if(score >= 1000)
		offset += 36;
	else if(score >= 100)
		offset += 24;
	else if(score >= 10)
		offset += 12;

	return 49 + offset;
}
