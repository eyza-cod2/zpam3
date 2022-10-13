#include maps\mp\gametypes\global\_global;

init()
{
	if(game["firstInit"])
	{
		precacheString2("STRING_AUTO_SPECTATING", 				&"Auto-spectating");
		precacheString2("STRING_AUTO_SPECTATING_REASON_MANUAL", 		&"Manual change");
		precacheString2("STRING_AUTO_SPECTATING_REASON_VISIBLE_ENEMY", 		&"Enemy in sight");
		precacheString2("STRING_AUTO_SPECTATING_REASON_VISIBLE_BY_ENEMY", 	&"Spotted by enemy");
		precacheString2("STRING_AUTO_SPECTATING_REASON_BOMB_PLANTED", 		&"Bomb planted");
		precacheString2("STRING_AUTO_SPECTATING_REASON_BOMB_SCORE", 		&"Follow loosing team");
		precacheString2("STRING_AUTO_SPECTATING_REASON_LAST_PLAYER", 		&"Last player in team");
		precacheString2("STRING_AUTO_SPECTATING_REASON_1V1_SCORE", 		&"1v1 loosing team");
		precacheString2("STRING_AUTO_SPECTATING_REASON_NO_ACTION_NEARBY", 	&"Next to each other");
		precacheString2("STRING_AUTO_SPECTATING_REASON_NO_ACTION_MOVING", 	&"Follow moving player");
		precacheString2("STRING_AUTO_SPECTATING_REASON_RADIO_DEFEND", 		&"Radio defending team");

		game["STRING_AUTO_SPECT_IS_ENABLED"] = 		"Auto-spectator is ^2On";
		game["STRING_AUTO_SPECT_IS_DISABLED"] = 	"Auto-spectator is ^1Off";
		game["STRING_AUTO_SPECT_NAMES_ON"] = 		"Player names ^2On";
		game["STRING_AUTO_SPECT_NAMES_OFF"] = 		"Player names ^1Off";
	}

	level.autoSpectating_do = false;
	level.autoSpectating_ID = -1;		// spectated player
	level.autoSpectating_spectatedPlayer = undefined;
	level.autoSpectating_noSwitchUntill = 0;
	level.autoSpectating_refreshPlayerNames = false;
	level.autoSpectating_HUD_text = "";

	if (!isDefined(game["spectatingSystem_recommandedPlayerMode_teamLeft_player"]) || level.gametype != "sd" || game["round"] == 0) // round in case of bash
		game["spectatingSystem_recommandedPlayerMode_teamLeft_player"] = undefined;
	if (!isDefined(game["spectatingSystem_recommandedPlayerMode_teamRight_player"]) || level.gametype != "sd" || game["round"] == 0) // round in case of bash
		game["spectatingSystem_recommandedPlayerMode_teamRight_player"] = undefined;

	if (!level.spectatingSystem || level.in_readyup)
	{
		return;
	}

	addEventListener("onConnected",  	::onConnected);
	addEventListener("onConnectedAll",    	::onConnectedAll);
	addEventListener("onSpawnedPlayer",  	::onSpawnedPlayer);
	addEventListener("onSpawnedSpectator",  ::onSpawnedSpectator);
	addEventListener("onPlayerDamaged", 	::onPlayerDamaged);
	addEventListener("onPlayerKilled", 	::onPlayerKilled);
}

onConnected()
{
	if (!isDefined(self.pers["autoSpectating"]))
		self.pers["autoSpectating"] = false;

	self.autoSpectating_inCinematic = false;
	self.freeSpectating = true; // free spectating, not following any player
	self.autoSpectating_ESP = true;
}

onConnectedAll()
{
	thread checkSpectatorTeam();
	thread playersCanSeeEachOthers();
	thread playersCloseToEachOther();
	thread autoFollowedPlayer();
}

onSpawnedSpectator()
{
	if (self.pers["team"] == "spectator")
	{
		// enable auto-spectator feaures
		self thread autoSpectator();
	}
}

onSpawnedPlayer()
{
	level.autoSpectating_refreshPlayerNames = true;
}


/*
Called when player has taken damage.
self is the player that took damage.
*/
onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{

}

/*
Called when player is killed
self is the player that was killed.
*/
onPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self thread switchNextPlayerForNonAutoSpectators();
}

