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
	level.players_num++;
}

onDisconnect()
{
	level.players_num--;

	if (level.players_num == 0)
	{
		level thread restartServer();
	}

	if (level.players_num < 0)
		assertMsg("Server restart not working");
}


restartServer()
{
	//Println("---------------- Last player disconnectc - turning on waiting-thread to hibernation");

	// Will disable all comming map-restrat (so map can be changed correctly)
	level.pam_mode_change = true;

	wait level.fps_multiplier * 10;

	//Println("------------- Hibernation activated");

	map_restart(false);
}
