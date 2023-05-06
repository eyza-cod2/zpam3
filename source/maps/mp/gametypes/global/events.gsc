/*
This script implements new event system
Basicly script that need do some action based on some event will register function for that event
and if event happends, that function is called

(by eyza)

*/

Init()
{
	level.events = spawnstruct();
	level.events.onStartGameType = [];
	level.events.onConnecting = [];
	level.events.onConnected = [];
	level.events.onConnectedAll = [];
	level.events.onDisconnect = [];
	level.events.onSpawned = [];
	level.events.onSpawnedPlayer = [];
	level.events.onSpawnedSpectator = [];
	level.events.onSpawnedStreamer = [];
	level.events.onSpawnedIntermission = [];
	level.events.onJoinedTeam = [];
	level.events.onJoinedAlliesAxis = [];
	level.events.onJoinedSpectator = [];
	level.events.onJoinedStreamer = [];
	level.events.onPlayerDamaging = [];
	level.events.onPlayerDamaged = [];
	level.events.onPlayerKilling = [];
	level.events.onPlayerKilled = [];
	level.events.onCvarChanged = [];
	level.events.onMenuResponse = [];


	// Print events only in developer mode
	/#
	addListener("onStartGameType",    	::onStartGameType);

	addListener("onConnecting",    		::onConnecting);
	addListener("onConnected",     		::onConnected);
	addListener("onConnectedAll",     	::onConnectedAll);
	addListener("onDisconnect",    		::onDisconnect);

	addListener("onSpawned",           	::onSpawned);
	addListener("onSpawnedPlayer",     	::onSpawnedPlayer);
	addListener("onSpawnedSpectator",  	::onSpawnedSpectator);
	addListener("onSpawnedStreamer",  	::onSpawnedStreamer);

	addListener("onJoinedTeam",        	::onJoinedTeam);
	addListener("onJoinedAlliesAxis",  	::onJoinedAlliesAxis);
	addListener("onJoinedSpectator",   	::onJoinedSpectator);
	addListener("onJoinedStreamer",   	::onJoinedStreamer);

	addListener("onPlayerKilling",   	::onPlayerKilling);
	addListener("onPlayerKilled",   	::onPlayerKilled);
	addListener("onPlayerDamaging",   	::onPlayerDamaging);
	addListener("onPlayerDamaged",   	::onPlayerDamaged);

	//addListener("onCvarChanged", ::onCvarChanged);

	addListener("onMenuResponse",   	::onMenuResponse);
	#/
}


