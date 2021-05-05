// This function is called from every <gametype>.gsc::main function
InitSystems()
{
	/#
	println("### Call: maps/mp/gametypes/" + getcvar("g_gametype") + ".gsc::main()");
	#/

	if (isDefined(game["firstInit"]))
		game["firstInit"] = false;
	else
		game["firstInit"] = true;

	thread resetFirstInit();


	maps\mp\gametypes\global\events::Init();	// Init evets so we can use them
	maps\mp\gametypes\global\cvar_system::Init();	// Define g_gametpe, fs_mode, ... cvars
	maps\mp\gametypes\global\pam::Init();		// Define pam_mode cvar
	maps\mp\gametypes\global\rules::Init();		// Register rule cvar values
	maps\mp\gametypes\global\cvars::Init();		// Define game and shared cvars

	// Precache (only once)
	if (game["firstInit"])
	{
		maps\mp\gametypes\global\precache::Init();
	}

	// Other system scripts
	maps\mp\gametypes\global\hud_system::Init();
	thread maps\mp\gametypes\global\developer::init();
}

resetFirstInit()
{
	wait 0;
	game["firstInit"] = false;
}

// This function is called at the end of <gametype>.gsc::main() function
InitModules()
{
	thread maps\mp\gametypes\_callbacksetup::Init();

	thread maps\mp\gametypes\_pam::init();
	thread maps\mp\gametypes\_punkbuster::init();
	thread maps\mp\gametypes\_force_download::init();
	thread maps\mp\gametypes\_cvar_forces::init();

	thread maps\mp\gametypes\_log::init();
	thread maps\mp\gametypes\_server_restart::init();


	thread maps\mp\gametypes\_menus::init();		// must be called before another onMenuResponse
	thread maps\mp\gametypes\_teams::init();
	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_healthoverlay::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_friendicons::init();
	thread maps\mp\gametypes\_hud_teamscore::init();
	thread maps\mp\gametypes\_quickmessages::init();
	thread maps\mp\gametypes\_quicksettings::init();

	thread maps\mp\gametypes\_weapon_drop::init();
	thread maps\mp\gametypes\_weapon_limiter::init();


	thread maps\mp\gametypes\_overtime::init();	// must be caled before readyup
	thread maps\mp\gametypes\_timeout::init();	// must be caled before readyup
	thread maps\mp\gametypes\_halftime::init(); 	// must be caled before readyup and overtime
	thread maps\mp\gametypes\_end_of_map::init();	// depends on overtime
	thread maps\mp\gametypes\_readyup::init();
	thread maps\mp\gametypes\_cracked::init();
	thread maps\mp\gametypes\_bash::init();	// depends on readup

	thread maps\mp\gametypes\_blackout::init();	// depends on timeout and readyup
	thread maps\mp\gametypes\_spectating::init(); // depends on _blackout



	thread maps\mp\gametypes\_scoreboard::init();	// must be called before matchinfo
	thread maps\mp\gametypes\_teamname::init();
	thread maps\mp\gametypes\_matchinfo::init();	// depends on readyup, teamname, bash, overtime
	thread maps\mp\gametypes\_record::init();	// depends on matchinfo
	thread maps\mp\gametypes\_players_left::Init(); // depends on matchinfo
	thread maps\mp\gametypes\_spectating_system::init(); // depends on readyup, matchinfo
	thread maps\mp\gametypes\_spectating_auto::init(); // depends on spectating_system
	thread maps\mp\gametypes\_spectating_menu::init(); // depends on spectating_system
	thread maps\mp\gametypes\_archive::init(); // depends on spectating_system and killcam


	thread maps\mp\gametypes\_menu_rcon::init();
	thread maps\mp\gametypes\_menu_kick::init();
	thread maps\mp\gametypes\_menu_scoreboard::init(); // depends on matchinfo
	thread maps\mp\gametypes\_menu_map::init();


	thread maps\mp\gametypes\_bots::Init();
	thread maps\mp\gametypes\_fast_reload::init();
	thread maps\mp\gametypes\_prone_peek_fix::Init();
	thread maps\mp\gametypes\_mapvote::Init();
	thread maps\mp\gametypes\_player_stat::init();
	thread maps\mp\gametypes\_mg_fix::init();
	thread maps\mp\gametypes\_round_report::init();
	thread maps\mp\gametypes\_score_set::init(); // depends on readyup, halftime, sd




	thread maps\mp\gametypes\_objective::init(); // depends on readyup, timeout




	/# //This is called only if developer_script is set to 1
	thread maps\mp\gametypes\_menu_debug::init();
	#/


}