switchNextPlayerForNonAutoSpectators()
{
	self endon("disconnect");

	wait level.fps_multiplier * 1;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		spectator = players[i];
		if (spectator != self && spectator.sessionteam == "spectator" && !spectator.pers["autoSpectating"] && spectator.spectatorclient == -1 && !spectator.isMoving)
		{
			// When spectator is following a player, player origin is not changing (player is in last free spectating position)
			// only angles are changing wich follows spectated player angles
			if (spectator getPlayerAngles() == self getPlayerAngles())
			{
				nextPlayer = getNextPlayerFrom(self);
				if (!isDefined(nextPlayer))
					return;

				//spectator iprintln("I was following " + self.name);
				spectator thread followPlayer_nonAutoSpec(nextPlayer);

				if (level.debug_spectator) spectator iprintln("^9Auto follow next player for classic spectator");
			}
		}
	}
}




// Check if any spectator is in auto-spectating mode
checkSpectatorTeam()
{
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

printToAutoSpectators(text)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player.pers["team"] == "spectator" && player.pers["autoSpectating"])
		{
			player iprintln(text);
			break;
		}
	}
}


// self.spectatorclient is used to force spectating player
// By default is -1 - dont force
// Other number represents spectated client id
// If is set, player is not able to change spectated player
// self.spectatorclient does not show actually spectated player
autoSpectator()
{
	self endon("disconnect");

	// Wait untill readyup is over (used when timeout is called in time based gametypes and somebody connect)
	while(level.in_readyup)
	{
		if (self.pers["team"] != "spectator") // leaved spectator in timeout
			return;
		wait level.fps_multiplier * 1;
	}

	autoSpectatorEnable(); // enable by default

	self thread playerNames();

	self thread keys_help();

	wait level.frame* 3;

	inKillcam = false;
	self.waitForAttackKeyRelease = false;
	self.waitForMeleeKeyRelease = false;
	self.waitForUseKeyRelease = false;

	hud_text_last = "";

	for(;;)
	{
		wait level.frame;

		// End this thread if player join team
		if (self.pers["team"] != "spectator")
		{
			self autoSpectatorDisable();
			self autoSpectatorExit();
			break;
		}

		// Use own variable to suppress double F press
		if (isDefined(self.killcam))
			inKillcam = true;
		else if (!(self usebuttonpressed()))
			inKillcam = false;


		// Skip these key checks if we are in killcam
		if (inKillcam)
			continue;

		// Wait untill timeout is over
		if (level.in_readyup)
		{
			autoSpectatorDisable();

			while (level.in_readyup)
				wait level.fps_multiplier * 1;

			autoSpectatorEnable();

			self thread playerNames();
		}



		// Key attack
		if(self attackbuttonpressed() && !self.waitForAttackKeyRelease)
		{
			self.waitForAttackKeyRelease = true;
			self thread handleAttackButtonPress();
		}

		// Key Shift
		if(self meleebuttonpressed() && !self.waitForMeleeKeyRelease)
		{
			self.waitForMeleeKeyRelease = true;
			self thread handleMeleeButtonPress();
		}

		// Key F
		if(self usebuttonpressed() && !self.waitForUseKeyRelease && !self.autoSpectating_killcamProposingVisible)	// Ignore F press is killcam proposing is visible
		{
			self.waitForUseKeyRelease = true;
			self thread handleUseButtonPress();
		}


		// For autospectating players make sure they always follow somebody
		if (self.pers["autoSpectating"] && !self.autoSpectating_inCinematic && !isDefined(self.killcam) && level.autoSpectating_ID != self.spectatorclient)
		{
			self.spectatorclient = level.autoSpectating_ID;

			//if (level.debug_spectator) self iprintln("^8 set self.spectatorclient="+level.autoSpectating_ID);

			self.freeSpectating = false; // free spectating ended, now following a player
		}



		// Update text with follow reason
		if (self.pers["autoSpectating"])
		{
			if (level.autoSpectating_HUD_text != "" && level.autoSpectating_HUD_text != hud_text_last)
			{
				self.autoSpectatingText setText(game[level.autoSpectating_HUD_text]);
			}
			hud_text_last = level.autoSpectating_HUD_text;
		}

	}
}



