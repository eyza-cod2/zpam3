Init()
{
	maps\mp\gametypes\global\_global::addEventListener("onCvarChanged", ::onCvarChanged);

	if (game["firstInit"])
	{
		// Reset cheat cvars that may be changed if map before was runned via devmap
		maps\mp\gametypes\global\cvars::ResetCheatCvars();
	}

	Register_Shared_Cvars();
}

// Define all cvars shared by all scripts
Register_Shared_Cvars()
{
	sVar = maps\mp\gametypes\global\_global::registerCvar;


	// /# #/ 		This will execute any script between /# #/
	// println 		This will also execute println command
	// runtime errors: 	This will cause script runtime errors for undefined variables
	// game dev prints:	Game prints like "Giving bot0 a 999 ping - !count:"


	// developer = 0, developer_script = 0
	// /# #/ 		No
	// println 		No
	// runtime errors: 	No
	// game dev prints:	No

	// developer = 0, developer_script = 1
	// /# #/ 		Yes
	// println 		Yes
	// runtime errors: 	No
	// game dev prints:	No

	// developer = 1 | 2, developer_script = 0
	// /# #/ 		No
	// println 		No
	// runtime errors: 	No
	// game dev prints:	Yes

	// developer = 1 | 2, developer_script = 1
	// /# #/ 		Yes
	// println 		Yes
	// runtime errors: 	Yes
	// game dev prints:	Yes

	//[[sVar]]("developer", "INT", 0, 0, 2);
	//[[sVar]]("developer_script", "BOOL", 0);


	[[sVar]]("sv_fps", "INT", 20, 10, 1000);
	[[sVar]]("rate", "INT", 25000, 25000, 25000);
	[[sVar]]("g_allowVote", "BOOL", 1);
	[[sVar]]("g_clonePlayerMaxVelocity", "FLOAT", 80, 0, undefined);
	[[sVar]]("g_deadChat", "BOOL", 1); // Allow dead players to chat with living players
	[[sVar]]("g_dropForwardSpeed", "FLOAT", 10, 0, 1000); // Forward speed of a dropped item
	[[sVar]]("g_dropUpSpeedBase", "FLOAT", 10, 0, 1000); // Base component of the initial vertical speed of a dropped item
	[[sVar]]("g_dropUpSpeedRand", "FLOAT", 5, 0, 1000); // Random component of the initial vertical speed of a dropped item
	[[sVar]]("g_gravity", "FLOAT", 800, 1, undefined); // Gravity in inches per second
	[[sVar]]("g_inactivity", "INT", 0, 0, undefined); // Time delay before player is kicked for inactivity
	[[sVar]]("g_knockback", "FLOAT", 1000, undefined, undefined); // speed energy if player is hitted by grenade, other player, atc..
	[[sVar]]("g_listEntity", "BOOL", 0); // Prints list of entities and set back to 0
	[[sVar]]("g_maxDroppedWeapons", "INT", 16, 1, 32); // Maximum number of dropped weapons
	[[sVar]]("g_no_script_spam", "BOOL", 0); // Turn off script debugging info working??
	[[sVar]]("g_oldVoting", "BOOL", 1); // musi bit 1, jinak nefunguje vote
	[[sVar]]("g_playerCollisionEjectSpeed", "INT", 25, 0, 32000); // Speed at which to push intersecting players away from each other
	[[sVar]]("g_smoothClients", "BOOL", 1); // Enable extrapolation between client states
	[[sVar]]("g_speed", "INT", 190, undefined, undefined); // Player speed
	[[sVar]]("g_synchronousClients", "BOOL", 0); // (ne vsechny prokazy od klienta jsou zpracovany) Call 'client think' exactly once for each server frame to make smooth demos
	[[sVar]]("g_useholdtime", "INT", 0, 0, undefined); // Time to hold the 'use' button to activate use
	[[sVar]]("g_voiceChatTalkingDuration", "INT", 500, 0, 10000);
	[[sVar]]("g_voteAbstainWeight", "FLOAT", 0.5, 0, 1);
	[[sVar]]("g_weaponAmmoPools", "BOOL", 0);
	[[sVar]]("g_debugDamage", "BOOL", 0);
	[[sVar]]("packetDebug", "BOOL", 0);
	[[sVar]]("player_toggleBinoculars", "BOOL", 1);
	[[sVar]]("sv_allowAnonymous", "BOOL", 0);
	[[sVar]]("sv_allowDownload", "BOOL", 1);
	[[sVar]]("sv_disableClientConsole", "BOOL", 0);
	[[sVar]]("sv_floodProtect", "BOOL", 1);
	[[sVar]]("sv_kickBanTime", "FLOAT", 300, 0, 3600);
	[[sVar]]("sv_maxPing", "INT", 0, 0, 999);
	[[sVar]]("sv_maxRate", "INT", 0, 0, 25000);
	[[sVar]]("sv_minPing", "INT", 0, 0, 999);
	[[sVar]]("sv_pure", "BOOL", 1);						// requires players files to be same as the servers
	[[sVar]]("sv_reconnectlimit", "INT", 3, 0, 1800);
	[[sVar]]("sv_timeout", "INT", 240, 0, 1800);		// time after 999 player is kicked
	[[sVar]]("sv_voice", "BOOL", 0);
	[[sVar]]("sv_voiceQuality", "INT", 1, 0, 9);
	[[sVar]]("sv_zombietime", "INT", 2, 0, 1800);
	[[sVar]]("voice_deadChat", "BOOL", 0);
	[[sVar]]("voice_global", "BOOL", 0);
	[[sVar]]("voice_localEcho", "BOOL", 0);


	[[sVar]]("scr_allow_ambient_sounds", "BOOL", 1);       // level.scr_allow_ambient_sounds
	[[sVar]]("scr_allow_ambient_fire", "BOOL", 1);         // level.scr_allow_ambient_fire
	[[sVar]]("scr_allow_ambient_weather", "BOOL", 1);      // level.scr_allow_ambient_weather
	[[sVar]]("scr_allow_ambient_fog", "BOOL", 1);          // level.scr_allow_ambient_fog
	[[sVar]]("scr_remove_killtriggers", "BOOL", 0); 	        // level.scr_remove_killtriggers - remove some of the killtriggers created by infinityward where kill is not needed (like toujane jump on middle building,...)
	[[sVar]]("scr_replace_russian", "BOOL", 0);              // level.scr_replace_russian  (can be changed only at start of the game, in progress it will mess up britsh/russians scripts...)
	[[sVar]]("scr_friendlyfire", "INT", 0, 0, 3); 	// level.scr_friendlyfire on, off, reflect, shared
}


// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "sv_fps":

			if (value == 30)
			{
				level.fps_multiplier = 1.51382;
				level.frame = .033;
			}
			else if (value == 25)
			{
				level.fps_multiplier = 1.26110;
				level.frame = .039;
			}
			else
			{
				level.frame = 1 / value;
				level.fps_multiplier = 0.05 / level.frame;
			}
			level.sv_fps = value;
			//println("Server FPS is: " + value);
			return true;

		case "rate": 				return true;
		case "developer":			return true;
		case "developer_script":		return true;
		case "g_allowvote":			level.allowvote = value; return true;
		case "g_cloneplayermaxvelocity":	return true;
		case "g_deadchat":			level.deadchat = value; return true;
		case "g_dropforwardspeed":		return true;
		case "g_dropupspeedbase":		return true;
		case "g_dropupspeedrand":		return true;
		case "g_gravity":			return true;
		case "g_inactivity":			return true;
		case "g_knockback":			return true;
		case "g_listentity":			return true;
		case "g_maxdroppedweapons":		return true;
		case "g_no_script_spam":		return true;
		case "g_oldvoting":			return true;
		case "g_playercollisionejectspeed":	return true;
		case "g_smoothclients":			return true;
		case "g_speed":				return true;
		case "g_synchronousclients":		return true;
		case "g_useholdtime":			return true;
		case "g_voicechattalkingduration":	return true;
		case "g_voteabstainweight":		return true;
		case "g_weaponammopools":		return true;
		case "g_debugdamage":			level.debugDamage = value; return true;
		case "packetdebug":			return true;
		case "player_togglebinoculars":		return true;
		case "sv_allowanonymous":		return true;
		case "sv_allowdownload":		return true;
		case "sv_disableclientconsole":		return true;
		case "sv_floodprotect":			return true;
		case "sv_kickbantime":			return true;
		case "sv_maxping":			return true;
		case "sv_maxrate":			return true;
		case "sv_minping":			return true;
		case "sv_pure":				return true;
		case "sv_reconnectlimit":		return true;
		case "sv_timeout":			return true;
		case "sv_voice":			return true;
		case "sv_voicequality":			return true;
		case "sv_zombietime":			return true;
		case "voice_deadchat":			return true;
		case "voice_global":			return true;
		case "voice_localecho":			return true;
		case "scr_allow_ambient_sounds":	level.scr_allow_ambient_sounds = value; return true;
		case "scr_allow_ambient_fire": 		level.scr_allow_ambient_fire = value; return true;
		case "scr_allow_ambient_weather": 	level.scr_allow_ambient_weather = value; return true;
		case "scr_allow_ambient_fog": 		level.scr_allow_ambient_fog = value; return true;
		case "scr_remove_killtriggers":		level.scr_remove_killtriggers = value; return true;
		case "scr_replace_russian": 		level.scr_replace_russian = value; return true;
		case "scr_friendlyfire": 		level.scr_friendlyfire = value; return true;
	}
	return false;
}



