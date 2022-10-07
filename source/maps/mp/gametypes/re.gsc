#include maps\mp\gametypes\global\_global;


main()
{
	// Initialize global systems (scripts for events, cvars, hud, player...)
	InitSystems();


	// Register events that should be caught
	addEventListener("onStartGameType", ::onStartGameType);
	addEventListener("onConnecting", ::onConnecting);
	addEventListener("onConnected", ::onConnected);
	addEventListener("onDisconnect", ::onDisconnect);
	addEventListener("onPlayerDamaging", ::onPlayerDamaging);
	addEventListener("onPlayerDamaged", ::onPlayerDamaged);
	addEventListener("onPlayerKilling", ::onPlayerKilling);
	addEventListener("onPlayerKilled", ::onPlayerKilled);
	addEventListener("onCvarChanged", ::onCvarChanged);

	// Events for this gametype that are called last after all events are processed
	level.onAfterConnected = ::onAfterConnected;
	level.onAfterPlayerDamaged = ::onAfterPlayerDamaged;
	level.onAfterPlayerKilled = ::onAfterPlayerKilled;

	// Same functions across gametypes
	level.autoassign = ::menuAutoAssign;
	level.allies = ::menuAllies;
	level.axis = ::menuAxis;
	level.spectator = ::menuSpectator;
	level.weapon = ::menuWeapon;

	level.spawnPlayer = ::spawnPlayer;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;


	// Define gametype specific cvars here
	// Default values of these variables are overwrited by rules
	// Event onCvarChanged is called on every cvar registration
	// Make sure that onCvarChanged event is added first before cvar registration
	registerCvarEx("C", "scr_re_timelimit", "FLOAT", 0, 0, 1440); 	// Total Time limit per map
	registerCvarEx("C", "scr_re_half_round", "INT", 0, 0, 99999);	// Round limit for 1st half (0 means there is no half time)
	registerCvarEx("C", "scr_re_half_score", "INT", 0, 0, 99999);	// Score limit for 1st half (0 means there is no half time)
	registerCvarEx("C", "scr_re_end_round", "INT", 20, 0, 99999);	// Total round limit for map
	registerCvarEx("C", "scr_re_end_score", "INT", 0, 0, 99999);	// Total score limit for map

	registerCvar("scr_re_strat_time", "FLOAT", 5, 0, 10);	// Time before round starts (sec) (0 - 10, default 0)
	registerCvar("scr_re_roundlength", "FLOAT", 4, 0, 10);	// Time length of each round (min) (0 - 10, default 4)
	registerCvar("scr_re_end_time", "FLOAT", 0, 0, 15);		// Timer at the end of the round
	registerCvar("scr_re_count_draws", "BOOL", 1);		// Count Draws? (may happend if last players from allies and axis are killed in same time)

	registerCvar("scr_auto_deadchat", "BOOL", 0);
	registerCvar("scr_re_sniper_shotgun_info", "BOOL", 0);	// Show weapon info about sniper and shotgun players
	registerCvar("scr_re_round_report", "BOOL", 0);
	registerCvar("scr_re_showcarrier", "BOOL", 0);




	// Init all shared modules in this pam (scripts with underscore)
	InitModules();
}



// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	// Server info update
	if (!isRegisterTime && !game["firstInit"] && !isDefined(game["cvars"][cvar]["inQuiet"]) && cvar != "pam_mode_custom")
	{
		thread serverInfo();
	}

	switch(cvar)
	{
		case "scr_re_timelimit": 		level.timelimit = value; return true;
		case "scr_re_half_round": 		level.halfround = value; return true;
		case "scr_re_half_score": 		level.halfscore = value; return true;
		case "scr_re_end_round": 		level.matchround = value; return true;
		case "scr_re_end_score": 		level.scorelimit = value; return true;

		case "scr_re_strat_time": 		level.strat_time = value; return true;
		case "scr_re_roundlength": 		level.roundlength = value; return true;
		case "scr_re_end_time": 		level.round_endtime = value; return true;
		case "scr_re_count_draws": 		level.countdraws = value; return true;
		case "scr_re_showcarrier": 		level.showcarrier = value; return true;


		case "scr_re_round_report": 	level.scr_sd_round_report = value; return true;
		case "scr_re_sniper_shotgun_info": 	level.scr_sd_sniper_shotgun_info = value; return true;
		case "scr_auto_deadchat": 		level.scr_auto_deadchat = value; return true;
	}


	return false;
}

// Precache specific stuff for this gametype
// Is called only once per map
precache()
{
	precacheShader("obj_rally");
	precacheShader("obj_defend");
	precacheShader("obj_goal");
	precacheShader("objpoint_star");
	precacheShader("hint_use_touch");
	precacheHeadIcon(game["headicon_carrier"]);
	precacheStatusIcon(game["headicon_carrier"]);
	precacheString(&"RE_CARRYINGGENERIC");
	precacheString(&"RE_PICKUPAXISONLYGENERIC");
	precacheString(&"RE_PICKUPALLIESONLYGENERIC");
	precacheString(&"RE_PRESSTOPICKUPGENERIC");
	precacheString(&"RE_DELAYPICKUPGENERIC");
	precacheString(&"RE_PICKEDUPGENERIC");
	precacheString(&"RE_DROPPEDGENERIC");
	precacheString(&"RE_TIMEOUTRETURNINGGENERIC");
	precacheString(&"RE_INMINESGENERIC");
	precacheString(&"RE_CAPTUREDALLIESGENERIC");
	precacheString(&"RE_CAPTUREDAXISGENERIC");
	precacheString(&"RE_CAPTUREDALL");
	precacheString(&"RE_FIELDRADIO");
	precacheString(&"RE_EXPLOSIVES");
	precacheString(&"RE_ATTACKER");
	precacheString(&"RE_DEFENDER");

	precacheString2("STRING_ROUND", &"Round");
	precacheString2("STRING_ROUND_STARTING", &"Starting");
	precacheString2("STRING_ROUND_FIRST", &"First Round");
	precacheString2("STRING_ROUND_LAST_HALF", &"Last round before half");
	precacheString2("STRING_ROUND_LAST", &"Last round");
	precacheString2("STRING_STRAT_TIME", &"Strat Time");

	precacheString(&"MP_MATCHSTARTING");
	precacheString(&"MP_MATCHRESUMING");
	precacheString(&"MP_ROUNDDRAW");
	precacheString(&"MP_TIMEHASEXPIRED");
	precacheString(&"MP_ALLIEDMISSIONACCOMPLISHED");
	precacheString(&"MP_AXISMISSIONACCOMPLISHED");
	precacheString(&"MP_ALLIESHAVEBEENELIMINATED");
	precacheString(&"MP_AXISHAVEBEENELIMINATED");
}