handleAttackButtonPress()
{
	self endon("disconnect");

	// Start following nearby player
	spec_follow = undefined;
	if (self.freeSpectating && isDefined(self.spec_follow) && !self.pers["autoSpectating"])
	{
		if (level.debug_spectator) self iprintln("attackBtn> follow close by player");

		spec_follow = self.spec_follow;

		self.spectatorclient = self.spec_follow getEntityNumber();

		wait level.frame;

		self.spectatorclient = -1;
	}

	self.freeSpectating = false; // free spectating ended, now following a player
	if (level.debug_spectator) self iprintln("attackBtn> self.freeSpectating = ^1false");

	// if is pressed for 0.5 sec
	holded = false;
	i = 0;
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
			self autoSpectatorEnable();
			self iprintln(game["STRING_AUTO_SPECT_IS_ENABLED"]);
		}
		else
		{
			selectedPlayer = level getPreviousPlayerFrom(level.autoSpectating_spectatedPlayer);
			if (isDefined(selectedPlayer))
			{
				level followPlayer(selectedPlayer);
				level.autoSpectating_noSwitchUntill = gettime() + 15000; // wait some time untill next change
				level.autoSpectating_HUD_text = "STRING_AUTO_SPECTATING_REASON_MANUAL";
			}
		}
	}
	else
	{
		if (self.pers["autoSpectating"])
		{
			selectedPlayer = level getNextPlayerFrom(level.autoSpectating_spectatedPlayer);
			if (isDefined(selectedPlayer))
			{
				level followPlayer(selectedPlayer);
				level.autoSpectating_noSwitchUntill = gettime() + 15000; // wait some time untill next change
				level.autoSpectating_HUD_text = "STRING_AUTO_SPECTATING_REASON_MANUAL";
			}
		}
	}

	while(self attackbuttonpressed())
		wait level.frame;

	self.waitForAttackKeyRelease = false;
}


handleMeleeButtonPress()
{
	self endon("disconnect");

	// We are not auto-spectating - what ever spectator state is, now we pressed shift for freespectating
	if (!self.pers["autoSpectating"])
	{
		self.freeSpectating = true; // free spectating, not following any player
		self.autoSpectating_ESP = true; // by default enabled
		if (level.debug_spectator) self iprintln("meleeBtn> self.freeSpectating = ^2true");
	}

	while(self meleeButtonPressed())
		wait level.frame;

	if (self.pers["autoSpectating"])
	{
		autoSpectatorDisable();
		self iprintln(game["STRING_AUTO_SPECT_IS_DISABLED"]);

		self.freeSpectating = false; // no free spectating - we still follow the same player
		if (level.debug_spectator) self iprintln("attackBtn> self.freeSpectating = ^1false");
	}





	self.waitForMeleeKeyRelease = false;
}

handleUseButtonPress()
{
	self endon("disconnect");

	// if is pressed for 0.5 sec
	holded = false;
	i = 0;
	while(self useButtonPressed())
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
		self.autoSpectating_ESP = !self.autoSpectating_ESP;
		if (self.autoSpectating_ESP) 	self iprintln(game["STRING_AUTO_SPECT_NAMES_ON"]);
		else				self iprintln(game["STRING_AUTO_SPECT_NAMES_OFF"]);
	}
	else
	{
		if (level.debug_spectator) self iprintln("(menu was opened)");

		if (!self.pers["autoSpectating"])
		{
			self autoSpectatorEnable();
			self iprintln(game["STRING_AUTO_SPECT_IS_ENABLED"]);
		}

		self maps\mp\gametypes\_spectating_killcam::openSpectMenu();

		// Because session state is changed from spectator to dead for a frame, spectated player is stopped
		if (self.spectatorclient == -1)
			self.freeSpectating = true; // free spectating, not following any player
	}

	while(self useButtonPressed())
		wait level.frame;

	self.waitForUseKeyRelease = false;
}



keys_help()
{
	self endon("disconnect");

	self thread maps\mp\gametypes\_spectating_hud::keys_show();

	wait level.fps_multiplier * 5;

	self thread maps\mp\gametypes\_spectating_hud::keys_hide();
}







