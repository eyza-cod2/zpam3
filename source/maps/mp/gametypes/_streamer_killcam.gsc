#include maps\mp\gametypes\global\_global;

init()
{
	if (!level.streamerSystem)
		return;

	if(game["firstInit"])
	{
		precacheString2("STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL", &"Press ^3[F]^7 to replay ^2multi-kill ^7 of:");
		precacheString2("STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL_2", &"Press ^3[F]^7 to replay ^22 kills ^7 of:");
		precacheString2("STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL_3", &"Press ^3[F]^7 to replay ^23 kills ^7 of:");
		precacheString2("STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL_4", &"Press ^3[F]^7 to replay ^24 kills ^7 of:");
		precacheString2("STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL_5", &"Press ^3[F]^7 to replay ^25 kills ^7 of:");
		precacheString2("STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_NOZOOM", &"Press ^3[F]^7 to replay ^2nozoom ^7 of:");
		precacheString2("STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_BASH", &"Press ^3[F]^7 to replay ^2bash ^7 of:");

		precacheString2("STRING_STREAMERSYSTEM_KILLCAM_REPLAY", &"Streamer killcam replay");
	}


	level.streamerSystem_killcam_kills = [];
	level.streamerSystem_killcam_proposingTime = 6;		// in seconds
	level.streamerSystem_killcam_intenseSituation = false;

	level thread watchIntenseSituation();

	addEventListener("onConnected",  ::onConnected);
	addEventListener("onPlayerKilled",  ::onPlayerKilled);
        addEventListener("onMenuResponse",  ::onMenuResponse);
}

onConnected()
{
	self.streamerSystem_killcam_indexes = [];
	self.streamerSystem_killcam_proposingVisible = false;

	if (self.pers["team"] == "streamer")
		self HUD_SetRowsInMenu(); // set "No record to play!"
}

/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu == game["menu_streamersystem"])
	{
		if (response == "killcam_open")
		{
			self HUD_SetRowsInMenu();

			return true;
		}
		else if (response == "killcam_close")
		{
			return true;
		}
		else
		{
			i = -1;
	    		switch(response)
			{
				case "killcam_1": i = 0; break;
				case "killcam_2": i = 1; break;
				case "killcam_3": i = 2; break;
				case "killcam_4": i = 3; break;
				case "killcam_5": i = 4; break;
				case "killcam_6": i = 5; break;
				case "killcam_7": i = 6; break;
				case "killcam_8": i = 7; break;
				case "killcam_9": i = 8; break;
				case "killcam_0": i = 9; break;
			}

			if (i > -1)
			{
				if (i < self.streamerSystem_killcam_indexes.size)
					replayAction(self.streamerSystem_killcam_indexes[i], true);
				else
					self iprintln("^1Not existing record");

				return true;
			}
		}
	}
}


onPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	save = (level.gametype == "sd" && !level.in_readyup && level.roundstarted && !level.roundended) || (level.gametype != "sd" && level.matchstarted && !level.mapended);

	if (isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self && save)
	{
		killRecord = spawnstruct();
		killRecord.player = eAttacker;
		killRecord.time = gettime();
		killRecord.timeFirst = killRecord.time;
		killRecord.kills = 1;
		killRecord.fullyFollowedBySpectator = isDefined(level.streamerSystem_player) && eAttacker == level.streamerSystem_player;
		killRecord.followedKillsBySpectator = killRecord.fullyFollowedBySpectator * 1; // how many kills were watched by spectator
		killRecord.nozoom = (eAttacker playerAds() == 0) && (distance(eAttacker.origin, self.origin) > 800) && (sMeansOfDeath != "MOD_GRENADE_SPLASH") && sWeapon != "mg42_bipod_stand_mp" && sWeapon != "30cal_stand_mp";
		killRecord.bash = sMeansOfDeath == "MOD_MELEE";
		killRecord.grenade = sMeansOfDeath == "MOD_GRENADE_SPLASH";
		killRecord.bombPlanted = (level.gametype == "sd" && level.bombplanted);
		killRecord.lastKill = (level.gametype == "sd" && level.exist[self.pers["team"]] == 1);
		killRecord.deleted = false;

		for (i = level.streamerSystem_killcam_kills.size-1; i >= 0; i--)
		{
			lastRecord = level.streamerSystem_killcam_kills[i];

			if (lastRecord.deleted) continue;

			timeAgo = gettime() - lastRecord.time;

			if (timeAgo > 6000) break; // look only for records in last 6 sec

			// Find record with the same guy
			if (isDefined(lastRecord.player) && lastRecord.player == eAttacker)
			{
				killRecord.fullyFollowedBySpectator = killRecord.fullyFollowedBySpectator && level.streamerSystem_killcam_kills[i].fullyFollowedBySpectator;
				killRecord.followedKillsBySpectator += level.streamerSystem_killcam_kills[i].followedKillsBySpectator;
				killRecord.nozoom = killRecord.nozoom || level.streamerSystem_killcam_kills[i].nozoom;
				killRecord.bash = killRecord.bash || level.streamerSystem_killcam_kills[i].bash;
				killRecord.grenade = level.streamerSystem_killcam_kills[i].grenade;	// first kill was grenade (need more time)
				killRecord.lastKill = killRecord.lastKill || level.streamerSystem_killcam_kills[i].lastKill;
				killRecord.timeFirst = level.streamerSystem_killcam_kills[i].timeFirst;
				killRecord.kills += level.streamerSystem_killcam_kills[i].kills;

				level.streamerSystem_killcam_kills[i].deleted = true;

				break;
			}
		}

		// Add new
		id = level.streamerSystem_killcam_kills.size;
		level.streamerSystem_killcam_kills[level.streamerSystem_killcam_kills.size] = killRecord;

		level thread potencialAutoKillcam(id);
	}
}

potencialAutoKillcam(killId)
{
	record = level.streamerSystem_killcam_kills[killId];

	// Is this action interesting to watch
	isInterestingAction = (record.kills >= 2 || record.nozoom || record.bash);

	// If bomb is planted, replay last kill only if there is enught time
	replayLastKill = true;
	if(record.lastKill && level.gametype == "sd")
	{
		if (level.bombplanted)
		{
			remaining = level.bombtimer - (gettime() - level.bombtimerstart) / 1000; // decimal seconds
			if (remaining < 25)
				replayLastKill = false;
		}
	}


	// Replay last kill if it was not fully spectated, or if it was interesting action (even if it was already replayed)
	if (record.lastKill && replayLastKill && (!record.fullyFollowedBySpectator || isInterestingAction))
	{
		wait level.fps_multiplier * 1.5;

		// Replay action for all spectators
		replayActionForAll(killId);

		return;
	}

	if (isInterestingAction)
	{
		// Replay action for all spectators
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.pers["team"] == "streamer" && player.streamerSystem_turnedOn)
			{
				player thread potencialAutoKillcamForPlayer(killId);
			}
		}
	}
}