addListener(eventName, funcPointer)
{
	if (eventName == "onStartGameType")
		level.events.onStartGameType[level.events.onStartGameType.size] = funcPointer;

	else if (eventName == "onConnecting")
		level.events.onConnecting[level.events.onConnecting.size] = funcPointer;
	else if (eventName == "onConnected")
		level.events.onConnected[level.events.onConnected.size] = funcPointer;
	else if (eventName == "onConnectedAll")
		level.events.onConnectedAll[level.events.onConnectedAll.size] = funcPointer;
	else if (eventName == "onDisconnect")
		level.events.onDisconnect[level.events.onDisconnect.size] = funcPointer;

	else if (eventName == "onSpawned")
		level.events.onSpawned[level.events.onSpawned.size] = funcPointer;
	else if (eventName == "onSpawnedPlayer")
		level.events.onSpawnedPlayer[level.events.onSpawnedPlayer.size] = funcPointer;
	else if (eventName == "onSpawnedSpectator")
		level.events.onSpawnedSpectator[level.events.onSpawnedSpectator.size] = funcPointer;
	else if (eventName == "onSpawnedStreamer")
		level.events.onSpawnedStreamer[level.events.onSpawnedStreamer.size] = funcPointer;
	else if (eventName == "onSpawnedIntermission")
		level.events.onSpawnedIntermission[level.events.onSpawnedIntermission.size] = funcPointer;

	else if (eventName == "onJoinedTeam")
		level.events.onJoinedTeam[level.events.onJoinedTeam.size] = funcPointer;
	else if (eventName == "onJoinedAlliesAxis")
		level.events.onJoinedAlliesAxis[level.events.onJoinedAlliesAxis.size] = funcPointer;
	else if (eventName == "onJoinedSpectator")
		level.events.onJoinedSpectator[level.events.onJoinedSpectator.size] = funcPointer;
	else if (eventName == "onJoinedStreamer")
		level.events.onJoinedStreamer[level.events.onJoinedStreamer.size] = funcPointer;

	else if (eventName == "onPlayerDamaging")
		level.events.onPlayerDamaging[level.events.onPlayerDamaging.size] = funcPointer;
	else if (eventName == "onPlayerDamaged")
		level.events.onPlayerDamaged[level.events.onPlayerDamaged.size] = funcPointer;

	else if (eventName == "onPlayerKilling")
		level.events.onPlayerKilling[level.events.onPlayerKilling.size] = funcPointer;
	else if (eventName == "onPlayerKilled")
		level.events.onPlayerKilled[level.events.onPlayerKilled.size] = funcPointer;

	else if (eventName == "onCvarChanged")
		level.events.onCvarChanged[level.events.onCvarChanged.size] = funcPointer;

	else if (eventName == "onMenuResponse")
		level.events.onMenuResponse[level.events.onMenuResponse.size] = funcPointer;


	else
		assertMsg("Unknown event listener");
}


notifyConnecting()
{
	for (i = 0; i < level.events.onConnecting.size; i++)
		self thread [[level.events.onConnecting[i]]]();
}

notifyConnected()
{
	self endon("disconnect");

	// Create player entity - so getentarray("player", "classname"); can be used in "onConnected" event
	//self spawn((0, 0, 0),(0, 0, 0));

	self thread maps\mp\gametypes\global\player::BeforeOnConnected();

	// Additional events what need to be watched
	self thread _onSpawned();
	self thread _onSpawnedPlayer();
	self thread _onSpawnedSpectator();
	self thread _onSpawnedStreamer();
	self thread _onSpawnedIntermission();

	self thread _onJoinedTeam();
	self thread _onJoinedAlliesAxis();
	self thread _onJoinedSpectator();
	self thread _onJoinedStreamer();

	self thread _onMenuResponse();

	// Process onConnected events
	for (i = 0; i < level.events.onConnected.size; i++)
	{
		self thread [[level.events.onConnected[i]]]();
	}

	// Wait for other players to connect
	waittillframeend;

	// Notify "all_connected" once
	if (!isDefined(level.allPlayersConnected))
	{
		level.allPlayersConnected = true;

		// Process onConnectedAll events
		for (i = 0; i < level.events.onConnectedAll.size; i++)
			level thread [[level.events.onConnectedAll[i]]]();
	}
}


notifyDisconnect()
{
	// Process events
	for (i = 0; i < level.events.onDisconnect.size; i++)
		self thread [[level.events.onDisconnect[i]]]();

	self thread maps\mp\gametypes\global\player::AfterOnDisconnect();
}


notifyDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	// First loop onPlayerDamaging events that can prevent from the damage
	return_value = [];
	for (i = 0; i < level.events.onPlayerDamaging.size; i++)
		return_value[i] = self thread [[level.events.onPlayerDamaging[i]]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);

	for (i = 0; i < return_value.size; i++)
		if (isDefined(return_value[i]) && return_value[i])
			return true; // prevent damage
	return false;
}

notifyDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	// Do onPlayerDamaged event
	for (i = 0; i < level.events.onPlayerDamaged.size; i++)
		self thread [[level.events.onPlayerDamaged[i]]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}