playerNames()
{
	self endon("disconnect");

	wait level.frame;

	// Wait untill readyup is over (used when timeout is called in time based gametypes and somebody connect)
	while(level.in_readyup || isDefined(self.spec_waypoint))
		wait level.fps_multiplier * 1;

	level.autoSpectating_refreshPlayerNames = false;
	self.spec_waypoint = [];

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player != self && (player.pers["team"] == "allies" || player.pers["team"] == "axis") && player.sessionstate == "playing")
		{
			index = self.spec_waypoint.size;
			self.spec_waypoint[index] = addHUDClient(self, 10, 10, 1.2, (1,1,1), "center", "bottom", "subleft", "subtop");
			self.spec_waypoint[index].name = "name";
			self.spec_waypoint[index].player = player;
			self.spec_waypoint[index].fontscale = 0.75;
			self.spec_waypoint[index].archived = false;
			self.spec_waypoint[index] SetPlayerNameString(player);
			self.spec_waypoint[index] thread SetPlayerWaypoint(self, player, (0, 0, 10));
			self.spec_waypoint[index] thread hud_watchPlayer(self, player);
		}
	}

	index = self.spec_waypoint.size;
	self.spec_waypoint[index] = addHUDClient(self, 0, 0, undefined, (1,1,1), "center", "middle", "center", "middle");
	self.spec_waypoint[index].name = "cross";
	self.spec_waypoint[index].player = self;
	self.spec_waypoint[index] setShader("white", 2, 2);
	self.spec_waypoint[index] thread hud_watchPlayer(self);


	self.spec_follow_text = addHUDClient(self, 0, -85, 1.2, (1,1,1), "center", "middle", "center", "bottom");
	self.spec_follow_text.fontscale = 1;
	self.spec_follow_text.alpha = 0;



	waypoints = self.spec_waypoint.size;
	saved_player_last = undefined;

	for(;;)
	{
		wait level.frame;

		// All needs to be removed (changed team or new player connected)
		if (self.pers["team"] != "spectator" || level.in_readyup || level.autoSpectating_refreshPlayerNames)
		{
			break;
		}

		saved_dist2D = 0;
		saved_dist3D = 0;
		saved_player = undefined;

		for(i = 0; i < waypoints; i++)
		{
			hud = self.spec_waypoint[i];

			// If HUD is not defined, it means player disconnect and HUD object was deleted
			if (!isDefined(hud))
				continue;

			if (hud.name != "name" || !isDefined(hud.player) || !isAlive(hud.player))
				continue;

			self.spec_waypoint[i].paused = !self.autoSpectating_ESP && !self.freeSpectating && self.pers["autoSpectating"];

			if (!self.freeSpectating)
				continue;


			dist3D = distance(self.origin, hud.player.origin);

			// If text is somewhere in rectangle around center
			if ((hud.x > 160 && hud.x < 480 && hud.y > 120 && hud.y < 360) || (dist3D < 300 && hud.x > 160 && hud.x < 480))
			{
				if (dist3D < 1000)
				{
					dist2D = distance((hud.x, hud.y, 0), (320, 240, 0));	// Distance of text from center - text is in 640x480 rectangle aligned left top

					if (!isDefined(saved_player) || (dist2D < saved_dist2D && dist3D < saved_dist3D))
					{
						saved_dist2D = dist2D;
						saved_dist3D = dist3D;
						saved_player = hud.player;
					}
				}
			}
		}

		time = 0.1;

		if (isDefined(saved_player))
		{
			if (isDefined(saved_player_last) && saved_player_last != saved_player)
			{
				self.spec_follow_text fadeOverTime(time);
				self.spec_follow_text.alpha = 0;
				wait level.fps_multiplier * time;
			}
			if (!isDefined(saved_player_last) || saved_player_last != saved_player)
			{
				self.spec_follow_text SetPlayerNameString(saved_player);
				self.spec_follow_text fadeOverTime(time);
				self.spec_follow_text.alpha = 1;
				wait level.fps_multiplier * time;
			}
		}
		else if (isDefined(saved_player_last))
		{
			self.spec_follow_text fadeOverTime(time);
			self.spec_follow_text.alpha = 0;
			wait level.fps_multiplier * time;
		}

		saved_player_last = saved_player;

		self.spec_follow = saved_player;
	}


	// Destroy all
	for(i = 0; i < waypoints; i++)
	{
		hud = self.spec_waypoint[i];

		// If HUD is not defined, it means player disconnect and HUD object was deleted
		if (!isDefined(hud))
			continue;

		hud destroy2();
	}
	self.spec_waypoint = undefined;

	self.spec_follow_text destroy2();

	// Run again
	if (level.autoSpectating_refreshPlayerNames)
	{
		level.autoSpectating_refreshPlayerNames = false;
		self thread playerNames();
	}
}


