#include maps\mp\gametypes\global\_global;

Init()
{
	game["bots_allow_connect"] = false;

	if (!isDefined(game["bots_connected"]))
		game["bots_connected"] = false;

	if (game["bots_connected"])
		level thread bots_fill_balance();

	addEventListener("onConnecting",    ::onConnecting);
	addEventListener("onConnected",     ::onConnected);
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvarEx("I", "scr_bots_add", "INT", 0, 0, 64); 		// add <num> bots to the server
	registerCvarEx("I", "scr_bots_remove", "INT", 0, 0, 64); 	// remove <num> bots from the server
	registerCvarEx("I", "scr_bots_removeAll", "BOOL", 0);		// remove all bots from server
	registerCvarEx("I", "scr_bots_freeze", "BOOL", 1); 		// freeze bots movement
	registerCvarEx("I", "scr_bots_spam", "FLOAT", 0); 		// periodically connect and disconnect a bot - the value set time cycle in seconds
}


// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_bots_add":
			if (value > 0)
			{
				iprintln("Adding " + value + " bots to the server.");
				thread addBots(value);
				changeCvarQuiet("scr_bots_add", 0);
			}
			return true;


		case "scr_bots_remove":
			if(value > 0) {
				iprintln("Removing " + value + " bots from the server.");
				thread removeBots(value);
				changeCvarQuiet("scr_bots_remove", 0);
			}
			return true;


		case "scr_bots_removeall":
			if(value == 1)
			{
				iprintln("Removing all bots from the server.");
				thread removeBots(64);
				changeCvarQuiet("scr_bots_removeAll", 0);
			}
			return true;

		case "scr_bots_freeze": 		level.bots_freeze = value;		return true;

		case "scr_bots_spam": 			thread spam_bot(value);		return true;

	}
	return false;
}


onConnecting(firstTime)
{
	if (!isDefined(self.pers["isBot"]))
		self.pers["isBot"] = false;
	if (!isDefined(self.pers["isBotCustom"]))
		self.pers["isBotCustom"] = false;

	// When map is changed and bots are present, there is a bug that they stay in connecting state
	// Kick all players with bot prefix to get rid of these bots
	// When bot is added by script, kick needs to be ignored
	if (self isBotName() && self.pers["isBot"] == false && game["bots_allow_connect"] == false)
		kick(self getEntityNumber());
}

onConnected()
{
	// Run thread on bots again
	if (self.pers["isBot"] && self.pers["isBotCustom"] == false)
	{
		self thread bot_think();
	}
}

isBotName()
{
	// Check if suffix is number
	for (i = 0; i < 64; i++)
	{
		if (self.name == "bot"+i) // This player have name as bot
			return true;
	}
	return false;
}

addBot(customLogic)
{
	game["bots_allow_connect"] = true; // addtestclient directly calls OnPlayerConnect

	ent = addtestclient();

	game["bots_allow_connect"] = false;

	if (!isDefined(ent))
		return undefined;

	ent.pers["isBot"] = true; // save its a bot added by script

	// Thread to balance teams
	if (!isDefined(customLogic))
	{
		ent.pers["isBotCustom"] = false; // its a bot spawned by other script

		level thread bots_fill_balance();

		game["bots_connected"] = true;
	}
	else
		ent.pers["isBotCustom"] = true; // its a bot spawned by other script

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

		ent[i] thread bot_think();

		// Spawnout zasebou, ne naráz
		wait level.fps_multiplier * 0.25;
	}
}


removeBot()
{
	userid = self getEntityNumber();

	// For bots only
	if (isDefined(self.botLockPosition))
	{
		self.botLockPosition delete();
	}

	kick(userid);
}


removeBots(number)
{
	players = getentarray("player", "classname");
	kickedBots = 0;
	for(i = 0; i < players.size; i++)
	{
		if (players[i].pers["isBot"])
		{
			players[i] removeBot();

			kickedBots++;
			if (kickedBots >= number)
				break;

			wait level.fps_multiplier * 0.1;
		}
	}
}


spam_bot(value)
{
	level notify("spam_bot");
	level endon("spam_bot");

	// To not spawn bot in frame 0
	wait level.frame;

	if (value > 0)
	{
		while (true)
		{
			if (!isDefined(game["bots_spammer"]))
			{
				game["bots_spammer"] = addBot();
				if (!isDefined(game["bots_spammer"])) // adding failed
					return;
				game["bots_spammer"] thread bot_think();
			}

			wait level.fps_multiplier * value;
			if (isDefined(game["bots_spammer"]))
			{
				game["bots_spammer"] removeBot();
				game["bots_spammer"] = undefined;
			}
			wait level.fps_multiplier * value;
		}
	}
	else
	{
		if (isDefined(game["bots_spammer"]))
		{
			game["bots_spammer"] removeBot();
			game["bots_spammer"] = undefined;
		}
	}
}

bots_fill_balance()
{
	// Make sure only 1 thread is running
	level notify("bots_fill_balance");
	level endon("bots_fill_balance");

	// Wait untill all players/bots are connected
	wait level.fps_multiplier * 1;

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
			if (players[i].pers["isBot"])
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
					if (players[i].pers["team"] == "allies" && players[i].pers["isBot"])
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
					if (players[i].pers["team"] == "axis" && players[i].pers["isBot"])
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

	self thread bot_think_freeze();

	// Wait while client is connected
	while(!isdefined(self.pers["team"]))
		wait level.fps_multiplier * .1;

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



		wait level.fps_multiplier * 0.2;
	}

}

bot_think_freeze()
{
	self endon("disconnect");

	for(;;)
	{
		if (!isDefined(self.botLockPosition))
		{
			self.botLockPosition = spawn("script_model", (0,0,0));
		}

		wait level.fps_multiplier * .25;

		for (;;)
		{
			self enableWeapon();
			self unlink();
			while(!isAlive(self) || !level.bots_freeze)	wait level.fps_multiplier * 1;

			self linkto(self.botLockPosition);
			self disableWeapon();

			while(isAlive(self) && level.bots_freeze)	wait level.fps_multiplier * 1;
		}
	}


}
