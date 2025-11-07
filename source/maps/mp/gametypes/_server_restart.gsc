#include maps\mp\gametypes\global\_global;

// This will make sure when last player disconnect from server, fast_restart is applied

init()
{
	if (!isDefined(game["watchEmptyServer"]))
		game["watchEmptyServer"] = false;

	addEventListener("onConnected",     ::onConnected);
	addEventListener("onDisconnect",     ::onDisconnect);

	if (game["watchEmptyServer"])
		level thread restartIfEmpty();
}

onConnected()
{
	game["watchEmptyServer"] = true;
}

onDisconnect()
{
	level thread restartIfEmpty();
}

restartIfEmpty()
{
		level notify("server_restart");
		level endon("server_restart");

		wait level.fps_multiplier * 60;

		players = getentarray("player", "classname");
		if (players.size == 0)
		{
			if (matchIsActivated())
			{
				return;
			}

			iprintln("Restarting server...");
			// Will disable all comming map-restrat (so map can be changed correctly)
			level.pam_mode_change = true;
			map_restart(false);
		}
}
