#include maps\mp\gametypes\_callbacksetup;
#include maps\mp\gametypes\_cvar_system;

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

    if (!isDefined(self.playersLeftCreated))
        self.playersLeftCreated = false;

    if (!self.playersLeftCreated)
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

  players = getentarray("player", "classname");
  for(i = 0; i < players.size; i++)
	{
		player = players[i];
    player deleteHUD();
	}
}



createHUD()
{
    self endon("disconnect");

    self.playersLeftCreated = true;

    self.teamleftnum = maps\mp\gametypes\_hud_system::addHUDClient(self, -280, 479, 1.2, undefined, "right", "bottom", "right");
    self.teamleft = maps\mp\gametypes\_hud_system::addHUDClient(self, -275, 479, 1.2, undefined, "left", "bottom", "right");

    self.enemyleftnum = maps\mp\gametypes\_hud_system::addHUDClient(self, -190, 479, 1.2, undefined, "right", "bottom", "right");
    self.enemyleft = maps\mp\gametypes\_hud_system::addHUDClient(self, -185, 479, 1.2, undefined, "left", "bottom", "right");
}

updateHUD()
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
}

deleteHUD()
{
    if (self.playersLeftCreated)
    {
      self.teamleft maps\mp\gametypes\_hud_system::removeHUD();
      self.teamleftnum maps\mp\gametypes\_hud_system::removeHUD();
      self.enemyleft maps\mp\gametypes\_hud_system::removeHUD();
      self.enemyleftnum maps\mp\gametypes\_hud_system::removeHUD();
    }
}



updatePlayersCount()
{
  // This will make sure this function is called only once in single frame
  level notify("playersleft_update");
  level endon("playersleft_update");

  wait level.frame; // wait a frame to process a player disconnection

  // If timeout was called in strattime, dont update
  if (level.gametype == "sd" && level.in_timeout)
      return;

	allied_alive = 0;
	axis_alive = 0;

  allies_names = [];
  axis_names = [];

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(player.pers["team"] != "spectator" && player.pers["team"] != "none" && player.sessionstate == "playing")
		{
			if(player.pers["team"] == "allies")
      {
				allied_alive++;
        allies_names[allies_names.size] = player.name;
      }
			else if(player.pers["team"] == "axis")
      {
				axis_alive++;
        axis_names[axis_names.size] = player.name;
      }
		}
	}

  // TODO clear
  //level thread updateNickNames(allies_names, axis_names);

	level.axis_alive = axis_alive;
	level.allies_alive = allied_alive;

  // Update HUD to all players
  for(i = 0; i < players.size; i++)
	{
		player = players[i];
    player updateHUD();
	}

}

// TODO clear
/*
updateNickNames(allies_names, axis_names)
{
  players = getentarray("player", "classname");
  for(i = 0; i < players.size; i++)
  {
    player = players[i];

    if(isAlive(player))
    {
      player updatePlayerList(allies_names, axis_names);
    }
  }

  wait level.frame;

  for(i = 0; i < players.size; i++)
  {
    player = players[i];

    if(!isAlive(player))
    {
      player updatePlayerList(allies_names, axis_names);
    }
  }
}

updatePlayerList(allies_names, axis_names)
{
  team1_name = "team1";
  team2_name = "team2";
  if (self.pers["team"] == "axis")
  {
    team1_name = "team2";
    team2_name = "team1";
  }

  for (i = 0; i < 5; i++)
  {
    if (i < allies_names.size)
      self setClientCvarIfChanged("ui_playersleft_"+team1_name+"_line"+i, allies_names[i]);
    else
      self setClientCvarIfChanged("ui_playersleft_"+team1_name+"_line"+i, "");
  }
  for (i = 0; i < 5; i++)
  {
    if (i < axis_names.size)
      self setClientCvarIfChanged("ui_playersleft_"+team2_name+"_line"+i, axis_names[i]);
    else
      self setClientCvarIfChanged("ui_playersleft_"+team2_name+"_line"+i, "");
  }


}
*/
