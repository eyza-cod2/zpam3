#include maps\mp\gametypes\global\_global;

init()
{
	game["STRING_AUTO_SPECT_IS_ENABLED"] =  "Auto-spectator is ^2Enabled";
	game["STRING_AUTO_SPECT_IS_DISABLED"] = "Auto-spectator is ^1Disabled";

	if(game["firstInit"])
	{
		precacheString2("STRING_AUTO_SPECTATING", &"Auto-spectating");
		precacheString2("STRING_AUTO_SPECTATOR_KEY1", &"Press ^3[{+attack}]^7 to disable auto-spectator");
		precacheString2("STRING_AUTO_SPECTATOR_KEY2", &"Hold ^3[{+attack}]^7 to enable auto-spectator");
		precacheString2("STRING_AUTO_SPECTATOR_KEY3", &"Press ^3[{+activate}]^7 to play killcam");
	}


	level.autoSpectating_do = false;
	level.autoSpectating_forceTime = 0;

	if (!level.spectatingSystem)
		return;

	thread checkSpectatorTeam();

	addEventListener("onConnected",  ::onConnected);
	addEventListener("onSpawnedSpectator",  ::onSpawnedSpectator);
}

onConnected()
{
	if (!isDefined(self.pers["autoSpectating"]))
		self.pers["autoSpectating"] = false;
	if (!isDefined(self.pers["autoSpectatingID"]))
		self.pers["autoSpectatingID"] = -1;

	if (!isDefined(self.pers["spectatingSystem_recommandedPlayerMode_teamLeft_lastId"]) || game["round"] == 0) // round in case of bash
		self.pers["spectatingSystem_recommandedPlayerMode_teamLeft_lastId"] = -1;
	if (!isDefined(self.pers["spectatingSystem_recommandedPlayerMode_teamRight_lastId"]) || game["round"] == 0) // round in case of bash
		self.pers["spectatingSystem_recommandedPlayerMode_teamRight_lastId"] = -1;

	self.autoSpectating_inCinematic = false;


	if (!level.in_readyup)
	{
		self thread watchAction();

		// Enable auto-spectator on every start of new round
		if (self.pers["team"] == "spectator")
		{
			self thread cinematicMove(); // called only on start of new round
		}
	}
}

onSpawnedSpectator()
{
	if (self.pers["team"] == "spectator" && !level.in_readyup)
	{
		autoSpectatorEnable(); // enable by default

		// enable auto-spectator feaures
		self thread autoSpectator();
	}
}



checkSpectatorTeam()
{
	wait level.fps_multiplier * 0.1337; // :)

	for(;;)
	{
		autospectator_exists = false;
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.pers["team"] == "spectator" && player.pers["autoSpectating"])
			{
				autospectator_exists = true;
				break;
			}
		}

		level.autoSpectating_do = autospectator_exists;

		// Enable archive for killcam
		if (level.autoSpectating_do)
			maps\mp\gametypes\_archive::update();

		wait level.fps_multiplier * 1;
	}
}



