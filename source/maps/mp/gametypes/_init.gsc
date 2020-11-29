initAllFunctions()
{
	/#
	thread maps\mp\gametypes\__events::init();
    #/

	thread maps\mp\gametypes\_pam::init();
	thread maps\mp\gametypes\_punkbuster::init();


    // Monitor cvar changes
	thread maps\mp\gametypes\_cvar_system::monitorCvarChanges();
	thread maps\mp\gametypes\_hud_system::init();



	thread maps\mp\gametypes\_force_download::init();


	thread maps\mp\gametypes\_log::init();

	thread maps\mp\gametypes\_hud::init();


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
	thread maps\mp\gametypes\_quickmessages::init();
	thread maps\mp\gametypes\_quicksettings::init();

	thread maps\mp\gametypes\_weapon_drop::init();
	thread maps\mp\gametypes\_weapon_limiter::init();




	thread maps\mp\gametypes\_bots::Init();

	thread maps\mp\gametypes\_fast_reload::init();
	thread maps\mp\gametypes\_diagonal_fix::Init();
	thread maps\mp\gametypes\_prone_peak_fix::Init();



	thread maps\mp\gametypes\_overtime::init();	// must be caled before readyup
	thread maps\mp\gametypes\_timeout::init();	// must be caled before readyup
	thread maps\mp\gametypes\_halftime::init(); // must be caled before readyup and overtime
	thread maps\mp\gametypes\_readyup::init();

	thread maps\mp\gametypes\_blackout::init();	// depends on timeout and readyup
	thread maps\mp\gametypes\_spectating::init(); // depends on _blackout
	thread maps\mp\gametypes\_bash::init();	// depends on readup
	thread maps\mp\gametypes\_players_left::Init();
	thread maps\mp\gametypes\_mapvote::Init();
	thread maps\mp\gametypes\_end_of_map::init();




	thread maps\mp\gametypes\_spectating_system::init(); // depends on readyup




	// Clientside DVAR Enforcer Start-Up
	thread maps\mp\gametypes\_cvar_forces::init();




	thread maps\mp\gametypes\_menu_rcon::init();
	thread maps\mp\gametypes\_menu_kick::init();
	thread maps\mp\gametypes\_menu_scoreboard::init();
	thread maps\mp\gametypes\_menu_map::init();

	thread maps\mp\gametypes\_teamname::init();

	thread maps\mp\gametypes\_matchinfo::init();	// depends on readyup, teamname

	thread maps\mp\gametypes\_record::init();		// depends on matchinfo, teamname

	thread maps\mp\gametypes\_scoreboard::init();	// depends on matchinfo



	thread maps\mp\gametypes\_player_stat::init();

	thread maps\mp\gametypes\_lag::init();
	thread maps\mp\gametypes\_cracked::init();


	thread maps\mp\gametypes\_objective::init();

	// Has to be called last
	thread maps\mp\gametypes\_on_connect::init();

	/#
	println("------------------------------------------------");
	println("zPAM: All scripts are initialized correctly.");
	println("------------------------------------------------");

	// This is called only if developer_script is set to 1
	thread maps\mp\gametypes\__developer::init();
	thread maps\mp\gametypes\_menu_debug::init();
	#/


}
