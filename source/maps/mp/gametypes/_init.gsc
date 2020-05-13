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

	thread maps\mp\gametypes\_spectating_system::init();

	thread maps\mp\gametypes\_hud::init();


	thread maps\mp\gametypes\_server_restart::init();


	thread maps\mp\gametypes\_menus::init();		// must be called before another onMenuResponse
	thread maps\mp\gametypes\_teams::init();
	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_hud_teamscore::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_healthoverlay::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_friendicons::init();
	thread maps\mp\gametypes\_quickmessages::init();


	thread maps\mp\gametypes\_weapon_drop::init();
	thread maps\mp\gametypes\_weapon_limiter::init();




	thread maps\mp\gametypes\_bots::Init();

	thread maps\mp\gametypes\_fast_reload::init();
	thread maps\mp\gametypes\_diagonal_fix::Init();




	thread maps\mp\gametypes\_overtime::init();	// must be caled before readyup
	thread maps\mp\gametypes\_timeout::init();	// must be caled before readyup
	thread maps\mp\gametypes\_halftime::init(); // must be caled before readyup and overtime
	thread maps\mp\gametypes\_readyup::init();

	thread maps\mp\gametypes\_blackout::init();	// depends on timeout and readyup
	thread maps\mp\gametypes\_spectating::init(); // depends on _blackout
	thread maps\mp\gametypes\_players_left::Init();
	thread maps\mp\gametypes\_mapvote::Init();
	thread maps\mp\gametypes\_end_of_map::init();







	// Clientside DVAR Enforcer Start-Up
	thread maps\mp\gametypes\_cvar_forces::init();




	thread maps\mp\gametypes\_menu_rcon::init();
	thread maps\mp\gametypes\_menu_kick::init();
	thread maps\mp\gametypes\_menu_map::init();
	thread maps\mp\gametypes\_menu_matchinfo::init();	// depends on readyup

	thread maps\mp\gametypes\_record::init();		// depends on matchinfo

	thread maps\mp\gametypes\_scoreboard::init();	// depends on matchinfo





	thread maps\mp\gametypes\_objective::init();

	// Has to be called last
	thread maps\mp\gametypes\_on_connect::init();

	/#
	println("------------------------------------------------");
	println("zPAM: All scripts are initialized correctly.");
	println("------------------------------------------------");

	thread maps\mp\gametypes\__developer::init();

	thread maps\mp\gametypes\_menu_debug::init();
	#/


}