autoSpectator()
{
	self endon("disconnect");

	wait level.frame* 3;

	inKillcam = false;

	for(;;)
	{
		// End this thread if player join team
		if (self.pers["team"] != "spectator" || level.in_readyup) // in case of timeout
		{
			autoSpectatorDisable();
			autoSpectatorExit();
			break;
		}

		// Use own variable to suppress double F press
		if (isDefined(self.killcam))
			inKillcam = true;
		else if (!(self usebuttonpressed()))
			inKillcam = false;


		// Skip these key checks if we are in killcam
		if (inKillcam)
		{
			wait level.fps_multiplier * 0.5;
			continue;
		}


		// For autospectating players make sure they always follow somebody
		if (self.pers["autoSpectating"] && !self.autoSpectating_inCinematic && !isDefined(self.killcam))
		{
			// If no one is followed, start following
			if (self.spectatorclient == -1)
			{
				self followNextPlayer();
				if (level.debug_spectator) self iprintln("(no one was followed)");
			}
			else
			{
				id = self.spectatorclient;
				player = GetEntityByClientId(id);

				// If followed player is dead, follow next
				if (isDefined(player) && isPlayer(player) && player.sessionstate != "playing" /*&& player.sessionstate != "dead"*/)
				{
					wait level.fps_multiplier * 1;

					if (id == self.spectatorclient && !isDefined(self.killcam)) // if we are still following the same player (may be changed during waiting)
					{
						self followNextPlayer();
						if (level.debug_spectator) self iprintln("(followed player died)");
					}
				}
			}
		}


		if(self attackbuttonpressed())
		{
			// if is pressed for 0.5 sec
			i = 0;
			holded = false;
			while(self attackbuttonpressed())
			{
				i += level.frame;
				if (i > 0.5)
				{
					holded = true;
					break;
				}
				wait level.frame;
			}

			if (holded)
			{
				if (!self.pers["autoSpectating"])
				{
					autoSpectatorEnable();
					followNextPlayer();
					self iprintln("Auto-spectator ^2Enabled");
				}
			}
			else
			{
				if (self.pers["autoSpectating"])
				{
					autoSpectatorDisable();
					self iprintln("Auto-spectator ^1Disabled");
				}
			}

			// Wait untill key is released
			while(self attackbuttonpressed())
				wait level.frame;
		}


		// Key Shift
		if(self meleebuttonpressed())
		{
			if (self.pers["autoSpectating"])
			{
				autoSpectatorDisable();
				self iprintln("Auto-spectator ^1Disabled");
			}

			// Wait untill key is released
			while(self meleebuttonpressed())
				wait level.fps_multiplier * 0.2;
		}




		// Key F
		if(self usebuttonpressed())
		{

			self maps\mp\gametypes\_spectating_menu::openSpectMenu();

			// Because following is canceled when menu is opened, start folowing again by auto-spectator
			if (!self.pers["autoSpectating"])
			{
				autoSpectatorEnable();
				followNextPlayer();
				if (level.debug_spectator) self iprintln("(menu was opened)");
			}


			// Wait untill key is released
			while(self usebuttonpressed())
				wait level.fps_multiplier * 0.2;
		}


		wait level.frame;
	}
}



autoSpectatorEnable()
{
	self.pers["autoSpectating"] = true;


	if(!isdefined(self.autoSpectatingBG))
	{
		self.autoSpectatingBG = newClientHudElem2(self);
		self.autoSpectatingBG.archived = false;
		self.autoSpectatingBG.x = -30;
		self.autoSpectatingBG.y = 40;
		self.autoSpectatingBG.horzAlign = "center";
		self.autoSpectatingBG.vertAlign = "top";
		self.autoSpectatingBG.alpha = 0.5;
		self.autoSpectatingBG setShader("black", 60, 10);
	}

	// Auto-spectating
	if(!isdefined(self.autoSpectatingText))
	{
		self.autoSpectatingText = newClientHudElem2(self);
		self.autoSpectatingText.horzAlign = "center";
		self.autoSpectatingText.vertAlign = "top";
		self.autoSpectatingText.alignX = "center";
		self.autoSpectatingText.alignY = "top";
		self.autoSpectatingText.x = 0;
		self.autoSpectatingText.y = 42;
		self.autoSpectatingText.archived = false;
		self.autoSpectatingText.font = "default";
		self.autoSpectatingText.sort = 2;
		self.autoSpectatingText.alpha = 0.9;
		self.autoSpectatingText.fontscale = 0.6;
	}

	// Press F to toggle auto-spectator...
	if(!isdefined(self.autoSpectatingKeyInfo1))
	{
		self.autoSpectatingKeyInfo1 = addHUDClient(self, -7, 60, 0.7, (1,1,1), "right", "top", "right", "top");
		self.autoSpectatingKeyInfo1.archived = false;
		self.autoSpectatingKeyInfo1 setText(game["STRING_AUTO_SPECTATOR_KEY1"]);
	}
	if(!isdefined(self.autoSpectatingKeyInfo2))
	{
		self.autoSpectatingKeyInfo2 = addHUDClient(self, -7, 70, 0.7, (1,1,1), "right", "top", "right", "top");
		self.autoSpectatingKeyInfo2.archived = false;
		self.autoSpectatingKeyInfo2 setText(game["STRING_AUTO_SPECTATOR_KEY2"]);
	}
	if(!isdefined(self.autoSpectatingKeyInfo3))
	{
		self.autoSpectatingKeyInfo3 = addHUDClient(self, -7, 82, 0.7, (1,1,1), "right", "top", "right", "top");
		self.autoSpectatingKeyInfo3.archived = false;
		self.autoSpectatingKeyInfo3 setText(game["STRING_AUTO_SPECTATOR_KEY3"]);
	}

	self.autoSpectatingText setText(game["STRING_AUTO_SPECTATING"]);
}

