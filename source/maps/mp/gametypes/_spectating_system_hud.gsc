#include maps\mp\gametypes\global\_global;

init()
{
	if (!level.spectatingSystem)
		return;

	if(game["firstInit"])
	{
		precacheString2("STRING_SPECTATINGSYSTEM_PRESS_ATTACT_TO_ENABLE", &"Press ^3[{+attack}]^7 to activate spectating system");
		precacheString2("STRING_SPECTATINGSYSTEM_PRESS_ESC_WARNING", &"Press ^3[ESC]^7 to close spectating system\n(binds are not working when spectating system is opened)");
	}

	if (!isDefined(game["spectatingSystem_scoreProgress"]))
		game["spectatingSystem_scoreProgress"] = [];

	level.spectatingSystem_boxesLeft_players = [];
	level.spectatingSystem_boxesRight_players = [];

	addEventListener("onConnected",  	::onConnected);
}

onConnected()
{
	if (!isDefined(self.pers["spectatingSystem_keysVisible"]))
		self.pers["spectatingSystem_keysVisible"] = false;
}

keys_help()
{
	self endon("disconnect");

	self keys_show();

	self endon("spectatingSystem_keysVisible");

	wait level.fps_multiplier * 5;

	self keys_hide();
}

keys_toggle()
{
	// Already hided
	if (!self.pers["spectatingSystem_keysVisible"])
		self keys_show();
	else
		self keys_hide();
}

keys_show()
{
	self.pers["spectatingSystem_keysVisible"] = true;
	self setClientCvar2("ui_spectatorsystem_keys", "1");
	self notify("spectatingSystem_keysVisible", 1);
}

keys_hide()
{
	self.pers["spectatingSystem_keysVisible"] = false;
	self setClientCvar2("ui_spectatorsystem_keys", "0");
	self notify("spectatingSystem_keysVisible", 0);
}




HUD_KeysWelcome_show()
{
	self setClientCvar2("ui_spectatorsystem_keysWelcome", "1");
}

HUD_KeysWelcome_hide()
{
	self setClientCvar2("ui_spectatorsystem_keysWelcome", "0");
}




HUD_ActivateSpectatingSystem_show()
{
	if (!isDefined(self.spectatingSystem_HUD_enableBG))
	{
		self.spectatingSystem_HUD_enableBG = addHUDClient(self, -100, 135, undefined, (1,1,1), "left", "top", "center", "middle");
	    	self.spectatingSystem_HUD_enableBG setShader("black", 200, 20);
		self.spectatingSystem_HUD_enableBG.archived = false;
		//self.spectatingSystem_HUD_enableBG.sort =
	        self.spectatingSystem_HUD_enableBG.alpha = 0.75;
	}
	if (!isDefined(self.spectatingSystem_HUD_enable))
	{
	        self.spectatingSystem_HUD_enable = addHUDClient(self, 0, 141, 0.8, (1,1,1), "center", "top", "center", "middle");
		self.spectatingSystem_HUD_enable.archived = false;
		self.spectatingSystem_HUD_enable setText(game["STRING_SPECTATINGSYSTEM_PRESS_ATTACT_TO_ENABLE"]);
	}

	self HUD_CloseMenuWarning_destroy();
}

HUD_ActivateSpectatingSystem_hide()
{
	if (isDefined(self.spectatingSystem_HUD_enableBG))
	{
		self.spectatingSystem_HUD_enableBG destroy2();
		self.spectatingSystem_HUD_enableBG = undefined;
	}
	if (isDefined(self.spectatingSystem_HUD_enable))
	{
	        self.spectatingSystem_HUD_enable destroy2();
		self.spectatingSystem_HUD_enable = undefined;
	}
}




