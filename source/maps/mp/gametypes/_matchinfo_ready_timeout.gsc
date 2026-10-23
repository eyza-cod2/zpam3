#include maps\mp\gametypes\global\_global;

/*
Strict time limit for players to join and ready-up in CoD2x match.

Enabled only if match data contains key "readyTimeout" with number of seconds (for example 180).
If the key is missing or is 0, feature is disabled (ladder matches).

Timer runs only in first ready-up of the first map of the match.
Timer follows the ready-up "Clock" - it starts when the Clock starts (first player connected)
and is reset together with the Clock on map change / map restart.
If nobody connects, time is counted from map start.
If ready-up does not end in time, match is canceled:
 - if some players did not join, only their uuids are sent
 - else uuids of players who did not ready-up are sent (not ready, not in allies/axis, wrong side, misnamed)
Players are informed about the time limit when they connect.
Every player must stay on the server until the end - player who leaves during the countdown is not joined.
During the countdown (last 10 seconds) connected players are saved every second, so it's possible
to see in the server log who left during the countdown.
During the countdown, players who block the match start are printed every few seconds.
On cancel, state of every player is written into server log (lines starting with "READY_TIMEOUT:").

Uploaded global data:
	state:               "canceled"
	cancel_reason:       "not_joined" / "not_ready"
	cancel_player_uuids: "uuid1,uuid2"
	cancel_details:      "uuid1:not_connected,uuid2:ok,..." - state of every player from match data:
	                     ok, not_connected, left_during_countdown, not_ready, not_in_team, wrong_side_or_name

After the upload, matchCancel() is called (CoD2x sends type "error" with cancel reason).
*/
init()
{
	if (game["firstInit"])
	{
		precacheString2("STRING_READY_TIMEOUT_CANCEL_IN", &"Match will be canceled in");
		precacheString2("STRING_READY_TIMEOUT_DO_NOT_LEAVE", &"Do not leave the server");
	}

	if (!isDefined(game["readyup_first_run"]) || !game["readyup_first_run"])
		return;

	addEventListener("onConnected", ::onConnected);

	// Level time is not reset by map_restart, so save the start time of this level
	level.ready_timeout_level_start = getTime();

	level thread watchTimeout();
}


watchTimeout()
{
	level endon("rupover");

	// Offset thread from other threads, wait for matchinfo to prepare map
	wait level.frame * 10;

	if (!matchIsActivated() || !level.in_readyup)
	{
		setCvar("_ready_timeout_canceled", "");
		return;
	}

	// Map was restarted while the match was being canceled, finish the cancel
	if (getCvar("_ready_timeout_canceled") == matchGetData("match_id"))
	{
		setCvar("_ready_timeout_canceled", "");
		matchCancel("Players did not join / ready-up in time");
		return;
	}

	// Only first map of the match
	if (int(matchGetData("finishedMapsCount")) > 0 || !isEnabled())
	{
		setCvar("_ready_timeout_canceled", "");
		return;
	}

	level thread onReadyupOver();

	// Players are informed about the time limit when they connect
	level.ready_timeout_seconds = int(matchGetData("readyTimeout"));

	timeout = level.ready_timeout_seconds * 1000;

	for (;;)
	{
		// Same start time as ready-up Clock (set in _readyup::createLevelHUD)
		// Clock is created when first player connects, until then count from map start
		start = level.ready_timeout_level_start;
		if (isDefined(level.readyup_clock_start))
			start = level.readyup_clock_start;

		remaining = start + timeout - getTime();
		if (remaining <= 0)
			break;

		if (remaining <= 10000 && !isDefined(level.ready_timeout_hud))
		{
			// Players connected during the countdown (updated every second)
			level.ready_timeout_snapshot = undefined;
			level thread HUD_CancelIn(remaining / 1000);
			level thread printBlockingPlayers();
		}
		else if (remaining > 10000 && isDefined(level.ready_timeout_hud))
		{
			// Clock started in the meantime
			HUD_Destroy();
			level.ready_timeout_snapshot = undefined;
		}

		wait level.fps_multiplier * 0.1;
	}

	// Players who readied-up right before the deadline (level.playersready is set with 1 second delay)
	for (i = 0; i < 6 && !level.playersready && maps\mp\gametypes\_readyup::areAllPlayersReady(); i++)
	{
		if (i == 0)
			level thread maps\mp\gametypes\_readyup::Check_All_Ready();
		wait level.fps_multiplier * 0.5;
	}

	// All players are ready, match is starting
	if (level.playersready)
		return;

	// Match data might be redownloaded in the meantime (player added to team for example)
	if (!isEnabled())
	{
		HUD_Destroy();
		return;
	}

	// From now the match will be canceled, ready-up cannot end anymore (checked in _readyup::areAllPlayersReady)
	level.ready_timeout_expired = true;

	// If map is restarted before matchCancel is called, match is canceled right after the restart
	setCvar("_ready_timeout_canceled", matchGetData("match_id"));

	level thread cancelMatch();
}


