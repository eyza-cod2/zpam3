#include maps\mp\gametypes\_callbacksetup;

// This will make sure when last player disconnect from server, fast_restart is applied

init()
{
	addEventListener("onConnecting",     ::onConnecting);
	addEventListener("onDisconnect",     ::onDisconnect);

	level.players_num = 0;
}

onConnecting()
{
	level notify("exit_server_restart"); // If some player connects, cancel waiting-threat that turning on hibernartion

	level.players_num++;
}

onDisconnect()
{
	level.players_num--;

	if (level.players_num == 0)
	{
		// Turn to hibernation after a few minutes
		level thread waitBeforeHibernation();

		//Println("---------------- Last player disconnectc - turning on waiting-thread to hibernation");
	}

	if (level.players_num < 0)
		assertMsg("Server restart not working");
}

waitBeforeHibernation()
{
	level endon("exit_server_restart");

	wait level.fps_multiplier * 300;

	//Println("------------- Hibernation activated");

	level notify("log_server_restart");

	map_restart(false);
}