HUD_CloseMenuWarning_show()
{
	self endon("disconnect");

	self notify("spectatingSystem_HUD_closeMenuWarningBG");
	self endon("spectatingSystem_HUD_closeMenuWarningBG");

	if (!isDefined(self.spectatingSystem_HUD_closeMenuWarningBG))
	{
		self.spectatingSystem_HUD_closeMenuWarningBG = addHUDClient(self, -150, 135, undefined, (1,1,1), "left", "top", "center", "middle");
	    	self.spectatingSystem_HUD_closeMenuWarningBG setShader("black", 300, 23);
		self.spectatingSystem_HUD_closeMenuWarningBG.archived = false;
	}
	if (!isDefined(self.spectatingSystem_HUD_closeMenuWarning))
	{
	        self.spectatingSystem_HUD_closeMenuWarning = addHUDClient(self, 0, 137, 0.8, (1,1,1), "center", "top", "center", "middle");
		self.spectatingSystem_HUD_closeMenuWarning.archived = false;
		self.spectatingSystem_HUD_closeMenuWarning setText(game["STRING_SPECTATINGSYSTEM_PRESS_ESC_WARNING"]);
	}

	self.spectatingSystem_HUD_closeMenuWarning.alpha = 1;

	for (i = 0; i < 3; i++)
	{
		self.spectatingSystem_HUD_closeMenuWarningBG.alpha = 0.75;

		wait level.fps_multiplier * 0.1;
		if (!isDefined(self.spectatingSystem_HUD_closeMenuWarningBG) || !isDefined(self.spectatingSystem_HUD_closeMenuWarning)) return;

		self.spectatingSystem_HUD_closeMenuWarningBG.alpha = 0.5;

		wait level.fps_multiplier * 0.1;
		if (!isDefined(self.spectatingSystem_HUD_closeMenuWarningBG) || !isDefined(self.spectatingSystem_HUD_closeMenuWarning)) return;
	}

	self.spectatingSystem_HUD_closeMenuWarningBG.alpha = 0.75;
	self.spectatingSystem_HUD_closeMenuWarning.alpha = 1;

	wait level.fps_multiplier * 0.5;
	if (!isDefined(self.spectatingSystem_HUD_closeMenuWarningBG) || !isDefined(self.spectatingSystem_HUD_closeMenuWarning)) return;

	self.spectatingSystem_HUD_closeMenuWarningBG FadeOverTime(.5);
	self.spectatingSystem_HUD_closeMenuWarning FadeOverTime(.5);
	self.spectatingSystem_HUD_closeMenuWarningBG.alpha = 0;
	self.spectatingSystem_HUD_closeMenuWarning.alpha = 0;

	wait level.fps_multiplier * .5;

	self HUD_CloseMenuWarning_destroy();
}

HUD_CloseMenuWarning_destroy()
{
	if (isDefined(self.spectatingSystem_HUD_closeMenuWarningBG))
	{
		self.spectatingSystem_HUD_closeMenuWarningBG destroy2();
		self.spectatingSystem_HUD_closeMenuWarningBG = undefined;
	}
	if (isDefined(self.spectatingSystem_HUD_closeMenuWarning))
	{
	        self.spectatingSystem_HUD_closeMenuWarning destroy2();
		self.spectatingSystem_HUD_closeMenuWarning = undefined;
	}

}




hide_player_boxes()
{
	self endon("disconnect");
	self endon("spectatingSystem_bars_updated");

	// Hide from top to bottom
	for (i = 4; i >= 0; i--)
	{
		self setClientCvarIfChanged("ui_spectatingsystem_team1_player"+i+"_health", "");
		self setClientCvarIfChanged("ui_spectatingsystem_team2_player"+i+"_health", "");

		self setClientCvarIfChanged("ui_spectatingsystem_team1_player"+i+"_text", "");
		self setClientCvarIfChanged("ui_spectatingsystem_team2_player"+i+"_text", "");

		self setClientCvarIfChanged("ui_spectatingsystem_team1_player"+i+"_info", "");
		self setClientCvarIfChanged("ui_spectatingsystem_team2_player"+i+"_info", "");

		self setClientCvarIfChanged("ui_spectatingsystem_team1_player"+i+"_icons", "");
		self setClientCvarIfChanged("ui_spectatingsystem_team2_player"+i+"_icons", "");

		//wait level.fps_multiplier * 0.05; // 0.5s total

	}

	wait level.fps_multiplier * 0.2;

	self setClientCvarIfChanged("ui_spectatingsystem_team1_scoreProgress", "");
	self setClientCvarIfChanged("ui_spectatingsystem_team2_scoreProgress", "");

	self setClientCvarIfChanged("ui_spectatingsystem_playerProgress", "");
}


