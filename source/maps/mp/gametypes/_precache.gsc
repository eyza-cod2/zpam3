addString(gameName, string)
{

	game[gameName] = string;

	precacheString(game[gameName]);
}

Precache()
{
	precacheShader("black");
	precacheShader("white");

	precacheShader("$levelBriefing"); // map image

    // Stopwatch
    precacheShader("hudStopwatch");
	precacheShader("hudStopwatchNeedle");


	precacheStatusIcon("hud_status_dead");
	precacheStatusIcon("hud_status_connecting");


	precacheStatusIcon("icon_blackout");
	precacheStatusIcon("icon_mod");


	precacheString(&"PAM_UNKNOWN_MODE");

	precacheShader("cybergamer_logo");

	// TODO: REMOVE in release
	addString("STRING_NOT_RELEASED_1", &"You are testing new version of zPAM");  // This is not the final release of zPAM
	addString("STRING_NOT_RELEASED_2", &"Check changes on github.com/eyza-cod2/zpam3"); // It is not allowed to play matches on it



	// HUD: PAM header
	addString("STRING_VERSION_INFO", &"zPAM 3.1 ^1BETA");
	addString("STRING_RELEASED_INFO", &"Released 2020/04");



	addString("STRING_OVERTIME_MODE", &"Overtime");
	// League name header (is defined in each mode file)
	if (!isdefined(game["leagueString"]))
		game["leagueString"] = &"PAM_UNKNOWN_MODE";
	precacheString(game["leagueString"]);


	// HUD: Scoreboard
	addString("STRING_SCOREBOARD_TITLE", &"Match info"); // Scoreboard
	addString("STRING_SCOREBOARD_TEAM1", &"My team");
	addString("STRING_SCOREBOARD_TEAM2", &"Enemy");
	addString("STRING_SCOREBOARD_FIRST_HALF", &"1st Half");
	addString("STRING_SCOREBOARD_SECOND_HALF", &"2nd Half");
	addString("STRING_SCOREBOARD_PLAYING_TIME", &"Playing time:");
	addString("STRING_SCOREBOARD_ROUNDS_TO_HALF", &"Rounds to half:");
	addString("STRING_SCOREBOARD_ROUNDS_TO_END", &"Rounds to end:");
	addString("STRING_SCOREBOARD_NO_SCORE", &"-");


	// HUD: Next_Round
	addString("STRING_NEXTROUND_ROUND", &"Round");
	addString("STRING_NEXTROUND_STARTING", &"Starting");

	// HUD: Timeout
	addString("STRING_TIMEOUT", &"Time-out");
	addString("STRING_GOING_TO_TIMEOUT", &"Going to Time-out");

	// HUD: Teamswap
	addString("STRING_HALFTIME", &"Halftime");
	addString("STRING_TEAM_AUTO_SWITCH", &"Team Auto-Switch");

	// HUD: Matchover
	addString("STRING_ALLIES_WIN", &"Allies Win!");
	addString("STRING_AXIS_WIN", &"Axis Win!");
	addString("STRING_ITS_TIE", &"Its a TIE!");
	addString("STRING_GOING_TO_SCOREBOARD", &"Going to Scoreboard");
	addString("STRING_GOING_TO_OVERTIME", &"Going to Over-time");

	// HUD: Half_Start
	addString("STRING_READYUP_MATCH_BEGINS_IN", &"Match begins in:");
	addString("STRING_READYUP_MATCH_CONTINUES_IN", &"Match continues in:");
	addString("STRING_READYUP_MATCH_RESUMES_IN", &"Match resumes in:");

	// HUD: Strattime
	addString("STRING_STRAT_TIME", &"Strat Time");

	// HUD Shared
	addString("STRING_PLEASE_WAIT", &"Please wait");








	// Force download
	addString("STRING_FORCEDOWNLOAD_ERROR_1", &"You must download zPAM mod to play on this server.");
	addString("STRING_FORCEDOWNLOAD_ERROR_2", &"Downloading was enabled (/cl_allowDownload 1).");
	addString("STRING_FORCEDOWNLOAD_ERROR_3", &"Please reconnect to the server.");

	// PAM installed wrong
	addString("STRING_NOT_INSTALLED_CORRECTLY_1", &"Error: zPAM is not installed correctly.");
	addString("STRING_NOT_INSTALLED_CORRECTLY_2", &"Folder with mod must exists under zpam310_beta/zpam310_beta.iwd"); // TODO: rename to actual version

	// PBSVUSER.cfg load error
	addString("STRING_PBSV_NOT_LOADED_ERROR_1", &"Punkbuster file pbsvuser.cfg was not loaded.");

	// Help url
	addString("STRING_GITHUB_URL", &"https://github.com/eyza-cod2/zpam3");
	addString("STRING_GITHUB_URL_HELP", &"Please visit https://github.com/eyza-cod2/zpam3 for more info.");










	// Readyup
	precacheString(&"PAM_READYUP_MODE");
	precacheString(&"PAM_READYUP_WAITING_ON");
	precacheString(&"PAM_READYUP_PLAYERS");
	precacheString(&"PAM_READYUP_YOUR_STATUS");
	precacheString(&"PAM_READYUP_READY");
	precacheString(&"PAM_READYUP_NOT_READY");
	precacheStatusIcon("party_ready");
	precacheStatusIcon("party_notready");
	precacheString(&"PAM_READYUP_CLOCK");
	precachestring(&"PAM_READYUP_KILLS");

	// Readyup warnings
	precachestring(&"PAM_WARNING_PASSWORD_IS_NOT_SET");
	precachestring(&"PAM_WARNING_CHEATS_ARE_ENABLED");
	precachestring(&"PAM_WARNING_PUNKBUSTER_IS_DISABLED");
	precachestring(&"PAM_WARNING_CVARS_ARE_CHANGED");


	addString("STRING_READYUP_MODE", &"Ready-Up Mode");
	addString("STRING_READYUP_MODE_HALF", &"Half-Time Ready-Up Mode");
	addString("STRING_READYUP_MODE_TIMEOUT", &"Time-Out Ready-Up Mode");
	addString("STRING_READYUP_MODE_OVERTIME", &"Overtime Ready-Up Mode");





	game["STRING_READYUP_ALL_PlAYERS_ARE_READY"] = "All players are ready.";




	// Readyup (problem with precache...)
	game["readyup_team_allies"] = 		"^7You are on ^3Team Allies";
	game["readyup_team_axis"] = 		"^7You are on ^3Team Axis";
	game["readyup_team_spectator"] = 	"^7You are on ^3Team Spectator";
	game["readyup_press_activate"] = 	"Press the ^3[{+activate}] ^7button to Ready-Up.";
	game["readyup_hold_melee"] = 		"Double press the ^3[{+melee_breath}] ^7button to disable killing.";

	game["objective_readyup"] = game["readyup_press_activate"] + "\n" + game["readyup_hold_melee"];
	game["objective_timeout"] = game["readyup_press_activate"];



	game["empty"] = &" ";
	precacheString(game["empty"]);



	// bomb exploedes in
	game["rushexplode"] = &"Bomb explodes in";
	precacheString(game["rushexplode"]);


	game["startingin"] = &"Starting In";
	precacheString(game["startingin"]);


	//Half Starting Display
	game["first"] = &"First";
	precacheString(game["first"]);
	game["second"] = &"Second";
	precacheString(game["second"]);
	game["half"] = &"Half";
	precacheString(game["half"]);



	game["blackout_protection"] = &"Blackout Protection";
	precacheString(game["blackout_protection"]);

	game["blackout_info"] = &"You see this map background because match is in progress.";
	precacheString(game["blackout_info"]);



	//Timeout
	game["timeouthead"] = &"Time-out Mode";
	precacheString(game["timeouthead"]);
	game["resuming"] = &"Resuming In";
	precacheString(game["resuming"]);
	game["timeoutcount"] = &"Time-outs";
	precacheString(game["timeoutcount"]);

	game["goingtoo"] = &"Going to time-out in";
	precacheString(game["goingtoo"]);
	game["start_time"] = &"Start time";
	precacheString(game["start_time"]);

	game["axis_text"] = &"Axis";
	precacheString(game["axis_text"]);
	game["allies_text"] = &"Allies";
	precacheString(game["allies_text"]);
	game["kdisabled"] = &"Disabled";
	precachestring(game["kdisabled"]);
	game["kenabled"] = &"Enabled";
	precachestring(game["kenabled"]);
	game["killingt"] = &"Killing";
	precachestring(game["killingt"]);

	// Bash Round
	game["bashrnd"] = &"Starting Bash Round";
	precacheString(game["bashrnd"]);
	game["bashbegin"] = &"BEGIN!";
	precacheString(game["bashbegin"]);

	// Players Left Display
	game["axis_hud_text"] = &"Axis Left";
	precacheString(game["axis_hud_text"]);
	game["allies_hud_text"] = &"Allies Left";
	precacheString(game["allies_hud_text"]);


	// Round Timer
	game["startingin"] = &"Starting In";
	precacheString(game["startingin"]);
	game["matchstarting"] = &"Match Starting In";
	precacheString(game["matchstarting"]);

	game["matchresuming"] = &"Match Resuming In";
	precacheString(game["matchresuming"]);



	//Health Bar for spectator?
	game["health_bar"] = "gfx/hud/hud@health_bar.tga";
	precacheShader(game["health_bar"]);

	//Health Packs
	game["Item_Healthpack"] = "xmodel/health_medium";
	precacheModel(game["Item_Healthpack"]);


	// CTF Status Icons
	if (level.gametype == "ctf")
	{
		precacheStatusIcon("compass_flag_" + game["allies"]);
		precacheStatusIcon("compass_flag_" + game["axis"]);

		game["alive_hud_text"] = &"Alive";
		precacheString(game["alive_hud_text"]);
	}

	// Strat mode
	game["flyenabled"] = &"Enabled";
	precacheString(game["flyenabled"]);
	game["flydisabled"] = &"Disabled";
	precacheString(game["flydisabled"]);
	game["toenable"] = &"Enable: Hold ^3[{+melee_breath}]";
	precacheString(game["toenable"]);
	game["todisable"] = &"Disable: Hold ^3[{+melee_breath}]";
	precacheString(game["todisable"]);


}