potencialAutoKillcamForPlayer(killId)
{
	self endon("disconnect");

	// Wait untill this player does not see enemy no more - then we can replay killcam
	// If player kills another enemy, this record is deleted, this thread ends and new thread is created
	time_killer_no_enemy = 0;
	time_spectated_no_enemy = 0;
	record = level.streamerSystem_killcam_kills[killId];
	for(;;)
	{
		wait level.frame;

		if (self.pers["team"] != "streamer")
			break;

		if (record.deleted || !isDefined(record.player))
			return;

		if ((gettime() - record.timeFirst) > 40000)
			return;

		// If round ended change it to auto-replay
		if (level.gametype == "sd" && level.roundended)
		{
			wait level.fps_multiplier * 1.5; // wait untill killcam for last kill is played as first (if there is no killcam, it will start this one)
			wait level.frame;

			self thread replayAction(killId, false);

			break;
		}

		// Dont replay this action if it was fully followed (keep it in loop if round ended and we replay it again)
		if (record.fullyFollowedBySpectator)
			continue;

		if (isDefined(self.killcam))
			continue;

		if (level.streamerSystem_killcam_intenseSituation)
			continue;

		// Killer does not see more enemy for 3 seconds (action is finished)
		if (!isDefined(record.player.autospectator_visibleEnemy))
			time_killer_no_enemy += 0.05;
		else
			time_killer_no_enemy = 0;

		// Spectated player does not see enemy for 3 seconds (to avoid switch before some interesting action)
		if (!isDefined(level.streamerSystem_player) || !isDefined(level.streamerSystem_player.autospectator_visibleEnemy))
			time_spectated_no_enemy += 0.05;
		else
			time_spectated_no_enemy = 0;


		// No action for few seconds and no killcam proposal is active
		if (time_killer_no_enemy >= 3 && time_spectated_no_enemy >= 3 && !self.streamerSystem_killcam_proposingVisible)
		{
			// Show killcam proposal
			self thread showKillcamProposingForPlayer(killId);

			// While proposing is visible, watch for round end or active killcam replay (in that case cancel proposing)
			while(self.streamerSystem_killcam_proposingVisible)
			{
				// If round ended whole we were proposing for killcam, change it to auto-replay
				if (level.gametype == "sd" && level.roundended)
				{
					self thread hideKillcamProposingForPlayer();

					wait level.fps_multiplier * 1.5; // wait untill killcam for last kill is played as first (if there is no killcam, it will start this one)
					wait level.frame;

					self thread replayAction(killId, false);

					break;
				}

				// In any other case if killcam is started other way, cancel proposing
				if (isDefined(self.killcam))
				{
					self thread hideKillcamProposingForPlayer();
					break;
				}

				// Player changed team
				if (self.pers["team"] != "streamer")
				{
					self thread hideKillcamProposingForPlayer();
					return;
				}

				wait level.frame;
			}

			break;
		}
	}
}

showKillcamProposingForPlayer(killId)
{
	self endon("disconnect");

	if (self.streamerSystem_killcam_proposingVisible)
		return;

	self.streamerSystem_killcam_proposingVisible = true;

	record = level.streamerSystem_killcam_kills[killId];
	time = level.streamerSystem_killcam_proposingTime;
	disableTime = 1.5;
	prematureEnd = .5;
	fadeOutTime = 0.25;


	if(!isdefined(self.autoSpectating_KillcamProposingBG))
		self.autoSpectating_KillcamProposingBG = addHUDClient(self, -80, 410, undefined, undefined, undefined, undefined, "center", "top"); // addHUDClient(player, x, y, fontSize, color, alignX, alignY, horzAlign, vertAlign)
	self.autoSpectating_KillcamProposingBG.archived = false;
	self.autoSpectating_KillcamProposingBG.sort = -1;
	self.autoSpectating_KillcamProposingBG.alpha = 0.7;
	self.autoSpectating_KillcamProposingBG setShader("black", 160, 22);


	if(!isdefined(self.autoSpectating_KillcamProposingBGline))
		self.autoSpectating_KillcamProposingBGline = addHUDClient(self, -80, 410+22, undefined, undefined, undefined, undefined, "center", "top"); // addHUDClient(player, x, y, fontSize, color, alignX, alignY, horzAlign, vertAlign)
	self.autoSpectating_KillcamProposingBGline.archived = false;
	self.autoSpectating_KillcamProposingBGline.alpha = 1;
	self.autoSpectating_KillcamProposingBGline setShader("black", 160, 2);


	if(!isdefined(self.autoSpectating_KillcamProposingText))
		self.autoSpectating_KillcamProposingText = addHUDClient(self, 0, 410+2, 0.7, (1,1,1), "center", "top", "center", "top");
	self.autoSpectating_KillcamProposingText.archived = false;
	if (record.nozoom && record.kills == 1) 	self.autoSpectating_KillcamProposingText setText(game["STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_NOZOOM"]);
	else if (record.bash && record.kills == 1)	self.autoSpectating_KillcamProposingText setText(game["STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_BASH"]);
	else if (record.kills == 2)			self.autoSpectating_KillcamProposingText setText(game["STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL_2"]);
	else if (record.kills == 3)			self.autoSpectating_KillcamProposingText setText(game["STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL_3"]);
	else if (record.kills == 4)			self.autoSpectating_KillcamProposingText setText(game["STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL_4"]);
	else if (record.kills == 5)			self.autoSpectating_KillcamProposingText setText(game["STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL_5"]);
	else						self.autoSpectating_KillcamProposingText setText(game["STRING_STREAMERSYSTEM_KILLCAM_PROPOSAL_KEY_MULTIKILL"]);


	if(!isdefined(self.autoSpectating_KillcamProposingPlayer))
		self.autoSpectating_KillcamProposingPlayer = addHUDClient(self, 0, 410+12, 0.7, (1,1,1), "center", "top", "center", "top");
	self.autoSpectating_KillcamProposingPlayer.archived = false;
	self.autoSpectating_KillcamProposingPlayer SetPlayerNameString(record.player);



	self.autoSpectating_KillcamProposingBG fadeOverTime(time);
	self.autoSpectating_KillcamProposingBGline fadeOverTime(time);
	self.autoSpectating_KillcamProposingText fadeOverTime(time);
	self.autoSpectating_KillcamProposingPlayer fadeOverTime(time);
	self.autoSpectating_KillcamProposingBGline scaleovertime(time, 1, 2); // time, new_with, new_height

	self.autoSpectating_KillcamProposingBG.alpha = .4;
	self.autoSpectating_KillcamProposingBGline.alpha = .4;
	self.autoSpectating_KillcamProposingText.alpha = .75;
	self.autoSpectating_KillcamProposingPlayer.alpha = .75;

	// Wait a while before we allow key Press to be registered
	wait level.fps_multiplier * disableTime;
	time -= disableTime;

	if (!self.streamerSystem_killcam_proposingVisible)
		return;

	self thread killcamProposingKey(killId);

	wait level.fps_multiplier * time;

	if (!self.streamerSystem_killcam_proposingVisible)
		return;

	self.autoSpectating_KillcamProposingBG fadeOverTime(fadeOutTime);
	self.autoSpectating_KillcamProposingBGline fadeOverTime(fadeOutTime);
	self.autoSpectating_KillcamProposingText fadeOverTime(fadeOutTime);
	self.autoSpectating_KillcamProposingPlayer fadeOverTime(fadeOutTime);

	self.autoSpectating_KillcamProposingBG.alpha = 0;
	self.autoSpectating_KillcamProposingBGline.alpha = 0;
	self.autoSpectating_KillcamProposingText.alpha = 0;
	self.autoSpectating_KillcamProposingPlayer.alpha = 0;

	wait level.fps_multiplier * prematureEnd;

	if (!self.streamerSystem_killcam_proposingVisible)
		return;

	self hideKillcamProposingForPlayer();
}

