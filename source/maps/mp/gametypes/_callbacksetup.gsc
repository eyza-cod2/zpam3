//	Callback Setup
//	This script provides the hooks from code into script for the gametype callback functions.

/*
	Order of loading scripts:

		1. Init game cvars:
			\fs_game\PAM2016\g_antilag\1\g_gametype\sd\gamename\Call of Duty 2\mapname\mp_toujane\protocol\118\shortversion\1.3\sv_allowAnonymous\0\sv_floodProtect\1\sv_hostname\CoD2Host\sv_maxclients\20\sv_maxPing\0\sv_maxRate\0\sv_minPing\0\sv_privateClients\0\sv_punkbuster\0\sv_pure\1\sv_voice\0

		2. Call gametype:
			maps/mp/gametypes/<gametype>.gsc :: main()

		3. Call map:
			maps/mp/<map>.gsc :: main()

		4. Call callbacks: (called by game engine)
			CodeCallback_StartGameType,
			CodeCallback_PlayerConnect,
			CodeCallback_PlayerDisconnect,
			CodeCallback_PlayerDamage,
			CodeCallback_PlayerKilled


	Example of loading:
		------- Game Initialization -------
		gamename: Call of Duty 2
		gamedate: May  1 2006
		-----------------------------------
		Call: sd.gsc::main()
		Call: mp_toujane.gsc::main()
		Call: sd.gsc::StartGametype
		-----------------------------------
		Call: sd.gsc::PlayerConnect


	Menu loading order:
		1. ui_mp/menus.txt	- loads classic menus for Join Game, Start New Server, Options, ..
		2. ui_mp/ingame.txt   	- menus in this file are loaded when map is loaded
		3. ui_mp/hud.txt	- loads hud.menu if map is loaded
		4. ui_mp/scriptmenus  	- thease menus are loaded individually by script

*/


Init()
{
	SetupCallbacks();
}

//=============================================================================
// Code Callback functions