// Placing special retrieval spawnpoints
// Precache and setup retrieval objectives
setupTeamSpawnpoints()
{
	spawnpoint_defenders = [];
	spawnpoint_attackers = [];

	if(level.mapname == "mp_burgundy" || level.mapname == "mp_burgundy_fix_v1" || level.mapname == "mp_burgundy_fix_v2")
	{
		spawnpoint_attackers[0] = add_array((1944, 2360, 40), (0, 180, 0));
		spawnpoint_attackers[1] = add_array((1760, 1984, 40), (0, 180, 0));
		spawnpoint_attackers[2] = add_array((1760, 2104, 40), (0, 180, 0));
		spawnpoint_attackers[3] = add_array((1760, 2168, 40), (0, 180, 0));
		spawnpoint_attackers[4] = add_array((1816, 2392, 40), (0, 180, 0));
		spawnpoint_attackers[5] = add_array((1816, 2456, 40), (0, 180, 0));
		spawnpoint_attackers[6] = add_array((1888, 2456, 40), (0, 180, 0));
		spawnpoint_attackers[7] = add_array((1888, 2392, 40), (0, 180, 0));
		spawnpoint_attackers[8] = add_array((1832, 2176, 40), (0, 180, 0));
		spawnpoint_attackers[9] = add_array((1824, 1984, 40), (0, 180, 0));
		spawnpoint_attackers[10] = add_array((1832, 2040, 40), (0, 180, 0));
		spawnpoint_attackers[11] = add_array((1832, 2112, 40), (0, 180, 0));
		spawnpoint_attackers[12] = add_array((1912, 1992, 40), (0, 180, 0));
		spawnpoint_attackers[13] = add_array((1912, 2048, 40), (0, 180, 0));
		spawnpoint_attackers[14] = add_array((1912, 2112, 40), (0, 180, 0));
		spawnpoint_attackers[15] = add_array((1912, 2176, 40), (0, 180, 0));

		spawnpoint_defenders[0] = add_array((-1208, 1352, 48), (0, 0, 0));
		spawnpoint_defenders[1] = add_array((-1208, 1288, 48), (0, 0, 0));
		spawnpoint_defenders[2] = add_array((-1208, 1224, 48), (0, 0, 0));
		spawnpoint_defenders[3] = add_array((-1208, 1160, 48), (0, 0, 0));
		spawnpoint_defenders[4] = add_array((-1208, 1416, 48), (0, 0, 0));
		spawnpoint_defenders[5] = add_array((-1144, 1384, 48), (0, 0, 0));
		spawnpoint_defenders[6] = add_array((-1144, 1320, 48), (0, 0, 0));
		spawnpoint_defenders[7] = add_array((-1144, 1256, 48), (0, 0, 0));
		spawnpoint_defenders[8] = add_array((-1144, 1192, 48), (0, 0, 0));
		spawnpoint_defenders[9] = add_array((-1144, 1448, 48), (0, 0, 0));
		spawnpoint_defenders[10] = add_array((-1080, 1368, 48), (0, 0, 0));
		spawnpoint_defenders[11] = add_array((-1080, 1304, 48), (0, 0, 0));
		spawnpoint_defenders[12] = add_array((-1080, 1240, 48), (0, 0, 0));
		spawnpoint_defenders[13] = add_array((-1080, 1176, 48), (0, 0, 0));
		spawnpoint_defenders[14] = add_array((-1080, 1432, 48), (0, 0, 0));
		spawnpoint_defenders[15] = add_array((-1208, 1480, 48), (0, 0, 0));

		level.Allies_Spawnpoints = spawnpoint_attackers;
		level.Axis_Spawnpoints = spawnpoint_defenders;
	}

	else if(level.mapname == "mp_dawnville" || level.mapname == "mp_dawnville_fix" || level.mapname == "mp_dawnville_fix_v2")
	{
		spawnpoint_attackers[0] = add_array((-976, -16248, 0), (0, 0, 0));
		spawnpoint_attackers[1] = add_array((-976, -16184, 0), (0, 0, 0));
		spawnpoint_attackers[2] = add_array((-976, -16120, 0), (0, 0, 0));
		spawnpoint_attackers[3] = add_array((-976, -16056, 0), (0, 0, 0));
		spawnpoint_attackers[4] = add_array((-976, -15992, 0), (0, 0, 0));
		spawnpoint_attackers[5] = add_array((-976, -15928, 0), (0, 0, 0));
		spawnpoint_attackers[6] = add_array((-848, -15976, 0), (0, 0, 0));
		spawnpoint_attackers[7] = add_array((-955, -15871, 0), (0, 0, 0));
		spawnpoint_attackers[8] = add_array((-912, -16216, 0), (0, 0, 0));
		spawnpoint_attackers[9] = add_array((-912, -16152, 0), (0, 0, 0));
		spawnpoint_attackers[10] = add_array((-912, -16088, 0), (0, 0, 0));
		spawnpoint_attackers[11] = add_array((-912, -16024, 0), (0, 0, 0));
		spawnpoint_attackers[12] = add_array((-912, -15960, 0), (0, 0, 0));
		spawnpoint_attackers[13] = add_array((-853, -15973, 0), (0, 0, 0));
		spawnpoint_attackers[14] = add_array((-802, -16119, 0), (0, 0, 0));
		spawnpoint_attackers[15] = add_array((-844, -16149, 0), (0, 0, 0));

		spawnpoint_defenders[0] = add_array((2704, -15864, 0), (0, 180, 0));
		spawnpoint_defenders[1] = add_array((2704, -15800, 0), (0, 180, 0));
		spawnpoint_defenders[2] = add_array((2704, -15736, 0), (0, 180, 0));
		spawnpoint_defenders[3] = add_array((2704, -15672, 0), (0, 180, 0));
		spawnpoint_defenders[4] = add_array((2640, -15592, 0), (0, 180, 0));
		spawnpoint_defenders[5] = add_array((2640, -15656, 0), (0, 180, 0));
		spawnpoint_defenders[6] = add_array((2640, -15718, 0), (0, 180, 0));
		spawnpoint_defenders[7] = add_array((2640, -15784, 0), (0, 180, 0));
		spawnpoint_defenders[8] = add_array((2661, -15831, 0), (0, 180, 0));
		spawnpoint_defenders[9] = add_array((2704, -15608, 0), (0, 180, 0));
		spawnpoint_defenders[10] = add_array((2576, -15560, 0), (0, 180, 0));
		spawnpoint_defenders[11] = add_array((2576, -15624, 0), (0, 180, 0));
		spawnpoint_defenders[12] = add_array((2576, -15688, 0), (0, 180, 0));
		spawnpoint_defenders[13] = add_array((2576, -15752, 0), (0, 180, 0));
		spawnpoint_defenders[14] = add_array((2576, -15816, 0), (0, 180, 0));
		spawnpoint_defenders[15] = add_array((2576, -15880, 0), (0, 180, 0));

		level.Allies_Spawnpoints = spawnpoint_attackers;
		level.Axis_Spawnpoints = spawnpoint_defenders;
	}

	else if(level.mapname == "mp_matmata" || level.mapname == "mp_matmata_fix" || level.mapname == "mp_matmata_fix_v2")
	{
		spawnpoint_defenders[0] = add_array((3896, 8016, 24), (0, 270, 0));
		spawnpoint_defenders[1] = add_array((3832, 8016, 24), (0, 270, 0));
		spawnpoint_defenders[2] = add_array((3768, 8000, 24), (0, 270, 0));
		spawnpoint_defenders[3] = add_array((3688, 7968, 24), (0, 270, 0));
		spawnpoint_defenders[4] = add_array((3912, 7936, 24), (0, 270, 0));
		spawnpoint_defenders[5] = add_array((3912, 7856, 24), (0, 270, 0));
		spawnpoint_defenders[6] = add_array((3832, 7856, 24), (0, 270, 0));
		spawnpoint_defenders[7] = add_array((3752, 7856, 24), (0, 270, 0));
		spawnpoint_defenders[8] = add_array((3688, 7840, 24), (0, 270, 0));
		spawnpoint_defenders[9] = add_array((3960, 7808, 24), (0, 270, 0));
		spawnpoint_defenders[10] = add_array((3880, 7792, 24), (0, 270, 0));
		spawnpoint_defenders[11] = add_array((3800, 7776, 24), (0, 270, 0));
		spawnpoint_defenders[12] = add_array((3768, 7920, 24), (0, 270, 0));
		spawnpoint_defenders[13] = add_array((3848, 7936, 24), (0, 270, 0));
		spawnpoint_defenders[14] = add_array((3720, 7776, 24), (0, 270, 0));
		spawnpoint_defenders[15] = add_array((3640, 7776, 24), (0, 270, 0));

		spawnpoint_attackers[0] = add_array((3816, 5056, 24), (0, 90, 0));
		spawnpoint_attackers[1] = add_array((3928, 5056, 24), (0, 90, 0));
		spawnpoint_attackers[2] = add_array((3624, 4880, 24), (0, 90, 0));
		spawnpoint_attackers[3] = add_array((3608, 5024, 24), (0, 90, 0));
		spawnpoint_attackers[4] = add_array((3736, 4848, 24), (0, 90, 0));
		spawnpoint_attackers[5] = add_array((3608, 5104, 24), (0, 90, 0));
		spawnpoint_attackers[6] = add_array((3880, 5056, 24), (0, 90, 0));
		spawnpoint_attackers[7] = add_array((3928, 4976, 24), (0, 90, 0));
		spawnpoint_attackers[8] = add_array((3864, 4992, 24), (0, 90, 0));
		spawnpoint_attackers[9] = add_array((3864, 4928, 24), (0, 90, 0));
		spawnpoint_attackers[10] = add_array((3624, 4960, 24), (0, 90, 0));
		spawnpoint_attackers[11] = add_array((3560, 4960, 24), (0, 90, 0));
		spawnpoint_attackers[12] = add_array((3560, 4864, 24), (0, 90, 0));
		spawnpoint_attackers[13] = add_array((3672, 4848, 24), (0, 90, 0));
		spawnpoint_attackers[14] = add_array((3800, 4848, 24), (0, 90, 0));
		spawnpoint_attackers[15] = add_array((3864, 4848, 24), (0, 90, 0));

		level.Allies_Spawnpoints = spawnpoint_attackers;
		level.Axis_Spawnpoints = spawnpoint_defenders;
	}

	else if(level.mapname == "mp_railyard")
	{
		spawnpoint_defenders[0] = add_array((120, 1456, 32), (0, 180, 0));
		spawnpoint_defenders[1] = add_array((120, 1392, 32), (0, 180, 0));
		spawnpoint_defenders[2] = add_array((184, 1392, 32), (0, 180, 0));
		spawnpoint_defenders[3] = add_array((184, 1456, 32), (0, 180, 0));
		spawnpoint_defenders[4] = add_array((248, 1456, 32), (0, 180, 0));
		spawnpoint_defenders[5] = add_array((248, 1392, 32), (0, 180, 0));
		spawnpoint_defenders[6] = add_array((248, 1520, 32), (0, 180, 0));
		spawnpoint_defenders[7] = add_array((248, 1584, 32), (0, 180, 0));
		spawnpoint_defenders[8] = add_array((248, 1648, 32), (0, 180, 0));
		spawnpoint_defenders[9] = add_array((184, 1328, 32), (0, 180, 0));
		spawnpoint_defenders[10] = add_array((248, 1328, 32), (0, 180, 0));
		spawnpoint_defenders[11] = add_array((56, 1856, 32), (0, 270, 0));
		spawnpoint_defenders[12] = add_array((-56, 1776, 32), (0, 210, 0));
		spawnpoint_defenders[13] = add_array((120, 1328, 32), (0, 180, 0));
		spawnpoint_defenders[14] = add_array((56, 1456, 32), (0, 180, 0));
		spawnpoint_defenders[15] = add_array((56, 1376, 32), (0, 180, 0));

		spawnpoint_attackers[0] = add_array((-2544, -384, 32), (0, 0, 0));
		spawnpoint_attackers[1] = add_array((-2544, -480, 32), (0, 0, 0));
		spawnpoint_attackers[2] = add_array((-2544, -560, 32), (0, 0, 0));
		spawnpoint_attackers[3] = add_array((-2544, -624, 32), (0, 0, 0));
		spawnpoint_attackers[4] = add_array((-2624, -656, 32), (0, 0, 0));
		spawnpoint_attackers[5] = add_array((-2624, -576, 32), (0, 0, 0));
		spawnpoint_attackers[6] = add_array((-2688, -576, 32), (0, 0, 0));
		spawnpoint_attackers[7] = add_array((-2688, -656, 32), (0, 0, 0));
		spawnpoint_attackers[8] = add_array((-2752, -656, 32), (0, 0, 0));
		spawnpoint_attackers[9] = add_array((-2624, -384, 32), (0, 0, 0));
		spawnpoint_attackers[10] = add_array((-2688, -384, 32), (0, 0, 0));
		spawnpoint_attackers[11] = add_array((-2480, -624, 32), (0, 0, 0));
		spawnpoint_attackers[12] = add_array((-2480, -544, 32), (0, 0, 0));
		spawnpoint_attackers[13] = add_array((-2480, -464, 32), (0, 0, 0));
		spawnpoint_attackers[14] = add_array((-2480, -400, 32), (0, 0, 0));
		spawnpoint_attackers[15] = add_array((-2512, -704, 32), (0, 0, 0));

		level.Allies_Spawnpoints = spawnpoint_attackers;
		level.Axis_Spawnpoints = spawnpoint_defenders;
	}

	else if(level.mapname == "mp_toujane" || level.mapname == "mp_toujane_fix_v2")
	{
		spawnpoint_defenders[0] = add_array((1179, -44, 51), (0, 99.3, 0));
		spawnpoint_defenders[1] = add_array((1108, -55, 51), (0, 95.2, 0));
		spawnpoint_defenders[2] = add_array((994, 12, 51), (0, 90, 0));
		spawnpoint_defenders[3] = add_array((1071, 10, 51), (0, 94.5, 0));
		spawnpoint_defenders[4] = add_array((1186, 25, 51), (0, 98.3, 0));
		spawnpoint_defenders[5] = add_array((1254, 37, 51), (0, 102.6, 0));
		spawnpoint_defenders[6] = add_array((1271, 119, 51), (0, 100.5, 0));
		spawnpoint_defenders[7] = add_array((1206, 108, 51), (0, 98.3, 0));
		spawnpoint_defenders[8] = add_array((1136, 98, 51), (0, 96.4, 0));
		spawnpoint_defenders[9] = add_array((1059, 91, 51), (0, 96.3, 0));
		spawnpoint_defenders[10] = add_array((982, 93, 51), (0, 90, 0));
		spawnpoint_defenders[11] = add_array((1341, 132, 51), (0, 102, 0));
		spawnpoint_defenders[12] = add_array((917, 86, 51), (0, 90, 0));
		spawnpoint_defenders[13] = add_array((1127, 18, 51), (0, 96.5, 0));
		spawnpoint_defenders[14] = add_array((1158, 172, 51), (0, 95, 0));
		spawnpoint_defenders[15] = add_array((1179, -44, 51), (0, 99.3, 0));

		spawnpoint_attackers[0] = add_array((854, 3280, 64), (0, 299.7, 0));
		spawnpoint_attackers[1] = add_array((918, 3312, 64), (0, 299.7, 0));
		spawnpoint_attackers[2] = add_array((982, 3344, 64), (0, 299.7, 0));
		spawnpoint_attackers[3] = add_array((1102, 3368, 64), (0, 299.7, 0));
		spawnpoint_attackers[4] = add_array((1014, 3280, 64), (0, 299.7, 0));
		spawnpoint_attackers[5] = add_array((950, 3248, 64), (0, 299.7, 0));
		spawnpoint_attackers[6] = add_array((886, 3216, 64), (0, 299.7, 0));
		spawnpoint_attackers[7] = add_array((1070, 3304, 64), (0, 299.7, 0));
		spawnpoint_attackers[8] = add_array((1246, 3304, 72), (0, 284.7, 0));
		spawnpoint_attackers[9] = add_array((1179, 3215, 64), (0, 299.7, 0));
		spawnpoint_attackers[10] = add_array((1102, 3168, 64), (0, 299.7, 0));
		spawnpoint_attackers[11] = add_array((990, 3104, 64), (0, 299.7, 0));
		spawnpoint_attackers[12] = add_array((926, 3072, 64), (0, 299.7, 0));
		spawnpoint_attackers[13] = add_array((766, 3160, 64), (0, 299.7, 0));
		spawnpoint_attackers[14] = add_array((774, 3056, 64), (0, 299.7, 0));
		spawnpoint_attackers[15] = add_array((822, 3104, 64), (0, 299.7, 0));

		level.Allies_Spawnpoints = spawnpoint_attackers;
		level.Axis_Spawnpoints = spawnpoint_defenders;
	}
}