notifyKilling(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	// First loop onPlayerKilling events that can prevent from the kill
	return_value = [];
	for (i = 0; i < level.events.onPlayerKilling.size; i++)
		return_value[i] = self thread [[level.events.onPlayerKilling[i]]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);

	for (i = 0; i < return_value.size; i++)
		if (isDefined(return_value[i]) && return_value[i])
			return true; // prevent kill
	return false;
}

notifyKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	// Do onPlayerKilled event
	for (i = 0; i < level.events.onPlayerKilled.size; i++)
		self thread [[level.events.onPlayerKilled[i]]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
}






_onSpawned()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned");
		self thread _onSpawnedCallEvents();
	}
}
_onSpawnedCallEvents()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	for (i = 0; i < level.events.onSpawned.size; i++)
		self thread [[level.events.onSpawned[i]]]();
}


_onSpawnedPlayer()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_player");
		self thread _onSpawnedPlayerCallEvents();
	}
}
_onSpawnedPlayerCallEvents()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	for (i = 0; i < level.events.onSpawnedPlayer.size; i++)
		self thread [[level.events.onSpawnedPlayer[i]]]();
}


_onSpawnedSpectator()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_spectator");
		self thread _onSpawnedSpectatorCallEvents();
	}
}
_onSpawnedSpectatorCallEvents()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	for (i = 0; i < level.events.onSpawnedSpectator.size; i++)
		self thread [[level.events.onSpawnedSpectator[i]]]();
}


_onSpawnedStreamer()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_streamer");
		self thread _onSpawnedStreamerCallEvents();
	}
}
_onSpawnedStreamerCallEvents()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	for (i = 0; i < level.events.onSpawnedStreamer.size; i++)
		self thread [[level.events.onSpawnedStreamer[i]]]();
}


_onSpawnedIntermission()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_intermission");
		self thread _onSpawnedIntermissionCallEvents();
	}
}
_onSpawnedIntermissionCallEvents()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	for (i = 0; i < level.events.onSpawnedIntermission.size; i++)
		self thread [[level.events.onSpawnedIntermission[i]]]();
}


_onJoinedTeam()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("joined", teamName);
		self thread _onJoinedTeamCallEvents(teamName);
	}
}
_onJoinedTeamCallEvents(teamName)
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	for (i = 0; i < level.events.onJoinedTeam.size; i++)
		self thread [[level.events.onJoinedTeam[i]]](teamName);
}


_onJoinedAlliesAxis()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("joined_allies_axis");
		self thread _onJoinedAlliesAxisCallEvents();
	}
}
_onJoinedAlliesAxisCallEvents()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	for (i = 0; i < level.events.onJoinedAlliesAxis.size; i++)
		self thread [[level.events.onJoinedAlliesAxis[i]]]();
}


_onJoinedSpectator()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("joined_spectators");
		self thread _onJoinedSpectatorCallEvents();
	}
}
_onJoinedSpectatorCallEvents()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	for (i = 0; i < level.events.onJoinedSpectator.size; i++)
		self thread [[level.events.onJoinedSpectator[i]]]();
}


_onJoinedStreamer()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("joined_streamers");
		self thread _onJoinedStreamerCallEvents();
	}
}
_onJoinedStreamerCallEvents()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	for (i = 0; i < level.events.onJoinedStreamer.size; i++)
		self thread [[level.events.onJoinedStreamer[i]]]();
}



_onMenuResponse()
{
	self endon("intermission");
	self endon("disconnect");

	for(;;)
	{
		self waittill("menuresponse", menu, response);

		/#
		println("##### " + gettime() + " " + level.frame_num + " ##### menuresponse("+menu+", "+response+"): " + self.name);
		#/

		// Process events
		self thread _onMenuResponseCallEvents(menu, response);
	}
}
_onMenuResponseCallEvents(menu, response)
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();
	// Call events one by one and if true is returned, it means menuresponse was handled and no other events need to be called
	for (i = 0; i < level.events.onMenuResponse.size; i++)
	{
		handled = self [[level.events.onMenuResponse[i]]](menu, response);
		if (isDefined(handled) && handled)
			break;
	}
}





