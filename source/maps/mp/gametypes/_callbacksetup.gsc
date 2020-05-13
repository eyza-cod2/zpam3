//	Callback Setup
//	This script provides the hooks from code into script for the gametype callback functions.

/*
zPAM 3.1

This script implements new event system
Basicly script that need do some action based on some event will register function for that event
and if event happends, that function is called

(by eyza)


*/

// This function needs to be called from gametype script main()
InitCallbacks()
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
    level.events.onSpawnedIntermission = [];
    level.events.onJoinedTeam = [];
    level.events.onJoinedAlliesAxis = [];
    level.events.onJoinedSpectator = [];
    level.events.onPlayerDamaging = [];
    level.events.onPlayerDamaged = [];
    level.events.onPlayerKilling = [];
    level.events.onPlayerKilled = [];
    level.events.onCvarChanged = [];
    level.events.onMenuResponse = [];

    level thread _onCvarChanged();

	// Init cvars
	// Must be init here, because cvars are used in map script
	level maps\mp\gametypes\_cvars::Init();

	SetupCallbacks();
}


addEventListener(eventName, funcPointer)
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
    else if (eventName == "onSpawnedIntermission")
        level.events.onSpawnedIntermission[level.events.onSpawnedIntermission.size] = funcPointer;

    else if (eventName == "onJoinedTeam")
        level.events.onJoinedTeam[level.events.onJoinedTeam.size] = funcPointer;
    else if (eventName == "onJoinedAlliesAxis")
        level.events.onJoinedAlliesAxis[level.events.onJoinedAlliesAxis.size] = funcPointer;
    else if (eventName == "onJoinedSpectator")
        level.events.onJoinedSpectator[level.events.onJoinedSpectator.size] = funcPointer;

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

//=============================================================================
// Code Callback functions

/*================
Called by code after the level's main script function has run.
================*/
CodeCallback_StartGameType()
{
    // If the gametype has not beed started, run the startup
	if(!isDefined(level.gametypestarted) || !level.gametypestarted)
	{
		// Process onStartGameType events
		for (i = 0; i < level.events.onStartGameType.size; i++)
			self thread [[level.events.onStartGameType[i]]]();

		level.gametypestarted = true; // so we know that the gametype has been started up
	}
}



/*================
Called when a player begins connecting to the server.
Called again for every map change or tournement restart.

Return undefined if the client should be allowed, otherwise return
a string with the reason for denial.

Otherwise, the client will be sent the current gamestate
and will eventually get to ClientBegin.

firstTime will be qtrue the very first time a client connects
to the server machine, but qfalse on map changes and tournement
restarts.

Default values of self (defined in game engine)
self.psoffsettime 		= 0
self.archivetime 		= 0
self.spectatorclient 	= -1
self.headiconteam 		= none
self.headicon 			= ""
self.statusicon 		= ""; // examp: hud_status_connecting
self.score				= 0; // score kills
self.deaths 			= 0; // score deaths
self.maxhealth 			= 0;
self.sessionstate 		= "spectator"; // [playing, dead, spectator, intermission]
self.sessionteam 		= "spectator"; // [allies, axis, spectator, none] (real team assigment)
================*/
CodeCallback_PlayerConnect()
{
	self endon("disconnect");

	self.sessionteam = "none"; // show player in "none" team in scoreboard while connecting

	self thread notifyConnecting();

	// Wait here until player is fully connected
	self waittill("begin");

	// Notify connected
	self thread notifyConnected();
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

	// Additional events what need to be watched
	self thread _onSpawned();
	self thread _onSpawnedPlayer();
	self thread _onSpawnedSpectator();
	self thread _onSpawnedIntermission();

	self thread _onJoinedTeam();
	self thread _onJoinedAlliesAxis();
	self thread _onJoinedSpectator();

	self thread _onMenuResponse();

	// Process onConnected events
	for (i = 0; i < level.events.onConnected.size; i++)
	{
		self thread [[level.events.onConnected[i]]]();
	}

    // Notify "all_connected" once
	if (!isDefined(level.allPlayersConnected))
	{
		level.allPlayersConnected = true;

		// Process onConnectedAll events
		for (i = 0; i < level.events.onConnectedAll.size; i++)
			level thread [[level.events.onConnectedAll[i]]]();
	}
}



/*================
Called when a player drops from the server.
Will not be called between levels.
self is the player that is disconnecting.
================*/
CodeCallback_PlayerDisconnect()
{
	self notify("disconnect");

	// Process events
	for (i = 0; i < level.events.onDisconnect.size; i++)
        self thread [[level.events.onDisconnect[i]]]();
}