setupObjectives()
{
	obj = [];
	goal = (0,0,0);
	// obj[i] = (origin, angles, objective name, trigger radius, model, modelobj)


	if(level.mapname == "mp_breakout")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (6585, 5102, -30);
		obj[0] = add_array((4611, 4800, 190), (0, 15, 0), &"RE_FIELDRADIO", 64, "xmodel/military_german_fieldradio_green", "xmodel/military_german_fieldradio_green_obj");
	}

	else if(level.mapname == "mp_breakout_tls")
	{
		game["attackers"] = "axis";
		game["defenders"] = "allies";
		goal = (6581, 5148, -20);
		obj[0] = add_array((4545, 4060, 90), (0, 292, 0), &"RE_FIELDRADIO", 50, "xmodel/military_german_fieldradio_green", "xmodel/military_german_fieldradio_green_obj");
		obj[1] = add_array((5247, 5351, 233), (0, 271, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	else if(level.mapname == "mp_brecourt")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (-3080, 1049, 30);
		obj[0] = add_array((1115, -1118, 30), (0, 254, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	if(level.mapname == "mp_burgundy" || level.mapname == "mp_burgundy_fix_v1" || level.mapname == "mp_burgundy_fix_v2")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (1888, 2208, -24);
		obj[0] = add_array((899, 9, 100), (0, 126, 0), &"RE_FIELDRADIO", 64, "xmodel/military_german_fieldradio_green", "xmodel/military_german_fieldradio_green_obj");
		obj[1] = add_array((-451, 2829, 35), (0, 154, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	else if(level.mapname == "mp_carentan" || level.mapname == "mp_carentan_fix" || level.mapname == "mp_carentan_fix_v2")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (374, -946, 26);
		obj[0] = add_array((1060, 1548, 28), (0, 263, 0), &"RE_FIELDRADIO", 50, "xmodel/military_german_fieldradio_green", "xmodel/military_german_fieldradio_green_obj");
		obj[1] = add_array((354, 2115, 193), (0, 156, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	else if(level.mapname == "mp_chelm")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (10, -604, -110);
		obj[0] = add_array((-2268, 9, 117), (0, 154, 0), &"RE_FIELDRADIO", 50, "xmodel/military_german_fieldradio_green", "xmodel/military_german_fieldradio_green_obj");
		obj[1] = add_array((-2136, -1549, 150), (0, 23, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	else if(level.mapname == "mp_dawnville" || level.mapname == "mp_dawnville_fix" || level.mapname == "mp_dawnville_fix_v2")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (-1204, -16020, -28);
		obj[0] = add_array((490, -15297, 47), (0, 123, 0), &"RE_FIELDRADIO", 64, "xmodel/military_german_fieldradio_green", "xmodel/military_german_fieldradio_green_obj");
		obj[1] = add_array((742,-17512, 90), (0, 121, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	else if(level.mapname == "mp_decoy")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (5642, -13824, -570);
		obj[0] = add_array((7762, -13962, -487), (0, 32, 0), &"RE_EXPLOSIVES", 64, "xmodel/military_german_fieldradio_green", "xmodel/military_german_fieldradio_green_obj");
	}

	else if(level.mapname == "mp_farmhouse")
	{
		game["attackers"] = "axis";
		game["defenders"] = "allies";
		goal = (-2505, 365, -100);
		obj[0] = add_array((-246, -1481, 100), (0, -154, 0), &"RE_FIELDRADIO", 64, "xmodel/military_german_fieldradio_green", "xmodel/military_german_fieldradio_green_obj");
	}

	else if(level.mapname == "mp_harbor")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (-6637, -7360, -26);
		obj[0] = add_array((-9245, -8379, 200), (0, 34, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	else if(level.mapname == "mp_matmata" || level.mapname == "mp_matmata_fix" || level.mapname == "mp_matmata_fix_v2")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (3157, 5561, -5);
		obj[0] = add_array((4685, 5912, 180), (0, 230, 0), &"RE_FIELDRADIO", 64, "xmodel/military_german_fieldradio_tan", "xmodel/military_german_fieldradio_tan_obj");
		obj[1] = add_array((3659, 6175, 200), (0, 20, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	else if(level.mapname == "mp_railyard")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (-2732, -476, -10);
		obj[0] = add_array((-2460, 1380, 20), (0, -62, 0), &"RE_FIELDRADIO", 64, "xmodel/military_german_fieldradio_tan", "xmodel/military_german_fieldradio_tan_obj");
	}

	else if(level.mapname == "mp_rhine")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (3327, 15517, 300);
		obj[0] = add_array((5737, 16130, 500), (0, 210, 0), &"RE_FIELDRADIO", 64, "xmodel/military_german_fieldradio_tan", "xmodel/military_german_fieldradio_tan_obj");
		obj[1] = add_array((5802, 15104, 480), (0, 21, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	else if(level.mapname == "mp_toujane" || level.mapname == "mp_toujane_fix_v2")
	{
		game["attackers"] = "allies";
		game["defenders"] = "axis";
		goal = (1039, 3188, 30);
		obj[0] = add_array((2, 1119, 52), (0, 59, 0), &"RE_FIELDRADIO", 64, "xmodel/military_german_fieldradio_tan", "xmodel/military_german_fieldradio_tan_obj");
		obj[1] = add_array((3043, 1925, 160), (0, 100, 0), &"RE_EXPLOSIVES", 50, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}

	else if(level.mapname == "mp_trainstation")
	{
		game["attackers"] = "axis";
		game["defenders"] = "allies";
		goal = (8514, -2994, 0);
		obj[0] = add_array((5489, -3644, 70), (0, 19, 0), &"RE_EXPLOSIVES", 64, "xmodel/mp_tntbomb", "xmodel/mp_tntbomb_obj");
	}



	level.objectivesArray = obj;

	level.attackersbase = goal;


	for(i = 0; i < level.objectivesArray.size; i++)
	{
		precacheModel(level.objectivesArray[i][4]);
		precacheModel(level.objectivesArray[i][5]);
	}
}


// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	if(game["firstInit"])
	{
		// defaults if not defined in level script
		if(!isdefined(game["allies"]))
			game["allies"] = "american";
		if(!isdefined(game["axis"]))
			game["axis"] = "german";
		if(!isdefined(game["attackers"]))
			game["attackers"] = "allies";
		if(!isdefined(game["defenders"]))
			game["defenders"] = "axis";



		// Main scores
		game["allies_score"] = 0;
		game["axis_score"] = 0;

		// For spectators
		game["allies_score_history"] = "";
		game["axis_score_history"] = "";

		// Half-separed scoresg
		game["half_1_allies_score"] = 0;
		game["half_1_axis_score"] = 0;
		game["half_2_allies_score"] = 0;
		game["half_2_axis_score"] = 0;

		// Other variables
		game["state"] = "playing";
		game["roundsplayed"] = 0;
		game["round"] = 0;

		// Counts length of all rounds (used for scr_sd_timelimit)
		game["timepassed"] = 0;
	}

	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);

	game["headicon_carrier"] = "obj_carrier";



	// Retrieval variable
	level.mapname = getcvar("mapname");
	level.Allies_Spawnpoints = undefined;
	level.Axis_Spawnpoints = undefined;
	level.Allies_Spawnpoints_Spawned = [];
	level.Axis_Spawnpoints_Spawned = [];
	level.objectives = [];



	// Setup new team spawnpoints
	setupTeamSpawnpoints();

	// Setup retrieval objectives
	setupObjectives();


	// Precache gametype specific stuff
	if (game["firstInit"])
		precache();


	// Gametype specific variables
	level.matchstarted = false;
	level.in_strattime = false;
	level.starttime = 0;
	level.roundstarted = false;
	level.roundended = false;
	level.mapended = false;


	// Variables to determinate endRound()
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;
	level.exist["teams"] = false;
	level.didexist["allies"] = false;
	level.didexist["axis"] = false;
	level.numobjectives = 0;
	level.objectives_done = 0;
	level.hudcount = 0;
	level.barsize = 288;
	level.obj_exist = false;


	// Spawn points
	spawnpointname = "mp_sd_spawn_attacker";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
		AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	spawnpointname = "mp_sd_spawn_defender";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
		AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] PlaceSpawnpoint();



	// Custom spawn points
	if(isdefined(level.Allies_Spawnpoints))
	{
		for(i = 0; i < level.Allies_Spawnpoints.size; i++)
		{
			toGround = positionToGround(level.Allies_Spawnpoints[i][0], level.Allies_Spawnpoints[i]);
			toAngles = level.Allies_Spawnpoints[i][1];

			level.Allies_Spawnpoints_Spawned[i] = spawn("script_origin", toGround);
			level.Allies_Spawnpoints_Spawned[i].origin = toGround;
			level.Allies_Spawnpoints_Spawned[i].angles = toAngles;
		}
	}

	if(isdefined(level.Axis_Spawnpoints))
	{
		for(i = 0; i < level.Axis_Spawnpoints.size; i++)
		{
			toGround = positionToGround(level.Axis_Spawnpoints[i][0], level.Axis_Spawnpoints[i]);
			toAngles = level.Axis_Spawnpoints[i][1];

			level.Axis_Spawnpoints_Spawned[i] = spawn("script_origin", toGround);
			level.Axis_Spawnpoints_Spawned[i].origin = toGround;
			level.Axis_Spawnpoints_Spawned[i].angles = toAngles;
		}
	}





	allowed[0] = "re";
	allowed[1] = "retrieval";
	maps\mp\gametypes\_gameobjects::main(allowed);




	// Disable name changing to avoid spamming (is enabled in readyup)
	setClientNameMode("manual_change"); // name is changed after map restart ()



	thread serverInfo();



	players = getentarray("player", "classname");

	for(i = 0; i < players.size; i++)
		players[i].objs_held = 0;


	minefields = [];
	minefields = getentarray("minefield", "targetname");
	trigger_hurts = [];
	trigger_hurts = getentarray("trigger_hurt", "classname");

	level.minefield = minefields;

	for(i = 0; i < trigger_hurts.size; i++)
		level.minefield[level.minefield.size] = trigger_hurts[i];





	// Wait here untill there is atleast one player connected
	if (game["firstInit"])
	{
		for(;;)
		{
			players = getentarray("player", "classname");
			if (players.size > 0)
				break;
			wait level.fps_multiplier * 1;
		}

		// For public mode, wait untill most of player connect
		if (game["is_public_mode"])
		{
			for(;;)
			{
				allies = 0;
				axis = 0;

				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					if (players[i].pers["team"] == "allies")
						allies++;
					else if (players[i].pers["team"] == "axis")
						axis++;
				}

				if (allies > 0 && axis > 0)
				{
					iprintln("Match starting");

					wait level.fps_multiplier * 8;

					if (!level.pam_mode_change)
						map_restart(true);

					break;
				}

				wait level.fps_multiplier * 3;
			}
		}
	}


	level.starttime = getTime();


	level.matchstarted = true;


	// Show weapon info about sniper and shotgun players
	level thread maps\mp\gametypes\_sniper_shotgun_info::updateSniperShotgunHUD();

	thread deadchat();

	if (!level.in_readyup)
	{
		thread startRound();
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
================*/
onConnecting()
{
	self.statusicon = "hud_status_connecting";
}

/*
Called when player is fully connected to game
*/
onConnected()
{
	self.statusicon = "";

	// Variables in self.pers[] stay defined after scriped map restart
	// Other like self.ownvariable will be undefined after scriped map restart
	// Except a few special vars, like self.sessionteam, their are defined after map restart, but with default value

	// If is players first connect, his team is undefined (in SD is PlayerConnected called every round)
	if (!isDefined(self.pers["team"]))
	{
		// Show player in spectator team
		// If mod is not downloaded or blackout is needed to show, player is moved to none team in another script
		self.pers["team"] = "none";
		self.sessionteam = "none";

		// Print "<NAME> Connected" to all
		iprintln(&"MP_CONNECTED", self.name);
	}
	else
	{
		// If is team selected from last round, set the real team variable
		self.sessionteam = self.pers["team"];
	}


	// Define default variables specific for this gametype
	self.spawnsInStrattime = 0;
	self.obj_carrier = false;

	// Set score and deaths
	if(!isdefined(self.pers["score"]))
		self.pers["score"] = 0;
	self.score = self.pers["score"];

	if(!isdefined(self.pers["deaths"]))
		self.pers["deaths"] = 0;
	self.deaths = self.pers["deaths"];

	self setClientCvar("cg_objectiveText", "");
}

// This function is called as last after all events are processed
onAfterConnected()
{
	// If the game is at the post game state (scoreboard) the connecting player should spawn into intermission
	if (game["state"] == "intermission")
		spawnIntermission();

	// If player is just connected and blackout needs to be activated
	else if (self.pers["team"] == "none")
	{
		if (self maps\mp\gametypes\_blackout::isBlackoutNeeded())
			self maps\mp\gametypes\_blackout::spawnBlackout();
		else
			spawnSpectator();
	}

	// Spectator team
	else if (self.pers["team"] == "spectator")
		spawnSpectator();

	// If team is selected
	else if (self.pers["team"] == "allies" || self.pers["team"] == "axis")
	{
		// If player have choozen weapon
		if(isDefined(self.pers["weapon"]))
			spawnPlayer();
		// If player have choosen team, but have not choosen weapon (he is selecting from weapons menu)
		else
			spawnSpectator();
	}

	else
		assertMsg("Unknown team");
}



/*================
Called when a player drops from the server.
Will not be called between levels.
self is the player that is disconnecting.
================*/
onDisconnect()
{
	iprintln(&"MP_DISCONNECTED", self.name);

	if(isdefined(self.objs_held))
	{
		if(self.objs_held > 0)
		{
			for(i = 0; i < (level.numobjectives + 1); i++)
			{
				if(isdefined(self.hasobj[i]))
				{
					//if(self isonground())
						self.hasobj[i] drop_objective_on_disconnect_or_death(self);
					//else
					//	self.hasobj[i] drop_objective_on_disconnect_or_death(self, "trace");
				}
			}
		}
	}

	level thread updateTeamStatus(); // in thread because of wait 0
}

/*
Called when player is about to take a damage.
self is the player that took damage.
Return true to prevent the damage.
*/
onPlayerDamaging(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// In readyup there is own onPlayerDamaging function
	if (level.in_readyup)
		return false;

	// Prevent damage when:
	if (!level.matchstarted || level.in_strattime || level.roundended)
		return true;

	// In bash mode allow damage only via pistol bash
	if (level.in_bash && (sMeansOfDeath != "MOD_MELEE" || !maps\mp\gametypes\_weapons::isPistol(sWeapon)))
		return true;

	// Friendly fire is disabled - prevent damage
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]))
		{
			if(level.scr_friendlyfire == 0)
			{
				return true;
			}
		}
	}
}



/*
Called when player has taken damage.
self is the player that took damage.
*/
onPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// check for completely getting out of the damage
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		// Player's stats - increase damage points (_player_stat.gsc)
		if (isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self && eAttacker.pers["team"] != self.pers["team"] && !level.in_readyup && level.roundstarted && !level.roundended)
		{
			eAttacker thread watchPlayerDamageForStats(self, iDamage);

			// For assists
			if (isDefined(self.lastAttacker) && self.lastAttacker != eAttacker)
			{
				self.lastAttacker2 = self.lastAttacker;
				self.lastAttackerTime2 = self.lastAttackerTime;
			}

			self.lastAttacker = eAttacker;
			self.lastAttackerTime = gettime();
		}
	}
}

// Called as last funtction after all onPlayerDamaged events are processed
onAfterPlayerDamaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{

	isFriendlyFire = false; // used for log

	//println("^2"+self.name+" took damage " + iDamage + " idflags " + iDFlags);

	// check for completely getting out of the damage
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]))
		{
			if(level.scr_friendlyfire == 1)
			{
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				self notify("damaged_player", iDamage);

				// Shellshock/Rumble
				self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
			}
			else if(level.scr_friendlyfire == 2)
			{
				eAttacker.friendlydamage = true;

				iDamage = int(iDamage * .5);

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker notify("damaged_player", iDamage);
				eAttacker.friendlydamage = undefined;

				isFriendlyFire = true;
			}
			else if(level.scr_friendlyfire == 3)
			{
				eAttacker.friendlydamage = true;

				iDamage = int(iDamage * .5);

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				self notify("damaged_player", iDamage);

				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker notify("damaged_player", iDamage);

				eAttacker.friendlydamage = undefined;

				// Shellshock/Rumble
				self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);

				isFriendlyFire = true;
			}
		}
		else
		{
			// Make sure at least one point of damage is done
			if(iDamage < 1)
				iDamage = 1;

			self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			self notify("damaged_player", iDamage);

			// Shellshock/Rumble
			self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
		}
	}


	if(self.sessionstate != "dead" && !level.in_readyup)
		level notify("log_damage", self, eAttacker, sWeapon, iDamage, sMeansOfDeath, sHitLoc, isFriendlyFire);
}

// Self if player who is hitting enemy
watchPlayerDamageForStats(enemy, damage)
{
	self endon("disconnect");
	enemy endon("disconnect");

	// Wait untill player starts healing
	lastValue = enemy.health;
	for(;;)
	{
		wait level.fps_multiplier * 1;
		if (enemy.health > lastValue)
			break;
		if (enemy.health <= 0)	// if enemy is killed, dont count damage
			return;
		lastValue = enemy.health;
	}

	// Enemy was not killed in 5sec, count damage
	self maps\mp\gametypes\_player_stat::AddDamage(damage);
}

/*
Called when player is about to be killed.
self is the player that was killed.
Return true to prevent the kill.
*/
onPlayerKilling(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Prevent kill if round didnt start
	if (!level.matchstarted)
		return true;

	// Prevent death when round ended
	if (level.roundended && !isdefined(self.switching_teams))
		return true;
}

/*
Called when player is killed
self is the player that was killed.
*/
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Add score to Deaths
	if(!isdefined(self.switching_teams))
	{
		// Player's stats - increase kill points (_player_stat.gsc)
		if (!level.in_readyup && level.roundstarted && !level.roundended)
			self maps\mp\gametypes\_player_stat::AddDeath();
	}

	if(isPlayer(attacker) && attacker != self)
	{
		if(self.pers["team"] == attacker.pers["team"]) // killed by a friendly
		{
			// Player's stats - decrease score points (_player_stat.gsc)
			if (!level.in_readyup && level.roundstarted && !level.roundended)
				attacker maps\mp\gametypes\_player_stat::AddScore(-1);
		}
		else
		{
			// Player's stats - increase kill points (_player_stat.gsc)
			if (!level.in_readyup && level.roundstarted && !level.roundended)
			{
				attacker maps\mp\gametypes\_player_stat::AddKill();
				attacker maps\mp\gametypes\_player_stat::AddScore(1);

				// For assists
				if (isDefined(self.lastAttacker) && isDefined(self.lastAttacker2) && self.lastAttacker2 != attacker && (self.lastAttackerTime2 + 5000) > gettime())
				{
					self.lastAttacker2 thread maps\mp\gametypes\_damagefeedback::updateAssistsFeedback();

					self.lastAttacker2 maps\mp\gametypes\_player_stat::AddAssist();
					self.lastAttacker2 maps\mp\gametypes\_player_stat::AddScore(0.5);
				}

			}
		}
	}
}

// Called as last funtction after all onPlayerKilled events are processed
onAfterPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self endon("disconnect");
	self endon("spawned");

	// Kill is handled in readyup functions
	if (level.in_readyup)
		return;

	// Send out an obituary message to all clients about the kill
	obituary(self, attacker, sWeapon, sMeansOfDeath);

	// Weapon/Nade Drops
	if (!isDefined(self.switching_teams) && level.roundstarted && !level.roundended)
		self thread maps\mp\gametypes\_weapons::dropWeapons();

	// Drop objectives
	if(isdefined(self.objs_held))
	{
		if(self.objs_held > 0)
		{
			for(i = 0; i < (level.numobjectives + 1); i++)
			{
				if(isdefined(self.hasobj[i]))
				{
					//if(self isonground())
					//{
					//	println("PLAYER KILLED ON THE GROUND");
						self.hasobj[i] thread drop_objective_on_disconnect_or_death(self);
					//}
					//else
					//{
					//	println("PLAYER KILLED NOT ON THE GROUND");
					//	self.hasobj[i] thread drop_objective_on_disconnect_or_death(self.origin, "trace");
					//}
				}
			}
		}
	}

	// Show as dead
	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";

	// Add score to Deaths
	if(!isdefined(self.switching_teams))
	{
		self.pers["deaths"]++;
		self.deaths = self.pers["deaths"];
	}

	doKillcam = false;
	attackerNum = -1; // used for killcam
	if(isPlayer(attacker))
	{
		if(attacker == self) // killed himself
		{
			doKillcam = false;

			// switching teams
			if(isdefined(self.switching_teams))
			{
				if((self.leaving_team == "allies" && self.joining_team == "axis") || (self.leaving_team == "axis" && self.joining_team == "allies"))
				{
					players = maps\mp\gametypes\_teams::CountPlayers();
					players[self.leaving_team]--;
					players[self.joining_team]++;

					if((players[self.joining_team] - players[self.leaving_team]) > 1)
					{
						attacker.pers["score"]--;
						attacker.score = attacker.pers["score"];
					}
				}
			}

			if(isdefined(attacker.friendlydamage))
				attacker iprintln(&"MP_FRIENDLY_FIRE_WILL_NOT");
		}
		else
		{
			attackerNum = attacker getEntityNumber();
			doKillcam = true;

			if(self.pers["team"] == attacker.pers["team"]) // killed by a friendly
			{
				attacker.pers["score"]--;
				attacker.score = attacker.pers["score"];
			}
			else
			{
				attacker.pers["score"]++;
				attacker.score = attacker.pers["score"];
			}
		}
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;

		self.pers["score"]--;
		self.score = self.pers["score"];
	}


	level notify("log_kill", self, attacker,  sWeapon, iDamage, sMeansOfDeath, sHitLoc);


	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;

	// Wait before dead body is spawned to allow double kills (bullets may stop in this dead body)
	// Ignore this for shotgun, because it create a smoke effect on dead body (for good feeling)
	if (sWeapon != "shotgun_mp")
		waittillframeend;

	// Clone players model for death animations
	body = undefined;
	if(!isdefined(self.switching_teams))
		body = self cloneplayer(deathAnimDuration);


	//Remove HUD text if there is any
	for(i = 1; i < 16; i++)
	{
		if((isdefined(self.hudelem)) && (isdefined(self.hudelem[i])))
			self.hudelem[i] destroy();
	}
	if(isdefined(self.progressbackground))
		self.progressbackground destroy();
	if(isdefined(self.progressbar))
		self.progressbar destroy();


	self.switching_teams = undefined;


	level thread updateTeamStatus(); // in thread because of wait 0


	delay = 2;	// Delay the player becoming a spectator till after he's done dying
	wait level.fps_multiplier * delay;	// ?? Also required for Callback_PlayerKilled to complete before killcam can execute



	// If the last player on a team was just killed
	if((self.pers["team"] == "allies" || self.pers["team"] == "axis") && !level.exist[self.pers["team"]])
	{
		// Dont do killcam
		doKillcam = false;
	}


	// Do killcam - if enabled, wait here until killcam is done
	if(doKillcam && level.scr_killcam && !level.roundended)
		self maps\mp\gametypes\_killcam::killcam(attackerNum, 7, 8, psOffsetTime);

	// In SD - show score for dead player even if score is disabled
	self maps\mp\gametypes\_hud_teamscore::showScore(0.5);

	// Spawn from "dead" player session to spectator
	self thread spawnSpectator(self.origin + (0, 0, 60), self.angles);
}

spawnPlayer()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");


	self.sessionteam = self.pers["team"];
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.maxhealth = 100;
	self.health = self.maxhealth;
	self.friendlydamage = undefined;
	self.objs_held = 0;
	self.timeafterdrop_obj = false;
	self.obj_carrier = false;

	self.statusicon = "";



	if (isDefined(self.hintstring))
		self.hintstring destroy();

	if (isDefined(self.hintstringusehint))
		self.hintstringusehint destroy();

	self.display_use_hintstring = false;


	// Select correct spawn position according to selected team
	if(self.pers["team"] == "allies")
		spawnpointname = "mp_sd_spawn_attacker";
	else
		spawnpointname = "mp_sd_spawn_defender";


	// Select new spawnpoints if they exist
	if(isdefined(level.Allies_Spawnpoints) && isdefined(level.Axis_Spawnpoints))
	{
		if(self.pers["team"] == "allies")
			spawnpoint = getRandomSpawnpoint(level.Allies_Spawnpoints, level.Allies_Spawnpoints_Spawned);
		else
			spawnpoint = getRandomSpawnpoint(level.Axis_Spawnpoints, level.Axis_Spawnpoints_Spawned);
	}
	else
	{
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	}

	if(isdefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");



	// Update status about players into level.exist and check of round is draw/winner/atd..
	level thread updateTeamStatus(); // in thread because of wait 0


	if(!isdefined(self.pers["savedmodel"]))
		maps\mp\gametypes\_teams::model();
	else
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);


	if(!level.in_readyup && !level.in_timeout)
	{
		if(self.pers["team"] == game["attackers"])
			self setClientCvar("cg_objectiveText", &"RE_ATTACKER");

		else if(self.pers["team"] == game["defenders"])
			self setClientCvar("cg_objectiveText", &"RE_DEFENDER");
	}



	// If there is saved weapons from last round
	if(isdefined(self.pers["weapon1"]) && isdefined(self.pers["weapon2"]))
	{
	 	self setWeaponSlotWeapon("primary", self.pers["weapon1"]);
		self giveMaxAmmo(self.pers["weapon1"]);

	 	self setWeaponSlotWeapon("primaryb", self.pers["weapon2"]);
		self giveMaxAmmo(self.pers["weapon2"]);

		self setSpawnWeapon(self.pers["weapon1"]);

		self.spawnedWeapon = self.pers["weapon1"];
	}
	else
	{
		self setWeaponSlotWeapon("primary", self.pers["weapon"]);
		self giveMaxAmmo(self.pers["weapon"]);

		self setSpawnWeapon(self.pers["weapon"]);

		self.spawnedWeapon = self.pers["weapon"];
	}

	// Give grenades only if we are in readyup
	if(level.in_readyup)
	{
		maps\mp\gametypes\_weapons::giveSmokesFor(self.spawnedWeapon, 0);
		maps\mp\gametypes\_weapons::giveGrenadesFor(self.spawnedWeapon, 0); // grenades are handled in readyup now
	}
	else
	{
		maps\mp\gametypes\_weapons::giveSmokesFor(self.spawnedWeapon, 0);
		maps\mp\gametypes\_weapons::giveGrenadesFor(self.spawnedWeapon, 0);	// grenades will be added after start time
	}
	maps\mp\gametypes\_weapons::givePistol();
	maps\mp\gametypes\_weapons::giveBinoculars();

	// Switch to pistol in bash mode
	if (level.in_bash)
	{
		self setSpawnWeapon(self getweaponslotweapon("primaryb"));
	}


	self.selectedWeaponOnRoundStart = self.pers["weapon"]; // to determine is weapon was changed during round


	// Hide score if it may be hidden
	if (level.roundstarted)
		self maps\mp\gametypes\_hud_teamscore::hideScore(0.5);

	// Count how many times player changed team in strattime (used to limit it in menu_weapon)
	if (level.in_strattime && (self.pers["team"] == "allies" || self.pers["team"] == "axis"))
		self.spawnsInStrattime++;

	// Notify "spawned" notifications
	self notify("spawned");
	self notify("spawned_player");
}


spawnSpectator(origin, angles)
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	else if (self.pers["team"] == "allies" || self.pers["team"] == "axis") // dead team spectartor
		self.statusicon = "hud_status_dead";


	if(isdefined(origin) && isdefined(angles))
		self spawn(origin, angles);
	else
	{
 		spawnpointname = "mp_global_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

		if(isdefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
		{
			self spawn((0,0,0), (0,0,0));
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
		}
	}


	// Update status about players into level.exist and check of round is draw/winner/atd..
	level thread updateTeamStatus(); // in thread because of wait 0


	// Notify "spawned" notifications
	self notify("spawned");

	self setClientCvar("cg_objectiveText", "");


	// If is real spectator (is in team spectator, not session state spectator)
	if(self.pers["team"] == "spectator")
	{
		self notify("spawned_spectator");
	}
}

spawnIntermission()
{
	// Resets the infinite loop check timer, to prevent an incorrect infinite loop error when a lot of script must be run
	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isdefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");

	for (i = 0; i < 7; i++)
		objective_delete(i);

	// Notify "spawned" notifications
	self notify("spawned");
	self notify("spawned_intermission");
}




startRound()
{
	level endon("round_ended");


	logPrint("RoundStart;\n");
	logPrint("RoundInfo;score:"+game["allies_score"]+":"+game["axis_score"]+";round:"+game["round"]+"\n");

	// Define round number
	game["round"] = game["roundsplayed"] + 1;


	// If is bash, there is no time-limit
	if(level.in_bash)
	{
		//maps\mp\gametypes\_weapons::deletePlacedEntity("misc_turret");
		maps\mp\gametypes\_weapons::deletePlacedEntity("misc_mg42");

		wait level.fps_multiplier * 1;

		// Hide score if it may be hidden
		level maps\mp\gametypes\_hud_teamscore::hideScore(0.5);
		thread sayObjective();

		return;
	}


	level.in_strattime = false;

	// Timeout was called from previous round, exit
	if (level.in_timeout)
		return;



	// Starting essential things
	thread startRetrieval();



	// Show name of league + pam version
	thread maps\mp\gametypes\_pam::PAM_Header();

	// Do strat time if is enabled
	if (level.strat_time > 0)
	{
		level.in_strattime = true;

		// Disable players movement
		level thread stratTime_g_speed();

		// Show HUD stuff...
		thread HUD_StratTime(level.strat_time);
		thread HUD_RoundInfo(level.strat_time);

		// End strattime when time expires or timeout is called
		level thread strattime_end_timer(level.strat_time);
		level thread strattime_end_ontimeout();

		level waittill("strat_time_end");

		// Out of strat time
		level.in_strattime = false;

		// Timeout was called in middle of strat time, exit
		if (level.in_timeout)
			return;
	}

	// Round started
	level.roundstarted = true;



	thread HUD_Clock(level.roundlength * 60);


	// Hide pam info hud
	thread maps\mp\gametypes\_pam::PAM_Header_Delete();
	// Hide score if it may be hidden
	level maps\mp\gametypes\_hud_teamscore::hideScore(0.5);



	thread sayObjective();






	players = getentarray("player", "classname");

	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player.pers["team"] == "none" || player.pers["team"] == "spectator")
			continue;

		// Players on a team but without a weapon or dead show as dead since they can not get in this round
		if(player.sessionstate != "playing")
			player.statusicon = "hud_status_dead";

		// To all living player give grenades
		if (isDefined(player.selectedWeaponOnRoundStart) && player.sessionstate == "playing" && (player.pers["team"] == "allies" || player.pers["team"] == "axis") && !level.in_bash)
		{
			player maps\mp\gametypes\_weapons::giveSmokesFor(player.selectedWeaponOnRoundStart);
			player maps\mp\gametypes\_weapons::giveGrenadesFor(player.selectedWeaponOnRoundStart);
		}

	}


	// Wait until round time expires (2 min default)
	wait level.fps_multiplier * level.roundlength * 60;


	// Time expired
	iprintln(&"MP_TIMEHASEXPIRED");

	// If there is no opponent -> draw
	if(!level.exist[game["attackers"]] || !level.exist[game["defenders"]])
		level thread endRound("draw");

	// By default defenders wins if time expires, because attackers did not plant bonb
	else
	{
		level thread playSoundOnPlayers("MP_announcer_objective_defended");
		level thread endRound(game["defenders"]);
	}
}

