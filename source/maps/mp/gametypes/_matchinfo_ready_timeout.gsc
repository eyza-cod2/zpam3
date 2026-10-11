#include maps\mp\gametypes\global\_global;

/*
Strict time limit for players to join and ready-up in CoD2x match.

Enabled only if match data contains key "readyTimeout" with number of seconds (for example 180).
If the key is missing or is 0, feature is disabled (ladder matches).

Timer runs only in first ready-up of the first map of the match.
Time is kept in cvars, so it continues after map change or map restart in ready-up.
If ready-up does not end in time, match is canceled:
 - if some players did not join, only their uuids are sent
 - else uuids of players who did not ready-up are sent (not ready, not in allies/axis, wrong side, misnamed)

Uploaded global data:
	state:               "canceled"
	cancel_reason:       "not_joined" / "not_ready"
	cancel_player_uuids: "uuid1,uuid2"

After the upload, matchCancel() is called (CoD2x sends type "error" with cancel reason).
*/
init()
{
	if (game["firstInit"])
	{
		precacheString2("STRING_READY_TIMEOUT_CANCEL_IN", &"Match will be canceled in");
	}

	if (!isDefined(game["readyup_first_run"]) || !game["readyup_first_run"])
		return;

	level thread watchTimeout();
}


watchTimeout()
{
	level endon("rupover");

	// Offset thread from other threads, wait for matchinfo to prepare map
	wait level.frame * 10;

	// Only first map of the match
	if (!matchIsActivated() || !level.in_readyup || int(matchGetData("finishedMapsCount")) > 0 || !isEnabled())
	{
		clearSavedTime();
		return;
	}

	// Continue with time saved before map change / map restart
	matchId = matchGetData("match_id");
	remaining = int(matchGetData("readyTimeout"));
	if (getCvar("_ready_timeout_match") == matchId && getCvar("_ready_timeout_left") != "")
		remaining = getCvarInt("_ready_timeout_left");

	setCvar("_ready_timeout_match", matchId);
	setCvar("_ready_timeout_left", "" + remaining);

	level thread onReadyupOver();

	while (remaining > 0)
	{
		if (remaining <= 10 && !isDefined(level.ready_timeout_hud))
			level thread HUD_CancelIn(remaining);

		wait level.fps_multiplier * 1;

		remaining--;
		setCvar("_ready_timeout_left", "" + remaining);
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
		clearSavedTime();
		HUD_Destroy();
		return;
	}

	// From now the match will be canceled, ready-up cannot end anymore (checked in _readyup::areAllPlayersReady)
	level.ready_timeout_expired = true;

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


clearSavedTime()
{
	setCvar("_ready_timeout_match", "");
	setCvar("_ready_timeout_left", "");
}


onReadyupOver()
{
	level waittill("rupover");

	clearSavedTime();
	HUD_Destroy();
}


isReadyInTeam()
{
	if (!isDefined(self.isReady) || !self.isReady)
		return false;
	if (!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
		return false;
	// Wrong side, misnamed, ... (sides are determined only in scr_matchinfo 2)
	if (game["scr_matchinfo"] == 2 && isDefined(self.pers["matchinfo_error"]) && self.pers["matchinfo_error"] != "")
		return false;
	return true;
}


cancelMatch()
{
	HUD_Destroy();

	// Make sure player errors (wrong side, misnamed) are up to date
	if (game["scr_matchinfo"] == 2)
		maps\mp\gametypes\_matchinfo::generateMatchDescription();

	expected_uuids = [];
	expected_names = [];
	for (t = 1; t <= 2; t++)
	{
		team_uuids = matchGetData("team" + t + "_player_uuids");
		team_names = matchGetData("team" + t + "_player_names");
		for (i = 0; i < team_uuids.size; i++) {
			expected_uuids[expected_uuids.size] = team_uuids[i];
			expected_names[expected_names.size] = team_names[i];
		}
	}

	// Also makes sure all connected players are part of uploaded players data
	players = getentarray("player", "classname");
	players_uuid = [];
	for (j = 0; j < players.size; j++)
		players_uuid[j] = players[j] matchPlayerGetData("uuid");

	notJoined_uuids = [];
	notJoined_names = [];
	notReady_uuids = [];
	notReady_names = [];

	for (i = 0; i < expected_uuids.size; i++)
	{
		joined = false;
		ready = false;
		name = expected_names[i];
		if (!isDefined(name))
			name = expected_uuids[i];
		for (j = 0; j < players.size; j++)
		{
			if (players_uuid[j] != expected_uuids[i])
				continue;
			joined = true;
			name = players[j].name;
			if (players[j] isReadyInTeam())
				ready = true;
		}

		if (!joined)
		{
			notJoined_uuids[notJoined_uuids.size] = expected_uuids[i];
			notJoined_names[notJoined_names.size] = name;
		}
		else if (!ready)
		{
			notReady_uuids[notReady_uuids.size] = expected_uuids[i];
			notReady_names[notReady_names.size] = name;
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
	namesString = "";
	for (i = 0; i < names.size; i++)
	{
		if (i > 0) namesString += "^7, ";
		namesString += names[i];
	}
	if (namesString != "")
		iprintln("^1" + text + ": ^7" + namesString);

	matchSetData(
		"map", level.mapname,
		"state", "canceled",
		"cancel_reason", reason,
		"cancel_player_uuids", uuidsString
	);

	matchUploadData(::onUploadDone, ::onUploadError);

	// Wait for upload, but give players at least few seconds to read the message
	level thread uploadWaitLimit();
	level waittill("ready_timeout_upload_finished");
	wait level.fps_multiplier * 3;

	// Cleared only now - if map is restarted in the meantime, match is canceled again right away (saved time is 0)
	clearSavedTime();

	matchCancel(text);
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
	level.ready_timeout_hud = undefined;
	level.ready_timeout_hud_clock = undefined;
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
}