// self is HUD, spectator is hud owner and player is waypoined player
hud_watchPlayer(spectator, player)
{
	for (;;)
	{
		if (!isDefined(self))
			break;

		if (!isDefined(player))
		{
			self destroy2();
			break;
		}

		if (self.name == "name")
		{
			color = (0.8, 0.8, 0.8);
			if (player.sessionteam == "allies")
			{
				if(game["allies"] == "american")
					color = (0.4, 0.9, .56);
				else if(game["allies"] == "british")
					color = (0.45, 0.73, 1);
				else if(game["allies"] == "russian")
					color = (1, 0.4, 0.4);
			}
			self.color = color;

			// ESP for spectated player - show only enemy
			alpha = 0;
			if (!isDefined(spectator.killcam) && spectator.autoSpectating_ESP && !spectator.freeSpectating && spectator.pers["autoSpectating"])
			{
				if(isAlive(player) && isDefined(level.autoSpectating_spectatedPlayer) && level.autoSpectating_spectatedPlayer.sessionteam != player.sessionteam)
				{
					alpha = 1;

					// If is in center, add alpha
					dist2D = distance((self.x, self.y, 0), (320, 240, 0));	// Distance of text from center - text is in 640x480 rectangle aligned left top
					if (dist2D < 100)
					{
						alpha = dist2D / 100;
					}
				}
			}
			else if (!isDefined(spectator.killcam) && spectator.freeSpectating)
			{
				if (isAlive(player))
					alpha = 1;
				else
					alpha = 0.4;
			}

			self.alpha = alpha;
		}

		if (self.name == "cross")
		{
			if (spectator.freeSpectating)
				self.alpha = 1;
			else
				self.alpha = 0;
		}

		wait level.frame;
	}
}







autoSpectatorEnable()
{
	if (level.in_readyup)
		return;

	self.pers["autoSpectating"] = true;


	if(!isdefined(self.autoSpectatingBG))
	{
		self.autoSpectatingBG = newClientHudElem2(self);
		self.autoSpectatingBG.archived = false;
		self.autoSpectatingBG.x = -40;
		self.autoSpectatingBG.y = 40;
		self.autoSpectatingBG.horzAlign = "center";
		self.autoSpectatingBG.vertAlign = "top";
		self.autoSpectatingBG.alpha = 0.5;
		self.autoSpectatingBG setShader("black", 80, 10);
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

	self.autoSpectatingText setText(game["STRING_AUTO_SPECTATING"]);
}


autoSpectatorDisable()
{
	self.pers["autoSpectating"] = false;
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

	self thread maps\mp\gametypes\_spectating_hud::keys_hide();
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

	if (level.autoSpectating_ID == -1)
	{
		return;
	}

	player = level.autoSpectating_spectatedPlayer;

	stratime = 6; // 6
	if (isDefined(level.strat_time)) stratime = level.strat_time;
	length = stratime * 0.83333; // 5
	acceleration = stratime * 0.5; // 3
	deceleration = length - acceleration; // 2


	origin = player.origin - (0, 0, 20);
	angles = (12, player.angles[1] + 180, 0);
	forward = AnglesToForward(angles); // 1.0 scale

	dist = -50; // how far
	originStart = origin + (forward[0] * dist, forward[1] * dist, forward[2] * dist); // new pos

	dist = -50 + (-150 * (stratime / 6)); // how far
	originEnd = origin + (forward[0] * dist, forward[1] * dist, forward[2] * dist); // new pos

	//self iprintln(originStart);
	//self iprintln(originEnd);

	self.autoSpectating_inCinematic = true;

	self.freeSpectating = false; // free spectating ended, now following a player




	self.spectatorLock = spawn("script_model", originStart);
	self.spectatorLock.angles = angles;

	self setOrigin(originStart);
	self setPlayerAngles(angles);
	self linkto(self.spectatorLock);

	// 3 2.49 1.5  0.99

	self.spectatorLock moveTo(originEnd, length, acceleration, deceleration);

	startTime = getTime();
	for(;;)
	{
		if (self attackbuttonpressed() || self meleebuttonpressed())
			break;

		if ((gettime() - startTime) > (length * 1000))
			break;

		wait level.frame;
	}

	self unlink();

	self.autoSpectating_inCinematic = false;

	// If we are still in autospectator (not cnceled during cinematic)
	if (!self.pers["autoSpectating"])
		self.freeSpectating = true;
	else
		self.spectatorclient =  level.autoSpectating_ID;
}


getRecommandedPlayer()
{
	if (level.gametype != "sd")
	{
		return findBestPlayer();
	}

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


	selectedPlayer = undefined;


	// Team left
	if (game["round"] % 2 != 0)
	{
		if (game["round"] == 1)
		{
			// Find sniper of first team
			selectedPlayer = findSniper(teamLeft);
			game["spectatingSystem_recommandedPlayerMode_teamLeft_player"] = selectedPlayer;
		}
		if (game["round"] % 3 == 0) // every 3. rounds
		{
			// Find best player with the most kills
			selectedPlayer = findBestPlayer(teamLeft);
		}
	}
	// Team right
	else
	{
		if (game["round"] == 2)
		{
			// Find sniper of first team
			selectedPlayer = findSniper(teamRight);
			game["spectatingSystem_recommandedPlayerMode_teamRight_player"] = selectedPlayer;
		}
		else if ((game["round"]-1) % 3 == 0) // every 3. rounds
		{
			// Find best player with the most kills
			selectedPlayer = findBestPlayer(teamRight);
		}

	}


	// Find next player in row as default
	if (!isDefined(selectedPlayer))
	{
		// Team left
		if (game["round"] % 2 != 0)
		{
			selectedPlayer = getNextPlayerFrom(game["spectatingSystem_recommandedPlayerMode_teamLeft_player"], teamLeft);
			game["spectatingSystem_recommandedPlayerMode_teamLeft_player"] = selectedPlayer;

			printToAutoSpectators("Following next player in team " + teamLeft);
		}
		// Team right
		else
		{
			selectedPlayer = getNextPlayerFrom(game["spectatingSystem_recommandedPlayerMode_teamRight_player"], teamRight);
			game["spectatingSystem_recommandedPlayerMode_teamRight_player"] = selectedPlayer;

			printToAutoSpectators("Following next player in team " + teamRight);
		}

	}

	return selectedPlayer;
}

findSniper(team)
{
	selectedPlayer = undefined;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if ((player.pers["team"] == team) && player.sessionstate == "playing" && isDefined(player.pers["weapon"]))
		{
			weaponData = level.weapons[player.pers["weapon"]];

			if (isDefined(weaponData) && weaponData.classname == "sniper")
			{
				selectedPlayer = player;

				printToAutoSpectators("Following sniper in team " + team + ": " + player.name );
				//if (level.debug_spectator) printToAutoSpectators("Spect: selecting sniper: " + player.name + "  in team " + team);

				break;
			}
		}
	}
	return selectedPlayer;
}