// Feature is enabled only if readyTimeout is defined and teams have exactly playersCount players
// (with substitutes it's not possible to say who did not join)
isEnabled()
{
	timeout = matchGetData("readyTimeout");
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


onReadyupOver()
{
	level waittill("rupover");

	level.ready_timeout_seconds = undefined;

	HUD_Destroy();
}


// Inform player about the time limit (when the feature is active)
onConnected()
{
	self endon("disconnect");

	// Wait until player fully loads in
	wait level.fps_multiplier * 3;

	if (!isDefined(level.ready_timeout_seconds) || isDefined(level.ready_timeout_expired))
		return;

	self iprintln("^3Ready-up time limit: ^7" + formatTime(level.ready_timeout_seconds) + " ^3(Clock)");
	self iprintln("^3Ready-up in time and do not leave the server until the match starts.");
}


// Returns "" if player is ready in team, otherwise reason why not
getNotReadyReason()
{
	if (!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
		return "not in team";
	// Wrong side, misnamed, ... (sides are determined only in scr_matchinfo 2)
	if (game["scr_matchinfo"] == 2 && isDefined(self.pers["matchinfo_error"]) && self.pers["matchinfo_error"] != "")
		return self.pers["matchinfo_error"];
	if (!isDefined(self.isReady) || !self.isReady)
		return "not ready";
	return "";
}


// Returns array with state of every player from match data:
//   ["uuid"], ["name"], ["state"] = "ok" / "not_ready" / "not_joined", ["detail"]
getRosterStatus()
{
	// Make sure player errors (wrong side, misnamed) are up to date
	if (game["scr_matchinfo"] == 2)
		maps\mp\gametypes\_matchinfo::generateMatchDescription();

	// Also makes sure all connected players are part of uploaded players data
	players = getentarray("player", "classname");
	players_uuid = [];
	for (j = 0; j < players.size; j++)
		players_uuid[j] = players[j] matchPlayerGetData("uuid");

	status = [];
	for (t = 1; t <= 2; t++)
	{
		team_uuids = matchGetData("team" + t + "_player_uuids");
		team_names = matchGetData("team" + t + "_player_names");
		for (i = 0; i < team_uuids.size; i++)
		{
			player = [];
			player["uuid"] = team_uuids[i];
			player["name"] = team_names[i];
			if (!isDefined(player["name"]))
				player["name"] = team_uuids[i];
			player["state"] = "not_joined";
			player["detail"] = "not connected";

			// Ready if any client with this uuid is ready
			for (j = 0; j < players.size; j++)
			{
				if (players_uuid[j] != team_uuids[i] || player["state"] == "ok")
					continue;
				player["name"] = players[j].name;
				player["detail"] = players[j] getNotReadyReason();
				if (player["detail"] == "")
					player["state"] = "ok";
				else
					player["state"] = "not_ready";
			}

			status[status.size] = player;
		}
	}
	return status;
}


// Max 5 names, so the line is not too long
joinNames(names)
{
	text = "";
	for (i = 0; i < names.size && i < 5; i++)
	{
		if (i > 0) text += ", ";
		text += removeColorsFromString(names[i]);
	}
	if (names.size > 5)
		text += " +" + (names.size - 5) + " more";
	return text;
}


// Save players who are connected now, so it's possible to log who left during the countdown
updateSnapshot(status)
{
	snapshot = level.ready_timeout_snapshot;
	if (!isDefined(snapshot))
		snapshot = [];

	for (i = 0; i < status.size; i++)
	{
		if (status[i]["state"] == "not_joined")
			continue;


		found = false;
		for (j = 0; j < snapshot.size; j++)
		{
			if (snapshot[j]["uuid"] == status[i]["uuid"])
			{
				snapshot[j] = status[i];
				found = true;
				break;
			}
		}
		if (!found)
			snapshot[snapshot.size] = status[i];
	}

	level.ready_timeout_snapshot = snapshot;
}


// During the countdown save state of players every second and print players who block the match start
printBlockingPlayers()
{
	level endon("rupover");
	level endon("ready_timeout_hud_destroyed");

	for (tick = 0; ; tick++)
	{
		status = getRosterStatus();
		updateSnapshot(status);

		if (tick % 3 != 0)
		{
			wait level.fps_multiplier * 1;
			continue;
		}

		notJoined = [];
		notReady = [];
		for (i = 0; i < status.size; i++)
		{
			if (status[i]["state"] == "not_joined")
				notJoined[notJoined.size] = status[i]["name"];
			else if (status[i]["state"] == "not_ready")
				notReady[notReady.size] = status[i]["name"];
		}

		if (notJoined.size > 0)
			iprintln("^1Waiting for: ^7" + joinNames(notJoined));
		else if (notReady.size > 0)
			iprintln("^1Not ready: ^7" + joinNames(notReady));

		wait level.fps_multiplier * 1;
	}
}


cancelMatch()
{
	HUD_Destroy();

	status = getRosterStatus();

	// Players who left during the countdown are not joined too, only mark them for the log
	snapshot = level.ready_timeout_snapshot;
	for (i = 0; i < status.size; i++)
	{
		status[i]["left"] = false;
		if (status[i]["state"] != "not_joined" || !isDefined(snapshot))
			continue;
		for (j = 0; j < snapshot.size; j++)
		{
			if (snapshot[j]["uuid"] == status[i]["uuid"])
			{
				status[i]["name"] = snapshot[j]["name"];
				status[i]["left"] = true;
				break;
			}
		}
	}

	notJoined_uuids = [];
	notJoined_names = [];
	notReady_uuids = [];
	notReady_names = [];
	for (i = 0; i < status.size; i++)
	{
		if (status[i]["state"] == "not_joined")
		{
			notJoined_uuids[notJoined_uuids.size] = status[i]["uuid"];
			notJoined_names[notJoined_names.size] = status[i]["name"];
		}
		else if (status[i]["state"] == "not_ready")
		{
			notReady_uuids[notReady_uuids.size] = status[i]["uuid"];
			notReady_names[notReady_names.size] = status[i]["name"];
		}
	}

	// Not joined players have priority, send only them
	if (notJoined_uuids.size > 0)
	{
		reason = "not_joined";
		uuids = notJoined_uuids;
		names = notJoined_names;
		text = notJoined_uuids.size + " player(s) did not join in time";
	}
	else
	{
		// List might be empty if ready-up is blocked by player who is not part of the match
		reason = "not_ready";
		uuids = notReady_uuids;
		names = notReady_names;
		if (notReady_uuids.size > 0)
			text = notReady_uuids.size + " player(s) did not ready-up in time";
		else
			text = "Match did not start in time";
	}

	uuidsString = "";
	for (i = 0; i < uuids.size; i++)
	{
		if (i > 0) uuidsString += ",";
		uuidsString += uuids[i];
	}

	iprintlnbold("^1Match canceled: " + text);
	namesString = joinNames(names);
	if (namesString != "")
		iprintln("^1" + text + ": ^7" + namesString);

	logStatus(reason, uuids.size, status);

	matchSetData(
		"map", level.mapname,
		"state", "canceled",
		"cancel_reason", reason,
		"cancel_player_uuids", uuidsString,
		"cancel_details", getDetailsString(status)
	);

	matchUploadData(::onUploadDone, ::onUploadError);

	// Wait for upload, but give players at least few seconds to read the message
	level thread uploadWaitLimit();
	level waittill("ready_timeout_upload_finished");
	wait level.fps_multiplier * 3;

	setCvar("_ready_timeout_canceled", "");

	matchCancel(text);
}

// State of every player from match data for upload: "uuid1:not_connected,uuid2:ok,..."
getDetailsString(status)
{
	text = "";
	for (i = 0; i < status.size; i++)
	{
		if (status[i]["state"] == "ok")
			code = "ok";
		else if (status[i]["left"])
			code = "left_during_countdown";
		else if (status[i]["state"] == "not_joined")
			code = "not_connected";
		else if (status[i]["detail"] == "not in team")
			code = "not_in_team";
		else if (status[i]["detail"] == "not ready")
			code = "not_ready";
		else
			code = "wrong_side_or_name";

		if (i > 0) text += ",";
		text += status[i]["uuid"] + ":" + code;
	}
	return text;
}


// Write state of every player into server log, so it's possible to check disputes
logStatus(reason, reportedCount, status)
{
	logprint("READY_TIMEOUT: match " + matchGetData("match_id") + " canceled, reason: " + reason + ", reported players: " + reportedCount + "\n");

	for (i = 0; i < status.size; i++)
	{
		line = "READY_TIMEOUT: " + status[i]["uuid"] + " " + status[i]["name"] + " - ";
		if (status[i]["state"] == "ok")
			line += "ok";
		else
			line += status[i]["detail"];
		if (status[i]["left"])
			line += " (left during countdown)";
		if ((reason == "not_joined" && status[i]["state"] == "not_joined") || (reason == "not_ready" && status[i]["state"] == "not_ready"))
			line += " [reported]";
		logprint(line + "\n");
	}

	// Connected players who are not part of the match
	players = getentarray("player", "classname");
	for (j = 0; j < players.size; j++)
	{
		uuid = players[j] matchPlayerGetData("uuid");
		found = false;
		for (i = 0; i < status.size; i++)
		{
			if (status[i]["uuid"] == uuid)
			{
				found = true;
				break;
			}
		}
		if (found)
			continue;
		if (uuid == "")
			logprint("READY_TIMEOUT: " + players[j].name + " - connected, not logged in to the match\n");
		else
			logprint("READY_TIMEOUT: " + players[j].name + " - connected, uuid " + uuid + " is not part of the match\n");
	}
}

onUploadDone()
{
	level notify("ready_timeout_upload_finished");
}
onUploadError(error)
{
	level notify("ready_timeout_upload_finished");
}
uploadWaitLimit()
{
	level endon("ready_timeout_upload_finished");
	wait level.fps_multiplier * 5;
	level notify("ready_timeout_upload_finished");
}


HUD_Destroy()
{
	if (isDefined(level.ready_timeout_hud))
		level.ready_timeout_hud destroy2();
	if (isDefined(level.ready_timeout_hud_clock))
		level.ready_timeout_hud_clock destroy2();
	if (isDefined(level.ready_timeout_hud_info))
		level.ready_timeout_hud_info destroy2();
	level.ready_timeout_hud = undefined;
	level.ready_timeout_hud_clock = undefined;
	level.ready_timeout_hud_info = undefined;
	level notify("ready_timeout_hud_destroyed");
}

HUD_CancelIn(seconds)
{
	level.ready_timeout_hud = newHudElem2();
	level.ready_timeout_hud.x = 320;
	level.ready_timeout_hud.y = 120;
	level.ready_timeout_hud.alignX = "center";
	level.ready_timeout_hud.alignY = "middle";
	level.ready_timeout_hud.font = "default";
	level.ready_timeout_hud.fontscale = 1.4;
	level.ready_timeout_hud.color = (1, 0.2, 0.2);
	level.ready_timeout_hud setText(game["STRING_READY_TIMEOUT_CANCEL_IN"]);

	level.ready_timeout_hud_clock = newHudElem2();
	level.ready_timeout_hud_clock.x = 320;
	level.ready_timeout_hud_clock.y = 140;
	level.ready_timeout_hud_clock.alignX = "center";
	level.ready_timeout_hud_clock.alignY = "middle";
	level.ready_timeout_hud_clock.font = "default";
	level.ready_timeout_hud_clock.fontscale = 1.4;
	level.ready_timeout_hud_clock.color = (1, 0.2, 0.2);
	level.ready_timeout_hud_clock setTimer(seconds);

	level.ready_timeout_hud_info = newHudElem2();
	level.ready_timeout_hud_info.x = 320;
	level.ready_timeout_hud_info.y = 160;
	level.ready_timeout_hud_info.alignX = "center";
	level.ready_timeout_hud_info.alignY = "middle";
	level.ready_timeout_hud_info.font = "default";
	level.ready_timeout_hud_info.fontscale = 1.1;
	level.ready_timeout_hud_info.color = (0.9, 0.9, 0.9);
	level.ready_timeout_hud_info setText(game["STRING_READY_TIMEOUT_DO_NOT_LEAVE"]);
}