ScoreProgress_AddWinner(winner)
{
	if (!level.spectatingSystem) return;

	teamLeft = "allies";
	teamRight = "axis";

	// If match info is enabled, ensure teams are in correct sides
	if (game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2)
	{
		if (game["match_team1_side"] == "axis")
		{
			teamLeft = "axis";
			teamRight = "allies";
		}
	}

	team = 0; // draw
	if (winner == "allies" && teamLeft == "allies") team = 1; // team left
	if (winner == "allies" && teamRight == "allies") team = 2; // team right
	if (winner == "axis" && teamLeft == "axis") team = 1; // team left
	if (winner == "axis" && teamRight == "axis") team = 2; // team right

	game["spectatingSystem_scoreProgress"][game["spectatingSystem_scoreProgress"].size] = team;
}

ScoreProgress_AddHalftime()
{
	if (!level.spectatingSystem) return;
	game["spectatingSystem_scoreProgress"][game["spectatingSystem_scoreProgress"].size] = 3; // halftime
}

ScoreProgress_AddTimeout()
{
	if (!level.spectatingSystem) return;
	game["spectatingSystem_scoreProgress"][game["spectatingSystem_scoreProgress"].size] = 4; // timeout
}

ScoreProgress_AddOvertime()
{
	if (!level.spectatingSystem) return;
	game["spectatingSystem_scoreProgress"][game["spectatingSystem_scoreProgress"].size] = 5; // overtime
}



HUD_PlayerBoxes_Loop()
{
	self endon("disconnect");

	wait level.frame;

	teamLeft = "allies";
	teamRight = "axis";

	// If match info is enabled, ensure teams are in correct sides
	if (game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2)
	{
		if (game["match_team1_side"] == "axis")
		{
			teamLeft = "axis";
			teamRight = "allies";
		}
	}


	for(;;)
	{
		wait level.fps_multiplier * 0.1;

		if (self.pers["team"] == "streamer")
		{
			// Hide for a while
			if (isDefined(self.killcam) || level.in_readyup || game["state"] == "intermission") // readyup in case timeout is called
			{
				self thread hide_player_boxes();
				continue;
			}


			if (game["spectatingSystem_scoreProgress"].size > 0)
			{
				str = "";
				for (i = 0; i < game["spectatingSystem_scoreProgress"].size; i++)
				{
					code = game["spectatingSystem_scoreProgress"][i];
					if (code == 0) // Draw
						str += "^7-";
					else if (code == 1) // team left winner
					{
						if (teamLeft == "allies") str += "^4#"; // blue
						if (teamLeft == "axis") str += "^1#"; // red
					}
					else if (code == 2) // team right winner
					{
						if (teamRight == "allies") str += "^4#"; // blue
						if (teamRight == "axis") str += "^1#"; // red
					}
					else if (code == 3) // halftime
					{
						str += "^7|";
					}
					else if (code == 4) // timeout
					{
						str += "^7[T]";
					}
					else if (code == 5) // overtime
					{
						str += "^7 [O] ";
					}

				}

				self notify("spectatingSystem_bars_updated");
				self setClientCvarIfChanged("ui_spectatingsystem_team1_scoreProgress", "Score progress:");
				self setClientCvarIfChanged("ui_spectatingsystem_team2_scoreProgress", str);
			}



			playerProgress = "";
			if (level.gametype == "sd" && isDefined(level.player_alive_history) && level.player_alive_history != "")
				playerProgress = "Players:" + level.player_alive_history;

			self notify("spectatingSystem_bars_updated");
			self setClientCvarIfChanged("ui_spectatingsystem_playerProgress", playerProgress);





			level.spectatingSystem_boxesLeft_players = getPlayersByTeam(teamLeft);
			level.spectatingSystem_boxesRight_players = getPlayersByTeam(teamRight);

			// Fill bars
			for(r = 0; r < 5; r++)
			{
				if (r < level.spectatingSystem_boxesLeft_players.size)
					self fill_box(r, "left", teamLeft, level.spectatingSystem_boxesLeft_players[r]);
				else
					self unfill_box(r, "left");

				if (r < level.spectatingSystem_boxesRight_players.size)
					self fill_box(r, "right", teamRight, level.spectatingSystem_boxesRight_players[r]);
				else
					self unfill_box(r, "right");
			}

		}
		else
		{
			// Player left spectators
			// Hide hud elements
			self thread hide_player_boxes();
			return;
		}
	}
}


