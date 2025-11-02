#include maps\mp\gametypes\global\_global;

init()
{
	if(game["firstInit"])
	{
		precacheString2("STRING_AUTO_SPECTATING", 					&"Auto-spectating");
		precacheString2("STRING_AUTO_SPECTATING_OFF", 					&"Auto-spectating off");
		precacheString2("STRING_AUTO_SPECTATING_REASON_MANUAL", 			&"Manual change");
		precacheString2("STRING_AUTO_SPECTATING_REASON_VISIBLE_ENEMY", 			&"Enemy in sight");
		precacheString2("STRING_AUTO_SPECTATING_REASON_VISIBLE_BY_ENEMY", 		&"Spotted by enemy");
		precacheString2("STRING_AUTO_SPECTATING_REASON_VISIBLE_ENEMY_IN_FUTURE", 	&"Enemy in sight (P)");
		precacheString2("STRING_AUTO_SPECTATING_REASON_VISIBLE_BY_ENEMY_IN_FUTURE", 	&"Spotted by enemy (P)");
		precacheString2("STRING_AUTO_SPECTATING_REASON_BOMB_PLANTED", 			&"Bomb planted");
		precacheString2("STRING_AUTO_SPECTATING_REASON_BOMB_SCORE", 			&"Follow losing team");
		precacheString2("STRING_AUTO_SPECTATING_REASON_LAST_PLAYER", 			&"Last player in team");
		precacheString2("STRING_AUTO_SPECTATING_REASON_1V1_SCORE", 			&"1v1 losing team");
		precacheString2("STRING_AUTO_SPECTATING_REASON_NO_ACTION_NEARBY", 		&"Next to each other");
		precacheString2("STRING_AUTO_SPECTATING_REASON_NO_ACTION_MOVING", 		&"Follow moving player");
		precacheString2("STRING_AUTO_SPECTATING_REASON_RADIO_DEFEND", 			&"Radio defending team");

		//game["STRING_AUTO_SPECT_IS_ENABLED"] = 		"Auto-spectating ^2On";
		//game["STRING_AUTO_SPECT_IS_DISABLED"] = 	"Auto-spectating ^1Off";
	}

	level.streamerSystem_auto_turnedOn = true;
	level.streamerSystem_auto_lockedUntill = 0;
	level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING";
	level.streamerSystem_auto_runThreads = false;


	if (!level.streamerSystem)
	{
		return;
	}

	addEventListener("onConnected",  	::onConnected);
	addEventListener("onConnectedAll",    	::onConnectedAll);
}

onConnected()
{
	self.streamerSystem_inCinematic = false;
}

onConnectedAll()
{
	thread playersCanSeeEachOthers();
	thread playersCloseToEachOther();
	thread autoFollowedPlayer();
}



autoSpectatorEnable()
{
	level.streamerSystem_auto_turnedOn = true;

	level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING";

	//level printToAutoSpectators(game["STRING_AUTO_SPECT_IS_ENABLED"]);

	level thread maps\mp\gametypes\_streamer_hud::settingsChanged("auto");
}


autoSpectatorDisable()
{
	//level printToAutoSpectators(game["STRING_AUTO_SPECT_IS_DISABLED"]);

	level.streamerSystem_auto_turnedOn = false;

	level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING_OFF";

	level thread maps\mp\gametypes\_streamer_hud::settingsChanged("auto");
}

autoSpectatorToggle()
{
	if (!level.streamerSystem_auto_turnedOn)
		autoSpectatorEnable();
	else
		autoSpectatorDisable();
}