notifyCvarChange(cvar, value, isRegisterTime)
{
	/#
	if (!isDefined(value))
	{
		assertMsg("OnCvarChange: cvar=" + cvar + ", value = undefined, isRegisterTime="+isRegisterTime);
	}
	#/
	return_value = [];
	for (i = 0; i < level.events.onCvarChanged.size; i++)
		return_value[i] = level thread [[level.events.onCvarChanged[i]]](cvar, value, isRegisterTime);

	for (i = 0; i < return_value.size; i++)
		if (isDefined(return_value[i]) && return_value[i])
			return;

	/#
	println("### Cvar " + cvar + " was registered, but is not handled in any function");
	#/
}






onStartGameType()
{
    if (getCvar("debug") == "1") iprintln(GetTime() + ": ^6CATCHED: onStartGameType");
}

onConnecting()
{
    if (getCvar("debug") == "1") iprintln(GetTime() + ": ^6CATCHED: connecting, "+self.name + "  entNum:" + self GetEntityNumber());
}

onConnected()
{
    if (getCvar("debug") == "1") iprintln(GetTime() + ": ^6CATCHED: connected, "+self.name + "  entNum:" + self GetEntityNumber());
}

onConnectedAll()
{
    if (getCvar("debug") == "1") iprintln(GetTime() + ": ^6CATCHED: connectedAll");
}

onDisconnect()
{
    if (getCvar("debug") == "1") iprintln(GetTime() + ": ^6CATCHED: disconnect, "+self.name);
}

onSpawned()
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: spawned, "+self.name);
}

onSpawnedPlayer()
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: spawned_player, "+self.name);
}

onSpawnedSpectator()
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: spawned_spectator, "+self.name);
}

onSpawnedStreamer()
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: spawned_streamer, "+self.name);
}

onJoinedTeam(teamName)
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: joined("+teamName+"), "+self.name);
}

onJoinedAlliesAxis()
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: joined_team, "+self.name);
}

onJoinedSpectator()
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: joined_spectators, "+self.name);
}

onJoinedStreamer()
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: joined_streamers, "+self.name);
}

onPlayerKilling(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: onPlayerKilling, "+self.name);
}

onPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: onPlayerKilled, "+self.name);

	/*
	    iprintln("onPlayerKilled");
	    if (isDefined(eInflictor) && isDefined(eInflictor.name)) iprintln("eInflictor.name:" + eInflictor.name);
	    if (isDefined(eInflictor) && !isDefined(eInflictor.name) && isDefined(eInflictor.classname)) iprintln("eInflictor.classname:" + eInflictor.classname);
	    if (isDefined(eAttacker) && isDefined(eAttacker.name)) iprintln("eAttacker.name:" + eAttacker.name);
	    if (isDefined(eAttacker) && !isDefined(eAttacker.name) && isDefined(eAttacker.classname)) iprintln("eAttacker.classname:" + eAttacker.classname);
	    if (isDefined(iDamage)) iprintln("iDamage:" + iDamage);
	    if (isDefined(sMeansOfDeath)) iprintln("sMeansOfDeath:" + sMeansOfDeath);
	    if (isDefined(sWeapon)) iprintln("sWeapon:" + sWeapon);
	    if (isDefined(vDir)) iprintln("vDir:" + vDir);
	    if (isDefined(sHitLoc)) iprintln("sHitLoc:" + sHitLoc);
	*/
}

onPlayerDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: onPlayerDamaging("+iDamage+"), "+self.name);
}

onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: onPlayerDamaged("+iDamage+"), "+self.name);
}

onMenuResponse(menu, response)
{
    if (getCvar("debug") == "1") self iprintln(GetTime() + ": ^6CATCHED: menuresponase("+menu+", "+response+"), "+self.name);
}