strattime_end_timer(time)
{
	level endon("strat_time_end");

	wait level.fps_multiplier * time;

	level notify("strat_time_end");
}

strattime_end_ontimeout()
{
	level endon("strat_time_end");

	level waittill("running_timeout");

	level notify("strat_time_end");
}

HUD_Clock(countDownTime)
{
	level.clock = newHudElem2();
	level.clock.font = "default";
	level.clock.fontscale = 2;
	level.clock.horzAlign = "center_safearea";
	level.clock.vertAlign = "top";
	level.clock.alignX = "center";
	level.clock.alignY = "top";
	level.clock.color = (1, 1, 1);
	level.clock.x = 0;
	level.clock.y = 445;
	level.clock setTimer(countDownTime);

	// If strattime is enabled, show fade-in animation
	if (level.strat_time > 0)
	{
		level.clock.alpha = 0;

		level.clock FadeOverTime(0.5);
		level.clock.alpha = 1;

		level.clock.x = 40;
		level.clock moveovertime(0.5);
		level.clock.x = 0;
	}


	waitTime = countDownTime - 30 - 0.3;
	if (waitTime <= 0)
		return;

	wait waitTime * level.fps_multiplier;
	if (!isDefined(level.clock) || level.roundended)
		return;

	// Orange
	level.clock.color = (1, 0.6, 0.15);

	waitTime = countDownTime - waitTime - 15;
	if (waitTime <= 0)
		return;

	wait waitTime * level.fps_multiplier;
	if (!isDefined(level.clock) || level.roundended)
		return;

	// Red
	level.clock.color = (1, 0.25, 0.25);
}