HUD_loop()
{
	self endon("disconnect");

	/*if(!isdefined(self.streamerSystem_HUD_autoSpectator_BG))
	{
		self.streamerSystem_HUD_autoSpectator_BG = newClientHudElem2(self);
		self.streamerSystem_HUD_autoSpectator_BG.archived = false;
		self.streamerSystem_HUD_autoSpectator_BG.x = -40;
		self.streamerSystem_HUD_autoSpectator_BG.y = 40;
		self.streamerSystem_HUD_autoSpectator_BG.horzAlign = "center";
		self.streamerSystem_HUD_autoSpectator_BG.vertAlign = "top";
		self.streamerSystem_HUD_autoSpectator_BG.alpha = 0;
		self.streamerSystem_HUD_autoSpectator_BG.color = (0, 0, 0);
		self.streamerSystem_HUD_autoSpectator_BG setShader("white", 80, 10);
	}

	// Auto-spectating
	if(!isdefined(self.streamerSystem_HUD_autoSpectator))
	{
		self.streamerSystem_HUD_autoSpectator = newClientHudElem2(self);
		self.streamerSystem_HUD_autoSpectator.horzAlign = "center";
		self.streamerSystem_HUD_autoSpectator.vertAlign = "top";
		self.streamerSystem_HUD_autoSpectator.alignX = "center";
		self.streamerSystem_HUD_autoSpectator.alignY = "top";
		self.streamerSystem_HUD_autoSpectator.x = 0;
		self.streamerSystem_HUD_autoSpectator.y = 42;
		self.streamerSystem_HUD_autoSpectator.archived = false;
		self.streamerSystem_HUD_autoSpectator.font = "default";
		self.streamerSystem_HUD_autoSpectator.alpha = 0;
		self.streamerSystem_HUD_autoSpectator.sort = 2;
		self.streamerSystem_HUD_autoSpectator.fontscale = 0.6;
	}*/

	/*if (!isDefined(self.streamerSystem_HUD_spectatedPlayerName))
	{
		self.streamerSystem_HUD_spectatedPlayerName = addHUDClient(self, 0, 50, 1, (1,1,1), "center", "top", "center", "top");
		self.streamerSystem_HUD_spectatedPlayerName.alpha = 0;
		self.streamerSystem_HUD_spectatedPlayerName.archived = false;
	}*/

	//hud_text_last = "";

	for (;;)
	{
		if (self.streamerSystem_freeSpectating || isDefined(self.killcam) || !isPlayer(level.streamerSystem_player) || self.pers["team"] != "streamer")
		{
			// Hide
			self setClientCvarIfChanged("ui_streamersystem_spectatedPlayerName", "");

			// CoD2x data for streamer overlays
			if (level.scr_vmix > 0) {
				self setClientCvarIfChanged("cl_vmix_scr_spectatedHWID", ""); // CoD2x 
				self setClientCvarIfChanged("cl_vmix_scr_spectatedUserId", ""); // CoD2x 
			}

			// Exit loop
			if (self.pers["team"] != "streamer")
				break;

		} else 
		{
			teamColor = "^7"; // default white
			if (level.streamerSystem_player.pers["team"] == "allies")
				teamColor = "^8"; // allies
			else if (level.streamerSystem_player.pers["team"] == "axis")
				teamColor = "^9"; // axis

			self setClientCvarIfChanged("ui_streamersystem_spectatedPlayerName", teamColor + removeColorsFromString(level.streamerSystem_player.name));

			// CoD2x data for streamer overlays
			if (level.scr_vmix > 0) {

				// HWID
				if (level.scr_vmix == 1) {
					self setClientCvarIfChanged("cl_vmix_scr_spectatedHWID", level.streamerSystem_player getHWID()); // CoD2x
				// IP
				} else if (level.scr_vmix == 2) {
					self setClientCvarIfChanged("cl_vmix_scr_spectatedHWID", level.streamerSystem_player getIp()); // CoD2x
				}

				userId = level.streamerSystem_player.name;
				if (matchIsActivated()) {
					userId = level.streamerSystem_player matchPlayerGetData("uuid");
				} else {
					userId = level.streamerSystem_player getCDKeyHash();
				}
				self setClientCvarIfChanged("cl_vmix_scr_spectatedUserId", userId); // CoD2x


				// Loop players and build debug string for vmix
				players = getentarray("player", "classname");
				allies = [];
				axis = [];
				for (i = 0; i < players.size; i++) {
					player = players[i];
					if (player.pers["team"] == "allies") {
						allies[allies.size] = player;
					} else if (player.pers["team"] == "axis") {
						axis[axis.size] = player;
					}
				}
				// Loop all players starting from allies to axis
				debugString = "";
				for (i = 0; i < allies.size + axis.size; i++) {
					if (i < allies.size) {
						player = allies[i];
					} else {
						player = axis[i - allies.size];
					}
					if (debugString != "") {
						debugString += "^7\n";
					}
					// HWID
					if (level.scr_vmix == 1) {
						debugString += "HWID:" +player getHWID();
					// IP
					} else if (level.scr_vmix == 2) {
						debugString += "IP:" + player getIp();
					}
					if (matchIsActivated()) {
						debugString += " | MATCH-UUID:" + player matchPlayerGetData("uuid");
					} else {
						debugString += " | CDKEYHASH:" + player getCDKeyHash();
					}
					teamColor = "^7"; // default white
					if (player.pers["team"] == "allies")
						teamColor = "^8"; // allies
					else if (player.pers["team"] == "axis")
						teamColor = "^9"; // axis
					debugString += " | NICK:" + teamColor + removeColorsFromString(player.name);
				}
				
				self setClientCvarIfChanged("cl_vmix_scr_playerIds", debugString); // CoD2x
			}

			
		}

		

		/*if (!self.streamerSystem_turnedOn || self.streamerSystem_freeSpectating)
		{
			// Hide
			if (self.streamerSystem_HUD_autoSpectator_BG.alpha != 0) 	self.streamerSystem_HUD_autoSpectator_BG.alpha = 0;
			if (self.streamerSystem_HUD_autoSpectator.alpha != 0) 	self.streamerSystem_HUD_autoSpectator.alpha = 0;
		}
		else if (level.streamerSystem_auto_turnedOn)
		{
			// Show
			if (self.streamerSystem_HUD_autoSpectator_BG.alpha != 0.5) 	self.streamerSystem_HUD_autoSpectator_BG.alpha = 0.5;
			if (self.streamerSystem_HUD_autoSpectator.alpha != 1) 	self.streamerSystem_HUD_autoSpectator.alpha = 1;

			canSwitch = ((gettime() - level.streamerSystem_auto_lockedUntill) > 0)  &&  ((gettime() - level.streamerSystem_lastChange) > 6000);

			color = (0, 0, 0); // black
			if (canSwitch) color = (0.03, 0.18, 0.1); // green

			if (self.streamerSystem_HUD_autoSpectator_BG.color != color) 	self.streamerSystem_HUD_autoSpectator_BG.color = color;
		}
		else
		{
			// No bg
			if (self.streamerSystem_HUD_autoSpectator_BG.alpha != 0) 	self.streamerSystem_HUD_autoSpectator_BG.alpha = 0;
			if (self.streamerSystem_HUD_autoSpectator.alpha != 1) 	self.streamerSystem_HUD_autoSpectator.alpha = 1;
		}

		// Update text with follow reason
		if (level.streamerSystem_auto_statusText != "" && level.streamerSystem_auto_statusText != hud_text_last)
		{
			self.streamerSystem_HUD_autoSpectator setText(game[level.streamerSystem_auto_statusText]);
		}
		hud_text_last = level.streamerSystem_auto_statusText;*/

		wait level.fps_multiplier * 0.1;
	}


	// Destroy
	/*if(isdefined(self.streamerSystem_HUD_autoSpectator_BG))
	{
		self.streamerSystem_HUD_autoSpectator_BG destroy2();
		self.streamerSystem_HUD_autoSpectator_BG = undefined;
	}
	if(isdefined(self.streamerSystem_HUD_autoSpectator))
	{
		self.streamerSystem_HUD_autoSpectator destroy2();
		self.streamerSystem_HUD_autoSpectator = undefined;
	}*/
	/*if(isdefined(self.streamerSystem_HUD_spectatedPlayerName))
	{
		self.streamerSystem_HUD_spectatedPlayerName destroy2();
		self.streamerSystem_HUD_spectatedPlayerName = undefined;
	}*/
}





