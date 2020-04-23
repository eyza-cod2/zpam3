#include maps\mp\gametypes\_callbacksetup;

// This is called only if developer_script is set to 1
init()
{
	addEventListener("onStartGameType",    ::onStartGameType);

    addEventListener("onConnecting",    ::onConnecting);
    addEventListener("onConnected",     ::onConnected);
    addEventListener("onConnectedAll",     ::onConnectedAll);
    addEventListener("onDisconnect",    ::onDisconnect);

    addEventListener("onSpawned",           ::onSpawned);
    addEventListener("onSpawnedPlayer",     ::onSpawnedPlayer);
    addEventListener("onSpawnedSpectator",  ::onSpawnedSpectator);

    addEventListener("onJoinedTeam",        ::onJoinedTeam);
    addEventListener("onJoinedAlliesAxis",  ::onJoinedAlliesAxis);
    addEventListener("onJoinedSpectator",   ::onJoinedSpectator);

    addEventListener("onPlayerKilling",   ::onPlayerKilling);
	addEventListener("onPlayerKilled",   ::onPlayerKilled);
    addEventListener("onPlayerDamaging",   ::onPlayerDamaging);
    addEventListener("onPlayerDamaged",   ::onPlayerDamaged);

    addEventListener("onMenuResponse",   ::onMenuResponse);

}

onStartGameType()
{
    if (getCvar("debug") != "") iprintln(GetTime() + ": ^6CATCHED: onStartGameType");
}

onConnecting()
{
    if (getCvar("debug") != "") iprintln(GetTime() + ": ^6CATCHED: connecting, "+self.name + "  entNum:" + self GetEntityNumber());
}

onConnected()
{
    if (getCvar("debug") != "") iprintln(GetTime() + ": ^6CATCHED: connected, "+self.name + "  entNum:" + self GetEntityNumber());
}

onConnectedAll()
{
    if (getCvar("debug") != "") iprintln(GetTime() + ": ^6CATCHED: connectedAll");
}

onDisconnect()
{
    if (getCvar("debug") != "") iprintln(GetTime() + ": ^6CATCHED: disconnect, "+self.name);
}

onSpawned()
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: spawned, "+self.name);
}

onSpawnedPlayer()
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: spawned_player, "+self.name);
}

onSpawnedSpectator()
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: spawned_spectator, "+self.name);
}

onJoinedTeam(teamName)
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: joined("+teamName+"), "+self.name);
}

onJoinedAlliesAxis()
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: joined_team, "+self.name);
}

onJoinedSpectator()
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: joined_spectators, "+self.name);
}

onPlayerKilling(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: onPlayerKilling, "+self.name);
}

onPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: onPlayerKilled, "+self.name);

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
	if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: onPlayerDamaging("+iDamage+"), "+self.name);
}

onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: onPlayerDamaged("+iDamage+"), "+self.name);
}

onMenuResponse(menu, response)
{
    if (getCvar("debug") != "") self iprintln(GetTime() + ": ^6CATCHED: menuresponase("+menu+", "+response+"), "+self.name);
}