autoSpectatorDisable()
{
	self.pers["autoSpectating"] = false;
	self.pers["autoSpectatingID"] = -1;
	self.spectatorclient = -1;


	if(isdefined(self.autoSpectatingBG))
	{
		self.autoSpectatingBG destroy2();
		self.autoSpectatingBG = undefined;
	}
	if(isdefined(self.autoSpectatingText))
	{
		self.autoSpectatingText destroy2();
		self.autoSpectatingText = undefined;
	}
}

autoSpectatorExit()
{
	if(isdefined(self.autoSpectatingText))
	{
		self.autoSpectatingText destroy2();
		self.autoSpectatingText = undefined;
	}
	if(isdefined(self.autoSpectatingKeyInfo1))
	{
		self.autoSpectatingKeyInfo1 destroy2();
		self.autoSpectatingKeyInfo1 = undefined;
	}
	if(isdefined(self.autoSpectatingKeyInfo2))
	{
		self.autoSpectatingKeyInfo2 destroy2();
		self.autoSpectatingKeyInfo2 = undefined;
	}
	if(isdefined(self.autoSpectatingKeyInfo3))
	{
		self.autoSpectatingKeyInfo3 destroy2();
		self.autoSpectatingKeyInfo3 = undefined;
	}
}


cinematicMove()
{
	self endon("disconnect");

	wait level.frame; // wait untill all players are spawned

	// For some reason, sometimes classname of spectator is not player and linkto() func does not work
	// Error: entity (classname: 'noclass') does not currently support linkTo:
	// this should avoid error
	if (self.classname != "player")
		return;

	//self iprintln("^2Cinematic move start");

	selectedId = getRecommandedPlayer();

	if (selectedId == -1)
	{
		return;
	}

	player = GetEntityByClientId(selectedId);

	if (!isDefined(player))
	{
		return;
	}

	self.pers["autoSpectatingID"] = selectedId; // this will make sure player is highlighted even he is not trully followed

	origin = player.origin - (0, 0, 20);
	angles = (12, player.angles[1] + 180, 0);
	forward = AnglesToForward(angles); // 1.0 scale

	dist = -50; // how far
	originStart = origin + (forward[0] * dist, forward[1] * dist, forward[2] * dist); // new pos

	dist = -200; // how far
	originEnd = origin + (forward[0] * dist, forward[1] * dist, forward[2] * dist); // new pos

	//self iprintln(originStart);
	//self iprintln(originEnd);

	self.autoSpectating_inCinematic = true;

	// Force spectating this player for this seconds
	level.autoSpectating_forceTime = gettime() + 15000;



	self.spectatorLock = spawn("script_model", originStart);
	self.spectatorLock.angles = angles;

	self setOrigin(originStart);
	self setPlayerAngles(angles);
	self linkto(self.spectatorLock);

	self.spectatorLock moveTo(originEnd, 5, 3, 2);

	startTime = getTime();
	for(;;)
	{
		if (self attackbuttonpressed() || self meleebuttonpressed())
			break;

		if ((gettime() - startTime) > 5000)
			break;

		wait level.frame;
	}

	self unlink();

	self.autoSpectating_inCinematic = false;

	// If we are still in autospectator (not cnceled during cinematic)
	if (self.pers["autoSpectating"])
		followPlayer(selectedId);
}


getRecommandedPlayer()
{
	// If match info is enabled, ensure teams are in correct sides
	teamLeft = "allies";
	teamRight = "axis";
	if ((game["scr_matchinfo"] == 1 || game["scr_matchinfo"] == 2) && game["match_team1_side"] == "axis")
	{
		teamLeft = "axis";
		teamRight = "allies";
	}

	/*
	Follow in this direction:
	Round	TEAM1	TEAM2
	1	sniper
	2		sniper
	3	best
	4		best
	5	p1
	6		p1
	7	p2
	8		p2
	9	best
	10		best
	11	p1
	12		p1
	13	p2
	14		p2
	15	...	...


	*/


	selectedId = -1;


	// Team left
	if (game["round"] % 2 != 0)
	{
		if (game["round"] == 1)
		{
			// Find sniper of first team
			selectedId = findSniper(teamLeft);
			self.pers["spectatingSystem_recommandedPlayerMode_teamLeft_lastId"] = selectedId;
		}
		if (game["round"] % 3 == 0) // every 3. rounds
		{
			// Find best player with the most kills
			selectedId = findBestPlayer(teamLeft);
		}
	}
	// Team right
	else
	{
		if (game["round"] == 2)
		{
			// Find sniper of first team
			selectedId = findSniper(teamRight);
			self.pers["spectatingSystem_recommandedPlayerMode_teamRight_lastId"] = selectedId;
		}
		else if ((game["round"]-1) % 3 == 0) // every 3. rounds
		{
			// Find best player with the most kills
			selectedId = findBestPlayer(teamRight);
		}

	}


	// Find next player in row as default
	if (selectedId == -1)
	{
		// Team left
		if (game["round"] % 2 != 0)
		{
			selectedId = getNextPlayerFrom(self.pers["spectatingSystem_recommandedPlayerMode_teamLeft_lastId"], teamLeft);
			self.pers["spectatingSystem_recommandedPlayerMode_teamLeft_lastId"] = selectedId;
		}
		// Team right
		else
		{
			selectedId = getNextPlayerFrom(self.pers["spectatingSystem_recommandedPlayerMode_teamRight_lastId"], teamRight);
			self.pers["spectatingSystem_recommandedPlayerMode_teamRight_lastId"] = selectedId;
		}

	}

	return selectedId;
}