printToAutoSpectators(text)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player.pers["team"] == "streamer" && player.streamerSystem_turnedOn && level.streamerSystem_auto_turnedOn)
		{
			player iprintln(text);
			break;
		}
	}
}



playersCanSeeEachOthers()
{
	for (;;)
	{
		// Not enabled, wait
		if (!level.streamerSystem_auto_runThreads)
		{
			wait level.fps_multiplier * 3;
			continue;
		}

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			player.autospectator_visibleEnemy = undefined;
			player.autospectator_seenByEnemy = undefined;

			player.streamerSystem_visibleEnemyInFuture = undefined;
			player.streamerSystem_seenByEnemyInFuture = undefined;
		}

		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if (!isDefined(player)) continue; // because of wait player may be disconnected

			if ((player.pers["team"] == "allies" || player.pers["team"] == "axis") && (player.sessionstate == "playing"))
			{
				eye = player maps\mp\gametypes\global\player::getEyeOrigin();
				angles = player getPlayerAngles();

				// If player is moving, predict future position
				predictedPosition = undefined;
				if (player.movingVector != (0, 0, 0))
				{
					multiplier = length(player.movingVector);
					if (multiplier > 12)
						multiplier = 12;
					vector = VectorNormalize(player.movingVector);

					multiplier = multiplier * 8;

					futureEye = eye + (vector[0] * multiplier, vector[1] * multiplier, vector[2] * multiplier);

					// Create forward point - it might be future position of player
					forwardTrace = Bullettrace(eye, futureEye, false, player); // BulletTrace( <start>, <end>, <hit characters>, <ignore entity> )
					predictedPosition = forwardTrace["position"];
				}

				// Debug point
				if (level.debug_spectator)
				{
					if (!isDefined(player.streamerSystem_eyeWaypoint))
					{
						player.streamerSystem_eyeWaypoint = spawn("script_origin",(0,0,0));
						player.streamerSystem_eyeWaypoint thread maps\mp\gametypes\global\developer::showWaypoint();
					}
					if (isDefined(predictedPosition))
						player.streamerSystem_eyeWaypoint.origin = predictedPosition;
					else
					{
						player.streamerSystem_eyeWaypoint delete();
						player.streamerSystem_eyeWaypoint = undefined;
					}
				}


				// Loop enemies of this player
				for(j = 0; j < players.size; j++)
				{
					enemy = players[j];

					if (!isDefined(enemy)) continue; // because of wait player may be disconnected

					if (enemy != player && (enemy.pers["team"] == "allies" || enemy.pers["team"] == "axis") && enemy.pers["team"] != player.pers["team"] && (enemy.sessionstate == "playing"))
					{
						angles2 = vectorToAngles(enemy getOrigin() - player getOrigin());
						angle_diff = angles[1] - angles2[1];

						if (angle_diff > 180) angle_diff -= 360;
						if (angle_diff < -180) angle_diff += 360;

						//player iprintln("i have player " + enemy.name + " in angle" + angle_diff);

						if (angle_diff > -35 && angle_diff < 35)
						{
							trace = Bullettrace(eye, enemy.headTag getOrigin(), true, player);
							headVisible = isDefined(trace["entity"]) && trace["entity"] == enemy;

							if (headVisible)
							{
								//player iprintln("i have players " + enemy.name + " head on screen");
								player.autospectator_visibleEnemy = enemy;
								enemy.autospectator_seenByEnemy = player;
								continue;
							}

							// Check predicted position
							else if (isDefined(predictedPosition))
							{
								// Check if future position is visible
								trace = Bullettrace(predictedPosition, enemy.headTag getOrigin(), true, player);
								headVisible = isDefined(trace["entity"]) && trace["entity"] == enemy;

								if (headVisible)
								{
									//player iprintln("i will see player " + enemy.name + " in future");
									player.streamerSystem_visibleEnemyInFuture = enemy;
									enemy.streamerSystem_seenByEnemyInFuture = player;
								}
							}
						}


					}
				}

				//wait level.frame;
			}
		}

		wait level.fps_multiplier * .1;
	}

}