killcamProposingKey(killId)
{
	self endon("disconnect");

	for(;;)
	{
		if (!self.streamerSystem_killcam_proposingVisible)
			break;

		if (self useButtonPressed())
		{
			// wait untill is released
			while (self useButtonPressed())
				wait level.frame;

			self thread hideKillcamProposingForPlayer();

			self thread replayAction(killId, false);

			break;
		}

		wait level.frame;
	}

}

hideKillcamProposingForPlayer()
{
	if(isdefined(self.autoSpectating_KillcamProposingBG))
	{
		self.autoSpectating_KillcamProposingBG destroy2();
		self.autoSpectating_KillcamProposingBG = undefined;
	}
	if(isdefined(self.autoSpectating_KillcamProposingBGline))
	{
		self.autoSpectating_KillcamProposingBGline destroy2();
		self.autoSpectating_KillcamProposingBGline = undefined;
	}
	if(isdefined(self.autoSpectating_KillcamProposingText))
	{
		self.autoSpectating_KillcamProposingText destroy2();
		self.autoSpectating_KillcamProposingText = undefined;
	}
	if(isdefined(self.autoSpectating_KillcamProposingPlayer))
	{
		self.autoSpectating_KillcamProposingPlayer destroy2();
		self.autoSpectating_KillcamProposingPlayer = undefined;
	}


	self.streamerSystem_killcam_proposingVisible = false;
}