/*================
Called when a player has taken damage.
self is the player that took damage.
Return undefined to prevent damage
================*/
CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	self endon("disconnect");


	/*
	- Shotgun rebalance -
	First in this function we need to process shotgun rebalance
	We will count all of the shots from shotgun in order to change method how hits are processed
	To do that we need to waittillframeend everytime this function is called to be able to count all shots in single frame

	Shotgun hits are splited into 3 parts:
		- Close range 	: 0 - 180 distance
		- Mid range		: 180 - 550 distance
		- Far range		: 550 - 800 distance

	Shotgun's bullets fired in single shot was increased from 8 to 16 (to increase chance player is hitted)
	In every part hits are processed according to this table:

	Close range: 0 - 180:

		To kill a player:
		2 to 16 bullets must hit the player

		85hp damage:
		1 bullet from 16 hit the player

	Mid range: 180 - 550:

		To kill a player:
		10 to 16 bullets must hit the player
		- or -
		atleast 4 bullets must hit the player and 50% of them must hit the body or head

		60hp damage:
		less than 4 bullets hit the player
		or 50% of bullets goes to legs

	Far range: 550 - 800:

		To kill a player:
		not possible by single fire
		you will always need to fire atleast twice to kill the player

		Damage:
		original damage from PAM2.07 is applied

	*/
	/*
	MOD_PISTOL_BULLET = pistol / shotgun / thompson
	MOD_RIFLE_BULLET
	MOD_MELEE = bash
	MOD_GRENADE_SPLASH = grenade
	*/

	damageFeedback = 1;

	if (level.scr_shotgun_rebalance && // Shotgun rebalance can be turned on/off by command
		isDefined(eAttacker) && isPlayer(eAttacker) && isDefined(sHitLoc) && isDefined(sMeansOfDeath) &&
		isDefined(sWeapon) && sWeapon == "shotgun_rebalanced_mp" && sMeansOfDeath == "MOD_PISTOL_BULLET")
	{
		// count distance
		dist = distance(self getOrigin(), eAttacker getOrigin());

		if (!isDefined(self._shotgunShots))
		{
			self._shotgunShots = 0;
			self._shotgunShotID = 0;
			self._shotgunTotalDamage = 0;
			self._shotgunShotsLegs = 0;
		}
		self._shotgunShots++;
		self._shotgunShotID++;
		self._shotgunTotalDamage += iDamage;

		/*
		Foot hitbox names:

				  torso_lower
		left_leg_upper	right_leg_upper
		left_leg_lower	right_leg_lower
		left_foot			right_foot

		*/

		legs = false;
		legs |= sHitLoc == "left_foot";
		legs |= sHitLoc == "left_leg_lower";
		legs |= sHitLoc == "right_foot";
		legs |= sHitLoc == "right_leg_lower";

		if (legs)
			self._shotgunShotsLegs++;


		//eAttacker iprintln("Shotgun damage to " + self.name + " damage:" + iDamage + " hitLoc:" + sHitLoc + " distance:" + dist);

		// Wait here to count all shot in single frame
		waittillframeend;


		// Ignore all other shotgun shots
		if (self._shotgunShotID > 1)
		{
			self._shotgunShotID--;
			return;
		}

		// If this is the last shot from all shots
		//eAttacker iprintln("This was last shot to " + self.name + "  shots: " + self._shotgunShots + " totDmg: " + self._shotgunTotalDamage);

		iDamage = self._shotgunTotalDamage;

		//scr_shotgun_rebalance

		// Very close range
		if (dist < 180)
		{
			// X shots from 16 (max shotCount) hits the player
			if (self._shotgunShots >= 2)
			{
				// do bigger damage feedback to feel player is killed
				if (self._shotgunShots > 12) damageFeedback = 3;
				else 						 damageFeedback = 2;

				iDamage = 100; // do kill
				if(getCvar("sg_debug")=="1") eAttacker iprintln("^1Close range, kill (distance: " + int(dist) + " bullets: " + self._shotgunShots + "/16)");
			}
			else
			{
				iDamage = 85; // do just big hit
				if(getCvar("sg_debug")=="1") eAttacker iprintln("^1Close range, "+iDamage+"hp damage (distance: " + int(dist) + " bullets: " + self._shotgunShots + "/16)");
			}
		}

		// Mid range
		else if (dist < 550)
		{
			// Atleast 8 bullets hits the player or atleast 4 bullets hits the player and 50% goes to body
			if (self._shotgunShots >= 10 || (self._shotgunShots >= 4 && (self._shotgunShotsLegs / self._shotgunShots) < 0.5))
			{
				// do bigger damage feedback to feel player is killed
				if (self._shotgunShots > 12) damageFeedback = 3;
				else 						 damageFeedback = 2;

				// do kill
				iDamage = 100;
				if(getCvar("sg_debug")=="1") eAttacker iprintln("^3Mid range, kill (distance: " + int(dist) + " bullets: " + self._shotgunShots + "/16 legs: " + self._shotgunShotsLegs + "/" + self._shotgunShots + ")");
			}
			else
			{
				iDamage = 60; // do just hit
				if(getCvar("sg_debug")=="1") eAttacker iprintln("^3Mid range, "+iDamage+"hp damage (distance: " + int(dist) + " bullets: " + self._shotgunShots + "/16 legs: " + self._shotgunShotsLegs + "/" + self._shotgunShots + ")");
			}
		}
		else
		{
			iDamage = self._shotgunTotalDamage;

			// Make sure you have to hit player twice to kill him
			if (iDamage >= 100)
				iDamage = 99;

			if(getCvar("sg_debug")=="1") eAttacker iprintln("Far range, " + iDamage + "hp damage (distance:" + int(dist) + " bullets: " + self._shotgunShots + " totDmg: " + self._shotgunTotalDamage + ")");

		}


		self._shotgunShots = undefined;
		self._shotgunShotID = undefined;
		self._shotgunTotalDamage = undefined;
		self._shotgunShotsLegs = undefined;
	}
	else
	{
		// If shot from 2 players came in same time, make sure the order of wich shot come first still stay the same
		waittillframeend;
	}
	// Because we wait till frame end, if 2 kill came in same time, both of them are called because we didnt fully process the first kill
	// So if first kill is done, we need to end second kill here, because the first already kills this player (to avoid kill both of them)
	// Avoid kill only if its from weapon bullet or bash (keep it for grenades)
	if (isDefined(eAttacker) && isDefined(eAttacker._preventDamageInThisFrame) &&
		(sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_MELEE"))
		return;



    // Do debug print if it's enabled
	if(getCvarInt("g_debugDamage"))
	{
		println("client:" + self getEntityNumber() + " health:" + self.health + " damage:" + iDamage + " hitLoc:" + sHitLoc + " iDFlags:" + iDFlags + " sMeansOfDeath: " + sMeansOfDeath);

		eAttacker iprintln("You inflicted " + iDamage + " damage to " + self.name + " (" + sHitLoc + ", "+ sMeansOfDeath +")");
		self iprintln("You recieved " + iDamage + " damage from " + eAttacker.name + " (" + sHitLoc + ", "+ sMeansOfDeath +")");
	}

    // Protection - players in spectator inflict damage
	if(isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker.sessionteam == "spectator")
		return;

    // Don't do knockback if the damage direction was not specified
	if(!isdefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;


	if (level.balance_ppsh && isDefined(sWeapon) && sWeapon == "ppsh_mp")
	{
		dist = distance(eAttacker.origin , self.origin);
		if (dist > 800)
			return;
	}
	// Prevents a pistol from killing in one shot if active
	if (level.prevent_single_shot_pistol && isDefined(sWeapon) && maps\mp\gametypes\_weapons::isPistol(sWeapon) && isdefined(sHitLoc) && sHitLoc == "head")
	iDamage = int(iDamage * .85);
	// Prevents a ppsh from killing in one shot if active
	if (level.prevent_single_shot_ppsh && isDefined(sWeapon) && sWeapon == "ppsh_mp" && isdefined(sHitLoc) && sHitLoc == "head")
	iDamage = int(iDamage * .9);




	// First loop onPlayerDamaging events that can prevent from the damage
	return_value = [];
    for (i = 0; i < level.events.onPlayerDamaging.size; i++)
        return_value[i] = self thread [[level.events.onPlayerDamaging[i]]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);

    for (i = 0; i < return_value.size; i++)
        if (isDefined(return_value[i]) && return_value[i])
            return; // prevent damage


	// Damage feedback
	for (i = 0; i < damageFeedback; i++)
	{
		if(isdefined(eAttacker) && eAttacker != self && !(iDFlags & level.iDFLAGS_NO_PROTECTION))
			eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback();
	}


	// Do onPlayerDamaged event
	for (i = 0; i < level.events.onPlayerDamaged.size; i++)
		self thread [[level.events.onPlayerDamaged[i]]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}


preventDamageThisFrame()
{
	self._preventDamageInThisFrame = true;
	waittillframeend;
	self._preventDamageInThisFrame = undefined;
}

/*================
Called when a player has been killed.
self is the player that was killed.
================*/
CodeCallback_PlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	self endon("disconnect");

	// Player in spectator cannot be killed
    if(self.sessionteam == "spectator")
		return;

	// This player was killed, disable kills from him if kills came in same frame
	self thread preventDamageThisFrame();

    // Fix bug when player kills somebody with grenade while is using MG - MG icon instead of grenade is shown
	// If sWeapon is MG and sMeansOfDeath is MOD_GRENADE_SPLASH, replace MG icon to grenade
	if ((sWeapon == "mg42_bipod_stand_mp" || sWeapon == "30cal_stand_mp") && sMeansOfDeath == "MOD_GRENADE_SPLASH")
	{
		if(self.pers["team"] == "allies")
		{
			switch(game["allies"])
			{
			case "american":
				sWeapon = "frag_grenade_american_mp";
				break;

			case "british":
				sWeapon = "frag_grenade_british_mp";
				break;

			case "russian":
				sWeapon = "frag_grenade_russian_mp";
				break;
			}
		}
		else if (self.pers["team"] == "axis")
			sWeapon = "frag_grenade_german_mp";
	}

    // If the player was killed by a head shot, let players know it was a head shot kill (except shotgun)
	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE" && sWeapon != "shotgun_mp" && sWeapon != "shotgun_rebalanced_mp")
		sMeansOfDeath = "MOD_HEAD_SHOT";



	// First loop onPlayerKilling events that can prevent from the kill
	return_value = [];
    for (i = 0; i < level.events.onPlayerKilling.size; i++)
        return_value[i] = self thread [[level.events.onPlayerKilling[i]]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);

    for (i = 0; i < return_value.size; i++)
        if (isDefined(return_value[i]) && return_value[i])
            return; // prevent kill


	// If kill is not prevented, do onPlayerKilled event
	for (i = 0; i < level.events.onPlayerKilled.size; i++)
	{
		self thread [[level.events.onPlayerKilled[i]]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
	}
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
	for (i = 0; i < level.events.onSpawnedSpectator.size; i++)
		self thread [[level.events.onSpawnedSpectator[i]]]();
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
	for (i = 0; i < level.events.onJoinedSpectator.size; i++)
		self thread [[level.events.onJoinedSpectator[i]]]();
}


_onMenuResponse()
{
    self endon("intermission");
    self endon("disconnect");

	for(;;)
	{
		self waittill("menuresponse", menu, response);

		// Process events
        self thread _onMenuResponseCallEvents(menu, response);
    }
}
_onMenuResponseCallEvents(menu, response)
{
	// Call events one by one and if true is returned, it means menuresponse was handled and no other events need to be called
	for (i = 0; i < level.events.onMenuResponse.size; i++)
	{
		handled = self [[level.events.onMenuResponse[i]]](menu, response);
		if (isDefined(handled) && handled)
			break;
	}
}



_onCvarChanged()
{
    for(;;)
	{
		level waittill("onCvarChanged", cvar, value);
        self thread _onCvarChangedCallEvents(cvar, value);
    }
}
_onCvarChangedCallEvents(cvar, value)
{
	for (i = 0; i < level.events.onCvarChanged.size; i++)
		level thread [[level.events.onCvarChanged[i]]](cvar, value);
}

//=============================================================================


/*================
Setup any misc callbacks stuff like defines and default callbacks
================*/
SetupCallbacks()
{
	SetDefaultCallbacks();

	// Set defined for damage flags used in the playerDamage callback
	level.iDFLAGS_RADIUS			= 1;
	level.iDFLAGS_NO_ARMOR			= 2;
	level.iDFLAGS_NO_KNOCKBACK		= 4;
	level.iDFLAGS_NO_TEAM_PROTECTION	= 8;
	level.iDFLAGS_NO_PROTECTION		= 16;
	level.iDFLAGS_PASSTHRU			= 32;
}

/*================
Called from the gametype script to store off the default callback functions.
This allows the callbacks to be overridden by level script, but not lost.
================*/
SetDefaultCallbacks()
{
	level.default_CallbackStartGameType = level.callbackStartGameType;
	level.default_CallbackPlayerConnect = level.callbackPlayerConnect;
	level.default_CallbackPlayerDisconnect = level.callbackPlayerDisconnect;
	level.default_CallbackPlayerDamage = level.callbackPlayerDamage;
	level.default_CallbackPlayerKilled = level.callbackPlayerKilled;
}

/*================
Called when a gametype is not supported.
================*/
AbortLevel()
{
	println("Aborting level - gametype is not supported");

	level.callbackStartGameType = ::callbackVoid;
	level.callbackPlayerConnect = ::callbackVoid;
	level.callbackPlayerDisconnect = ::callbackVoid;
	level.callbackPlayerDamage = ::callbackVoid;
	level.callbackPlayerKilled = ::callbackVoid;

	setcvar("g_gametype", "sd");	// only sd is supported now

	exitLevel(false);
}

/*================
================*/
callbackVoid()
{
}