findSniper(team)
{
	selectedId = -1;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if ((player.pers["team"] == team) && player.sessionstate == "playing" && isDefined(player.pers["weapon"]))
		{
			weaponData = level.weapons[player.pers["weapon"]];

			if (isDefined(weaponData) && weaponData.classname == "sniper")
			{
				selectedId = player getEntityNumber();

				if (level.debug_spectator) self iprintln("Spect: selecting sniper: (" + selectedId + ") " + player.name + "  in team " + team);

				break;
			}
		}
	}
	return selectedId;
}

findBestPlayer(team)
{
	lastPlayer = undefined;

	// Select player to watch by score and time
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player.pers["team"] == team && player.sessionstate == "playing")
		{
			if (!isDefined(lastPlayer) ||
			  player.score > lastPlayer.score ||
			  (player.score == lastPlayer.score && player.deaths < lastPlayer.deaths))
				lastPlayer = player;
		}
	}

	if (isDefined(lastPlayer))
	{
		selectedId = lastPlayer getEntityNumber();
		if (level.debug_spectator) self iprintln("Spect: selecting best player: (" + selectedId + ") " + lastPlayer.name + "  in team " + team);
		return selectedId;
	}
	else
		return -1;
}


getNextPlayerFrom(actualSpectatedId, team)
{
	myId = self GetEntityNumber();
	selectedId = -1;
	useNextId = false;

	// Join teams
	players = getentarray("player", "classname");
	playersFinal = [];
	if (!isDefined(team) || team == "allies")
	{
		for (i = 0; i < players.size; i++)
		{
			if (players[i].pers["team"] == "allies")
				playersFinal[playersFinal.size] = players[i];
		}
	}

	if (!isDefined(team) || team == "axis")
	{
		for (i = 0; i < players.size; i++)
		{
			if (players[i].pers["team"] == "axis")
				playersFinal[playersFinal.size] = players[i];
		}
	}


	for(i = 0; i < playersFinal.size; i++)
	{
		player = playersFinal[i];
		id = player getEntityNumber();

		//iprintln("-- " + id);

		// Skip mySelf
		if (myId == id)
			continue;

		// Skip dead players
		if (player.sessionstate != "playing" && player.sessionstate != "dead")
			continue;

		// Always select first client as default
		if (selectedId == -1)
			selectedId = id;

		if (useNextId)
		{
			selectedId = id;
			break;
		}

		// If this player is actually followed, next player is the one we will follow next
		if (actualSpectatedId == id)
			useNextId = true;

	}

	// Debug print
	if (selectedId > -1)
	{
		player = GetEntityByClientId(selectedId);
		teamStr = "from both teams"; if (isDefined(team)) teamStr = "in team " + team;
		if (level.debug_spectator) self iprintln("Spect: selecting next player "+teamStr+": (" + selectedId + ") " + player.name);
	}

	return selectedId;
}



followPlayer(selectedId)
{
	if (isDefined(self.killcam)) // if player is in killcam, player must not be switched
		return;

	self.pers["autoSpectatingID"] = selectedId;
	self.spectatorclient = selectedId;
}

followNextPlayer()
{
	selectedId = -1;

	// First try to find player from the same team
	player = GetEntityByClientId(self.pers["autoSpectatingID"]);
	if (isDefined(player))
	{
		selectedId = getNextPlayerFrom(self.pers["autoSpectatingID"], player.pers["team"]);
	}

	// If not found, select from both teams
	if (selectedId == -1)
	{
		selectedId = getNextPlayerFrom(self.pers["autoSpectatingID"]);
	}

	if (selectedId > -1)
	{
		followPlayer(selectedId);
	}
}


