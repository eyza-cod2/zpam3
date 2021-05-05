#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onSpawnedPlayer", ::onSpawnedPlayer);

	if (!level.spectatingSystem)
		return;

	level.autoSpectating_kills = [];

	addEventListener("onConnected",  ::onConnected);
	addEventListener("onPlayerKilled",  ::onPlayerKilled);
        addEventListener("onMenuResponse",  ::onMenuResponse);
}

onConnected()
{
	self.autoSpectating_killIndexes = [];

	if (!level.in_readyup)
	{
		spectMenuSetRows(); // set No record to play!
	}
}

onSpawnedPlayer()
{
	// We have to make sure that this cvar is defined, otherwise quickmessages menu will not work
	self setClientCvar2("ui_quickmessage_spectatormode", "0");
}


onPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	if (isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self && level.roundstarted && !level.roundended)
	{
		killRecord = spawnstruct();
		killRecord.player = eAttacker;
		killRecord.time = gettime();
		killRecord.timeFirst = killRecord.time;
		killRecord.kills = 1;
		killRecord.bombPlanted = level.bombplanted;
		killRecord.deleted = false;

		for (i = level.autoSpectating_kills.size-1; i >= 0; i--)
		{
			lastRecord = level.autoSpectating_kills[i];

			if (lastRecord.deleted) continue;

			timeAgo = gettime() - lastRecord.time;

			if (timeAgo > 6000) break; // look only for records in last 6 sec

			// Find record with the same guy
			if (isDefined(lastRecord.player) && lastRecord.player == eAttacker)
			{
				killRecord.timeFirst = level.autoSpectating_kills[i].timeFirst;
				killRecord.kills += level.autoSpectating_kills[i].kills;

				level.autoSpectating_kills[i].deleted = true;

				break;
			}
		}

		// Add new
		level.autoSpectating_kills[level.autoSpectating_kills.size] = killRecord;
	}
}


/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu == game["menu_spectatingsystem"])
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

		if (i > -1 && i < self.autoSpectating_killIndexes.size)
			replayAction(self.autoSpectating_killIndexes[i]);
		else
			self iprintln("^1Not existing record");

		return true;
	}
}

openSpectMenu()
{
	self endon("disconnect");

	self.sessionteam = "none";
	self.sessionstate = "dead"; // enable quickmessage


	self setClientCvar2("ui_quickmessage_spectatormode", "1");

	spectMenuSetRows();

	// Exec command on client side
	// If some menu is already opened:
	//	- by player (by ESC command) -> it will work well over already opened menu
	//  - by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
	//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
	self setClientCvar2("exec_cmd", "mp_quickmessage");
	self openMenu(game["menu_exec_cmd"]);		// open menu via script
	self closeMenu();							// will only close menu opened by script

	wait level.frame;

	self.sessionteam = "spectator";
	self.sessionstate = "spectator";
}

spectMenuSetRows()
{
	self.autoSpectating_killIndexes = [];

	str = "";
	row = 0;
	for (i = level.autoSpectating_kills.size-1; i >= 0; i--)
	{
		record = level.autoSpectating_kills[i];

		if (record.deleted) continue;
		if (!isDefined(record.player)) continue;
		if ((gettime() - record.time) > 37000) continue; // 40 seconds is a maximum that killcam can replay

		self.autoSpectating_killIndexes[row] = i;

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
	if (bombplanted)
		return "B " + formatTime(int(level.bombtimer - int((time - level.bombtimerstart)/1000)));
	else
		return formatTime(level.strat_time + int((level.roundlength * 60) - int((time - level.starttime)/1000)));
}


replayAction(killId)
{
	record = level.autoSpectating_kills[killId];

	if (!isDefined(record.player))
	{
		self iprintln("^1Selected player disconnects!");
		return;
	}

	self iprintln("Playing killcam for: " + record.player.name);

	timeBeforeKill = 3;
	timeAfterKill = 1.5;

	// Time between kills (0 if is single kill)
	actionTime = 0;
	if (record.time > record.timeFirst)
		actionTime = int((record.time - record.timeFirst)/1000);

	pastTime = timeBeforeKill + int((gettime() - record.timeFirst) / 1000);

	self maps\mp\gametypes\_killcam::killcam(record.player getEntityNumber(), pastTime, (timeBeforeKill + actionTime + timeAfterKill), 0, false, true); // killcam(attackerNum, pastTime, length, offsetTime, respawn, isReplay)
}