ResetCheatCvars()
{
	setCvar("bg_aimSpreadMoveSpeedThreshold", "11"); // When player is moving faster than this speed, the aim spread will increase
	setCvar("bg_bobAmplitudeDucked", "0.0075");
	setCvar("bg_bobAmplitudeProne", "0.03");
	setCvar("bg_bobAmplitudeStanding", "0.007");
	setCvar("bg_bobMax", "8");
	setCvar("bg_fallDamageMaxHeight", "480");
	setCvar("bg_fallDamageMinHeight", "256");
	setCvar("bg_foliagesnd_fastinterval", "500");
	setCvar("bg_foliagesnd_maxspeed", "180");
	setCvar("bg_foliagesnd_minspeed", "40");
	setCvar("bg_foliagesnd_resetinterval", "500");
	setCvar("bg_foliagesnd_slowinterval", "1500");
	setCvar("bg_ladder_yawcap", "100");
	setCvar("bg_prone_yawcap", "85");
	setCvar("bg_swingSpeed", "0.2");

	setCvar("fixedtime", "0"); // Use a fixed time rate for each frame
	setCvar("friction", "5.5"); // tření // slide - neco jako cas, kdy po dopadu se stezi zase rozhejbava

	setCvar("g_debugBullets", "0");
	setCvar("g_debugDamage", "0");
	setCvar("g_debugLocDamage", "0");

	setCvar("g_dumpAnims", "-1");	// Animation debugging info for the given character number
	setCvar("g_friendlyfireDist", "256"); // Maximum range for disabling fire at a friendly
	setCvar("g_friendlyNameDist", "15000"); // Maximum range for seeing a friendly's name

	setCvar("g_mantleBlockTimeBuffer", "500"); // Time that the client think is delayed after mantling, ??? working??

    	setCvar("g_useholdspawndelay", "1"); // Time that the player is unable to 'use' after spawning

	setCvar("inertiaAngle", "0"); // setrvacnost - neco spolecneho kdyz jde hrac dopredu a nahle zmeni smer dozadu
	setCvar("inertiaDebug", "0");
	setCvar("inertiaMax", "50");

	setCvar("jump_height", "39"); // The maximum height of a player's jump
	setCvar("jump_ladderPushVel", "128"); // The velocity of a jump off of a ladder
	setCvar("jump_slowdownEnable", "1"); // pokud nula - ze zebriku neseskoci ale vyspla nahoru rychle
	setCvar("jump_spreadAdd", "64"); // The amount of spread scale to add as a side effect of jumping
	setCvar("jump_stepSize", "18");

	setCvar("mantle_check_angle", "60");
	setCvar("mantle_check_radius", "0.1");
	setCvar("mantle_check_range", "20");
	setCvar("mantle_debug", "0");
	setCvar("mantle_enable", "1"); // zakaze preskoky
	setCvar("mantle_view_yawcap", "60");

	setCvar("player_adsExitDelay", "0");// za jak dlouho dojde k odzoomovani
	setCvar("player_backSpeedScale", "0.7");
	setCvar("player_breath_fire_delay", "0");
	setCvar("player_breath_gasp_lerp", "6");
	setCvar("player_breath_gasp_scale", "4.5");
	setCvar("player_breath_gasp_time", "1");
	setCvar("player_breath_hold_lerp", "4");
	setCvar("player_breath_hold_time", "4.5");// doba zadrzeni dechu
	setCvar("player_breath_snd_delay", "1");
	setCvar("player_breath_snd_lerp", "2");
	setCvar("player_dmgtimer_flinchTime", "500");
	setCvar("player_dmgtimer_maxTime", "750");
	setCvar("player_dmgtimer_minScale", "0");
	setCvar("player_dmgtimer_stumbleTime", "500");
	setCvar("player_dmgtimer_timePerPoint", "100");
    	setCvar("player_footstepsThreshhold", "0"); // read-only
	setCvar("player_meleeHeight", "10");
	setCvar("player_meleeRange", "64");
	setCvar("player_meleeWidth", "10");
    	setCvar("player_moveThreshhold", "10");	// read-only
	setCvar("player_scopeExitOnDamage", "0");
	setCvar("player_spectateSpeedScale", "2");	
	setCvar("player_strafeSpeedScale", "0.8");// pohyb do stran

	setCvar("player_turnAnims", "0");
	setCvar("player_view_pitch_down", "85");
	setCvar("player_view_pitch_up", "85");

	setCvar("stopspeed", "100"); // The player deceleration

	setCvar("timescale", "1");

	//setCvar("viewlog", "1");
}
