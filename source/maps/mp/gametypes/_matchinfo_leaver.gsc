#include maps\mp\gametypes\global\_global;

/*
Leaver detection for CoD2x match (similar to FACEIT "Leaver").

Enabled only if match data contains key "leaverTimeout" with number of seconds (for example 300).
If the key is missing or is 0, feature is disabled.
Disabled also if a team has more players than playersCount (substitutes would be flagged as leavers).
Works in SD and DM.

After the match started (first ready-up is over), time when a player from match data is not connected
is summed for all his disconnects. Only live time is counted:
 - SD: from the end of strat time to the end of the round
 - DM: from the end of strat time to the end of the map
Ready-ups (halftime), timeouts, strat time and time between rounds are not counted.
Players are taken from match data when the match starts, later changes in match data are ignored.
Note: a player whose game crashed stays connected (999 ping) until the server drops him (sv_timeout),
that time is not counted.

When the summed time reaches leaverTimeout, the player is flagged as leaver and match data are uploaded
with global data:
	leaver_uuids: "uuid1,uuid2"
The value stays in match data, so it's included also in all next uploads (round end, map end).
The match continues normally.
*/
init()
{
	if (level.gametype != "sd" && level.gametype != "dm")
		return;

	level thread watchLeavers();
}


watchLeavers()
{
	// Offset thread from other threads, wait for matchinfo to prepare map
	wait level.frame * 10;

	if (!matchIsActivated())
		return;

	// Match did not start yet (first ready-up is not counted, it's followed by map restart)
	if (game["readyup_first_run"])
		return;

	// Settings and players are saved when the match starts and kept in game[] with disconnected time
	// and flagged leavers, so they survive round restarts and are not changed if match data are redownloaded
	if (!isDefined(game["leaver_enabled"]))
	{
		game["leaver_enabled"] = isEnabled();
		if (game["leaver_enabled"])
		{
			match_uuids = [];
			for (t = 1; t <= 2; t++)
			{
				team_uuids = matchGetData("team" + t + "_player_uuids");
				for (i = 0; i < team_uuids.size; i++)
					match_uuids[match_uuids.size] = team_uuids[i];
			}
			game["leaver_players"] = match_uuids;
			game["leaver_timeout"] = int(matchGetData("leaverTimeout")) * 1000;
			game["leaver_uuids"] = "";
		}
	}
	if (!game["leaver_enabled"])
		return;

	timeout = game["leaver_timeout"];
	match_uuids = game["leaver_players"];

	lastTime = getTime();
	for (;;)
	{
		wait level.fps_multiplier * 1;

		now = getTime();
		elapsed = now - lastTime;
		lastTime = now;

		// Match was canceled / finished
		if (!matchIsActivated())
			return;

		if (!isLiveTime())
			continue;

		// Collect connected players from match data
		players = getentarray("player", "classname");
		players_uuid = [];
		for (j = 0; j < players.size; j++)
			players_uuid[j] = players[j] matchPlayerGetData("uuid");

		newLeaver = false;
		for (i = 0; i < match_uuids.size; i++)
		{
			uuid = match_uuids[i];

			connected = false;
			for (j = 0; j < players_uuid.size; j++)
			{
				if (players_uuid[j] == uuid)
				{
					connected = true;
					break;
				}
			}
			if (connected)
				continue;

			key = "leaver_time_" + uuid;
			if (!isDefined(game[key]))
				game[key] = 0;
			game[key] += elapsed;

			if (game[key] >= timeout && !isLeaver(uuid))
			{
				if (game["leaver_uuids"] != "")
					game["leaver_uuids"] += ",";
				game["leaver_uuids"] += uuid;
				newLeaver = true;

				logprint("LEAVER: " + uuid + " was disconnected for " + int(game[key] / 1000) + " seconds\n");
			}
		}

		if (newLeaver)
		{
			matchSetData("leaver_uuids", game["leaver_uuids"]);
			maps\mp\gametypes\_matchinfo::uploadMatchData("leaver", false, false);
		}
	}
}


isEnabled()
{
	timeout = matchGetData("leaverTimeout");
	if (!isDigitalNumber(timeout) || int(timeout) <= 0)
		return false;

	playersCount = matchGetData("playersCount");
	if (!isDigitalNumber(playersCount) || int(playersCount) <= 0)
		return false;

	team1_uuids = matchGetData("team1_player_uuids");
	team2_uuids = matchGetData("team2_player_uuids");
	if (team1_uuids.size != int(playersCount) || team2_uuids.size != int(playersCount))
		return false;

	return true;
}


isLeaver(uuid)
{
	leavers = splitString(game["leaver_uuids"], ",");
	for (i = 0; i < leavers.size; i++)
	{
		if (leavers[i] == uuid)
			return true;
	}
	return false;
}


// Time when the game is really played
isLiveTime()
{
	if (game["state"] != "playing" || level.in_readyup || level.in_timeout || level.in_strattime)
		return false;

	if (level.gametype == "sd")
		return level.roundstarted && !level.roundended;

	// dm
	return level.matchstarted && !level.mapended;
}
