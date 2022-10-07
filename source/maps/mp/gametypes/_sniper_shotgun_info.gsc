#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onConnected",             ::onConnected);
}

onConnected()
{
	if ((level.gametype != "sd" && level.gametype != "re") || level.in_readyup)
	{
		self setClientCvarIfChanged("ui_sniper_info", "");
		self setClientCvarIfChanged("ui_shotgun_info", "");
	}
}


// Called only in SD at start and end of the game
updateSniperShotgunHUD()
{
	wait level.frame; // wait untill all players are connected

	for(;;)
	{
		exit = !level.scr_sd_sniper_shotgun_info || (!level.in_strattime && !level.roundended);
		//exit = false;


		allies_sniper = "";
		axis_sniper = "";
		allies_shotgun = "";
		axis_shotgun = "";

		players = getentarray("player", "classname");

		// Get allies sniper
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if(isDefined(player.pers["weapon"]))
			{
				weapon1 = player getweaponslotweapon("primary");
			    	weapon2 = player getweaponslotweapon("primaryb");

				// Name the weapons
				color = "^9";
				if (weapon2 != "none" && !maps\mp\gametypes\_weapons::isPistol(weapon2))
					color = "^2";

				weapon1 = maps\mp\gametypes\_weapons::getWeaponName2(weapon1);
				if (weapon2 == "none" || maps\mp\gametypes\_weapons::isPistol(weapon2))
					weapon2 = "-";
				else
					weapon2 = maps\mp\gametypes\_weapons::getWeaponName2(weapon2);

				// Create HUD text lines
				if (player.sessionstate == "playing")
					text = removeColorsFromString(player.name) + "\n" + color + weapon1 + " / " + weapon2;
				else
					text =  removeColorsFromString(player.name) + "\n" + color + "-";


				if (maps\mp\gametypes\_weapons::isSniper(player.pers["weapon"]))
				{
					if (player.pers["team"] == "allies")
						allies_sniper = text;
					else if (player.pers["team"] == "axis")
						axis_sniper = text;
				}
				else if (maps\mp\gametypes\_weapons::isShotgun(player.pers["weapon"]))
				{
					if (player.pers["team"] == "allies")
						allies_shotgun = text;
					else if (player.pers["team"] == "axis")
						axis_shotgun = text;
				}
			}
		}



		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if (exit)
			{
				player setClientCvarIfChanged("ui_sniper_info", "");
				player setClientCvarIfChanged("ui_shotgun_info", "");
			}
			else
			{
				if (player.pers["team"] == "allies")
				{
					player setClientCvarIfChanged("ui_sniper_info", allies_sniper);
					player setClientCvarIfChanged("ui_shotgun_info", allies_shotgun);
				}
				else if (player.pers["team"] == "axis")
				{
					player setClientCvarIfChanged("ui_sniper_info", axis_sniper);
					player setClientCvarIfChanged("ui_shotgun_info", axis_shotgun);
				}
				else // leaved team
				{
					player setClientCvarIfChanged("ui_sniper_info", "");
					player setClientCvarIfChanged("ui_shotgun_info", "");
				}
			}
		}

		if (exit)
			return;

		wait level.fps_multiplier * 0.5;
	}
}
