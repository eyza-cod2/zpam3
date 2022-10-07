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

		...

	Order of loading scripts when map_restart is called:

		1. Init game cvars:
			\fs_game\PAM2016\g_antilag\1\g_gametype\sd\gamename\Call of Duty 2\mapname\mp_toujane\protocol\118\shortversion\1.3\sv_allowAnonymous\0\sv_floodProtect\1\sv_hostname\CoD2Host\sv_maxclients\20\sv_maxPing\0\sv_maxRate\0\sv_minPing\0\sv_privateClients\0\sv_punkbuster\0\sv_pure\1\sv_voice\0

		2. Call gametype:
			maps/mp/gametypes/<gametype>.gsc :: main()

		3. Call map:
			maps/mp/<map>.gsc :: main()

		4. (frame 0) CodeCallback_StartGameType
		5. (frame 2) CodeCallback_PlayerConnect

		6. CodeCallback_PlayerDamage
		7. CodeCallback_PlayerKilled
		8. CodeCallback_PlayerDisconnect


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
	/#
	thread frame_counter();
	println("##### " + gettime() + " " + level.frame_num + " ##### Call: maps/mp/gametypes/" + getcvar("g_gametype") + ".gsc::main()");
	#/

	SetupCallbacks();
}

frame_counter()
{
	level.frame_num = 0;
	for(;;)
	{
		wait 0.000000001;
		waittillframeend;waittillframeend;waittillframeend;waittillframeend;waittillframeend;waittillframeend;waittillframeend;waittillframeend;
		waittillframeend;waittillframeend;waittillframeend;waittillframeend;waittillframeend;waittillframeend;waittillframeend;waittillframeend;
		level.frame_num++;
	}
}

//=============================================================================
// Code Callback functions