HUD_StratTime(time)
{
	if (time <= 0)
		return;

	// Strat Time
	strattime = addHUD(0, 450, 2, (.98, .827, .58), "center", "bottom", "center_safearea", "top");
	strattime setText(game["STRING_STRAT_TIME"]);

	// 0:05
	strat_clock = addHUD(0, 445, 2, (.98, .827, .58), "center", "top", "center_safearea", "top");
	strat_clock setTimer(time);


	// Wait untill time expired or timeout was called
	level waittill("strat_time_end");


	strattime FadeOverTime(0.5);
	strattime.alpha = 0;

	strat_clock FadeOverTime(0.5);
	strat_clock.alpha = 0;

	strat_clock moveovertime(0.5);
	strat_clock.x = -40;

	wait level.fps_multiplier * 0.5;

	strattime destroy2();
	strat_clock destroy2();
}


HUD_RoundInfo(time)
{
	if (game["round"] == 1)
	{
		roundInfo = addHUD(0, 430, 1.3, (.8, 1, 1), "center", "bottom", "center_safearea", "top");
		roundInfo setText(game["STRING_ROUND_FIRST"]);
		roundInfo.y = 360;
		roundInfo moveovertime(3);
		roundInfo.y = 428;
		level waittill("strat_time_end");
		roundInfo thread removeHUDSmooth(.5);
	}
	// Last round before half
	else if (level.halfround > 0 && !game["is_halftime"] && game["round"] >= level.halfround)
	{
		roundInfo = addHUD(0, 430, 1.3, (.8, 1, 1), "center", "bottom", "center_safearea", "top");
		roundInfo setText(game["STRING_ROUND_LAST_HALF"]);
		roundInfo.y = 360;
		roundInfo moveovertime(3);
		roundInfo.y = 428;
		level waittill("strat_time_end");
		roundInfo thread removeHUDSmooth(.5);
	}
	// Last match round
	else if (level.matchround > 0 && game["is_halftime"] && game["round"] >= level.matchround)
	{
		roundInfo = addHUD(0, 430, 1.3, (.8, 1, 1), "center", "bottom", "center_safearea", "top");
		roundInfo setText(game["STRING_ROUND_LAST"]);
		roundInfo.y = 360;
		roundInfo moveovertime(3);
		roundInfo.y = 428;
		level waittill("strat_time_end");
		roundInfo thread removeHUDSmooth(.5);
	}
	else
	{
		roundInfo1 = addHUD(10, 428, 1.3, (.8, 1, 1), "right", "bottom", "center_safearea", "top");
		roundInfo2 = addHUD(14, 428, 1.3, (.8, 1, 1), "left", "bottom", "center_safearea", "top");

		roundInfo1 setText(game["STRING_ROUND"]);
		roundInfo2 setValue(game["round"]);

		level waittill("strat_time_end");

		roundInfo1 thread removeHUDSmooth(.5);
		roundInfo2 thread removeHUDSmooth(.5);
	}


}

/*
              __
  Round     (    )
    8      (  .   )
 Starting   ( __ )
*/
HUD_NextRound()
{
	x = -90;
        y = 270;

	// Time to wait
	time = level.round_endtime;

	// Ccount-down stopwatch
	stopwatch = addHUD(x+80, y, undefined, undefined, "right", "top", "right");
	stopwatch showHUDSmooth(.5);
	stopwatch.sort = 4;
	stopwatch.foreground = true;  // above blackbg and visible if menu opened
	stopwatch setClock(time, 60, "hudStopwatch", 60, 60); // count down for 5 of 60 seconds, size is 64x64

	// Round
    	round = addHUD(x, y, 1.2, (1,1,0), "center", "top", "right");
	round showHUDSmooth(.5);
	round setText(game["STRING_ROUND"]);
	y += 27;

	// 6
    	roundnum = addHUD(x, y, 1.4, (1,1,0), "center", "middle", "right");
	roundnum showHUDSmooth(.5);
	roundnum setValue(game["roundsplayed"]+1);
	y += 28;

	// Starting
    	starting = addHUD(x, y, 1.2, (1,1,0), "center", "bottom", "right");
	starting showHUDSmooth(.5);
	starting setText(game["STRING_ROUND_STARTING"]);


	// Remove HUD in case timeout is called (new hud about timeout is whowed)
	while (!game["do_timeout"])
		wait level.fps_multiplier * 0.2;

	round thread removeHUDSmooth(.5);
	roundnum thread removeHUDSmooth(.5);
	starting thread removeHUDSmooth(.5);
	stopwatch thread removeHUDSmooth(.5);
}


stratTime_g_speed()
{
	// Disable players movement
	maps\mp\gametypes\global\cvar_system::setCvarQuiet("g_speed", 0);

	level waittill("strat_time_end");

	maps\mp\gametypes\global\cvar_system::restoreCvarQuiet("g_speed");
}



// Is called when time expired, last player is killed, bomb expldoes, bomb is defused
endRound(roundwinner)
{
	level endon("intermission");

	// If this function was already called, dont do it again
	if(level.roundended)
		return;
 	level.roundended = true;




	// End bombzone threads and remove related hud elements and objectives
	level notify("round_ended");

	// Remove plant progress if round ended when some player was planting
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isdefined(player.progressbackground))
			player.progressbackground destroy2();

		if(isdefined(player.progressbar))
			player.progressbar destroy2();

		if(isdefined(player.hintstring))
			player.hintstring thread removeHUDSmooth(.5);

		if(isdefined(player.hintstringusehint))
			player.hintstringusehint thread removeHUDSmooth(.5);

		player.display_use_hintstring = false;

		player unlink();
		player enableWeapon();
	}

	// Say: Axis/Allies Win   after 2 sec
	level thread announceWinner(roundwinner, 2);



	if (level.in_bash)
	{
		wait level.fps_multiplier * 4;

		game["Do_Ready_up"] = undefined; // will restart readyup

		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			player.pers["score"] = undefined;
			player.pers["deaths"] = undefined;
		}

		if (!level.pam_mode_change)
        		map_restart(true);
		return;
	}


	// Show weapon info about sniper and shotgun players
	level thread maps\mp\gametypes\_sniper_shotgun_info::updateSniperShotgunHUD();




	if(roundwinner == "allies")
	{
		if (game["is_halftime"])
			game["half_2_allies_score"]++;
		else
			game["half_1_allies_score"]++;

		game["allies_score"]++;
	}
	else if(roundwinner == "axis")
	{
		if (game["is_halftime"])
			game["half_2_axis_score"]++;
		else
			game["half_1_axis_score"]++;

		game["axis_score"]++;
	}

	// Set Score
	setTeamScore("allies", game["allies_score"]);
	setTeamScore("axis", game["axis_score"]);

	// History score for spectators
	if(roundwinner == "allies")
	{
		game["allies_score_history"] += "^2#";
		game["axis_score_history"] += "^1=";
	}
	else if(roundwinner == "axis")
	{
		game["allies_score_history"] += "^1=";
		game["axis_score_history"] += "^2#";
	}
	else // draw
	{
		game["allies_score_history"] += "^7-";
		game["axis_score_history"] += "^7-";
	}


	// Update score
	level maps\mp\gametypes\_hud_teamscore::updateScore();

	// LOG stuff
	level notify("log_round_end", roundwinner);


	// Increase played rounds
	if ((roundwinner == "draw" && level.countdraws) || roundwinner == "allies" || roundwinner == "axis")
		game["roundsplayed"]++;


	// Check total time limit first (scr_sd_timelimit), may be used in pub
	game["timepassed"] = game["timepassed"] + ((getTime() - level.starttime) / 1000) / 60.0;




	// Wait a sec after last player is killed
	wait level.fps_multiplier * 2;


	thread maps\mp\gametypes\_pam::PAM_Header(true); // true = fadein

	// Show score even if is disabled
	level maps\mp\gametypes\_hud_teamscore::showScore(0.5);


	// Print damage stats
	//maps\mp\gametypes\_round_report::printToAll();


	// In SD there are 3 checks: Time limit, Score limit and Round limit

	// Check Time Limit - if is reached, map-end is runned
	ended = checkTimeLimit(); // Time expired
	if(ended) return;

	// Check Score Limit - if is reached, half-time is runned or map-end is runned
	ended = checkMatchScoreLimit();
	if(ended) return;

	// Check Round Limit - if is reached, half-time is runned or map-end is runned
	ended = checkMatchRoundLimit();
	if(ended) return;





	if(level.round_endtime > 0)
	{
		if (game["do_timeout"] == true)
			thread maps\mp\gametypes\_timeout::HUD_Timeout(); // show at the end of the round we are going to timeout
		else
			thread HUD_NextRound();


		wait level.fps_multiplier * level.round_endtime;
	}
	else
	{
		// Wait a sec if no warup time defined
		wait level.fps_multiplier * 3;
	}


	// for all living players store their weapons
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		/*
		Recoded weapon saving system:

		Round start  	| End of Round 	| Next round	| Case selected weapon is
		Spawned weap 	| Weapon slots 	| Spawned weap	| changed to thompson during round
		--------------------------------------------------------------------------------
		M1		| M1	-	| M1	-	| thomp	-
		M1		| -	M1	| M1	-	| thomp	-
		M1		| M1	KAR	| M1	KAR	| thomp	KAR
		M1		| KAR	M1	| KAR	M1	| thomp M1
		M1		| KAR	MP44	| KAR	MP44	| thomp	MP44
		M1		| KAR	-	| KAR	-	| thomp	-
		M1		| -	KAR	| KAR	-	| thomp	-
		M1		| M1	thomp	| M1	thomp	| thomp	-
		M1		| thomp	M1	| thomp M1	| thomp M1
		M1		| -	-	| M1	-	| thomp	-

		*/


		if(isDefined(player.pers["weapon"]) && (player.pers["team"] == "allies" || player.pers["team"] == "axis") && player.sessionstate == "playing")
		{
			weapon1 = player getWeaponSlotWeapon("primary");
			weapon2 = player getWeaponSlotWeapon("primaryb");

			// Remove pistols and limited weapons
			if (!player maps\mp\gametypes\_weapon_limiter::isWeaponSaveable(weapon1))
				weapon1 = "none";
			if (!player maps\mp\gametypes\_weapon_limiter::isWeaponSaveable(weapon2))
				weapon2 = "none";

			// Give player selected weapon if selected weapon is changed
			if (player.selectedWeaponOnRoundStart != player.pers["weapon"])
			{
				weapon1 = player.pers["weapon"];
				// In case we change to weapon, that is actually in slot, avoid duplicate
				if (weapon1 == weapon2)
					weapon2 = "none";
			}

			// Give player spawned weapon if there is no saveable weapons
			if (weapon1 == "none" && weapon2 == "none")
				weapon1 = player.pers["weapon"];

			// Swap weapons if there is weapon in secondary slot only
			if (weapon1 == "none" && weapon2 != "none")
			{
				temp = weapon1;
				weapon1 = weapon2;
				weapon2 = temp;
			}

			// Save spawned weapon
			player.pers["weapon1"] = weapon1;
			player.pers["weapon2"] = weapon2;
		}
		else
		{
			player.pers["weapon1"] = undefined;
			player.pers["weapon2"] = undefined;
		}
	}

	// Used for balance team at the end of the round
	level notify("restarting");

	if (!level.pam_mode_change)
		map_restart(true);


}

checkTimeLimit()
{
	if (level.timelimit > 0 && game["timepassed"] >= level.timelimit)
	{
		iprintln(&"MP_TIME_LIMIT_REACHED");

		level thread maps\mp\gametypes\_end_of_map::Do_Map_End();

		return true; // ended
	}

	return false;
}

// Score limit (not used in cg)
checkMatchScoreLimit()
{
	// Is it a score-based Halftime?
	if(!game["is_halftime"] && level.halfscore != 0)
	{
		if(game["half_1_allies_score"] >= level.halfscore || game["half_1_axis_score"] >= level.halfscore)
		{
			level thread maps\mp\gametypes\_halftime::Do_Half_Time();
			return true;
		}
	}

	// Is it a score-based Map-End?
	if (level.scorelimit != 0)
	{
		if (game["allies_score"] >= level.scorelimit || game["axis_score"] >= level.scorelimit)
		{
			level thread maps\mp\gametypes\_end_of_map::Do_Map_End();
			return true;
		}
	}

	return false;
}

// Round limit (20)
checkMatchRoundLimit()
{
	// Is it a round-based Halftime? (in cg is 10)
	if (!game["is_halftime"] && level.halfround != 0)
	{
		if(game["roundsplayed"] >= level.halfround)
		{
			level thread maps\mp\gametypes\_halftime::Do_Half_Time();
			return true;
		}
	}

	// Is it a round-based Map-End? (20)
	if (level.matchround != 0)
	{
		if (game["roundsplayed"] >= level.matchround)
		{
			if (level.scr_overtime && game["allies_score"] == game["axis_score"])
				level thread maps\mp\gametypes\_overtime::Do_Overtime();
			else
				level thread maps\mp\gametypes\_end_of_map::Do_Map_End();

			return true;
		}
	}

	return false;
}


// Update status about players into level.exist and check of round is draw/winner/atd..
// Called when: disconnect, player killed, player spawned, spectator spawned
updateTeamStatus()
{
	wait 0;	// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute

	resettimeout();

	//PAM - Dont want a round to end during readyup
	if (level.in_readyup)
		return;

	oldvalue["allies"] = level.exist["allies"];
	oldvalue["axis"] = level.exist["axis"];
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;


	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if((player.pers["team"] == "allies" || player.pers["team"] == "axis") && player.sessionstate == "playing")
			level.exist[player.pers["team"]]++;
	}

	if(level.exist["allies"])
		level.didexist["allies"] = true;
	if(level.exist["axis"])
		level.didexist["axis"] = true;

	if(level.roundended)
		return;

	// if both allies and axis were alive and now they are both dead in the same instance
	if(oldvalue["allies"] && !level.exist["allies"] && oldvalue["axis"] && !level.exist["axis"])
	{
		iprintln(&"MP_ALLIEDMISSIONACCOMPLISHED");
		level thread endRound("allies");
		return;
	}

	// if allies were alive and now they are not
	if(oldvalue["allies"] && !level.exist["allies"])
	{
		iprintln(&"MP_ALLIESHAVEBEENELIMINATED");
		level thread playSoundOnPlayers("mp_announcer_allieselim");
		level thread endRound("axis");
		return;
	}

	// if axis were alive and now they are not
	if(oldvalue["axis"] && !level.exist["axis"])
	{
		iprintln(&"MP_AXISHAVEBEENELIMINATED");
		level thread playSoundOnPlayers("mp_announcer_axiselim");
		level thread endRound("allies");
		return;
	}
}