// self.spectatorclient is used to force spectating player
// By default is -1 - dont force
// Other number represents spectated client id
// If is set, player is not able to change spectated player
// self.spectatorclient does not show actually spectated player


// If player is looking at enemy, spectators are forced to follow this player
// This runs on every player
watchAction()
{
	self endon("disconnect");

	// offset thread a litle bit
	wait level.frame * (self getEntityNumber());

	for(;;)
	{
		// Not enabled, wait
		if (!level.autoSpectating_do)
		{
			wait level.fps_multiplier * 3;
			continue;
		}


		// If this player is dead, or we are looking at somebody for less than speficied time -> ignore
		if (!isAlive(self) || (gettime() - level.autoSpectating_forceTime) < 0)
		{
			wait level.fps_multiplier * 1;
			continue;
		}



		follow = false;

		// Count numbers of players in teams
		myTeamAlive = 0;
		enemyAlive = 0;
		teamPlayersCount = 0;
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if ((player.pers["team"] == "allies" || player.pers["team"] == "axis"))
			{
				// Count alive players
				if (player.sessionstate == "playing" || player.sessionstate == "dead") // dead players are players in spectator session state
				{
					if (player.pers["team"] == self.pers["team"])
						myTeamAlive++;
					else
						enemyAlive++;
				}
				teamPlayersCount++;
			}
		}

		// If it is 2v2 match or more
		if (teamPlayersCount >= 4)
		{
			// 1vX - always folow alone player
			if (myTeamAlive == 1 && enemyAlive > 1)
			{
				follow = true;
			}

			// 1v1 - follow player with lower team score
			else if (myTeamAlive == 1 && enemyAlive == 1)
			{
				team1 = "allies";
				team2 = "axis";
				if (self.pers["team"] == "axis")
				{
					team1 = "axis";
					team2 = "allies";
				}
				// if my team score is lower then enemy team
				if (game[team1+"_score"] < game[team2+"_score"])
				{
					follow = true;
				}
			}
		}

		isLookingAtPlayer = undefined;
		if (!follow)
		{
			for(i = 0; i < players.size; i++)
			{
				player = players[i];
				// Find alive enemy players
				if (player != self && isAlive(player) && (player.pers["team"] == "allies" || player.pers["team"] == "axis") && player.pers["team"] != self.pers["team"])
				{
					isLooking = self isPlayerLookingAt(player);
					if (isLooking)
					{
						isLookingAtPlayer = player;
						follow = true;
						break;
					}
				}
			}
		}


		if (follow)
		{
			// Set all spectators to follow this player
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				player = players[i];
				if (player.pers["team"] == "spectator" && player.pers["autoSpectating"])
				{
					// Spectator is in killcam, dont swich
					if (isDefined(player.killcam))
						continue;

					// If this player is looking at player that we are spectating, dont switch view
					if (isDefined(isLookingAtPlayer) && (isLookingAtPlayer getEntityNumber()) == player.pers["autoSpectatingID"])
					{
						//player iprintln("Ignoring of following action of: " + self.name);
						continue;
					}


					// Find the player that this spectator is actually spectating
					spectatedPlayer = GetEntityByClientId(player.spectatorclient);


					// Im seeing a enemy, my team is less and spectator is following other team -> switch to me
					if (level.bombplanted && isDefined(isLookingAtPlayer) && myTeamAlive < enemyAlive && spectatedPlayer.pers["team"] != self.pers["team"])
					{
						player followPlayer(self getEntityNumber());
						if (level.debug_spectator) player iprintln("Spec: auto-spectator switch3 to: " + self.name);
					}

					// Make sure we always follow player from same team (to make it easier for people to watch)
					else if (isDefined(isLookingAtPlayer) && isDefined(spectatedPlayer) && spectatedPlayer.pers["team"] == isLookingAtPlayer.pers["team"])
					{
						player followPlayer(isLookingAtPlayer getEntityNumber());
						if (level.debug_spectator) player iprintln("Spec: auto-spectator switch2 to: " + isLookingAtPlayer.name);
					}
					else
					{
						player followPlayer(self getEntityNumber());
						if (level.debug_spectator) player iprintln("Spec: auto-spectator switch1 to: " + self.name);
					}

					// This will stop other threads for 8 sec
					level.autoSpectating_forceTime = gettime() + 8000;
				}
			}
		}

		resettimeout();

		wait level.fps_multiplier * .1;
	}
}