playersCloseToEachOther()
{
	for (;;)
	{
		// Not enabled, wait
		if (!level.streamerSystem_auto_runThreads)
		{
			wait level.fps_multiplier * 3;
			continue;
		}

		dist_min = -1;
		dist_player1 = undefined;
		dist_player2 = undefined;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			player.autoSpectating_veryCloseToEnemy = undefined;

			if ((player.pers["team"] == "allies" || player.pers["team"] == "axis") && (player.sessionstate == "playing"))
			{
				for(j = 0; j < players.size; j++)
				{
					enemy = players[j];

					if (enemy != player && (enemy.pers["team"] == "allies" || enemy.pers["team"] == "axis") && enemy.pers["team"] != player.pers["team"] && (enemy.sessionstate == "playing"))
					{
						dist = distance(player getOrigin(), enemy getOrigin());

						if (dist < dist_min || dist_min == -1)
						{
							dist_min = dist;
							dist_player1 = player;
							dist_player2 = enemy;
						}
					}
				}
			}
		}

		if (dist_min != -1 && dist_min < 800)
		{
			dist_player1.autoSpectating_veryCloseToEnemy = dist_player2;
			dist_player2.autoSpectating_veryCloseToEnemy = dist_player1;
		}

		wait level.fps_multiplier * .5;
	}

}


lockFor(time)
{
	level.streamerSystem_auto_lockedUntill = gettime() + time; // wait some time untill next change

	if (level.streamerSystem_auto_turnedOn)
		level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING_REASON_MANUAL";
}