startRetrieval()
{

	for(i = 0; i < level.objectivesArray.size; i++)
	{
		script_origin = level.objectivesArray[i][0];
		script_angles = level.objectivesArray[i][1];
		script_name = level.objectivesArray[i][2];
		script_radius = level.objectivesArray[i][3];
		script_model = level.objectivesArray[i][4];
		script_objmodel = level.objectivesArray[i][5];

		level.auxiliary_entity[i] = spawn("misc_model", script_origin);
		level.auxiliary_entity[i].origin = script_origin;

		plant = level.auxiliary_entity[i] maps\mp\_utility::getPlant();
		end_loc = plant.origin;

		level.objectives[i] = spawn("script_model", end_loc);
		level.objectives[i].origin = end_loc;
		level.objectives[i].angles = script_angles;
		level.objectives[i].script_objective_name = script_name;
		level.objectives[i] setModel( script_model );
		level.objectives[i] notSolid();

		level.objectives[i].obj = spawn("script_model", level.objectives[i].origin);
		level.objectives[i].obj.origin = level.objectives[i].origin;
		level.objectives[i].obj.angles = level.objectives[i].angles;
		level.objectives[i].obj setModel( script_objmodel );
		level.objectives[i].obj notSolid();

		level.objectives[i].trigger = spawn("trigger_radius", level.objectives[i].origin, 0, script_radius, 32);
		level.objectives[i].trigger.origin = level.objectives[i].origin;


		level.objectives[i] thread objective_think_rally();
		level.objectives[i] thread objective_think_defend();
		level.objectives[i] thread retrieval_spawn_objective();
	}

	level.objectives_goal = spawn("trigger_radius", level.attackersbase, 0, 190, 500);
	level.objectives_goal thread objective_think_goal();

	level.obj_exist = true;
}

objective_think_rally()
{
	level.numobjectives = (level.numobjectives + 1);
	num = level.numobjectives;

	objective_add(num, "current", self.origin, "obj_rally");
	objective_team(num, game["attackers"]);
	self.objnum = (num);

	level.hudcount++;
	self.hudnum = level.hudcount;
	objective_position(num, self.origin);
	if(getCvar("scr_re_showcarrier") == "0")
	{
		while(1)
		{
			self waittill("picked up");
			objective_team(num, game["attackers"]);

			self waittill("dropped");
			objective_team(num, "none");
		}
	}
}

objective_think_defend()
{
	level.numobjectives = (level.numobjectives + 1);
	num = level.numobjectives;

	objective_add(num, "current", self.origin, "obj_defend");
	objective_team(num, game["defenders"]);
	self.objnum = (num);


	level.hudcount++;
	self.hudnum = level.hudcount;
	objective_position(num, self.origin);
	if(getCvar("scr_re_showcarrier") == "0")
	{
		while(1)
		{
			self waittill("picked up");
			Objective_team(num, "none");
			Objective_state(num, "invisible");

			self waittill("dropped");
			Objective_state(num, "current");
			Objective_team(num, game["defenders"]);
		}
	}
}

objective_think_goal(type)
{
	level.numobjectives = (level.numobjectives + 1);
	num = level.numobjectives;

	objective_add(num, "current", self.origin, "obj_goal");
	self.objnum = (num);

	//if(getCvar("scr_re_showcarrier") == "0")
	//	objective_team(num, game["attackers"]);
}


retrieval_spawn_objective()
{
	self.startorigin = self.origin;
	self.startangles = self.angles;
	self.trigger.startorigin = self.trigger.origin;

	self thread retrieval_think();

	//Set hintstring on the objectives trigger
	//wait level.frame;

	//self.trigger setHintString(&"", self.script_objective_name);
}

retrieval_think() //each objective model runs this to find it's trigger and goal
{
	if(isdefined(self.objnum))
	{
		objective_position(self.objnum, self.origin);
		objective_position(self.objnum - 1, self.origin);
	}

	while(1)
	{
		self.trigger waittill ("trigger", other);

		wait level.fps_multiplier * 0.08;

		if(level.in_timeout) return;
		if(level.in_readyup) return;
		if(level.roundended) return;
		if(!level.matchstarted) return;

		other thread showHintString(self);

		if((isPlayer(other)) && other useButtonPressed() && (other.pers["team"] == game["attackers"]) && !other.timeafterdrop_obj)
		{
			iprintln(&"RE_PICKEDUPGENERIC", self.script_objective_name);

			self playsound ("re_pickup_paper");
			self thread hold_objective(other);
			other.hasobj[self.objnum] = self;
			//println("SETTING HASOBJ[" + self.objnum + "] as the " + self.script_objective_name);
			other.objs_held++;
			other destroyhintstringhud();
			/*
			println("PUTTING OBJECTIVE " + self.objnum + " ON THE PLAYER ENTITY");
			objective_onEntity(self.objnum, other);
			*/
			other thread display_holding_obj(self);
			return;

		}
		else if((isPlayer(other)) && other useButtonPressed() && (other.pers["team"] == game["defenders"]))
		{
		//	if(game["attackers"] == "allies")
		//		other thread client_print(self, &"RE_PICKUPALLIESONLYGENERIC", self.script_objective_name);
		//	else if(game["attackers"] == "axis")
		//		other thread client_print(self, &"RE_PICKUPAXISONLYGENERIC", self.script_objective_name);
		}
	}
}


hold_objective(player) //the objective model runs this to be held by 'player'
{
	self endon("completed");
	self endon("dropped");
	team = player.sessionteam;
	self hide();
	self.obj hide();


	self.trigger triggerOff();
	self notify("picked up");

	//println("PUTTING OBJECTIVE " + self.objnum + " ON THE PLAYER ENTITY");
	player.statusicon = game["headicon_carrier"];
	player.obj_carrier = true;
	objective_onEntity(self.objnum, player);
	objective_onEntity(self.objnum - 1, player);

	self thread objective_carrier_atgoal_wait(player);
	self thread holduse(player);
	self thread pressuse_notify(player);

	player.headicon = game["headicon_carrier"];
	if(getCvar("scr_re_showcarrier") == "0")
		player.headiconteam = game["attackers"];
	else
		player.headiconteam = "none";
}

objective_carrier_atgoal_wait(player)
{
	self endon("dropped");
	while(1)
	{
		level.objectives_goal waittill("trigger", other);
		if((other == player) && (isPlayer(player)) && (player.pers["team"] == game["attackers"]))
		{
			//player.pers["score"] += 3;
			//player.score = player.pers["score"];
			level.objectives_done++;

			objective_delete(self.objnum);
			objective_delete(self.objnum - 1);


			self notify("completed");

			//org = (player.origin);
			self thread drop_objective(player, 1);

			objective_delete(self.objnum);
			objective_delete(self.objnum - 1);


			self delete();
			self.obj delete();

			if(level.objectives_done < level.objectives.size)
			{
				return;
			}
			else
			{
				iprintlnbold(&"RE_CAPTUREDALL");
				level thread playSoundOnPlayers("MP_announcer_objective_captured");
				level thread endRound(game["attackers"]);
				return;
			}
		}
		else
		{
			wait level.fps_multiplier * 0.05;
		}
	}
}

drop_objective(player, option)
{
	if(isPlayer(player))
	{
		num = (16 - (self.hudnum));
		if(isdefined(self.objs_held))
		{
			if(self.objs_held > 0)
			{
				for(i = 0; i < (level.numobjectives + 1); i++)
				{
					if(isdefined(self.hasobj[i]))
					{
						//if(self isonground())
							self.hasobj[i] thread drop_objective_on_disconnect_or_death(self);
						//else
						//	self.hasobj[i] thread drop_objective_on_disconnect_or_death(self.origin, "trace");
					}
				}
			}
		}

		if((isdefined(player.hudelem)) && (isdefined(player.hudelem[num])))
			player.hudelem[num] destroy();
	}

	//if(isdefined(loc))
	loc = (player.origin + (0, 0, 25));


	if((isdefined(option)) && (option == 1))
	{
		player.objs_held--;

		if((isdefined(self.objnum)) && (isdefined(player.hasobj[self.objnum])))
			player.hasobj[self.objnum] = undefined;


		objective_delete(self.objnum);
		objective_delete(self.objnum - 1);

		if(game["attackers"] == "allies")
			iprintlnbold(&"RE_CAPTUREDALLIESGENERIC", self.script_objective_name);
		else
			iprintlnbold(&"RE_CAPTUREDAXISGENERIC", self.script_objective_name);

		level thread playSoundOnPlayers("MP_announcer_objective_captured");

		if(isdefined(self.trigger))
			self.trigger delete();

		if((isPlayer(player)) && (player.objs_held < 1))
		{
			if(isPlayer(player))
			{
				player.statusicon = "";
				player.obj_carrier = false;
			}
			if(player.pers["team"] == "allies")
			{
				player.headicon = game["headicon_allies"];
				player.headiconteam = "allies";
			}
			else if(player.pers["team"] == "axis")
			{
				player.headicon = game["headicon_axis"];
				player.headiconteam = "axis";
			}
			else
			{
				player.headicon = "";
			}
		}
	}
	else
	{
		/*
		if(player isOnGround())
		{
			trace = bulletTrace(loc, (loc - (0, 0, 5000)), false, undefined);
			end_loc = trace["position"]; //where the ground under the player is
		}
		else
		{
			println("PLAYER IS ON GROUND - SKIPPING TRACE");
			end_loc = player.origin;
		}
		*/
		//CHAD
		plant = player maps\mp\_utility::getPlant();
		end_loc = plant.origin;

		if(distance(loc, end_loc) > 0)
		{
			self.origin = loc;
			self.obj.origin = loc;
			self.angles = plant.angles;
			self.obj.angles = plant.angles;
			self show();
			self.obj show();
			speed = (distance(loc, end_loc) / 250);
			if(speed > 0.4)
			{
				self moveto(end_loc, speed, 0.1, 0.1);
				self.obj moveto(end_loc, speed, 0.1, 0.1);
				self waittill("movedone");
				self.trigger.origin = end_loc;
			}
			else
			{
				self.origin = end_loc;
				self.obj.origin = end_loc;
				self.angles = plant.angles;
				self.obj.angles = plant.angles;
				self show();
				self.obj show();
				self.trigger.origin = end_loc;
			}
		}
		else
		{
			self.origin = end_loc;
			self.obj.origin = end_loc;
			self.angles = plant.angles;
			self.obj.angles = plant.angles;
			self show();
			self.obj show();
			self.trigger.origin = end_loc;
		}

		//check if it's in a minefield
		In_Mines = 0;
		for(i = 0; i < level.minefield.size; i++)
		{
			if(self istouching(level.minefield[i]))
			{
				In_Mines = 1;
				break;
			}
		}

		if(In_Mines == 1)
		{
			if(player.objs_held > 1)
			{	//IF A PLAYER HOLDS 2 OR MORE OBJECTIVES AND DROPS ONLY ONE INTO THE MINEFIELD
				//THEN THIS WILL STILL SAY "MULTIPLE OBJECTIVES..." BUT A PLAYER SHOULD NEVER
				//BE ABOVE A MINEFIELD IN ONE OF THE SHIPPED MAPS SO I'LL LEAVE IT FOR NOW
				if((!isdefined(level.lastdropper)) || (level.lastdropper != player))
				{
					level.lastdropper = player;
					iprintln(&"RE_INMINESGENERIC", self.script_objective_name);
				}
			}
			else
			{
				if((!isdefined(level.lastdropper)) || (level.lastdropper != player))
				{
					level.lastdropper = player;
					iprintln(&"RE_INMINESGENERIC", self.script_objective_name);
				}
			}
			self.trigger.origin = self.trigger.startorigin;
			self.origin = self.startorigin;
			self.angles = self.startangles;
			self.obj.origin = self.startorigin;
			self.obj.angles = self.startangles;
		}
		else
		{
			iprintln(&"RE_DROPPEDGENERIC", self.script_objective_name);
			self playsound ("re_pickup_paper");
		}

		if(isPlayer(player))
		{
			if((isdefined(self.objnum)) && (isdefined(player.hasobj[self.objnum])))
				player.hasobj[self.objnum] = undefined;

			player.objs_held--;
		}

		if((isPlayer(player)) && (player.objs_held < 1))
		{
			if(isPlayer(player))
			{
				player.statusicon = "";
				player.obj_carrier = false;
			}
			if(player.pers["team"] == "allies")
			{
				player.headicon = game["headicon_allies"];
				player.headiconteam = "allies";
			}
			else if(player.pers["team"] == "axis")
			{
				player.headicon = game["headicon_axis"];
				player.headiconteam = "axis";
			}
			else
			{
				player.headicon = "";
			}
		}

		if(self istouching(level.objectives_goal))
		{
			if(game["attackers"] == "allies")
				iprintlnbold(&"RE_CAPTUREDALLIESGENERIC", self.script_objective_name);
			else
				iprintlnbold(&"RE_CAPTUREDAXISGENERIC", self.script_objective_name);

			level thread playSoundOnPlayers("MP_announcer_objective_captured");

			if(isdefined(self.trigger))
				self.trigger delete();

			if((isPlayer(player)) && (player.objs_held < 1))
			{
				if(isPlayer(player))
				{
					player.statusicon = "";
					player.obj_carrier = false;
				}
				if(player.pers["team"] == "allies")
				{
					player.headicon = game["headicon_allies"];
					player.headiconteam = "allies";
				}
				else if(player.pers["team"] == "axis")
				{
					player.headicon = game["headicon_axis"];
					player.headiconteam = "axis";
				}
				else
				{
					player.headicon = "";
				}
			}

			//player.pers["score"] += 3;
			//player.score = player.pers["score"];
			level.objectives_done++;

			self notify("completed");
			level thread clear_player_dropbar(player);

			objective_delete(self.objnum);
			objective_delete(self.objnum - 1);


			self delete();
			self.obj delete();

			if(level.objectives_done < level.objectives.size)
			{
				return;
			}
			else
			{
				iprintlnbold(&"RE_CAPTUREDALL");
				level thread playSoundOnPlayers("MP_announcer_objective_captured");
				level thread endRound(game["attackers"]);
				return;
			}
		}

		self thread objective_timeout();
		self notify("dropped");
		self thread retrieval_think();
	}
}