findBestPlayer(team)
{
	lastPlayer = undefined;

	if (!isDefined(team))
		team = "all";

	// Select player to watch by score and time
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if ((team == "all" || player.pers["team"] == team) && player.sessionstate == "playing")
		{
			if (!isDefined(lastPlayer) ||
			  player.score > lastPlayer.score ||
			  (player.score == lastPlayer.score && player.deaths < lastPlayer.deaths))
				lastPlayer = player;
		}
	}

	if (isDefined(lastPlayer))
	{
		printToAutoSpectators("Following best player in team " + team + ": " + lastPlayer.name );
		//if (level.debug_spectator) printToAutoSpectators("Spect: selecting best player: " + lastPlayer.name + "  in team " + team);
		return lastPlayer;
	}
	else
		return undefined;
}

getPreviousPlayerFrom(actualSpectatedPlayer, team)
{
	return getPlayerFrom(actualSpectatedPlayer, team, true);
}

getNextPlayerFrom(actualSpectatedPlayer, team)
{
	return getPlayerFrom(actualSpectatedPlayer, team, false);
}


getPlayerFrom(actualSpectatedPlayer, team, reverse)
{
	selectedPlayer = undefined;
	useNextId = false;
/*
	if (isDefined(actualSpectatedPlayer))
		iprintln("getNextPlayerFrom " + actualSpectatedPlayer.name);
	else
		iprintln("getNextPlayerFrom undefined");
*/

	// Join teams
	players = maps\mp\gametypes\_spectating_hud::getPlayersSortedByScore();
	playersFinal = [];
	if (!isDefined(team) || team == "allies")
	{
		for (i = 0; i < players.size; i++)
		{
			if (players[i].pers["team"] == "allies")
				playersFinal[playersFinal.size] = players[i];
		}
	}
	// PLayers from allies should be selected, but the team is empty -> follow from both teams
	if (isDefined(team) && team == "allies" && playersFinal.size == 0)
		return getPlayerFrom(actualSpectatedPlayer, undefined, reverse);


	if (!isDefined(team) || team == "axis")
	{
		for (i = 0; i < players.size; i++)
		{
			if (players[i].pers["team"] == "axis")
				playersFinal[playersFinal.size] = players[i];
		}
	}
	// PLayers from allies should be selected, but the team is empty -> follow from both teams
	if (isDefined(team) && team == "axis" && playersFinal.size == 0)
		return getPlayerFrom(actualSpectatedPlayer, undefined, reverse);


	for(i = 0; i < playersFinal.size; i++)
	{
		player = playersFinal[i];

		//iprintln("--" + player.name);

		// Skip dead players
		if (player.sessionstate != "playing")
			continue;


		if (reverse)
		{
			// Previous player is saved in selectedPlayer
			if (isDefined(selectedPlayer) && isDefined(actualSpectatedPlayer) && actualSpectatedPlayer == player)
				break;

			selectedPlayer = player;
		}
		else
		{
			// Save first player in case actually folowed player is the last one
			if (!isDefined(selectedPlayer))
				selectedPlayer = player;

			if (useNextId)
			{
				selectedPlayer = player;
				break;
			}

			// If this player is actually followed, next player is the one we will follow next
			if (isDefined(actualSpectatedPlayer) && actualSpectatedPlayer == player)
				useNextId = true;
		}




	}

	// Debug print
	if (isDefined(selectedPlayer))
	{
		teamStr = "from both teams"; if (isDefined(team)) teamStr = "in team " + team;
		if (level.debug_spectator) printToAutoSpectators("Spect: selecting next player "+teamStr+": " + selectedPlayer.name);
	}

	return selectedPlayer;
}