watchIntenseSituation()
{
	intenseSituationTime = 0;
	lastIntenseSituation = false;

	for (;;)
	{
		wait level.fps_multiplier * 1;

		// Count numbers of players in teams
		alliesAlive = 0;
		axisAlive = 0;
		teamPlayersCount = 0;
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if ((player.pers["team"] == "allies" || player.pers["team"] == "axis"))
			{
				// Count alive players
				if (player.sessionstate == "playing") // dead players are players in spectator session state
				{
					if (player.pers["team"] == "allies")
						alliesAlive++;
					else
						axisAlive++;
				}
				teamPlayersCount++;
			}
		}

		// In 5v5 it means there are only 1 or 2 player alive in team
		if (teamPlayersCount > 0 && ((alliesAlive / (teamPlayersCount / 2)) <= 0.5 || (axisAlive / (teamPlayersCount / 2)) <= 0.5))
			intenseSituationTime++;
		else
			intenseSituationTime = 0;

		// Intense situation is after 3 seconds elapse
		level.streamerSystem_killcam_intenseSituation = (intenseSituationTime > 3);



		//if (level.streamerSystem_killcam_intenseSituation != lastIntenseSituation)
		//	println("^3intenseSituation: " + level.streamerSystem_killcam_intenseSituation);

		lastIntenseSituation = level.streamerSystem_killcam_intenseSituation;
	}
}



HUD_SetRowsInMenu()
{
	self.streamerSystem_killcam_indexes = [];

	str = "";
	row = 0;
	for (i = level.streamerSystem_killcam_kills.size-1; i >= 0; i--)
	{
		record = level.streamerSystem_killcam_kills[i];

		if (record.deleted) continue;
		if (!isDefined(record.player)) continue;
		if ((gettime() - record.time) > 37000) continue; // 40 seconds is a maximum that killcam can replay

		self.streamerSystem_killcam_indexes[row] = i;

		str += (row+1) + ".   " + getTimeString(record.time, record.bombPlanted) + "  " + record.player.name + "^7   ("+record.kills+" kill)\n";
		row++;
	}

	if (str == "")
		self setClientCvar2("ui_spectatorsystem_menu_text", "No record to play!");
	else
		self setClientCvar2("ui_spectatorsystem_menu_text", str);
}


getTimeString(time, bombPlanted)
{
	if (level.gametype == "sd")
	{
		if (bombplanted)
			return "B " + formatTime(int(level.bombtimer - int((time - level.bombtimerstart)/1000)));
		else
			return formatTime(level.strat_time + int((level.roundlength * 60) - int((time - level.starttime)/1000)));
	}
	else
		return formatTime(int((level.timelimit * 60) - (int((time - level.starttime)/1000)) - level.timeout_elapsedTime));
}

replayActionForAll(killId)
{
	// Replay action for all spectators
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player.pers["team"] == "streamer" && player.streamerSystem_turnedOn)
		{
			player thread replayAction(killId, false);
		}
	}
}


replayAction(killId, print)
{
	self endon("disconnect");

	// Already in killcam, wait for end
	while(isDefined(self.killcam))
		wait level.frame;

	record = level.streamerSystem_killcam_kills[killId];

	if (!isDefined(record))
	{
		if (print || level.debug_spectator) self iprintln("^1Invalid record");
		return;
	}

	if (!isDefined(record.player))
	{
		if (print || level.debug_spectator) self iprintln("^1Selected player disconnects!");
		return;
	}

	if ((gettime() - record.timeFirst) > 40000)
	{
		if (print || level.debug_spectator) self iprintln("^1Record is too old and can not be replayed");

		return;
	}

	if (level.debug_spectator)
		self iprintln("Playing killcam for: " + record.player.name);

	timeBeforeKill = 2.5;
	timeAfterKill = 1.5;

	// First kill was grenade, need more time
	if (record.grenade)
		timeBeforeKill += 3;

	// Time between kills (0 if is single kill)
	actionTime = 0;
	if (record.time > record.timeFirst)
		actionTime = int((record.time - record.timeFirst)/1000);

	pastTime = timeBeforeKill + int((gettime() - record.timeFirst) / 1000);

	self maps\mp\gametypes\_killcam::killcam(record.player getEntityNumber(), pastTime, (timeBeforeKill + actionTime + timeAfterKill), 0, false, true); // killcam(attackerNum, pastTime, length, offsetTime, respawn, isReplay)
}