autoFollowedPlayer()
{
	level.streamerSystem_auto_lockedUntill = gettime() + 18000; // wait some time untill next change (also consider strat time)

	followed_team_last = "";
	for(;;)
	{
		wait level.fps_multiplier * 0.1;

		players = getentarray("player", "classname");

		autospectator_exists = false;
		players_exists = false;
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.pers["team"] == "streamer" && player.streamerSystem_turnedOn && level.streamerSystem_auto_turnedOn)
				autospectator_exists = true;

			if ((player.pers["team"] == "allies" || player.pers["team"] == "axis") && player.sessionstate == "playing")
				players_exists = true;

		}
		level.streamerSystem_auto_runThreads = (autospectator_exists && players_exists);

		// No players, do nothing
		if (level.streamerSystem_auto_runThreads == false)
			continue;

		// In timeout
		//if (level.in_readyup)
		//	continue;

		id = level.streamerSystem_playerID;
		spectated_player = level.streamerSystem_player;

		// If no one is followed, wait
		if (id == -1 || !isDefined(spectated_player) || !isPlayer(spectated_player))
			continue;

		// Autospectator is locked to some player, dont switch
		if (!level.streamerSystem_auto_turnedOn)
		{
			wait level.fps_multiplier * 1;
			level.streamerSystem_auto_lockedUntill = gettime() + 3000; // wait some time untill next change
			level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING_OFF";
			continue;
		}

		// Can switch after 6 second from last switch
		if ((gettime() - level.streamerSystem_lastChange) < 6000)
		{
			continue;
		}

		// Dont switch when round ended
		if (level.gametype == "sd" && level.roundended)
			continue;



		// Can switch after 6 second from last switch and untill timer expired
		canSwitch = (gettime() - level.streamerSystem_auto_lockedUntill) > 0;
		if (!canSwitch)
		{
			// Player has visible enemy on their screen or enemy is seeing this player or their screen
			// Extent time for this player
			if (isDefined(spectated_player.autospectator_visibleEnemy) || isDefined(spectated_player.autospectator_seenByEnemy))
			{
				if (level.debug_spectator) printToAutoSpectators("Extending time for this player (visisble enemy)");
				level.streamerSystem_auto_lockedUntill = gettime() + 8000;
				level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING_REASON_VISIBLE_ENEMY";
				wait level.fps_multiplier * 1;
			}

			// Player has in future visible enemy on their screen or enemy is seeing this player or their screen
			// Extent time for this player
			if (isDefined(spectated_player.streamerSystem_visibleEnemyInFuture) || isDefined(spectated_player.streamerSystem_seenByEnemyInFuture))
			{
				if (level.debug_spectator) printToAutoSpectators("Extending time for this player (visisble enemy in future)");
				level.streamerSystem_auto_lockedUntill = gettime() + 4000;
				level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING_REASON_VISIBLE_ENEMY_IN_FUTURE";
				wait level.fps_multiplier * 1;
			}

			// Dont continue untill we can switch
			continue;
		}
		else
			level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING";

		// Count numbers of players in teams
		alliesAlive = 0;
		axisAlive = 0;
		teamPlayersCount = 0;
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if ((player.pers["team"] == "allies" || player.pers["team"] == "axis"))
			{
				// Count alive players
				if (player.sessionstate == "playing" || player.sessionstate == "dead") // dead players are players in spectator session state
				{
					if (player.pers["team"] == "allies")
						alliesAlive++;
					else
						axisAlive++;
				}
				teamPlayersCount++;
			}
		}
		// If it is 2v2 match or more
		if (teamPlayersCount >= 4)
		{
			follow_team = "";
			switch_reason = "";
			hud_text = "";

			// 1vX - always folow alone player
			if (alliesAlive == 1 && axisAlive > 1)
			{
				follow_team = "allies";
				switch_reason = "Last player in team";
				hud_text = "STRING_AUTO_SPECTATING_REASON_LAST_PLAYER";
			}

			// 1vX - always folow alone player
			else if (axisAlive == 1 && alliesAlive > 1)
			{
				follow_team = "axis";
				switch_reason = "Last player in team";
				hud_text = "STRING_AUTO_SPECTATING_REASON_LAST_PLAYER";
			}

			// 1v1 - follow player with lower team score
			else if (alliesAlive == 1 && axisAlive == 1 && game["allies_score"] != game["axis_score"])
			{
				// if my team score is lower then enemy team
				if (game["allies_score"] < game["axis_score"])
					follow_team = "allies";
				else
					follow_team = "axis";

				switch_reason = "1v1 and lower score";
				hud_text = "STRING_AUTO_SPECTATING_REASON_1V1_SCORE";
			}

			if (follow_team != "")
			{
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					if (player.pers["team"] == follow_team && (player.sessionstate == "playing" || player.sessionstate == "dead"))
					{
						level maps\mp\gametypes\_streamer::followPlayer(player);
						if (level.debug_spectator) printToAutoSpectators(switch_reason);
						level.streamerSystem_auto_lockedUntill = gettime() + 1000; // wait some time untill next change
						level.streamerSystem_auto_statusText = hud_text;
						break;
					}
				}
				continue;
			}
		}



		// By default, follow one team
		followed_team = spectated_player.pers["team"];

		// When bomb is planted, follow team with lower score
		if (level.gametype == "sd" && level.bombplanted && alliesAlive >= 1 && axisAlive >= 1)
		{
			if ((gettime() - level.bombtimerstart) < 3000) // if no action, follow player who actually planted the bomb
			{
				if (isDefined(level.planting_player) && isAlive(level.planting_player)) // always follow planter when bomb is planted
				{
					level maps\mp\gametypes\_streamer::followPlayer(level.planting_player);
					if (level.debug_spectator) printToAutoSpectators("Bomb planted, following planter");
					level.streamerSystem_auto_lockedUntill = gettime() + 4000; // wait some time untill next change
					level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING_REASON_BOMB_PLANTED";
					continue;
				}
			}
			else if (game["allies_score"] != game["axis_score"])
			{
				if (game["allies_score"] < game["axis_score"])		followed_team = "allies";
       			 	else if (game["allies_score"] > game["axis_score"])	followed_team = "axis";
       			 	if (level.debug_spectator && followed_team != followed_team_last) printToAutoSpectators("bomb planted, following lower score team:" + followed_team);
				level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING_REASON_BOMB_SCORE";
			}
		}

		// In HQ, follow team that is defending the hq
		if (level.gametype == "hq" && (level.DefendingRadioTeam == "allies" || level.DefendingRadioTeam == "axis"))
		{
			followed_team = level.DefendingRadioTeam;
			if (level.debug_spectator && followed_team != followed_team_last) printToAutoSpectators("following defending radio team: " + followed_team);
			level.streamerSystem_auto_statusText = "STRING_AUTO_SPECTATING_REASON_RADIO_DEFEND";
		}

		followed_team_last = followed_team;



		// Possible to change to player from same spectated team
		follow = false;
		switch_reason = "";
		hud_text = "";
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if ((player.pers["team"] == followed_team))
			{
				// Player has visible enemy on their screen
				if (isDefined(player.autospectator_visibleEnemy))
				{
					follow = true;
					switch_reason = "Visible enemy on screen";
					hud_text = "STRING_AUTO_SPECTATING_REASON_VISIBLE_ENEMY";
				}

				// Player has visible enemy on their screen
				if (isDefined(player.streamerSystem_visibleEnemyInFuture))
				{
					follow = true;
					switch_reason = "Visible enemy on screen in future";
					hud_text = "STRING_AUTO_SPECTATING_REASON_VISIBLE_ENEMY_IN_FUTURE";
				}

				// Too long no change, find players very close together to follow
				if ((gettime() - level.streamerSystem_lastChange) > 16000)
				{
					// Enemy is seeing this player or their screen
					if (isDefined(player.autospectator_seenByEnemy))
					{
						follow = true;
						switch_reason = "Is visible on enemy screen";
						hud_text = "STRING_AUTO_SPECTATING_REASON_VISIBLE_BY_ENEMY";
					}
					else if (isDefined(player.streamerSystem_seenByEnemyInFuture))
					{
						follow = true;
						switch_reason = "Is visible on enemy screen in future";
						hud_text = "STRING_AUTO_SPECTATING_REASON_VISIBLE_BY_ENEMY_IN_FUTURE";
					}
					// Player very close to each other (< 800)
					else if (isDefined(player.autoSpectating_veryCloseToEnemy) && spectated_player != player)
					{
						follow = true;
						switch_reason = "No action - close enemy near by";
						hud_text = "STRING_AUTO_SPECTATING_REASON_NO_ACTION_NEARBY";
					}/*
					else if (player.isMoving)
					{
						follow = true;
						switch_reason = "No action - moving player";
						hud_text = "STRING_AUTO_SPECTATING_REASON_NO_ACTION_MOVING";
					}*/
				}

				if (follow)
				{
					level maps\mp\gametypes\_streamer::followPlayer(player);

					if (level.debug_spectator) printToAutoSpectators(switch_reason);

					level.streamerSystem_auto_lockedUntill = gettime() + 8000;

					level.streamerSystem_auto_statusText = hud_text;

					break;
				}
			}
		}
	}
}