followPlayerByNum(num)
{
	if (num < 1 || num > 10) return;

	player = undefined;
	if (num >= 1 && num <= 5)
	{
		if ((num - 1) < level.spectatingSystem_boxesLeft_players.size)
			player = level.spectatingSystem_boxesLeft_players[num - 1];
	}

	if (num >= 6 && num <= 10)
	{
		if ((num - 6) < level.spectatingSystem_boxesRight_players.size)
			player = level.spectatingSystem_boxesRight_players[num - 6];
	}

	if (isDefined(player))
	{
		if (player.sessionstate == "playing")
		{
			level maps\mp\gametypes\_spectating_system::followPlayer(player);
			level maps\mp\gametypes\_spectating_system_auto::lockFor(30000); // Lock selected player for 30 secods
			self iprintln("Follow player " + num/* + ": " + player.name*/);
		}
		else
			self iprintln("^3Player " + num + " is not alive");
	}
	else
		self iprintln("^3Player " + num + " does not exists");
}


getPlayersByTeam(teamname)
{
	playersFiltered = [];
	index = 0;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (!isDefined(teamname) || player.pers["team"] == teamname)
		{
			playersFiltered[index] = player;
			index++;
		}
	}

	// Sort and return
	return playersFiltered;
}


fill_box(index, barSide, teamname, player)
{
	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";

	health = "";
	// Because health is showed via menu elements, the health bar is splited only into a few sizes
	// So according to helth we select most corresponding size
	if (player.health <= 0)
		health =  "0";

	else if (player.health < 20)
		health =  "10";

	else if (player.health < 70)
		health =  "50";

	else if (player.health < 99)
		health =  "80";

	else
		health =  "100";

	// Health also contains apended info about color
	if (player.health > 0)
	{
	      	if (teamname == "allies")
			health = health + "_blue";
		else
			health = health + "_red";
	}


	if (self.spectatingSystem_turnedOn && isDefined(level.spectatingSystem_player) && player == level.spectatingSystem_player)
	{
		health = health + "_"; // underscore means this player is followed and rectangle around player box is showed
	}



	// Number of player
	keyNum = "";
	if (self.pers["spectatingSystem_keysVisible"])
	{
		if (barSide == "left")	keyNum = "" + (index + 1) + "|  ";
		else if (index == 4)	keyNum = "0|  "; // 10
		else			keyNum = "" + (index + 6) + "|  ";
	}

	// Weapon names
	weapon1 = player getweaponslotweapon("primary");
    	weapon2 = player getweaponslotweapon("primaryb");
	weapon1 = maps\mp\gametypes\_weapons::getWeaponName2(weapon1);
	weapon2 = maps\mp\gametypes\_weapons::getWeaponName2(weapon2);
	if (weapon2 == "none")
		weapon2 = "-";
	weapon_text = "";
	if (player.health > 0)
		weapon_text = weapon1 + " / " + weapon2;



	/* Icons
	Combinations:
		"" 		- no icons
		"grenade" 	- show grenade icon
		"grenade2" 	- show multi-grenade icons
		"smoke" 	- show smoke icon
		"grenade_smoke" - show grenade and smoke icons
		"grenade2_smoke" - show multi-grenade and smoke icons
	*/
	icons = "";
	if (player.health > 0)
	{
		grenades = player maps\mp\gametypes\_weapons::getFragGrenadeCount();
		smokes = player maps\mp\gametypes\_weapons::getSmokeGrenadeCount();

		if (grenades >= 2)
			icons += "grenade2";
		else if (grenades == 1)
			icons += "grenade";

		if (smokes > 0)
		{
			if (icons != "")
				icons += "_";
			icons += "smoke";
		}
	}


	self notify("spectatingSystem_bars_updated");
	self setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_health", 	health);
	self setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_text", 	keyNum + player.name);
	self setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_info", 	player.score + " / " + player.deaths + "        " + weapon_text);
	self setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_icons", 	icons);
}


unfill_box(index, barSide)
{
	teamNum = "1";
	if (barSide == "right")
		teamNum = "2";

	// Text does not need to be updated, because is hided automatically if healht is empty
	//setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_text", "");

	self notify("spectatingSystem_bars_updated");
	self setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_health", "");
	self setClientCvarIfChanged("ui_spectatingsystem_team"+teamNum+"_player"+index+"_icons", "");
}
