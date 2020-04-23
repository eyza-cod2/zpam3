#include maps\mp\gametypes\_callbacksetup;

Init()
{
	level thread bots_add();
	level thread bots_remove();
	level thread bots_removeAll();
	level thread bots_autoFill();

	addEventListener("onConnecting",    ::onConnecting);
    addEventListener("onConnected",     ::onConnected);

}

/*
scr_bots_add <num>   // add <num> bots to the server
scr_bots_remove <num>  // number of bots to remove
scr_bots_removeAll = 1

scr_bots_fillEnabled = 1 	// fill the server with bots automaticly up to limit
scr_bots_fillMaxBots = 6
scr_bots_fillAutoBalance = 1

*/

onConnecting()
{
	// If player have name bot1 or this is a testclient from previous map
	if (self checkBot())
	{
		kick(self getEntityNumber());
	}
}

onConnected()
{
	// Run again bots script
	if (isDefined(self.pers["isTestClient"]))
		self thread bot_think();
}

isBot()
{
	// Check if suffix is number
	for (i = 0; i < 64; i++)
	{
		if (self.name == "bot"+i)
		{
			// This player have name as bot (kick him)
			return true;
		}
	}
	return false;
}

checkBot()
{
	// This is original bot
	if (isDefined(self.pers["isTestClient"]))
		return false;

	// Bots are enabled (script is adding new bots at the moment)
	if (isDefined(game["allow_bots"]) && game["allow_bots"] == true)
		return false;

	// Check if suffix is number
	if (self isBot())
		return true;

	return false;
}

addBot()
{
	// Allow connecting players with name bot<number> in onPlayerConnect
	game["allow_bots"] = true;

	ent = addtestclient();

	if (!isDefined(ent))
		return undefined;

	ent.pers["modDownloaded"] = true; // to prevent showing warning message mod is not downloaded

	return ent;
}

addBots(number)
{
	for(i = 0; i < number; i++)
	{
		ent[i] = addBot();

		// Maximum number of clients reached
		if (!isDefined(ent[i]))
		{
			iprintln("Adding bot failed. (server restart is needed)");
			break;
		}

		ent[i].pers["isTestClient"] = true; // run think func when player connect after map_restart
		ent[i] thread bot_think();

		// Spawnout zasebou, ne naráz
		wait level.fps_multiplier * 0.25;
	}

	game["allow_bots"] = false;
}


removeBots(number)
{
	players = getentarray("player", "classname");
	kickedBots = 0;
	for(i = 0; i < players.size; i++)
	{
		if (isDefined(players[i].pers["isTestClient"]))
		{
			userid = players[i] getEntityNumber();
			kick(userid);

			kickedBots++;
			if (kickedBots >= number)
				break;

			wait level.fps_multiplier * 0.1;
		}
	}
}


bots_add()
{
	for(;;)
	{
		wait level.fps_multiplier * 1;

		testclients = getCvarInt("scr_bots_add");
		if(testclients > 0) {
			setCvar("scr_bots_add", 0);

			iprintln("Adding " + testclients + " bots to the server.");

			addBots(testclients);
		}
	}
}

bots_removeAll()
{
	for(;;)
	{
		wait level.fps_multiplier * 1;

		removeAll = getCvarInt("scr_bots_removeAll");
		if(removeAll == 1) {
			setCvar("scr_bots_removeAll", 0);

			iprintln("Removing all bots from the server.");

			removeBots(64);
		}
	}
}

bots_remove()
{
	for(;;)
	{
		wait level.fps_multiplier * 1;

		testclients = getCvarInt("scr_bots_remove");
		if(testclients > 0) {
			setCvar("scr_bots_remove", 0);

			iprintln("Removing " + testclients + " bots from the server.");

			removeBots(testclients);
		}
	}
}

bots_autoFill()
{
	// Wait untill all players/bots are connected
	wait level.fps_multiplier * 1;

	level thread bots_fill_balance();

	for (;;)
	{
		if (level.bots_fillEnabled)
		{

			players = getentarray("player", "classname");
			bots_count = 0;
			players_count = 0;
			for(i = 0; i < players.size; i++)
			{
				// This player is bot
				if (isDefined(players[i].pers["isTestClient"]))
				{
					bots_count++;
					continue;
				}

				// This player is normal and is in team
				if((players[i].pers["team"] == "allies" || players[i].pers["team"] == "axis"))
					players_count++;
			}

			botsToAdd = (level.bots_fillMaxBots - players_count) - bots_count;

			if (botsToAdd > 0)
				addBots(botsToAdd);
			//else if (botsToAdd < 0)
				//removeBots(botsToAdd*-1);

		}

		wait level.fps_multiplier * 2;
	}
}

bots_fill_balance()
{
	for (;;)
	{
		players = getentarray("player", "classname");
		allies_bots = 0;
		allies_players = 0;
		axis_bots = 0;
		axis_players = 0;
		for(i = 0; i < players.size; i++)
		{
			// This player is bot
			if (isDefined(players[i].pers["isTestClient"]))
			{
				if (players[i].pers["team"] == "allies")
					allies_bots++;
				else
					axis_bots++;
				continue;
			}

			// This player is normal and is in team
			if(players[i].pers["team"] == "allies")
				allies_players++;
			else if (players[i].pers["team"] == "axis")
				axis_players++;
		}

		allies = allies_bots + allies_players;
		axis = axis_bots + axis_players;

		diff = allies - axis;
		if (diff < 0)
			diff *= -1;

		if (diff >= 2)
		{
			if (allies > axis && allies_bots > 0)
			{
				moved_count = 0;
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					if (players[i].pers["team"] == "allies" && isDefined(players[i].pers["isTestClient"]))
					{
						players[i] [[level.axis]]();

						moved_count++;
						if (moved_count >= diff-1)
							break;
					}
				}
			}
			else if (axis > allies && axis_bots > 0)
			{
				moved_count = 0;
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					if (players[i].pers["team"] == "axis" && isDefined(players[i].pers["isTestClient"]))
					{
						players[i] [[level.allies]]();

						moved_count++;
						if (moved_count >= diff-1)
							break;
					}
				}
			}
		}

		wait level.fps_multiplier * 2;
	}
}




bot_think()
{
	self endon("disconnect");

	wait level.fps_multiplier * 0.1;

	// Wait while client is connected
	while(!isdefined(self.pers["team"]))
		wait level.fps_multiplier * .2;

	for (;;)
	{
		if (self.pers["team"] != "allies" && self.pers["team"] != "axis")
		{
			// Select team
			self notify("menuresponse", game["menu_team"], "autoassign");
			wait level.fps_multiplier * 0.2;
		}

		if (!isDefined(self.pers["weapon"]))
		{
			// Select weapon
			if(self.pers["team"] == "allies")
				self notify("menuresponse", game["menu_weapon_allies"], "random");
			else if(self.pers["team"] == "axis")
				self notify("menuresponse", game["menu_weapon_axis"], "random");

			wait level.fps_multiplier * 0.2;
		}

		wait level.fps_multiplier * 3;
	}

}
