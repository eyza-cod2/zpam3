#include maps\mp\gametypes\_callbacksetup;

// This is called in main function of gametype script
// Also called after map_restart (rounds, ...)
Init()
{
    // Register cvars only once map/gametype starts
    if (!isDefined(game["cvars"]))
    {
        game["cvars"] = [];
    	game["cvarnames"] = [];

        // Register all cvars
        registerCvars();
    }

    // Load registered cvars values into level. variables
	maps\mp\gametypes\_cvar_system::loadCvars();
}

// This is called only once map/gametype starts ()
registerCvars()
{
	// Load important cvars that needs to be loaded first
	Important_Cvars();

	// Register already defined variables from game engine (server cvars)
	Server_Cvars();

    // Reset server cvars to default only if this is not public
    if (!game["is_public_mode"])
    	maps\mp\gametypes\_cvar_system::resetServerCvars(); // default zpam300/players/<name>/config_mp.cfg is overwrited

	// Register all script variables used for this gametype (script cvars)
	Script_Variables();

    // Reset script cvars to default only if this is not public
    if (!game["is_public_mode"])
	   maps\mp\gametypes\_cvar_system::resetScriptCvars();

	// Reset cheat cvars that may be changed if map before was runned via devmap
	ResetCheatCvars();

	// Rules load - overide cvars with values for defined league mode
	maps\pam\rules\rules::load();

	// TODO comment for final release
	//setCvar("developer", 2);
	//setcvar("developer_script", 1);

	// Save rule sets values as default so we are able to check if some of the cvar was changed from original
	maps\mp\gametypes\_cvar_system::saveRuleValues();
}

Important_Cvars()
{
	iVar = maps\mp\gametypes\_cvar_system::addImportantCvar;

	// Read only cvars - cvars are not monitored - so if they changes nothing happend (onCvarChange is called only once)
	[[iVar]]("R", "mapname", "STRING", "");
	[[iVar]]("R", "g_gametype", "STRING", "sd");
	[[iVar]]("R", "fs_game", "STRING", "");
	[[iVar]]("R", "dedicated", "INT", 0, 0, 2);

	// To define level.fps_multiplier and level.frame vars
	[[iVar]]("S", "sv_fps", "INT", 20, 20, 30);

	// Register pam_mode cvar ("I" means that this cvar will be not restarted when resetScriptCvars is callled)
	[[iVar]]("I", "pam_mode", "STRING", "pub", maps\pam\rules\rules::getListOfRuleSets(level.gametype));

    // Important variables
    game["is_public_mode"] = level.pam_mode == "pub";
}