clear_player_dropbar(player)
{
	if(isdefined(player))
	{
		player.progressbackground destroy();
		player.progressbar destroy();
		player unlink();
		player.isusing = false;
	}
}

objective_timeout()
{
	self endon("picked up");
	obj_timeout = 115;
	wait level.fps_multiplier * obj_timeout;
	iprintln(&"RE_TIMEOUTRETURNINGGENERIC", self.script_objective_name);
	self.trigger.origin = self.trigger.startorigin;
	self.origin = self.startorigin;
	self.angles = self.startangles;
	self.obj.origin = self.startorigin;
	self.obj.angles = self.startangles;
	objective_position(self.objnum, self.origin);
	objective_position(self.objnum - 1, self.origin);
}

holduse(player)
{
	player endon("killed_player");
	self endon("completed");
	self endon("dropped");
	player.isusing = false;
	delaytime = .3;
	droptime = 1;
	barsize = 288;
	level.barincrement = int(barsize / (20.0 * droptime));

	wait level.fps_multiplier * (1);


	while(isPlayer(player))
	{
		player waittill("Pressed Use");

		player.currenttime = 0;
		while(player useButtonPressed() && (isAlive(player)))
		{
			usetime = 0;
			while(isAlive(player) && player useButtonPressed() && (usetime < delaytime))
			{
				wait .05;
				usetime = (usetime + .05);
			}

			if(player.isusing == true)
				continue;

			if(!(player isOnGround()))
				continue;

			player.isusing = true;


			if(!((isAlive(player)) && (player useButtonPressed())))
				continue;
			else
			{
				if(!isdefined(player.progressbackground))
				{
					player.progressbackground = newClientHudElem(player);
					player.progressbackground.alignX = "center";
					player.progressbackground.alignY = "middle";
					player.progressbackground.x = 320;
					player.progressbackground.y = 385;
					player.progressbackground.alpha = 0.5;
				}
				player.progressbackground setShader("black", (level.barsize + 4), 12);
				progresstime = 0;
				progresslength = 0;



				while(isAlive(player) && player useButtonPressed() && (progresstime < droptime))
				{
					progresstime += 0.05;
					progresslength += level.barincrement;

					if(!isdefined(player.progressbar))
					{
						player.progressbar = newClientHudElem(player);
						player.progressbar.alignX = "left";
						player.progressbar.alignY = "middle";
						player.progressbar.x = (320 - (level.barsize / 2.0));
						player.progressbar.y = 385;
					}
					player.progressbar setShader("white", progresslength, 8);

					wait level.fps_multiplier * 0.05;
				}

				if(progresstime >= droptime)
				{
					if(isdefined(player.progressbackground))
						player.progressbackground destroy();
					if(isdefined(player.progressbar))
						player.progressbar destroy();

					// Delay before picking up
					player.timeafterdrop_obj = true;
					player thread delaydrop_objective(self);

					self thread drop_objective(player);
					self notify("dropped");
					player unlink();
					player.isusing = false;
					return;
				}
				else if(isAlive(player))
				{
					player.progressbackground destroy();
					player.progressbar destroy();
				}
			}
		}
		player unlink();
		player.isusing = false;
		wait level.fps_multiplier * (.05);
	}
}

delaydrop_objective(objective)
{
	self endon("disconnect");
	self endon("killed_player");

	// Delay before picking up
	delaytime = 0;
	for(;;)
	{
		if (!self.timeafterdrop_obj)
			break;
		delaytime = (delaytime + .05);
		//iprintlnbold(self.name + " waits "+delaytime);
		if(delaytime > 1.2) // delaytime
		{
			if(self istouching(objective.trigger))
				self thread delaydrop_displayalterhintstring();
			self.timeafterdrop_obj = false;
			break;
		}
		wait level.fps_multiplier * .05;
	}
}

delaydrop_displayalterhintstring()
{
	if(isdefined(self.hintstring))
	{
		self.hintstring hideHUDSmooth(.3);
		self.hintstring.label = &"RE_PRESSTOPICKUPGENERIC";
		self.hintstring showHUDSmooth(.3);
	}
}


pressuse_notify(player)
{
	player endon("killed_player");
	self endon("dropped");
	while(isPlayer(player))
	{
		if(player useButtonPressed())
			player notify("Pressed Use");

		wait level.fps_multiplier * (.05);
	}
}

display_holding_obj(obj_ent)
{
	num = (16 - (obj_ent.hudnum));

	if(num > 16)
		return;

	offset = (150 + (obj_ent.hudnum * 8));

	self.hudelem[num] = newClientHudElem(self);
	self.hudelem[num].alignX = "right";
	self.hudelem[num].alignY = "middle";
	self.hudelem[num].x = 635;
	self.hudelem[num].y = (550 - offset);
	self.hudelem[num].fontscale = 1;
	self.hudelem[num].label = &"RE_CARRYINGGENERIC";
	self.hudelem[num] setText(obj_ent.script_objective_name);
}

triggerOff()
{
	self.origin = (self.origin - (0, 0, 10000));
}

client_print(obj, text, s)
{
	num = (16 - obj.hudnum);

	if(num > 16)
		return;

	self notify("stop client print");
	self endon("stop client print");

	//if((isdefined(self.hudelem)) && (isdefined(self.hudelem[num])))
	//	self.hudelem[num] destroy();

	for(i = 1; i < 16; i++)
	{
		if((isdefined(self.hudelem)) && (isdefined(self.hudelem[i])))
			self.hudelem[i] destroy();
	}

	self.hudelem[num] = newClientHudElem(self);
	self.hudelem[num].alignX = "center";
	self.hudelem[num].alignY = "middle";
	self.hudelem[num].x = 320;
	self.hudelem[num].y = 200;
	self.hudelem[num].fontscale = 1.3;

	if(isdefined(s))
	{
		self.hudelem[num].label = text;
		self.hudelem[num] setText(s);
	}
	else
		self.hudelem[num] setText(text);

	wait level.fps_multiplier * 3;

	if((isdefined(self.hudelem)) && (isdefined(self.hudelem[num])))
		self.hudelem[num] destroy();
}

drop_objective_on_disconnect_or_death(player)
{
	//CHAD
	/*
	if(isdefined(trace))
	{
		loc = (loc + (0, 0, 25));
		trace = bulletTrace(loc, (loc - (0, 0, 5000)), false, undefined);
		end_loc = trace["position"]; //where the ground under the player is
	}
	else
	{
		println("PLAYER IS ON GROUND - SKIPPING TRACE");
		end_loc = loc;
	}
	*/

	plant = player maps\mp\_utility::getPlant();
	end_loc = plant.origin;

	if(distance(player.origin, end_loc) > 0)
	{
		self.origin = player.origin;
		self.obj.origin = player.origin;
		self.angles = plant.angles;
		self.obj.angles = plant.angles;
		self show();
		self.obj show();

		speed = (distance(player.origin, end_loc) / 250);
		if(speed > 0.4)
		{
			self moveto(end_loc, speed, 0.1, 0.1);
			self.obj moveto(end_loc, speed, 0.1, 0.1);
			self waittill("movedone");
			self.trigger.origin = end_loc;
		}
		else
		{
			self.origin = end_loc;
			self.obj.origin = end_loc;
			self.angles = plant.angles;
			self.obj.angles = plant.angles;
			self show();
			self.obj show();
			self.trigger.origin = end_loc;
		}
	}
	else
	{
		self.origin = end_loc;
		self.obj.origin = end_loc;
		self.angles = plant.angles;
		self.obj.angles = plant.angles;
		self show();
		self.obj show();
		self.trigger.origin = end_loc;
	}

	//check if it's in a minefield
	In_Mines = 0;
	for(i = 0; i < level.minefield.size; i++)
	{
		if(self istouching(level.minefield[i]))
		{
			In_Mines = 1;
			break;
		}
	}

	if(In_Mines == 1)
	{
		iprintln(&"RE_INMINESGENERIC", self.script_objective_name);


		self.trigger.origin = self.trigger.startorigin;
		self.origin = self.startorigin;
		self.angles = self.startangles;
		self.obj.origin = self.startorigin;
		self.obj.angles = self.startangles;
	}
	else if(self istouching(level.objectives_goal))
	{
		if(game["attackers"] == "allies")
			iprintlnbold(&"RE_CAPTUREDALLIESGENERIC", self.script_objective_name);
		else
			iprintlnbold(&"RE_CAPTUREDAXISGENERIC", self.script_objective_name);

		level thread playSoundOnPlayers("MP_announcer_objective_captured");


		if(isdefined(self.trigger))
			self.trigger delete();

		if((isPlayer(player)) && (player.objs_held < 1))
		{
			if(isPlayer(player))
			{
				player.statusicon = "";
				player.obj_carrier = false;
			}
			if(player.pers["team"] == "allies")
			{
				player.headicon = game["headicon_allies"];
				player.headiconteam = "allies";
			}
			else if(player.pers["team"] == "axis")
			{
				player.headicon = game["headicon_axis"];
				player.headiconteam = "axis";
			}
			else
			{
				player.headicon = "";
			}
		}

		//player.pers["score"] += 3;
		//player.score = player.pers["score"];
		level.objectives_done++;

		self notify("completed");
		level thread clear_player_dropbar(player);

		objective_delete(self.objnum);
		objective_delete(self.objnum - 1);
		self delete();
		self.obj delete();

		if(level.objectives_done < level.objectives.size)
		{
			return;
		}
		else
		{
			iprintlnbold(&"RE_CAPTUREDALL");
			level thread playSoundOnPlayers("MP_announcer_objective_captured");
			level thread endRound(game["attackers"]);
			return;
		}
	}
	else
	{
		iprintln(&"RE_DROPPEDGENERIC", self.script_objective_name);
		self playsound ("re_pickup_paper");
	}

	self thread objective_timeout();
	self notify("dropped");
	self thread retrieval_think();
}









menuAutoAssign()
{
	// Team is already selected, do nothing and open menu again
	if(self.pers["team"] == "allies" || self.pers["team"] == "axis")
	{
		return;
	}

	numonteam["allies"] = 0;
	numonteam["axis"] = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(player.pers["team"] == "spectator" || player.pers["team"] == "none")
			continue;

		numonteam[player.pers["team"]]++;
	}

	// if teams are equal return the team with the lowest score
	if(numonteam["allies"] == numonteam["axis"])
	{
		if(getTeamScore("allies") == getTeamScore("axis"))
		{
			teams[0] = "allies";
			teams[1] = "axis";
			assignment = teams[randomInt(2)];
		}
		else if(getTeamScore("allies") < getTeamScore("axis"))
			assignment = "allies";
		else
			assignment = "axis";
	}
	else if(numonteam["allies"] < numonteam["axis"])
		assignment = "allies";
	else
		assignment = "axis";


	self.joining_team = assignment; // can be allies or axis
	self.leaving_team = self.pers["team"]; // can be "spectator" or "none"

	if(assignment != self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead"))
	{
		self.switching_teams = true;
		self suicide();
	}

	self.sessionteam = assignment;
	self.statusicon = "hud_status_dead";
	self.pers["team"] = assignment;
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["savedmodel"] = undefined;


	self notify("joined", assignment);
	self notify("joined_allies_axis");

	level notify("joined", assignment, self); // used in first round to check if someone joined team
}

menuAllies()
{
	// If team is already allies or we cannot join allies (to keep team balance), open team menu again
	if(self.pers["team"] == "allies" || !maps\mp\gametypes\_teams::getJoinTeamPermissions("allies"))
	{
		//self openMenu(game["menu_team"]);
		return;
	}

	self.joining_team = "allies";
	self.leaving_team = self.pers["team"];

	if(self.sessionstate == "playing")
	{
		self.switching_teams = true;
		self suicide();
	}

	self.sessionteam = "allies";
	self.statusicon = "hud_status_dead";
	self.pers["team"] = "allies";
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["savedmodel"] = undefined;


	self notify("joined", "allies");
	self notify("joined_allies_axis");

	level notify("joined", "allies", self); // used in first round to check if someone joined team
}

menuAxis()
{
	// If team is already axis or we cannot join axis (to keep team balance), open team menu again
	if(self.pers["team"] == "axis" || !maps\mp\gametypes\_teams::getJoinTeamPermissions("axis"))
	{
		//self openMenu(game["menu_team"]);
		return;
	}

	self.joining_team = "axis";
	self.leaving_team = self.pers["team"];

	if(self.sessionstate == "playing")
	{
		self.switching_teams = true;
		self suicide();
	}

	self.sessionteam = "axis";
	self.statusicon = "hud_status_dead";
	self.pers["team"] = "axis";
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["savedmodel"] = undefined;


	self notify("joined", "axis");
	self notify("joined_allies_axis");

	level notify("joined", "axis", self); // used in first round to check if someone joined team
}

menuSpectator()
{
	if(self.pers["team"] == "spectator")
		return;

	self.joining_team = "spectator";
	self.leaving_team = self.pers["team"];

	if(isAlive(self))
	{
		self.switching_teams = true;
		self suicide();
	}

	self.sessionteam = "spectator";
	self.statusicon = "";
	self.pers["team"] = "spectator";
	self.pers["weapon"] = undefined;
	self.pers["weapon1"] = undefined;
	self.pers["weapon2"] = undefined;
	self.pers["savedmodel"] = undefined;


	spawnSpectator();

	self notify("joined", "spectator");
	self notify("joined_spectators");

	level notify("joined", "spectator", self); // used in first round to check if someone joined team
}