/*================
Called by code after the level's main script function has run.
================*/
CodeCallback_StartGameType()
{
	/#
	println("##### " + gettime() + " " + level.frame_num + " ##### Call: maps/mp/gametypes/_callback.gsc::CodeCallback_StartGameType()");
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
	println("##### " + gettime() + " " + level.frame_num + " ##### Connecting: " + self.name);
	#/

	self.sessionteam = "none"; // show player in "none" team in scoreboard while connecting

	if (!isDefined(self.pers["antilagTimeOffset"]))
		self.pers["antilagTimeOffset"] = 0;

	self thread maps\mp\gametypes\global\events::notifyConnecting();
	
	// Wait here until player is fully connected
	self waittill("begin");

	self thread maps\mp\gametypes\global\events::notifyConnected();

	// If pam is not installed correctly, spawn outside
	if (level.pam_installation_error)
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

	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	// Do debug print if it's enabled
	if(level.debugDamage)
	{
		dist = -1; if (isDefined(eAttacker) && isPlayer(eAttacker)) dist = int(distance(self getOrigin(), eAttacker getOrigin()));
		strAttacker = "undefined"; if (isDefined(eAttacker)) if (isPlayer(eAttacker)) strAttacker = "#" + (eAttacker getEntityNumber()) + " " + eAttacker.name; else strAttacker = "-entity-";
		sPoint = "undefined";	if (isDefined(vPoint)) sPoint = vPoint;
		println("#Damage " + getTime() + " " + strAttacker + " -> #" + self getEntityNumber() + " " + self.name + " health:" + self.health + " damage:" + iDamage + " hitLoc:" + sHitLoc + " iDFlags:" + iDFlags +
		" sMeansOfDeath:" + sMeansOfDeath + " sWeapon:" + sWeapon + " vPoint:" + sPoint + " distance:" + dist);

		//client:client_2  health:100 damage:90 hitLoc:torso_lower iDFlags:32 sMeansOfDeath: MOD_RIFLE_BULLET sWeapon: m1garand_mp vPoint: (-61.1327, 1090.97, 25.2369) vDir: (0.651344, -0.728131, -0.213485) timeOffset: 0
		//client:client_2  health:55 damage:45 hitLoc:torso_lower iDFlags:0 sMeansOfDeath: MOD_PISTOL_BULLET sWeapon: webley_mp vPoint: (-189.78, 1102.76, 39.3595) vDir: (0.140321, -0.958474, -0.248269) timeOffset: 0

		if (isDefined(eAttacker) && isPlayer(eAttacker))
		{
			eAttacker iprintln("You inflicted " + iDamage + " damage to " + self.name + " (" + sHitLoc + ", "+ sMeansOfDeath +", distance "+dist+")");
			self iprintln("You recieved " + iDamage + " damage from " + eAttacker.name + " (" + sHitLoc + ", "+ sMeansOfDeath +", distance "+dist+")");
		}
		else
			self iprintln("You recieved " + iDamage + " damage (" + sHitLoc + ", "+ sMeansOfDeath +", distance "+dist+")");
	}


	// Save antilag time offset
	if (isDefined(eAttacker) && isPlayer(eAttacker))
	{
		eAttacker.pers["antilagTimeOffset"] = timeOffset;
	}


	// Protection - players in spectator inflict damage
	if(isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker.sessionteam == "spectator")
		return;

	// Don't do knockback if the damage direction was not specified
	if(!isdefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	damageFeedback = 1;

	/*
	// Debug angle
	if (isDefined(sWeapon) && isDefined(sHitLoc) && isDefined(eAttacker) && isPlayer(eAttacker))
	{
		angleDiff = angleDiff(self, eAttacker);
		iprintln("Hit angle:"+anglediff+"");
	}
	*/

	// Hitbox left and right hand fix
	if (level.scr_hitbox_hand_fix &&
		isDefined(sWeapon) && isDefined(sHitLoc) && isDefined(eAttacker) && isPlayer(eAttacker))
	{
		// Player is in ads and is shoted to left arm with rifle or scope
		if (self playerAds() > 0.5 &&
		    (sWeapon == "kar98k_mp" || sWeapon == "enfield_mp" || sWeapon == "mosin_nagant_mp" ||
		     sWeapon == "springfield_mp" || sWeapon == "enfield_scope_mp" || sWeapon == "kar98k_sniper_mp" || sWeapon == "mosin_nagant_sniper_mp"))
		{
			// If players are looking to each other, make shot to arm a kill
			distance = distance(self.origin, eAttacker.origin);
			angleDiff = angleDiff(self, eAttacker);

			// Left arm
			if (distance > 200 && (
				(anglediff > 0 && anglediff < 30 && sHitLoc == "left_hand") ||
				(anglediff > -20 && anglediff < 25 && sHitLoc == "left_arm_lower")
				) && self.angles[0] > -65 && self.angles[0] < 45)
			{
				if (level.debug_handhitbox) iprintln("^1Hand hitbox fix - making damage to "+sHitLoc+" as kill (angle:"+anglediff+")");
				//println("### Hand hitbox fix - making damage to "+sHitLoc+" as kill (angle:"+anglediff+")"); // EYZA_DEBUG
				iDamage = 135;
			}
			// Right arm
			if (distance > 200 && (
				(anglediff > 0  && anglediff < 75  && sHitLoc == "right_hand") ||
				(anglediff > 45 && anglediff < 100 && sHitLoc == "right_arm_lower")
				) && self.angles[0] > -65 && self.angles[0] < 45)
			{
				if (level.debug_handhitbox) iprintln("^1Hand hitbox fix - making damage to "+sHitLoc+" as kill (angle:"+anglediff+")");
				//println("### Hand hitbox fix - making damage to "+sHitLoc+" as kill (angle:"+anglediff+")"); // EYZA_DEBUG
				iDamage = 135;
			}
		}
	}


	// Bigger torso hitbox
	if (level.scr_hitbox_torso_fix && isDefined(sWeapon) && isDefined(sHitLoc) && isDefined(eAttacker) && isPlayer(eAttacker))
	{
		// Bigger torso hitbox
		// This change efectively applies only for rifles, because other weapons has the same damage for torso_lower and right/left_leg_upper
		if (sWeapon == "kar98k_mp" || sWeapon == "enfield_mp" || sWeapon == "mosin_nagant_mp")
		{
			if (sHitLoc == "left_leg_upper" || sHitLoc == "right_leg_upper")
			{
				dist = distance(self.pelvisTag getOrigin(), vPoint);

				// Distance between pelvis and knee is around 21
				if (dist < 15.0)
				{
					if (level.debug_torsohitbox) iprintln("^1Torso hitbox fix - adjusted damage from " + iDamage + " to 135");
					//println("### Torso hitbox fix - adjusted damage from " + iDamage + " to 135 for " + eAttacker.name); // EYZA_DEBUG
					iDamage = 135;
				}
			}
		}
	}

	// Consistent shotgun
	if (level.scr_shotgun_consistent && isDefined(eAttacker) && isPlayer(eAttacker) && isDefined(sHitLoc) && isDefined(sMeansOfDeath) && isDefined(sHitLoc) &&
	    isDefined(sWeapon) && sWeapon == "shotgun_mp" && sMeansOfDeath == "MOD_PISTOL_BULLET")
	{
		// When pellets from shotgun are fired, they have a random spread
		// The game engine will call this damage function if the pellet hits the target
		// In the same frame, all pellets that hit the target are called one by one
		// If one pellet kills the enemy, all other pellets are not called, because the player is already killed and is not part of world anymore

		// Create variable to hold info about shotgun hits
		if (!isDefined(eAttacker.shotgunHit))
		{
			eAttacker.shotgunHit = [];
			eAttacker thread shotgunCounterAutoRestart();		// will delete eAttacker.shotgunHit after this frame ends
		}

		// Because we can hit multiple players in same time (multikill), we need to save it according to players
		self_num = self getEntityNumber();
		if (!isDefined(eAttacker.shotgunHit[self_num]))
		{
			eAttacker.shotgunHit[self_num] = spawnstruct();
			eAttacker.shotgunHit[self_num].id = 0;			// inited to 0, but will be incremented. 1 then means first pellet
		}
		eAttacker.shotgunHit[self_num].id++;


		// count distance
		dist = distance(self getOrigin(), eAttacker getOrigin());


		// Make sure pellets do only once a feedback damage
		// This is the first pellet
		if (eAttacker.shotgunHit[self_num].id == 1)
			damageFeedback = 1;
		else
			damageFeedback = 0;


		// Range 0-250   (1 pellet needed for kill)
		if (dist <= 250)
		{
			isKill = true;

			// If its hit to hand or leg
			if (sHitLoc == "left_hand" || sHitLoc == "left_arm_lower" || sHitLoc == "right_hand" || sHitLoc == "right_arm_lower" ||
			    sHitLoc == "left_foot" || sHitLoc == "left_leg_lower" || sHitLoc == "right_foot" || sHitLoc == "right_leg_lower")
			{
				eye = eAttacker maps\mp\gametypes\global\player::getEyeOrigin();

				trace = Bullettrace(eye, self.headTag getOrigin(), true, eAttacker);
				headVisible = isDefined(trace["entity"]) && trace["entity"] == self;

				trace = Bullettrace(eye, self.pelvisTag getOrigin(), true, eAttacker);
				pelvisVisible = isDefined(trace["entity"]) && trace["entity"] == self;

				//println("### Consistent shotgun: upcoming hit is to leg or hand | headVisible:" + headVisible + " | pelvisVisible:" + pelvisVisible); // EYZA_DEBUG

				// Head and pelvis is not at sight (only hand or lags are visible to player) - this should be a hit only
				if (!headVisible && !pelvisVisible)
					isKill = false;
			}


			if (isKill)
			{
				iDamage = 100;
				damageFeedback = 2; // Do big damage feedback, because this bullet kills the player and the others are canceled due to this
				if (level.debug_shotgun) eAttacker iprintln("^1Distance " + int(dist) + " | close range 0-250 | KILL");
				//println("### Consistent shotgun: attacker:"+eAttacker.name+" | victim:"+self.name+" | distance:" + int(dist) + " | hitLoc:" + sHitLoc + " | close range 0-250 | KILL"); // EYZA_DEBUG
			}
			else
			{
				// Scale the damage based on distance
				iDamage = damageScale(dist, 0, 250, 100, 50); //distance, distStart, distEnd, hpStart, hpEnd
				if (level.debug_shotgun) eAttacker iprintln("^1Distance " + int(dist) + " | close range 0-250 | ^3hit to hand or leg");
				//println("### Consistent shotgun: attacker:"+eAttacker.name+" | victim:"+self.name+" | distance:" + int(dist) + " | hitLoc:" + sHitLoc + " | close range 0-250 | hit to hand or leg"); // EYZA_DEBUG
			}
		}

		// Range 250-384   (2 pellets needed for kill)
		else if (dist <= 384)
		{
			// Scale the damage based on distance
			iDamage = damageScale(dist, 250, 384, 100, 50); //distance, distStart, distEnd, hpStart, hpEnd

			if (level.debug_shotgun) eAttacker iprintln("^3Distance " + int(dist) + " | mid range 250-384 | " + iDamage + "hp damage (pellet id: " + eAttacker.shotgunHit[self_num].id + ")");

			//println("### Consistent shotgun: attacker:"+eAttacker.name+" | victim:"+self.name+" | distance:" + int(dist) + " | hitLoc:" + sHitLoc + " | mid range 250-384 | damage:" + iDamage + " | pelletId:" + eAttacker.shotgunHit[self_num].id); // EYZA_DEBUG
		}

		// Range 384-500   (3 pellets needed for kill)
		else if (dist <= 500)
		{
			// Scale the damage based on distance
			iDamage = damageScale(dist, 384, 500, 50, 34); //distance, distStart, distEnd, hpStart, hpEnd

			if (level.debug_shotgun) eAttacker iprintln("^4Distance " + int(dist) + " | mid range 384-500 | " + iDamage + "hp damage (pellet id: " + eAttacker.shotgunHit[self_num].id + ")");

			//println("### Consistent shotgun: attacker:"+eAttacker.name+" | victim:"+self.name+" | distance:" + int(dist) + " | hitLoc:" + sHitLoc + " | mid range 384-500 | damage:" + iDamage + " | pelletId:" + eAttacker.shotgunHit[self_num].id); // EYZA_DEBUG
		}

		// Range 500 - 800   (only 1 pellet is counted, so atleast 3 shots are needed for kill)
		else
		{
			// This is the first pellet
			if (eAttacker.shotgunHit[self_num].id == 1)
			{
				// Scale the damage based on distance
				iDamage = damageScale(dist, 500, 800, 34, 0); //distance, distStart, distEnd, hpStart, hpEnd

				if (level.debug_shotgun) eAttacker iprintln("^9Distance " + int(dist) + " | far range 500-800 | linear " + iDamage + "hp damage");

				//println("### Consistent shotgun: attacker:"+eAttacker.name+" | victim:"+self.name+" | distance:" + int(dist) + " | hitLoc:" + sHitLoc + " | far range 500-800 | linear damage:" + iDamage); // EYZA_DEBUG
			}
			else
			{
				return;
			}

		}
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

	//println("##################### " + "notifyDamage");
	// Call onPlayerDamaged event
	maps\mp\gametypes\global\events::notifyDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);

	// Call gametype specific event that is called as last
	[[level.onAfterPlayerDamaged]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);

	// Damage feedback
	if (damageFeedback >= 1)
	{
		//eAttacker iprintln("^6DMG feedback" + i);
		if(isPlayer(eAttacker) && eAttacker != self && !(iDFlags & level.iDFLAGS_NO_PROTECTION))
			eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(self, damageFeedback);
	}
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

damageScale(dist, distStart, distEnd, hpStart, hpEnd)
{
	return int(hpStart - ((dist - distStart) / (distEnd - distStart)) * (hpStart - hpEnd));
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


/kill
#Kill 880548 #0 client_1  -> #0 client_1  health:0 damage:100000 hitLoc:none sMeansOfDeath:MOD_SUICIDE sWeapon:none sessionstate:playing timeOffset:0

suicide()
#Kill 911898 #0 client_1  -> #0 client_1  health:0 damage:100000 hitLoc:none sMeansOfDeath:MOD_SUICIDE sWeapon:none sessionstate:playing timeOffset:0


================*/
CodeCallback_PlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	self endon("disconnect");

	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	// Do debug print if it's enabled
	if(level.debugDamage)
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
	println("Aborting level - gametype '" + getCvar("g_Gametype") + "' is not supported");

	level.callbackStartGameType = ::callbackVoid;
	level.callbackPlayerConnect = ::callbackVoid;
	level.callbackPlayerDisconnect = ::callbackVoid;
	level.callbackPlayerDamage = ::callbackVoid;
	level.callbackPlayerKilled = ::callbackVoid;

	setcvar("g_gametype", "dm");

	//wait level.fps_multiplier * 1;

	println("Restarting to DM gametype...");

	//exitLevel(false);
	map(level.mapname);
}

/*================
================*/
callbackVoid()
{
}