followPlayer(selectedPlayer)
{
	level.autoSpectating_ID = selectedPlayer getEntityNumber();
	level.autoSpectating_spectatedPlayer = selectedPlayer;
	level.autoSpectating_lastChange = getTime();

	//if (level.debug_spectator) printToAutoSpectators("Spect: set followed player: " + selectedPlayer.name);
}

followPlayer_nonAutoSpec(selectedPlayer)
{
	self.spectatorclient = selectedPlayer getEntityNumber();

	wait level.frame;

	self.spectatorclient = -1;
}

followNextPlayer()
{
	selectedPlayer = undefined;

	// First try to find player from the same team
	if (isDefined(level.autoSpectating_spectatedPlayer))
	{
		selectedPlayer = getNextPlayerFrom(level.autoSpectating_spectatedPlayer, level.autoSpectating_spectatedPlayer.pers["team"]);
	}

	// If not found, select from both teams
	if (!isDefined(selectedPlayer))
	{
		selectedPlayer = getNextPlayerFrom(level.autoSpectating_spectatedPlayer);
	}

	if (isDefined(selectedPlayer))
	{
		followPlayer(selectedPlayer);
	}
}



playersCanSeeEachOthers()
{
	for (;;)
	{
		// Not enabled, wait
		if (!level.autoSpectating_do)
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
		}

		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if (!isDefined(player)) continue; // because of wait player may be disconnected

			if ((player.pers["team"] == "allies" || player.pers["team"] == "axis") && (player.sessionstate == "playing"))
			{
				eye = player maps\mp\gametypes\global\player::getEyeOrigin();
				angles = player getPlayerAngles();

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
						}
					}
				}

			}

			wait level.frame;
		}

		wait level.fps_multiplier * .1;
	}

}