menuWeapon(response)
{
	// You has to be "allies" or "axis" to change a weapon
	if(self.pers["team"] != "allies" && self.pers["team"] != "axis")
		return;

	// Used by bots
	if (response == "random")
		response = self maps\mp\gametypes\_weapons::getRandomWeapon();

	// Weapon is not valid or is in use
	if(!self maps\mp\gametypes\_weapon_limiter::isWeaponAvaible(response))
	{
		// Open menu with weapons again
		if(self.pers["team"] == "allies")
			self openMenu(game["menu_weapon_allies"]);
		else if(self.pers["team"] == "axis")
			self openMenu(game["menu_weapon_axis"]);
		return;
	}

	weapon = response;

	primary = self getWeaponSlotWeapon("primary");
	primaryb = self getWeaponSlotWeapon("primaryb");

	// After selecting a weapon, show "ingame" menu when ESC is pressed
	self setClientCvar2("g_scriptMainMenu", game["menu_ingame"]);

	// If newly selected weapon is same as actualy selected weapon and is in player slot -> do nothing
	if(isdefined(self.pers["weapon"]))
	{
		if (self.pers["weapon"] == weapon && primary == weapon && maps\mp\gametypes\_weapons::isPistol(primaryb))
			return;
	}

	// Save weapon before change (used in weapon_limiter)
	leavedWeapon = undefined;
	leavedWeaponFromTeam = undefined;
	if (isDefined(self.pers["weapon"]))
	{
		leavedWeapon = self.pers["weapon"];
		leavedWeaponFromTeam = self.pers["team"];
	}


	// Readyup-mode
	if (level.in_readyup)
	{
		if(isDefined(self.pers["weapon"]))
		{
			self.pers["weapon"] = weapon;
			self.selectedWeaponOnRoundStart = weapon; // to determine is weapon was changed during round

			// Remove weapon from slot (can be "none", takeWeapon() will take it)
			self takeWeapon(primary);
			self takeWeapon(primaryb);

			// Give weapon to primary slot
			self setWeaponSlotWeapon("primary", weapon);
			self giveMaxAmmo(weapon);

			// Give pistol to secondary slot + give grenades and smokes
			maps\mp\gametypes\_weapons::givePistol();
			maps\mp\gametypes\_weapons::giveSmokesFor(weapon, 0);
			maps\mp\gametypes\_weapons::giveGrenadesFor(weapon, 0);

			// Switch to main weapon
			self switchToWeapon(weapon);
		}
		else
		{
			self.pers["weapon"] = weapon;

			spawnPlayer();
		}
	}

	else
	{
		/*
		| ------------------------ Strat time --------------------------| -----Round start -----|
		| On spawm	| Action 1		| Action 2		| Final			|
		|---------------|-----------------------|-----------------------|-----------------------|
		| M1 pis	| Drop pistol		| Select thompson	| Thompson -
		| M1 pis	| Take KAR, drop pis	| Select thompson	| Thompson KAR
		| M1 pis	| Take KAR, drop M1	| Select thompson	| KAR pis (new weapon after next round)
		| M1 pis	| Take KAR, drop M1	| pick M1, Select thomp	| KAR M1 (new weapon after next round)

		| M1 pis	| Drop pistol		| Select M1		| M1 -
		| M1 pis	| Take KAR, drop pis	| Select M1		| M1 pis
		| M1 pis	| Take KAR, drop M1	| Select M1		| KAR pis (new weapon after next round)
		| M1 pis	| Take KAR, drop M1	| pick M1, Select M1	| KAR M1 (new weapon after next round)

		| M1 KAR	| Drop M1		| Select M1		| - KAR (new weapon after next round)

		| KAR pis	| Drop M1		| Select M1		| M1 -

		| BAB TOM	| Select thomson	| 			| M1 -

		*/

		allowedInStrattime = false;

		if (!isDefined(self.pers["weapon"]))
			allowedInStrattime = true;
		else
		{
			if (level.in_strattime && /*self.dropped_weapons == 0 && self.taked_weapons == 0 && */self.spawnsInStrattime < 2)
			{
				// If weapon I spawned with is still in slot, allow change
				if (self.spawnedWeapon == primary)
				{
					allowedInStrattime = true;
				}
			}
		}

		// Free weapon chaging - allowed in strat-time
		if(!level.matchstarted || (level.in_strattime && allowedInStrattime))
		{

			if(isDefined(self.pers["weapon"]))
			{
				self.pers["weapon"] = weapon;
				self.selectedWeaponOnRoundStart = weapon; // to determine if weapon was changed during round

				// Remove weapon from first slot
				self takeWeapon(primary);

				// If newly selected weapon is already in secondary slot, remove it to avoid duplicate weapon!
				if (weapon == primaryb)
				{
					self takeWeapon(primaryb); // Remove weapon

					maps\mp\gametypes\_weapons::givePistol();
				}

				// If I select the same weapon that is already in slot, it means I want to remove secondary weapon to pistol
				if (weapon == primary && maps\mp\gametypes\_weapons::isMainWeapon(primaryb))
				{
					self takeWeapon(primaryb); // Remove weapon
					maps\mp\gametypes\_weapons::givePistol();
				}

				self.spawnedWeapon = weapon;

				// Set new selected weapon into first slot
				self setWeaponSlotWeapon("primary", weapon);
				self giveMaxAmmo(weapon);

				// Give empty grenade/smoke slots
				self maps\mp\gametypes\_weapons::giveSmokesFor(weapon, 0);
				self maps\mp\gametypes\_weapons::giveGrenadesFor(weapon, 0);

				// Switch to new selected weapon
				self switchToWeapon(weapon);

			}
			else
			{
				self.pers["weapon"] = weapon;

				spawnPlayer();
			}
		}

		// else if round started or player drop weapon in strattime
		else
		{
			self.pers["weapon"] = weapon;

			// If joining an empty team, spawn
			if(!level.didexist[self.pers["team"]] && !level.roundended)
			{
				spawnPlayer();
			}
			// else you will spawn with selected weapon next round
			else
			{
				weaponname = maps\mp\gametypes\_weapons::getWeaponName(self.pers["weapon"]);


				if(self.pers["team"] == "allies")
				{
					if(maps\mp\gametypes\_weapons::useAn(self.pers["weapon"]))
						self iprintln(&"MP_YOU_WILL_SPAWN_ALLIED_WITH_AN_NEXT_ROUND", weaponname);
					else
						self iprintln(&"MP_YOU_WILL_SPAWN_ALLIED_WITH_A_NEXT_ROUND", weaponname);
				}
				else if(self.pers["team"] == "axis")
				{
					if(maps\mp\gametypes\_weapons::useAn(self.pers["weapon"]))
						self iprintln(&"MP_YOU_WILL_SPAWN_AXIS_WITH_AN_NEXT_ROUND", weaponname);
					else
						self iprintln(&"MP_YOU_WILL_SPAWN_AXIS_WITH_A_NEXT_ROUND", weaponname);
				}
			}
		}
	}

	// Used in wepoan_limiter
	self notify("weapon_changed", weapon, leavedWeapon, leavedWeaponFromTeam);
}


announceWinner(winner, delay)
{
	wait level.fps_multiplier * delay;

	// Announce winner
	if(winner == "allies")
	{
		level thread playSoundOnPlayers("MP_announcer_allies_win");
	}
	else if(winner == "axis")
	{
		level thread playSoundOnPlayers("MP_announcer_axis_win");
	}
	else if(winner == "draw")
	{
		level thread playSoundOnPlayers("MP_announcer_round_draw");
	}
}


showHintString(trig)
{
	self endon("disconnect");
	self endon("killed_player");

	if(self.pers["team"] == game["defenders"])
		return;

	self thread killafterhintstringhud(trig);

	while (self istouching(trig.trigger) && isAlive(self) && !level.roundended)
	{
		if (self.display_use_hintstring)
			return;

		self.display_use_hintstring = true;

		if(!self.timeafterdrop_obj)
			trigger_label = &"RE_PRESSTOPICKUPGENERIC";
		else
			trigger_label = &"RE_DELAYPICKUPGENERIC";


		self.hintstring = addHUDClient(self, 0, 375, 1.3, (1, 1 ,1), "center", "bottom", "center_safearea", "top");
		self.hintstring.label = trigger_label;
		self.hintstring setText(trig.script_objective_name);
		self.hintstring thread showHUDSmooth(.15);

		self.hintstringusehint = addHUDClient(self, 0, 345, 3.2, (1, 1 ,1), "center", "bottom", "center_safearea", "top");
		self.hintstringusehint setShader("hint_use_touch");
		self.hintstringusehint thread showHUDSmooth(.15);
	}

	self destroyhintstringhud();
}

killafterhintstringhud(objective)
{
	self endon("disconnect");
	self endon("killed_player");

	while(isAlive(self))
	{
		wait level.fps_multiplier * .45;

		if(!self istouching(objective.trigger))
		{
			self destroyhintstringhud();
			break;
		}
	}
}

destroyhintstringhud()
{
	if(isdefined(self.hintstring))
		self.hintstring thread removeHUDSmooth(.4);

	if(isdefined(self.hintstringusehint))
		self.hintstringusehint thread removeHUDSmooth(.4);

	self.display_use_hintstring = false;
}


sayObjective()
{
	level endon("running_timeout");

	wait level.fps_multiplier * 1;

	attacksounds["american"] = "MP_announcer_offense";
	attacksounds["british"] = "MP_announcer_offense";
	attacksounds["russian"] = "MP_announcer_offense";
	attacksounds["german"] = "MP_announcer_offense";
	defendsounds["american"] = "MP_announcer_defense";
	defendsounds["british"] = "MP_announcer_defense";
	defendsounds["russian"] = "MP_announcer_defense";
	defendsounds["german"] = "MP_announcer_defense";

	level thread playSoundOnPlayers(attacksounds[game[game["attackers"]]], game["attackers"]);
	level thread playSoundOnPlayers(defendsounds[game[game["defenders"]]], game["defenders"]);
}


playSoundOnPlayers(sound, team)
{
	players = getentarray("player", "classname");

	if(isdefined(team))
	{
		for(i = 0; i < players.size; i++)
		{
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == team))
				players[i] playLocalSound(sound);
		}
	}
	else
	{
		for(i = 0; i < players.size; i++)
			players[i] playLocalSound(sound);
	}
}





getRandomSpawnpoint(spawnpointsarray, spawnpoints)
{
//	level endon("intermission");

	// randomize order
	for(i = 0; i < spawnpointsarray.size; i++)
	{
		j = randomInt(spawnpointsarray.size);

		spawnpoint = spawnpoints[i];
		spawnpoints[i] = spawnpoints[j];
		spawnpoints[j] = spawnpoint;
	}

	return maps\mp\gametypes\_spawnlogic::getSpawnpoint_Final(spawnpoints);

}

positionToGround(pos, ignoreentity)
{
	trace = bulletTrace(pos, pos + (0, 0, -10000), false, ignoreentity);
	return trace["position"];
}

add_array(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19)
{
	a=[];
	if(isdefined(a1))
	a[a.size] = a1;
	if(isdefined(a2))
	a[a.size] = a2;
	if(isdefined(a3))
	a[a.size] = a3;
	if(isdefined(a4))
	a[a.size] = a4;
	if(isdefined(a5))
	a[a.size] = a5;
	if(isdefined(a6))
	a[a.size] = a6;
	if(isdefined(a7))
	a[a.size] = a7;
	if(isdefined(a8))
	a[a.size] = a8;
	if(isdefined(a9))
	a[a.size] = a9;
	if(isdefined(a10))
	a[a.size] = a10;
	if(isdefined(a11))
	a[a.size] = a11;
	if(isdefined(a12))
	a[a.size] = a12;
	if(isdefined(a13))
	a[a.size] = a13;
	if(isdefined(a14))
	a[a.size] = a14;
	if(isdefined(a15))
	a[a.size] = a15;
	if(isdefined(a16))
	a[a.size] = a16;
	if(isdefined(a17))
	a[a.size] = a17;
	if(isdefined(a18))
	a[a.size] = a18;
	if(isdefined(a19))
	a[a.size] = a19;
	return a;
}





serverInfo()
{
	waittillframeend; // wait untill all other server change functions are processed

	title = "";
	value = "";


	if (level.timelimit > 0)
	{
		title +="Total time limit:\n";
		value += plural_s(level.timelimit, "minute") + "\n";
	}


	// There is no halftime
	if (level.halfround == 0 && level.halfscore == 0)
	{

		if (level.scorelimit != 0)
		{
			title +="Score limit:\n";
			value += level.scorelimit + "\n";
		}
		else
		{
			title +="Round limit:\n";
			value += level.matchround + "\n";
		}
	}
	else
	{
		title +="Limit 1st half:\n";
		if (level.halfscore != 0)
			value += level.halfscore + " points\n";
		else
			value += level.halfround + " rounds\n";

		title +="Limit 2nd half:\n";
		if (level.scorelimit != 0)
			value += level.scorelimit + " points\n";
		else
			value += level.matchround + " rounds\n";
	}


	title += "Strat time:\n";
	value += plural_s(level.strat_time, "second") + "\n";

	title +="Round length:\n";
	value += plural_s(level.roundlength, "minute") + "\n";


	title +="Overtime:\n";
	if (level.scr_overtime)
		value += "Yes" + "\n";
	else
		value += "No" + "\n";


	level.serverinfo_left1 = title;
	level.serverinfo_left2 = value;
}


deadchat()
{
	for(;;)
	{
		if (!level.scr_auto_deadchat)
			return;


		if ( (level.in_readyup || level.in_timeout || level.roundended) && level.deadchat == 0)
		{
			maps\mp\gametypes\global\cvar_system::restoreCvarQuiet("g_deadChat");
			maps\mp\gametypes\global\cvar_system::setCvarQuiet("g_deadChat", 1); //setcvar("g_deadchat", 1);
		}

		// Disable dead chat
		else if (level.roundstarted && !level.roundended && level.deadchat == 1)
		{
			maps\mp\gametypes\global\cvar_system::restoreCvarQuiet("g_deadChat");
			maps\mp\gametypes\global\cvar_system::setCvarQuiet("g_deadChat", 0); //setcvar("g_deadchat", 0);
		}

		wait level.fps_multiplier * 1;
	}
}
