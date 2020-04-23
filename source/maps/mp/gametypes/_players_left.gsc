#include maps\mp\gametypes\_callbacksetup;

init()
{
    if (!level.scr_show_players_left)
		return;

	if (level.in_readyup || level.in_timeout)
		return;

    level.axis_alive = 0;
	level.allies_alive = 0;

    addEventListener("onConnected",             ::onConnected);

    // Updating score:
    addEventListener("onDisconnect",            ::onDisconnect);
    addEventListener("onPlayerKilled",          ::onPlayerKilled);
    addEventListener("onSpawned",               ::onSpawned);

    // Remove Playersleft when timeout is called on sd
    if (level.gametype == "sd")
        level thread onTimeoutCalled();
}

onConnected()
{
    // If timeout was called in strattime, dont show players left
    if (level.gametype == "sd" && level.in_timeout)
        return;

    if (!isDefined(self.playersLeftVisible))
        self.playersLeftVisible = false;

    if (!self.playersLeftVisible)
        self thread createHUD();
}

onDisconnect()
{
	level thread updatePlayersCount();
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	level thread updatePlayersCount();
}

onSpawned()
{
	level thread updatePlayersCount();
}

onTimeoutCalled()
{
	level waittill("running_timeout");

    deleteHUD();
}



createHUD()
{
    self endon("disconnect");

    self.playersLeftVisible = true;

    self.teamleftnum = maps\mp\gametypes\_hud_system::addHUDClient(self, -280, 479, 1.2, undefined, "right", "bottom", "right");
    self.teamleft = maps\mp\gametypes\_hud_system::addHUDClient(self, -275, 479, 1.2, undefined, "left", "bottom", "right");

    self.enemyleftnum = maps\mp\gametypes\_hud_system::addHUDClient(self, -190, 479, 1.2, undefined, "right", "bottom", "right");
    self.enemyleft = maps\mp\gametypes\_hud_system::addHUDClient(self, -185, 479, 1.2, undefined, "left", "bottom", "right");

    // Keep updating count and color
    for (;;)
    {
        if (self.pers["team"] == "axis")
        {
            self.teamleft setText(game["axis_hud_text"]);
            self.teamleftnum setValue(level.axis_alive);
    		self.enemyleft setText(game["allies_hud_text"]);
            self.enemyleftnum setValue(level.allies_alive);
        }
    	else // allies or spectator
        {
            self.teamleft setText(game["allies_hud_text"]);
            self.teamleftnum setValue(level.allies_alive);
    		self.enemyleft setText(game["axis_hud_text"]);
            self.enemyleftnum setValue(level.axis_alive);
        }

        if (self.pers["team"] == "spectator")
        {
            self.teamleft.color = (1,1,1);
            self.teamleftnum.color = (1,1,1);
    		self.enemyleft.color = (1,1,1);
            self.enemyleftnum.color = (1,1,1);
        }
        else
        {
            self.teamleft.color = (.580,.961,.573);
            self.teamleftnum.color = (.580,.961,.573);
    		self.enemyleft.color = (.055,.855,.996);
            self.enemyleftnum.color = (.055,.855,.996);
        }

        level waittill("playersleft_update_hud", remove);

        if (remove)
        {
            self.teamleft maps\mp\gametypes\_hud_system::removeHUD();
            self.teamleftnum maps\mp\gametypes\_hud_system::removeHUD();
    		self.enemyleft maps\mp\gametypes\_hud_system::removeHUD();
            self.enemyleftnum maps\mp\gametypes\_hud_system::removeHUD();

            return;
        }
    }
}

updateHUD()
{
    level notify("playersleft_update_hud", false);
}

deleteHUD()
{
    level notify("playersleft_update_hud", true);
}



updatePlayersCount()
{
    wait level.frame; // wait a frame to process a player disconnection

    // If timeout was called in strattime, dont update
    if (level.gametype == "sd" && level.in_timeout)
        return;

	allied_alive = 0;
	axis_alive = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(player.pers["team"] != "spectator" && player.pers["team"] != "none" && player.sessionstate == "playing")
		{
			if(player.pers["team"] == "allies")
				allied_alive++;
			else if(player.pers["team"] == "axis")
				axis_alive++;
		}
	}

	level.axis_alive = axis_alive;
	level.allies_alive = allied_alive;

    // Update HUD to all players
    updateHUD();
}