// Define all defined variables that may modify gameplay
Server_Cvars()
{
	sVar = maps\mp\gametypes\_cvar_system::addServerCvar;

	// Monitored cvars - onCvarChange is called if this cvar changes value

    // All of theese cvars are set to default values (except for pub mode)

	[[sVar]]("rate", "INT", 25000, 25000, 25000);

	[[sVar]]("developer", "INT", 0, 0, 2);
	[[sVar]]("developer_script", "BOOL", 0);

	[[sVar]]("g_allowVote", "BOOL", 1); // level.allowvote
	[[sVar]]("g_antilag", "BOOL", 1); // Turn on antilag checks for weapon hits
	//[[sVar]]("g_banIPs", "STRING", "");  //	string of ips //?? working
	[[sVar]]("g_clonePlayerMaxVelocity", "FLOAT", 80, 0, undefined);
	[[sVar]]("g_deadChat", "BOOL", 0); // Allow dead players to chat with living players
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
	//[[sVar]]("g_password", "STRING", "");
	[[sVar]]("g_playerCollisionEjectSpeed", "INT", 25, 0, 32000); // Speed at which to push intersecting players away from each other
	[[sVar]]("g_smoothClients", "BOOL", 1); // Enable extrapolation between client states
	[[sVar]]("g_speed", "INT", 190, undefined, undefined); // Player speed
	[[sVar]]("g_synchronousClients", "BOOL", 0); // (ne vsechny prokazy od klienta jsou zpracovany) Call 'client think' exactly once for each server frame to make smooth demos
	[[sVar]]("g_useholdtime", "INT", 0, 0, undefined); // Time to hold the 'use' button to activate use
	[[sVar]]("g_voiceChatTalkingDuration", "INT", 500, 0, 10000);
	[[sVar]]("g_voteAbstainWeight", "FLOAT", 0.5, 0, 1);
	[[sVar]]("g_weaponAmmoPools", "BOOL", 0);

	[[sVar]]("packetDebug", "BOOL", 0);

	[[sVar]]("player_toggleBinoculars", "BOOL", 1);

	// Server (not all cvars, just needed)
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

Script_Variables()
{



		var = maps\mp\gametypes\_cvar_system::addScriptCvar;




		// Register gametype specific settings
		switch (level.gametype)
		{
			case "sd":  SD_Variables(); break;
			case "hq":  HQ_Variables(); break;
			case "ctf": CTF_Variables(); break;
			case "tdm": TDM_Variables(); break;
			case "dm":  DM_Variables(); break;
		}


        // SHARED VARIABLES FOR ALL GAMETYPES
		//addCvar(cvar, type, defaultValue, minValue, maxValue)


        [[var]]("scr_overtime", "BOOL", 0); //level.scr_overtime

        [[var]]("scr_readyup", "BOOL", 0); 	//level.scr_readyup
		[[var]]("scr_readyup_autoresume", "FLOAT", 0, 0, 10); 	// level.scr_readyup_autoresume
        [[var]]("scr_half_start_timer", "FLOAT", 0, 0, 10); 	// level.scr_half_start_timer

        [[var]]("scr_timeouts", "INT", 0, 0, 10); 	          // level.scr_timeouts
		[[var]]("scr_timeouts_half", "INT", 0, 0, 10); 	      // level.scr_timeouts_half
		[[var]]("scr_timeout_length", "FLOAT", 5, 0, 1440);   // level.scr_timeout_length

        [[var]]("scr_show_players_left", "BOOL", 1);	    // level.scr_show_players_left // NOTE: after reset
        [[var]]("scr_show_objective_icons", "BOOL", 1); 	// level.scr_show_objective_icons  // NOTE: after reset
		[[var]]("scr_show_hitblip", "BOOL", 1); 	        // level.scr_show_hitblip
		[[var]]("scr_show_scoreboard", "INT", 1, 0, 2); 	// level.scr_show_scoreboard // NOTE: after reset
        [[var]]("scr_show_scoreboard_limit", "BOOL", 0);    // level.scr_show_scoreboard_limit // NOTE: after reset

		[[var]]("scr_allow_health_regen", "BOOL", 1); 	       // level.scr_allow_health_regen		// NOTE: reset
		[[var]]("scr_allow_regen_sounds", "BOOL", 1); 	       // level.scr_allow_regen_sounds		// NOTE: imidietly
		[[var]]("scr_regen_delay", "INT", 5000, 3000, 30000);  // level.scr_regen_delay		// NOTE: imidietly

        [[var]]("scr_allow_ambient_sounds", "BOOL", 1);       // level.scr_allow_ambient_sounds
		[[var]]("scr_allow_ambient_fire", "BOOL", 1);         // level.scr_allow_ambient_fire
		[[var]]("scr_allow_ambient_weather", "BOOL", 1);      // level.scr_allow_ambient_weather
		[[var]]("scr_allow_ambient_fog", "BOOL", 1);          // level.scr_allow_ambient_fog


        [[var]]("scr_allow_shellshock", "BOOL", 1); 	        // level.scr_allow_shellshock
        [[var]]("scr_replace_russian", "BOOL", 0);              // level.scr_replace_russian  (can be changed only at start of the game, in progress it will mess up britsh/russians scripts...)
		[[var]]("scr_auto_deadchat", "BOOL", 0); 	            // level.scr_auto_deadchat
        [[var]]("scr_remove_killtriggers", "BOOL", 0); 	        // level.scr_remove_killtriggers - remove some of the killtriggers created by infinityward where kill is not needed (like toujane jump on middle building,...)
		[[var]]("scr_force_client_best_connection", "BOOL", 0); // level.scr_force_client_best_connection
        [[var]]("scr_force_client_exploits", "BOOL", 0);        // level.scr_force_client_exploits


        [[var]]("scr_friendlyfire", "INT", 0, 0, 3); 	// level.scr_friendlyfire on, off, reflect, shared
		[[var]]("scr_drawfriend", "BOOL", 1); 	        // level.scr_drawfriend // Draws a team icon over teammates // NOTE: restart needed
		[[var]]("scr_teambalance", "INT", 0); 	        // level.scr_teambalance // Auto Team Balancing - number of difference between number of players // NOTE: restart needed
		[[var]]("scr_killcam", "BOOL", 1); 	            // level.scr_killcam
		[[var]]("scr_spectatefree", "BOOL", 0); 	    // level.scr_spectatefree
		[[var]]("scr_spectateenemy", "BOOL", 0); 	    // level.scr_spectateenemy

		[[var]]("scr_blackout", "BOOL", 0);                     // level.scr_blackout
        [[var]]("scr_recording", "BOOL", 0);               		// level.scr_recording
		[[var]]("scr_diagonal_fix", "BOOL", 0);					// level.scr_diagonal_fix
		[[var]]("scr_matchinfo", "BOOL", 0);					// level.scr_matchinfo
		[[var]]("scr_map_vote", "BOOL", 1);						// level.mapvote
		[[var]]("scr_map_vote_replay", "BOOL", 0);				// level.mapvotereplay
		[[var]]("scr_shotgun_rebalance", "BOOL", 1);			// level.scr_shotgun_rebalance


		[[var]]("scr_bots_add", "INT", 0, 0, 64); 		// add <num> bots to the server
		[[var]]("scr_bots_remove", "INT", 0, 0, 64); 	// remove <num> bots from the server
		[[var]]("scr_bots_removeAll", "BOOL", 0);		// remove all bots from server

		[[var]]("scr_bots_fillEnabled", "BOOL", 0);		// enable / disable fill the server with bots automaticly up to limit
		[[var]]("scr_bots_fillMaxBots", "INT", 6, 0, 64); 	// maximum number of bots
		[[var]]("scr_bots_fillAutoBalance", "BOOL", 1);

		// Load weapons cvars (in another file because of clarity simplification)
		maps\mp\gametypes\_weapons::loadWeaponCvars();


		// If you want to add new command, you have to specify script variable into onCvarChanged() function

}


SD_Variables()
{
	var = maps\mp\gametypes\_cvar_system::addScriptCvar;
	// Register cvars specific for this gametype
	//addCvar(cvar, type, defaultValue, minValue, maxValue)
	[[var]]("scr_sd_timelimit", "FLOAT", 0, 0, 1440); 	// Total Time limit per map
	[[var]]("scr_sd_half_round", "INT", 0, 0, 99999);	// Round limit for 1st half (0 means there is no half time)
	[[var]]("scr_sd_half_score", "INT", 0, 0, 99999);	// Score limit for 1st half (0 means there is no half time)
	[[var]]("scr_sd_end_round", "INT", 20, 0, 99999);	// Total round limit for map
	[[var]]("scr_sd_end_score", "INT", 0, 0, 99999);	// Total score limit for map

	[[var]]("scr_sd_strat_time", "FLOAT", 0, 0, 10);		// Time before round starts (sec) (0 - 10, default 0)
	[[var]]("scr_sd_roundlength", "FLOAT", 4, 0, 10);	// Time length of each round (min) (0 - 10, default 4)
	[[var]]("scr_sd_end_time", "FLOAT", 0, 0, 10);	// Timer at the end of the round
	[[var]]("scr_sd_count_draws", "BOOL", 1);			// Count Draws? (may happend if last players from allies and axis are killed in same time)

	[[var]]("scr_sd_bombtimer_show", "BOOL", 1);			// Show bombtimr stopwatch
	[[var]]("scr_sd_bombtimer", "FLOAT", 60, 0, 60);		// Time untill bomb explodes. (seconds)
	[[var]]("scr_sd_planttime", "FLOAT", 5, 0, 10);
	[[var]]("scr_sd_defusetime", "FLOAT", 10, 0, 10);
	[[var]]("scr_sd_plant_points", "INT", 0, 0, 10);		// Points for planter
	[[var]]("scr_sd_defuse_points", "INT", 0, 0, 10);	     // Points for defuser
}

DM_Variables()
{
	var = maps\mp\gametypes\_cvar_system::addScriptCvar;

	[[var]]("scr_dm_half_score", "INT", 0, 0, 99999); //level.halfscore
	[[var]]("scr_dm_end_score", "INT", 0, 0, 99999); //level.scorelimit
	[[var]]("scr_dm_end_half2score", "INT", 0, 0, 99999); //level.matchscore2
	[[var]]("scr_dm_timelimit_halftime", "INT", 0, 0, 1); //level.do_halftime

    // NOTE: add also to all other non sd gametypes
    [[var]]("scr_spawnpointnewlogic", "BOOL", 0); // this cvar is used in _spawnlogic.gsc, add to non sd gametypes
}

HQ_Variables()
{/*
	level.halfscore = getcvarint("scr_hq_half_score");
	level.scorelimit = getcvarint("scr_hq_end_score");
	level.matchscore2 = getcvarint("scr_hq_end_half2score");

	level.do_halftime = [[//level.setdvar]]("scr_hq_timelimit_halftime", 0, 0, 1);

	level.orig_hq_style = 0;
	if (getcvar("scr_hq_gamestyle") == "original")
		level.orig_hq_style = 1;

	//Players Left Start-Up
	level.scr_show_players_left = [[//level.setdvar]]("scr_show_players_left", 1, 0, 1);
    */
}

CTF_Variables()
{/*
	level.flag_auto_return = [[//level.setdvar]]("scr_flag_autoreturn_time", 120, -1, 300);

	level.halfscore = getcvarint("scr_ctf_half_score");
	level.scorelimit = getcvarint("scr_ctf_end_score");
	level.matchscore2 = getcvarint("scr_ctf_end_half2score");

	level.do_halftime = [[//level.setdvar]]("scr_ctf_timelimit_halftime", 0, 0, 1);

	//Respawn Delay
	level.respawndelay = [[//level.setdvar]]("scr_ctf_respawn_time", 10, 0, 60);

	//Players Left Start-Up
	level.scr_show_players_left = [[//level.setdvar]]("scr_show_players_left", 1, 0, 1);

	//Compass/Flag Relationship Dvars
	level.show_compass_flag = [[//level.setdvar]]("scr_ctf_show_compassflag", 0, 0, 1);
	level.flag_grace = [[//level.setdvar]]("scr_ctf_flag_graceperiod", 30, 0, 600);
	level.positiontime = [[//level.setdvar]]("scr_ctf_positiontime", 10, 1, 60);

	// CTF Points
	level.ctf_capture_points = [[//level.setdvar]]("scr_ctf_capture_points", 10, 0, 20);
	level.ctf_return_points = [[//level.setdvar]]("scr_ctf_return_points", 2, 0, 20);

	// Respawn all on capture
	level.respawn_on_capture = [[//level.setdvar]]("scr_ctf_respawn_on_capture", 0, 0, 1);

	// Flag Status HUD
	level.hud_flagstatus = [[//level.setdvar]]("scr_ctf_show_flagstatus_hud", 0, 0, 1);
	thread maps\pam\flag_status::Init();
    */
}

TDM_Variables()
{/*
	level.tdm_tk_scoring = [[//level.setdvar]]("scr_tdm_tk_penalty", 0, 0, 1);

	level.halfscore = getcvarint("scr_tdm_half_score");
	level.scorelimit = getcvarint("scr_tdm_end_score");
	level.matchscore2 = getcvarint("scr_tdm_end_half2score");

	level.do_halftime = [[//level.setdvar]]("scr_tdm_timelimit_halftime", 0, 0, 1);
    */
}


// This function is called when cvar changes value.
// Is also called when cvar is registered (on startGameType)
onCvarChange(cvar, value, isRegisterTime)
{
	if (!isRegisterTime)
		level notify ("onCvarChanged", cvar, value);


	switch(cvar)
	{

		// SD Cvars
		case "scr_sd_timelimit": 		level.timelimit = value; break;
		case "scr_sd_half_round": 		level.halfround = value; break;
		case "scr_sd_half_score": 		level.halfscore = value; break;
		case "scr_sd_end_round": 		level.matchround = value; break;
		case "scr_sd_end_score": 		level.scorelimit = value; break;

		case "scr_sd_strat_time": 		level.strat_time = value; break;
		case "scr_sd_roundlength": 		level.roundlength = value; break;
		case "scr_sd_end_time": 		level.round_endtime = value; break;
		case "scr_sd_count_draws": 		level.countdraws = value; break;

		case "scr_sd_bombtimer": 		level.bombtimer = value; break;
		case "scr_sd_bombtimer_show": 	level.show_bombtimer = value; break;
		case "scr_sd_planttime": 		level.planttime = value; break;
		case "scr_sd_defusetime": 		level.defusetime = value; break;

		case "scr_sd_plant_points": 	level.bomb_plant_points = value; break;
		case "scr_sd_defuse_points": 	level.bomb_defuse_points = value; break;



		// DM Cvars
		case "scr_dm_half_score": level.halfscore = value; break;
		case "scr_dm_end_score": level.scorelimit = value; break;
		case "scr_dm_end_half2score": level.matchscore2 = value; break;
		case "scr_dm_timelimit_halftime": level.do_halftime = value; break;







		// Important cvars
		case "mapname": level.mapname = value; break;
		case "g_gametype": level.gametype = value; break;
		case "pam_mode":
			if (isRegisterTime)
            {
                level.pam_mode = value; // set pam mode only for first time

                // Cvar "pam_mode" was changed but no pam-change was executed (cvar was changed right before map_restart)
                if (isDefined(game["loaded_pam_mode"]) && game["loaded_pam_mode"] != level.pam_mode)
                    thread maps\mp\gametypes\_pam::ChangeTo(value);
            }
			else thread maps\mp\gametypes\_pam::ChangeTo(value);
		break;


		case "fs_game": 	level.fs_game = value; break;
		case "dedicated": 	level.dedicated = value; break;


		case "rate": 	break;

		// Server (not all cvars, just needed)
		case "sv_allowAnonymous":					break;
		case "sv_allowDownload":					break;
		case "sv_disableClientConsole":				break;
		case "sv_floodProtect":						break;
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


			//println("Server FPS is: " + value);
		break;
		case "sv_kickBanTime":			break;
		case "sv_maxclients":			break;
		case "sv_maxPing":			break;
		case "sv_maxRate":			break;
		case "sv_minPing":			break;
		case "sv_pure":			break;
		case "sv_reconnectlimit":			break;
		case "sv_timeout":			break;
		case "sv_voice":			break;
		case "sv_voiceQuality":			break;
		case "sv_zombietime":			break;
		case "voice_deadChat":			break;
		case "voice_global":			break;
		case "voice_localEcho":			break;


		// Server cvars
		case "developer":							break;
		case "developer_script":					break;

		case "g_allowVote":							break;
		case "g_antilag":					level.antilag = value;		break;
		case "g_banIPs":							break;
		case "g_clonePlayerMaxVelocity":			break;
		case "g_deadChat":					level.deadchat = value;		break;
		case "g_dropForwardSpeed":					break;
		case "g_dropUpSpeedBase":					break;
		case "g_dropUpSpeedRand":					break;
		case "g_gravity":							break;
		case "g_inactivity":						break;
		case "g_knockback":							break;
		case "g_listEntity":						break;
		case "g_maxDroppedWeapons":					break;
		case "g_no_script_spam":					break;
		case "g_oldVoting":							break;
		//case "g_password":						break;
		case "g_playerCollisionEjectSpeed":			break;
		case "g_smoothClients":						break;
		case "g_speed":								break;
		case "g_synchronousClients":				break;
		case "g_useholdtime":						break;
		case "g_voiceChatTalkingDuration":			break;
		case "g_voteAbstainWeight":					break;
		case "g_weaponAmmoPools":					break;

		case "packetDebug":							break;

		case "player_toggleBinoculars":				break;






		// Script variables
		case "scr_friendlyfire": 		level.scr_friendlyfire = value; break;
		case "scr_drawfriend": 			level.scr_drawfriend = value; break;
		case "scr_teambalance": 		level.scr_teambalance = value; break;
		case "scr_killcam": 			level.scr_killcam = value; break;			// NOTE: reset is NOT needed
		case "scr_spectatefree": 		level.scr_spectatefree = value; level thread maps\mp\gametypes\_spectating::setSpectatePermissionsToAll(); break;
		case "scr_spectateenemy": 		level.scr_spectateenemy = value; level thread maps\mp\gametypes\_spectating::setSpectatePermissionsToAll(); break;

		case "scr_half_start_timer": 	level.scr_half_start_timer = value; break;

		case "scr_readyup": 			level.scr_readyup = value; break;
		case "scr_readyup_autoresume": 	level.scr_readyup_autoresume = value; break;


        case "scr_overtime":	                level.scr_overtime = value; break;


		// If some wepaons was enabled/disabled
		case "scr_allow_greasegun":
		case "scr_allow_m1carbine":
		case "scr_allow_m1garand":
		case "scr_allow_springfield":
		case "scr_allow_thompson":
		case "scr_allow_bar":
		case "scr_allow_sten":
		case "scr_allow_enfield":
		case "scr_allow_enfieldsniper":
		case "scr_allow_bren":
		case "scr_allow_pps42":
		case "scr_allow_nagant":
		case "scr_allow_svt40":
		case "scr_allow_nagantsniper":
		case "scr_allow_ppsh":
		case "scr_allow_mp40":
		case "scr_allow_kar98k":
		case "scr_allow_g43":
		case "scr_allow_kar98ksniper":
		case "scr_allow_mp44":
		case "scr_allow_shotgun":
			if (!isRegisterTime) thread maps\mp\gametypes\_weapons::updateAllowed(cvar, value);
		break;


		// If class limit changed, update all weapons
		case "scr_boltaction_limit":
		case "scr_sniper_limit":
		case "scr_semiautomatic_limit":
		case "scr_smg_limit":
		case "scr_mg_limit":
		case "scr_shotgun_limit":
			if (!isRegisterTime)
            {
                thread maps\mp\gametypes\_weapons::updateLimit(cvar, value);
                thread maps\mp\gametypes\_weapon_limiter::Update_All_Weapon_Limits();
            }
		break;

		// Allow weapon drop if player dead
		case "scr_boltaction_allow_drop":
		case "scr_sniper_allow_drop":
		case "scr_semiautomatic_allow_drop":
		case "scr_smg_allow_drop":
		case "scr_mg_allow_drop":
		case "scr_shotgun_allow_drop":
            if (!isRegisterTime) thread maps\mp\gametypes\_weapons::updateDrop(cvar, value);
		break;

		// Nothing get updated because we are getting value directly from getCvar()
		case "scr_boltaction_nades":
		case "scr_boltaction_smokes":
		case "scr_semiautomatic_nades":
		case "scr_semiautomatic_smokes":
		case "scr_smg_nades":
		case "scr_smg_smokes":
		case "scr_sniper_nades":
		case "scr_sniper_smokes":
		case "scr_mg_nades":
		case "scr_mg_smokes":
		case "scr_shotgun_nades":
		case "scr_shotgun_smokes":
		break;



		case "scr_no_oneshot_pistol_kills": 		level.prevent_single_shot_pistol = value; break;
		case "scr_no_oneshot_ppsh_kills": 		level.prevent_single_shot_ppsh = value; break;
		case "scr_balance_ppsh_distance": 		level.balance_ppsh = value; break;

		case "scr_allow_grenade_drop": 		level.allow_nadedrops = value; break;
        case "scr_allow_smoke_drop": 		level.allow_smokedrops = value; break;

		case "scr_allow_primary_drop": 		level.allow_primary_drop = value; break;
        case "scr_allow_secondary_drop": 		level.allow_secondary_drop = value; break;

		case "scr_allow_pistols": 		level.allow_pistols = value; break;
		case "scr_allow_turrets": 		level.allow_turrets = value; break;





		case "scr_allow_health_regen": 		level.scr_allow_health_regen = value; break;
		case "scr_allow_regen_sounds": 		level.scr_allow_regen_sounds = value; break;
		case "scr_regen_delay": 		level.scr_regen_delay = value; break;
		case "scr_show_objective_icons": 		level.scr_show_objective_icons = value; break;
		case "scr_show_hitblip": 		level.scr_show_hitblip = value; break;
		case "scr_show_scoreboard": 		level.scr_show_scoreboard = value; break;
		case "scr_allow_shellshock": 		level.scr_allow_shellshock = value; break;
		case "scr_auto_deadchat": 		level.scr_auto_deadchat = value; break;
		case "scr_timeouts": 		level.scr_timeouts = value; break;
		case "scr_timeouts_half": 		level.scr_timeouts_half = value; break;
		case "scr_timeout_length": 		level.scr_timeout_length = value; break;
		case "scr_show_players_left": 		level.scr_show_players_left = value; break;
		case "scr_show_scoreboard_limit":		level.scr_show_scoreboard_limit = value; break;
		case "scr_force_client_best_connection":    level.scr_force_client_best_connection = value; break;
        case "scr_force_client_exploits":           level.scr_force_client_exploits = value; break;

		case "scr_allow_ambient_sounds":	level.scr_allow_ambient_sounds = value; break;
		case "scr_allow_ambient_fire": 		level.scr_allow_ambient_fire = value; break;
		case "scr_allow_ambient_weather": 	level.scr_allow_ambient_weather = value; break;
		case "scr_allow_ambient_fog": 		level.scr_allow_ambient_fog = value; break;

		case "scr_remove_killtriggers":	level.scr_remove_killtriggers = value; break;
		case "scr_spawnpointnewlogic": level.spawn_new_logic = value; break;

		case "scr_replace_russian": level.scr_replace_russian = value; break;
		case "scr_blackout": level.scr_blackout = value; break;
        case "scr_recording": level.scr_recording = value; break;
		case "scr_diagonal_fix": level.scr_diagonal_fix = value; break;
		case "scr_matchinfo": level.scr_matchinfo = value; break;
		case "scr_map_vote": level.mapvote = value; break;
		case "scr_map_vote_replay": level.mapvotereplay = value; break;
		case "scr_shotgun_rebalance":


			// Replace all weapons in players slots with new version of shotgun
			if (!isRegisterTime)
			{
				// for all living players store their weapons
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];

					weapon1 = player getWeaponSlotWeapon("primary");
					weapon2 = player getWeaponSlotWeapon("primaryb");

					shotgun_name = "shotgun_mp";
					if (level.scr_shotgun_rebalance)
						shotgun_name = "shotgun_rebalanced_mp";


					if((weapon1 == shotgun_name || weapon2 == shotgun_name) &&
						isDefined(player.pers["weapon"]) && (player.pers["team"] == "allies" || player.pers["team"] == "axis") && player.sessionstate == "playing")
					{

						slot = "primary";
						if(weapon2 == shotgun_name)
							slot = "primaryb";

						player takeWeapon(shotgun_name);

						shotgun_name_new = "shotgun_mp";
						if (value)
							shotgun_name_new = "shotgun_rebalanced_mp";

						player setWeaponSlotWeapon(slot, shotgun_name_new);
						player giveMaxAmmo(shotgun_name_new);

						player switchToWeapon(shotgun_name_new);

						if (player.pers["weapon"] == shotgun_name)
							player.pers["weapon"] = shotgun_name_new;
					}


				}
			}

			level.scr_shotgun_rebalance = value;

			break;




		// Bots
		case "scr_bots_add": 		 			break;
		case "scr_bots_remove": 		 		break;
		case "scr_bots_removeAll": 		 		break;
		case "scr_bots_fillEnabled": 		 	level.bots_fillEnabled = value;			break;
		case "scr_bots_fillMaxBots": 		 	level.bots_fillMaxBots = value;			break;
		case "scr_bots_fillAutoBalance": 		level.bots_fillAutoBalance = value;		break;


		default:
			assertMsg("Cvar " + cvar + " is not cased in onCvarChnge()");
	}
}



getValue(cvarName)
{
	cvar = game["cvars"][cvarName];
	if (isDefined(cvar))
	{
		return cvar["value"];
	}
	else
		assertMsg("Cvar "+cvarName+" not defined in cvar system.");
}