playersCloseToEachOther()
{
	for (;;)
	{
		// Not enabled, wait
		if (!level.autoSpectating_do)
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











autoFollowedPlayer()
{
	level.autoSpectating_HUD_text = "STRING_AUTO_SPECTATING";


	selectedPlayer = getRecommandedPlayer();

	// For cinematic
	if (isDefined(selectedPlayer))
	{
		level followPlayer(selectedPlayer);

		if (!isDefined(level.in_bash) || !level.in_bash) // ignore cinematic in bash mode
		{
			// Do cinematic move for all spectators
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				player = players[i];

				if (player.pers["team"] == "spectator" && player.pers["autoSpectating"])
					player thread cinematicMove();
			}
		}

		level.autoSpectating_noSwitchUntill = gettime() + 12000; // wait some time untill next change
	}


	followed_team_last = "";
	for(;;)
	{
		wait level.fps_multiplier * 0.1;

		players = getentarray("player", "classname");

		// No players, pause loop
		if (players.size == 0)
			continue;

		// In timeout
		if (level.in_readyup)
			continue;

		canSwitch = (gettime() - level.autoSpectating_noSwitchUntill) > 0;


		id = level.autoSpectating_ID;
		spectated_player = level.autoSpectating_spectatedPlayer;

		if (id == -1 || !isDefined(spectated_player) || !isPlayer(spectated_player))
		{
			level followNextPlayer();
			if (level.debug_spectator) printToAutoSpectators("(no one was followed)");
			level.autoSpectating_noSwitchUntill = gettime() + 6000; // wait some time untill next change
			continue;
		}

		// If followed player is dead, follow next
		if (spectated_player.sessionstate != "playing")
		{
			wait level.fps_multiplier * 1;

			level followNextPlayer();
			if (level.debug_spectator) printToAutoSpectators("(followed player died)");
			level.autoSpectating_noSwitchUntill = gettime() + 6000; // wait some time untill next change
			level.autoSpectating_HUD_text = "STRING_AUTO_SPECTATING";
			continue;
		}

		if (!canSwitch)
		{
			// Player has visible enemy on their screen or enemy is seeing this player or their screen
			// Extent time for this player
			if (isDefined(spectated_player.autospectator_visibleEnemy) || isDefined(spectated_player.autospectator_seenByEnemy))
			{
				if (level.debug_spectator) printToAutoSpectators("Extending time for this player (visisble enemy)");
				level.autoSpectating_noSwitchUntill = gettime() + 8000;
				level.autoSpectating_HUD_text = "STRING_AUTO_SPECTATING_REASON_VISIBLE_ENEMY";
				wait level.fps_multiplier * 1;
			}

			// Dont continue untill we can switch
			continue;
		}

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
						level followPlayer(player);
						if (level.debug_spectator) printToAutoSpectators(switch_reason);
						level.autoSpectating_noSwitchUntill = gettime() + 1000; // wait some time untill next change
						level.autoSpectating_HUD_text = hud_text;
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
					level followPlayer(level.planting_player);
					if (level.debug_spectator) printToAutoSpectators("Bomb planted, following planter");
					level.autoSpectating_noSwitchUntill = gettime() + 4000; // wait some time untill next change
					level.autoSpectating_HUD_text = "STRING_AUTO_SPECTATING_REASON_BOMB_PLANTED";
					continue;
				}
			}
			else
			{
				if (game["allies_score"] < game["axis_score"])		followed_team = "allies";
       			 	else if (game["allies_score"] > game["axis_score"])	followed_team = "axis";
       			 	if (level.debug_spectator && followed_team != followed_team_last) printToAutoSpectators("bomb planted, following lower score team:" + followed_team);
				level.autoSpectating_HUD_text = "STRING_AUTO_SPECTATING_REASON_BOMB_SCORE";
			}
		}

		// In HQ, follow team that is defending the hq
		if (level.gametype == "hq" && (level.DefendingRadioTeam == "allies" || level.DefendingRadioTeam == "axis"))
		{
			followed_team = level.DefendingRadioTeam;
			if (level.debug_spectator && followed_team != followed_team_last) printToAutoSpectators("following defending radio team: " + followed_team);
			level.autoSpectating_HUD_text = "STRING_AUTO_SPECTATING_REASON_RADIO_DEFEND";
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

				// Too long no change, find players very close together to follow
				if ((gettime() - level.autoSpectating_lastChange) > 16000)
				{
					// Enemy is seeing this player or their screen
					if (isDefined(player.autospectator_seenByEnemy))
					{
						follow = true;
						switch_reason = "Is visible on enemy screen";
						hud_text = "STRING_AUTO_SPECTATING_REASON_VISIBLE_BY_ENEMY";
					}
					// Player very close to each other (< 800)
					else if (isDefined(player.autoSpectating_veryCloseToEnemy) && spectated_player != player)
					{
						follow = true;
						switch_reason = "No action - close enemy near by";
						hud_text = "STRING_AUTO_SPECTATING_REASON_NO_ACTION_NEARBY";
					}
					else if (player.isMoving)
					{
						follow = true;
						switch_reason = "No action - moving player";
						hud_text = "STRING_AUTO_SPECTATING_REASON_NO_ACTION_MOVING";
					}
				}

				if (follow)
				{
					level followPlayer(player);

					if (level.debug_spectator) printToAutoSpectators(switch_reason);

					level.autoSpectating_noSwitchUntill = gettime() + 8000;

					level.autoSpectating_HUD_text = hud_text;

					break;
				}
			}
		}






	}
}