/*================
Called by code after the level's main script function has run.
================*/
CodeCallback_StartGameType()
{
	/#
	println("### Call: maps/mp/gametypes/_callback.gsc::CodeCallback_StartGameType()");
	#/

	// If the gametype has not beed started, run the startup
	if(!isDefined(level.gametypestarted) || !level.gametypestarted)
	{
		// Process onStartGameType events
		for (i = 0; i < level.events.onStartGameType.size; i++)
		{
			self thread [[level.events.onStartGameType[i]]]();
		}

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

	/#
	if (isDefined(self.alreadyConnected))
		assertMsg("Duplicated connection for " + self.name);
	self.alreadyConnected = true;
	println("### Connecting: " + self.name);
	#/

	self.sessionteam = "none"; // show player in "none" team in scoreboard while connecting

	self thread maps\mp\gametypes\global\events::notifyConnecting();

	// Wait here until player is fully connected
	self waittill("begin");

	self thread maps\mp\gametypes\global\events::notifyConnected();

	// If pam is not installed correctly, spawn outside
	if (level.pam_installation_error || game["pbsv_not_loaded"])
		[[level.spawnSpectator]]((999999, 999999, -999999), (90, 0, 0)); // Spawn spectator outside map

	// Mod is not downloaded
	else if (self maps\mp\gametypes\_force_download::modIsNotDownloadedForSure())
		self maps\mp\gametypes\_force_download::spawnModNotDownloaded();

	else
	{


		[[level.onAfterConnected]]();
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

	self thread maps\mp\gametypes\global\events::notifyDisconnect();
}



/*================
Called when a player has taken damage.
self is the player that took damage.
Return undefined to prevent damage

sMeansOfDeath
	MOD_PISTOL_BULLET = pistol / shotgun / thompson
	MOD_RIFLE_BULLET
	MOD_MELEE = bash
	MOD_GRENADE_SPLASH = grenade
	MOD_SUICIDE = killed by script (used only in PlayerKilled callback, not damage)

sHitLoc
	head
	neck
	torso_upper
	torso_lower
	left_arm_upper
	left_arm_lower
	left_hand
	right_arm_upper
	right_arm_lower
	right_hand
	left_leg_upper
	left_leg_lower
	left_foot
	right_leg_upper
	right_leg_lower
	right_foot

================*/
CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	self endon("disconnect");

	// Do debug print if it's enabled
	if(getCvarInt("g_debugDamage"))
	{
		dist = -1; if (isDefined(eAttacker) && isPlayer(eAttacker)) dist = int(distance(self getOrigin(), eAttacker getOrigin()));
		strAttacker = "undefined"; if (isDefined(eAttacker)) if (isPlayer(eAttacker)) strAttacker = "#" + (eAttacker getEntityNumber()) + " " + eAttacker.name; else strAttacker = "-entity-";
		sPoint = "undefined";	if (isDefined(vPoint)) sPoint = vPoint;
		println("#Damage " + getTime() + " " + strAttacker + " -> #" + self getEntityNumber() + " " + self.name + " health:" + self.health + " damage:" + iDamage + " hitLoc:" + sHitLoc + " iDFlags:" + iDFlags +
		" sMeansOfDeath:" + sMeansOfDeath + " sWeapon:" + sWeapon + " vPoint:" + sPoint + " distance:" + dist);

		//client:client_2  health:100 damage:90 hitLoc:torso_lower iDFlags:32 sMeansOfDeath: MOD_RIFLE_BULLET sWeapon: m1garand_mp vPoint: (-61.1327, 1090.97, 25.2369) vDir: (0.651344, -0.728131, -0.213485) timeOffset: 0
		//client:client_2  health:55 damage:45 hitLoc:torso_lower iDFlags:0 sMeansOfDeath: MOD_PISTOL_BULLET sWeapon: webley_mp vPoint: (-189.78, 1102.76, 39.3595) vDir: (0.140321, -0.958474, -0.248269) timeOffset: 0

		eAttacker iprintln("You inflicted " + iDamage + " damage to " + self.name + " (" + sHitLoc + ", "+ sMeansOfDeath +", distance "+dist+")");
		self iprintln("You recieved " + iDamage + " damage from " + eAttacker.name + " (" + sHitLoc + ", "+ sMeansOfDeath +", distance "+dist+")");
	}

	// Protection - players in spectator inflict damage
	if(isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker.sessionteam == "spectator")
		return;

	// Don't do knockback if the damage direction was not specified
	if(!isdefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	damageFeedback = 1;


	// Hitbox rebalance
	if (level.scr_hand_hitbox_fix &&
		isDefined(sWeapon) && isDefined(sHitLoc) && isDefined(eAttacker) && isPlayer(eAttacker))
	{
		// Player is in ads and is shoted to left arm with rifle or scope
		if (self playerAds() > 0.5 &&
		    sHitLoc == "left_arm_lower" &&
		    (sWeapon == "kar98k_mp" || sWeapon == "enfield_mp" || sWeapon == "mosin_nagant_mp" ||
		     sWeapon == "springfield_mp" || sWeapon == "enfield_scope_mp" || sWeapon == "kar98k_sniper_mp" || sWeapon == "mosin_nagant_sniper_mp"))
		{
			// If players are looking to each other, make shot to arm a kill
			distance = distance(self.origin, eAttacker.origin);
			angleDiff = angleDiff(self, eAttacker);
			if (distance > 200 && anglediff > -20 && anglediff < 20)
			{
				if (level.debug_handhitbox) iprintln("^1Hitbox fix - making damage as kill");
				iDamage = 135;
			}
		}
	}

	// Shotgun rebalance
	if (level.scr_shotgun_rebalance && // Shotgun rebalance can be turned on/off by command
		isDefined(eAttacker) && isPlayer(eAttacker) && isDefined(sHitLoc) && isDefined(sMeansOfDeath) && isDefined(sHitLoc) &&
		isDefined(sWeapon) && sWeapon == "shotgun_mp" && sMeansOfDeath == "MOD_PISTOL_BULLET")
	{
		// count distance
		dist = distance(self.origin, eAttacker.origin);

		// Reset counters after this frame ends
		if (!isDefined(eAttacker.shotgunHit))
			eAttacker.shotgunHit = [];

		self_num = self getEntityNumber();
		if (!isDefined(eAttacker.shotgunHit[self_num]))
		{
			hit = spawnstruct();
			hit.id = 0;
			hit.totalDamage = 0;
			eAttacker.shotgunHit[self_num] = hit;
			eAttacker thread shotgunCounterAutoRestart();
		}
		eAttacker.shotgunHit[self_num].id++;
		eAttacker.shotgunHit[self_num].totalDamage += iDamage;
		hitInfo = eAttacker.shotgunHit[self_num];


		//eAttacker iprintln("Shotgun damage to " + self.name + " damage:" + iDamage + " hitLoc:" + sHitLoc + " distance:" + dist);


		// Range 0-384
		if (dist < 384)
		{
			// Do linear damage 100hp - 50hp
			iDamage = int(50 + (50 - (dist / 384) * 50)); // damage 0 - 50 accorging to distance

			// Hit to main parts of body at distance < 200 change to kill
			doKill = false;
			if (dist < 200)
			{
				switch(sHitLoc)
				{
					case "head": case "neck": case "left_arm_upper": case "right_arm_upper":
					case "torso_upper": case "torso_lower": case "left_leg_upper": case "right_leg_upper":
						doKill = true;
				}
			}

			if (doKill)
			{
				iDamage = 100;
				damageFeedback = 2; // Do big damage feedback, because this bullet kills the player and the others are canceled due to this
				if (level.debug_shotgun) eAttacker iprintln("^1Distance " + int(dist) + " | close range 0-200 : Hit to " + sHitLoc+ " = KILL");
			}
			else
				if (level.debug_shotgun) eAttacker iprintln("^3Distance " + int(dist) + " | close range 0-384 : Hit to " + sHitLoc+ " = "+iDamage+"hp damage (bullet id: " + hitInfo.id + ")");
		}

		// Range 384-500
		else if (dist < 500)
		{
			if (level.debug_shotgun) eAttacker iprintln("Distance " + int(dist) + " | range 384-500 : original " + iDamage + "hp damage (bullet id: " + hitInfo.id + " totDmg: " + hitInfo.totalDamage + ")");
		}

		// Range 550 - 800
		// Limit damage to 99 (you can not kill player with single shot - this is fixing long range kills)
		else
		{
			if (hitInfo.totalDamage >= 100)  // Make sure you have to hit player twice to kill him
			{
				if (level.debug_shotgun) eAttacker iprintln("^9Distance " + int(dist) + " | far range 500-800 : ^9" + iDamage + "hp damage ^1CANCELED (bullet id: " + hitInfo.id + " totDmg: " + hitInfo.totalDamage + ")");
				return; // cancel damage
			}
		  	else
				if (level.debug_shotgun) eAttacker iprintln("^9Distance " + int(dist) + " | far range 500-800 : original " + iDamage + "hp damage (bullet id: " + hitInfo.id + " totDmg: " + hitInfo.totalDamage + ")");
		}

		// Fix the hit sound feedback, because if you hit player with 3 bullets with 15 HP, its the same feeling like if you hit with 3 bullets with 30HP - but everytime different damage!
		if (hitInfo.id >= 2 && hitInfo.totalDamage < 100)
		  damageFeedback = 0; // cancel damage feedback
	}


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


	//println("##################### " + "notifyDamaging");
	// Call onDamage event and return if damage was prevented
	ret = maps\mp\gametypes\global\events::notifyDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
	if (ret) return;


	// Damage feedback
	for (i = 0; i < damageFeedback; i++)
	{
		//eAttacker iprintln("^6DMG feedback" + i);
		if(isPlayer(eAttacker) && eAttacker != self && !(iDFlags & level.iDFLAGS_NO_PROTECTION))
			eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(self);
	}

	//println("##################### " + "notifyDamage");
	// Call onPlayerDamaged event
	maps\mp\gametypes\global\events::notifyDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);

	// Call gametype specific event that is called as last
	[[level.onAfterPlayerDamaged]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

shotgunCounterAutoRestart()
{
	waittillframeend;
	self.shotgunHit = undefined;
}

angleDiff(player, eAttacker)
{
	myAngle = player.angles[1]; // -180 <-> +180
	myAngle += 180; // flip direction, now in range 0 <-> 360
	if (myAngle > 180) myAngle -= 360; // back to range -180 <-> +180

	enemyAngle = eAttacker.angles[1];

	anglediff = myAngle - enemyAngle;
	if (anglediff > 180)		anglediff -= 360;
	else if (anglediff < -180)	anglediff += 360;

	//iprintln(anglediff);

	return anglediff;
}


/*================
Called when a player has been killed.
self is the player that was killed.


This function is called if:
	finishPlayerDamage is called and that damage applied leads to <= 0 health
	RadiusDamage is called and that damage applied leads to <= 0 health
	suicide is called
	player kills himself via /kill

After this function is executed, weapons are removed (getcurrentweapon will return none when the current frame ends)


================*/
CodeCallback_PlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	self endon("disconnect");

	// Do debug print if it's enabled
	if(getCvarInt("g_debugDamage"))
	{
		strAttacker = "undefined"; if (isDefined(eAttacker)) if (isPlayer(eAttacker)) strAttacker = "#" + (eAttacker getEntityNumber()) + " " + eAttacker.name; else strAttacker = "-entity-";
		println("#Kill " + getTime() + " " + strAttacker + " -> #" + self getEntityNumber() + " " + self.name + " health:" + self.health + " damage:" + iDamage + " hitLoc:" + sHitLoc +
		" sMeansOfDeath:" + sMeansOfDeath + " sWeapon:" + sWeapon + " sessionstate:" + self.sessionstate + " timeOffset:" + timeOffset);
	}

	// Player in spectator cannot be killed
	if(self.sessionteam == "spectator")
		return;

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
	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE" && sWeapon != "shotgun_mp")
		sMeansOfDeath = "MOD_HEAD_SHOT";



	// Call onKilling event and return if kill was prevented
	ret = maps\mp\gametypes\global\events::notifyKilling(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
	if (ret) return;

	// If kill is not prevented, do onPlayerKilled event
	maps\mp\gametypes\global\events::notifyKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);

	// Call gametype specific event that is called as last
	[[level.onAfterPlayerKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
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

	setcvar("g_gametype", "dm");

	exitLevel(false);
}

/*================
================*/
callbackVoid()
{
}
