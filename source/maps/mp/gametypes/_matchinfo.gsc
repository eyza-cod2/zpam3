#include maps\mp\gametypes\global\_global;
/*
First we need to determine wich team will be first
 - do this by saving information who connect to this server first - his team will be first
 - we will save time when player connect to the server

Procces is splited to 2 parts
 - 1. Readyup - in this period team names are not fixed and info may be refrshed according to connecting players
 - 2. Match start - in this part team names will be saved and will not refresh

Player names cannot be changed too much during match, othervise match info will reset

*/
Init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_matchinfo", "INT", 0, 0, 2);					// level.scr_matchinfo
	registerCvarEx("I", "scr_matchinfo_reset", "BOOL", 0);

	addEventListener("onConnected",     ::onConnected);

	// Save value of scr_matchinfo for entire map (if cvar scr_matchinfo is changed during match, it makes no effect until map change)
	firstMapRestart = false;
	if (!isDefined(game["scr_matchinfo"])) {
		game["scr_matchinfo"] = level.scr_matchinfo;
		firstMapRestart = true;
	}

	// Matchinfo cannot working without readyup...
	if (!level.scr_readyup)
		game["scr_matchinfo"] = 0;


	if (!isDefined(game["match_teams_set"]))
	{
		game["match_exists"] = false;
		game["match_teams_set"] = false;

		game["match_team1_name"] = "";
		game["match_team1_score"] = "";
		game["match_team1_side"] = "";
		game["match_team2_name"] = "";
		game["match_team2_score"] = "";
		game["match_team2_side"] = "";

		game["match_totaltime_text"] = "";

		game["match_round"] = "";
		game["match_state"] = "";
	}

	level.match_description = "";
	level.match_description_players1 = "";
	level.match_description_players2 = "";
	level.match_description_playersUnknown = "";
	level.match_missingPlayers = 0;
	level.match_mixedPlayers = 0;
	level.match_unjoinedPlayers = 0;

	// Matchinfo not possible, exit here
	if (game["scr_matchinfo"] == 0)
		return;

	// Once match start, save teams
	if (!level.in_readyup)
	{
		game["match_exists"] = true;
		game["match_teams_set"] = true;
	}

	addEventListener("onConnecting",   ::onConnecting);
	addEventListener("onDisconnect",   ::onDisconnect);
	addEventListener("onStopGameType", ::onStopGameType);
	addEventListener("onJoinedTeam",   ::onJoinedTeam);
	addEventListener("onSpawned",      ::onSpawned);
	thread onReadyupOver();

	level thread refresh(firstMapRestart);
}


prepareMap() {

	// Save data from previous map
	team1_winnedMaps = int(matchGetData("team1_winnedMaps")); // number of maps winned by team 1
	team2_winnedMaps = int(matchGetData("team2_winnedMaps")); // number of maps winned by team 2
	finishedMapsCount = int(matchGetData("finishedMapsCount")); // number of played maps
	finishedMap1 = matchGetData("finishedMap1");
	finishedMap2 = matchGetData("finishedMap2");
	finishedMap3 = matchGetData("finishedMap3");
	finishedMap4 = matchGetData("finishedMap4");
	finishedMap5 = matchGetData("finishedMap5");

	// Clear data from previous map
	matchClearData();

	// Restore data from previous map
	matchSetData("team1_winnedMaps", team1_winnedMaps);
	matchSetData("team2_winnedMaps", team2_winnedMaps);
	matchSetData("finishedMapsCount", finishedMapsCount);
	if (finishedMap1 != "") matchSetData("finishedMap1", finishedMap1);
	if (finishedMap2 != "") matchSetData("finishedMap2", finishedMap2);
	if (finishedMap3 != "") matchSetData("finishedMap3", finishedMap3);
	if (finishedMap4 != "") matchSetData("finishedMap4", finishedMap4);
	if (finishedMap5 != "") matchSetData("finishedMap5", finishedMap5);

	// Dont upload data on new map until RUP
	//uploadMatchData(false, true);
}


finishMap() {

	// Load data from previous map
	team1_winnedMaps = int(matchGetData("team1_winnedMaps")); // 0 if not defined
	team2_winnedMaps = int(matchGetData("team2_winnedMaps")); // 0 if not defined
	finishedMapsCount = int(matchGetData("finishedMapsCount")); // 0 if not defined
	finishedMap1 = matchGetData("finishedMap1");
	finishedMap2 = matchGetData("finishedMap2");
	finishedMap3 = matchGetData("finishedMap3");
	finishedMap4 = matchGetData("finishedMap4");
	finishedMap5 = matchGetData("finishedMap5");

	// Update data
	finishedMapsCount++;
	team1_score = int(game["match_team1_score"]);
	team2_score = int(game["match_team2_score"]);
	if (team1_score > team2_score) {
		team1_winnedMaps++;
	} else if (team2_score > team1_score) {
		team2_winnedMaps++;
	}

	// Save data
	matchSetData("team1_winnedMaps", team1_winnedMaps);
	matchSetData("team2_winnedMaps", team2_winnedMaps);
	matchSetData("finishedMapsCount", finishedMapsCount);
	switch(finishedMapsCount) {
		case 1: matchSetData("finishedMap1", level.mapname); break;
		case 2: matchSetData("finishedMap2", level.mapname); break;
		case 3: matchSetData("finishedMap3", level.mapname); break;
		case 4: matchSetData("finishedMap4", level.mapname); break;
		case 5: matchSetData("finishedMap5", level.mapname); break;
	}

	// Upload match data to master server
	uploadMatchData("finishMap", false, false);
}


endMap() {

	team1_winnedMaps = int(matchGetData("team1_winnedMaps")); // 0 if not defined
	team2_winnedMaps = int(matchGetData("team2_winnedMaps")); // 0 if not defined
	format = matchGetData("format"); // BO1, BO3, BO5 (defined by CoD2x)
	
	matchFinished = false;
	switch (format) {
		default:
		case "BO1":
			matchFinished = true;
			break;
		case "BO3":
			if (team1_winnedMaps >= 2 || team2_winnedMaps >= 2)
				matchFinished = true;
			break;
		case "BO5":
			if (team1_winnedMaps >= 3 || team2_winnedMaps >= 3)
				matchFinished = true;
			break;
	}

	if (matchFinished) {
		matchFinish(); // kick all players, cancel match, fast_restart

	} else {
		maps = matchGetData("maps"); // might be empty

		// Maps are defined
		if (maps.size > 0) {
			// Collect finished maps into an array
			finishedMaps = [];
			finishedMap1 = matchGetData("finishedMap1");  if (finishedMap1 != "") finishedMaps[finishedMaps.size] = finishedMap1;
			finishedMap2 = matchGetData("finishedMap2");  if (finishedMap2 != "") finishedMaps[finishedMaps.size] = finishedMap2;
			finishedMap3 = matchGetData("finishedMap3");  if (finishedMap3 != "") finishedMaps[finishedMaps.size] = finishedMap3;
			finishedMap4 = matchGetData("finishedMap4");  if (finishedMap4 != "") finishedMaps[finishedMaps.size] = finishedMap4;
			finishedMap5 = matchGetData("finishedMap5");  if (finishedMap5 != "") finishedMaps[finishedMaps.size] = finishedMap5;

			// Find the first unplayed map in the maps array
			nextMap = "";
			for (i = 0; i < maps.size; i++) {
				isPlayed = false;
				for (j = 0; j < finishedMaps.size; j++) {
					if (maps[i] == finishedMaps[j]) {
						isPlayed = true;
						break;
					}
				}
				if (!isPlayed) {
					nextMap = maps[i];
					break;
				}
			}

			// If all maps are played, fallback to first map
			if (nextMap == "" && maps.size > 0) {
				nextMap = maps[0];
			}

			map(nextMap, false);
		
		// Maps not defined, let players decide
		} else {		
			map_restart(false); // fast_restart
		}
	}

}


canMapBeChanged() {

	if (matchIsActivated()) {

		maps = matchGetData("maps"); // might be empty

		allow = true;

		// Maps are defined, cod2x set them into map_rotation, so disable map change / restart
		if (maps.size > 0) {
			allow = false;

		// Maps are not defined, allow match change before first round ends
		} else {	
			switch(level.gametype) {
				case "sd":				
					if (game["state"] == "playing" && // will be false on interrmission when we want to allow map change
						!game["readyup_first_run"] && // allow change in first readyup
						(game["allies_score"] > 0 || game["axis_score"] > 0) // allow change if score is 0:0 (so in first round its still possible to change))
					) {
						allow = false;
					}
					break;
				case "dm":
					if (game["state"] == "playing" && // will be false on interrmission when we want to allow map change
						!game["readyup_first_run"] // allow change in first readyup
					) {
						allow = false;
					}
					break;
			}
		}

		if (!allow) {
			iprint_to_team_players("^1Map change / restart is disabled during match!");
			return false; // prevent map change / restart
		}
	}
	return true;
}


// Called by code before map change, map restart, or server shutdown.
//  fromScript: true if map change was triggered from a script, false if from a command.
//  bComplete: true if map change or restart is complete, false if it's a round restart so persistent variables are kept.
//  shutdown: true if the server is shutting down, false otherwise.
//  source: "map", "fast_restart", "map_restart", "map_rotate", "shutdown"
onStopGameType(fromScript, bComplete, shutdown, source) {

	// Disable map change (if called via command, rcon for example)
	if (fromScript == false && shutdown == false)
	{
		if (!canMapBeChanged())
			return false; // prevent map change / restart
	}
}




uploadMatchData(debug, printSuccess, printError) {

	if (!matchIsActivated()) {
		return;
	}

	team1_score = "0";
	team2_score = "0";
	if (isDigitalNumber(game["match_team1_score"]))
		team1_score = game["match_team1_score"];
	if (isDigitalNumber(game["match_team2_score"]))
		team2_score = game["match_team2_score"];

	state = "playing";
	if (game["state"] == "intermission") {
		state = "finished";
	}

	// Set global data
	matchSetData(
		"team1_score", team1_score,
		"team2_score", team2_score,
		"map", level.mapname,
		"round", game["match_round"],
		"state", state,
		"debug", debug
	);

	// Set player data
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		stats = player maps\mp\gametypes\_player_stat::getStats();
		if (!isDefined(stats)) continue;
		
		if (level.gametype == "sd") {

			player matchPlayerSetData(
				"score", 	format_fractional(stats["score"], 1, 1),
				"kills", 	stats["kills"],
				"assists", 	stats["assists"],
				"damage", 	format_fractional(stats["damage"] / 100, 1, 1),
				"deaths", 	stats["deaths"],
				"grenades", stats["grenades"],
				"plants", 	stats["plants"],
				"defuses", 	stats["defuses"]
			);
		} else if (level.gametype == "dm") {
			player matchPlayerSetData(
				"score", 	format_fractional(stats["score"], 1, 1),
				"kills", 	stats["kills"],
				"deaths", 	stats["deaths"]
			);
		} else {
			player matchPlayerSetData(
				"score", 	player.score,
				"deaths", 	player.deaths
			);
		}
	}

	// Start upload
	if (printSuccess && printError)
		matchUploadData(::matchUploadDone, ::matchUploadError);
	else if (printSuccess)
		matchUploadData(::matchUploadDone, ::matchUploadErrorVoid);
	else if (printError)
		matchUploadData(::matchUploadDoneVoid, ::matchUploadError);
	else
		matchUploadData();

}

matchUploadDoneVoid() {}
matchUploadDone() {
	iprint_to_team_players("^2Match data uploaded successfully.");
}
matchUploadErrorVoid() {}
matchUploadError(error) {
	iprint_to_team_players("^1Error uploading match data: " + error);
}



// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_matchinfo": level.scr_matchinfo = value; return true;
		case "scr_matchinfo_reset":
		{
			if (value == 1)
			{
				clear();
				iprintln("Info about teams was cleared via rcon.");

				changeCvarQuiet(cvar, 0);
			}

			return true;
		}

	}
	return false;
}


onConnecting(firstTime) {
	self endon("disconnect");

	// Redownload match data when player is connecting to allow connect host that was added to team while match was already in progress
	if (matchIsActivated() && firstTime) {

		// Make sure redownload is called only once in short period of time
		level notify("matchinfo_data_redownload");
		level endon("matchinfo_data_redownload");

		wait level.fps_multiplier * 1;
		
		matchRedownloadData();
	}
}


iprint_to_team_players(text)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (isDefined(player.pers["team"]) && player.pers["team"] != "streamer")
		{
			player iPrintLn(text);
		}
	}
}


onConnected()
{
	self endon("disconnect");

	// Ingame match info bar
	if (!isDefined(self.pers["matchinfo_ingame"]))
	{
		// By default show match info ingame
		self.pers["matchinfo_ingame"] = false;
		self.pers["matchinfo_ingame_visible"] = false;
		self.pers["matchinfo_matchDataWarningShowed"] = false;
		self.pers["matchinfo_nickWarningLastTime"] = 0;
		self.pers["matchinfo_error"] = "";
		self.pers["matchinfo_color"] = "";

		// Show warning about unknown player
		if (matchIsActivated())
		{
			if (self matchPlayerIsAllowed() == false) {
				if (self matchPlayerGetData("uuid") == "")
					iprint_to_team_players(self.name + "^1 is not logged into the match!");
				else
					iprint_to_team_players(self.name + "^1 is not assigned to any team!");
			} else {
				//iprint_to_team_players(self.name + "^7's name: " + self matchPlayerGetData("name"));
				//iprint_to_team_players(self.name + "^7's team: " + self matchPlayerGetData("team_name"));
			}
		}
	}

	level thread generateMatchDescriptionDebounced();

	if (game["scr_matchinfo"] > 0)
	{
		self setClientCvar2("ui_matchinfo_show", "1");

		if (!isDefined(self.pers["timeConnected"]))
		{
			self.pers["timeConnected"] = getTime();
		}

		if (game["scr_matchinfo"] == 2)
		{
			//waittillframeend;
			// Update team names in scoreboard
			self updateScoreboardTeamNames();
		}
	}
	else
	{
		wait level.fps_multiplier * 0.2;
		self setClientCvar2("ui_matchinfo_show", "0");
	}

}

onDisconnect() {
	level thread generateMatchDescriptionDebounced();
}


generateMatchDescriptionDebounced()
{
	if (matchIsActivated()) {

		// Prevent calling multiple times in one frame
		level notify("generateMatchDescriptionDebounced");
		level endon("generateMatchDescriptionDebounced");
		waittillframeend;

		level generateMatchDescription(); // regenerate match description
	}
}


onJoinedTeam(teamName)
{
	// Ingame match info bar
	self ingame_handleVisiblity();

	level thread generateMatchDescriptionDebounced(); // regenerate match description
}

// On player or spectator is spawned
onSpawned()
{
	self endon("disconnect");

	if (self.pers["matchinfo_matchDataWarningShowed"] == false && (self.pers["team"] == "allies" || self.pers["team"] == "axis" || self.pers["team"] == "spectator")) {
		wait level.fps_multiplier * 0.5;
		self.pers["matchinfo_matchDataWarningShowed"] = true;
		//self printMatchDataInfo();
	}

	// Ingame match info bar
	self ingame_handleVisiblity();

	level thread generateMatchDescriptionDebounced(); // regenerate match description
}


onReadyupOver()
{
	for (;;)
	{
		level waittill("rupover");

		wait level.fps_multiplier * 3;

		if (!matchIsActivated())
			continue;

		// Upload data - readyup is over
		// Canceled
		//uploadMatchData(false, false);

		if (!game["readyup_first_run"])
			continue;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			player printMatchDataInfo();
		}
	}
}



printMatchDataInfo() {
	if (!matchIsActivated()) return;

	// Show downloaded match info
	if ((self.pers["team"] == "allies" || self.pers["team"] == "axis" || self.pers["team"] == "spectator")) // ignore streamer
	{
		team1_color = "^8";
		team2_color = "^9";
		if (self.pers["team"] == "axis") {
			team1_color = "^9";
			team2_color = "^8";
		}

		self iPrintLn("Match is activated and being recorded.");
		// Team1 vs Team2
		self iPrintLn("- [" + team1_color + removeColorsFromString(matchGetData("team1_name")) + "^7]  vs  [" + team2_color + removeColorsFromString(matchGetData("team2_name")) + "^7]");
		//self iPrintLn("- Match ID: " + matchGetData("match_id"));
		//self iPrintLn("- Team 1: " + matchGetData("team1_name"));
		//self iPrintLn("- Team 2: " + matchGetData("team2_name"));
		maps = matchGetData("maps");
		if (maps.size > 0) {
			if (maps.size == 1) {
				self iPrintLn("- Map: " + maps[0]);
			} else {
				mapsString = "";
				for (i = 0; i < maps.size; i++) {
					if (i > 0) mapsString += ", ";
					mapsString += GetMapName(maps[i]);
				}
				self iPrintLn("- Maps: " + mapsString);
			}
		}

		teamNum = self matchPlayerGetData("team"); // team1 / team2 / ""
		if (!self matchPlayerIsAllowed()) {
			self iPrintLn("^3- You are not assigned to any team!^7");
		}
	}

}


// Settings
ingame_isEnabled()
{
  return isDefined(self.pers["matchinfo_ingame"]) && self.pers["matchinfo_ingame"];
}

ingame_enable()
{
	self.pers["matchinfo_ingame"] = true;
	ingame_show();
}

ingame_disable()
{
	self.pers["matchinfo_ingame"] = false;
	ingame_hide();
}

ingame_toggle()
{
	// Toggle settings
	if (ingame_isEnabled() || self.pers["matchinfo_ingame_visible"]) // If is visible for spectator and "Hide in game" is clicked
		ingame_disable();
	else
		ingame_enable();
}

// Show match info ingame menu elements in hud menu
ingame_show()
{
	if (!self.pers["matchinfo_ingame_visible"] && self.pers["team"] != "streamer") // Always hide ingame menu for streamer as they have own menu
	{
		self.pers["matchinfo_ingame_visible"] = true;
		if (game["scr_matchinfo"] > 0)
		{
			self setClientCvarIfChanged("ui_matchinfo_ingame_show", "1");
			self thread UpdatePlayerCvars();
		}
	}
}

// Hide match info ingame menu elements in hud menu
ingame_hide()
{
	//if (self.pers["matchinfo_ingame_visible"])
	{
		self.pers["matchinfo_ingame_visible"] = false;
		self setClientCvarIfChanged("ui_matchinfo_ingame_show", "0");
		self setClientCvarIfChanged("ui_matchinfo_ingame_team1_team", 	""); // bg elements cannot be dependend on _show cvar, needs to be set separately
		self setClientCvarIfChanged("ui_matchinfo_ingame_team2_team", 	"");
		if (game["scr_matchinfo"] > 0)
			self thread UpdatePlayerCvars();
	}
}

ingame_handleVisiblity() {
	// Ingame match info bar
	if ((ingame_isEnabled() || (level.in_readyup && matchIsActivated())) && self.pers["team"] != "streamer") // always show ingame menu for spectator during readyup
		ingame_show();
	else if (!ingame_isEnabled() || self.pers["team"] == "streamer") // always hide ingame menu for streamer as they have own menu
		ingame_hide();
}



updateScoreboardTeamNames()
{
	//println("##updateTeamNames:"+game["match_team1_name"]);

	teamname_allies = game["match_team1_name"];
	teamname_axis = game["match_team2_name"];
	if (game["match_team1_side"] == "axis")
	{
		teamname_allies = game["match_team2_name"];
		teamname_axis = game["match_team1_name"];
	}


	if (teamname_allies != "")
		self setClientCvarIfChanged("g_TeamName_Allies", teamname_allies);
	else
	{
		alliesDef = "";
		switch(game["allies"])
		{
			case "american": alliesDef = "MPUI_AMERICAN"; break;
			case "british":  alliesDef = "MPUI_BRITISH"; break;
			case "russian":  alliesDef = "MPUI_RUSSIAN"; break;
		}
		self setClientCvarIfChanged("g_TeamName_Allies", alliesDef);
	}

	if (teamname_axis != "")
		self setClientCvarIfChanged("g_TeamName_Axis", teamname_axis);
	else
		self setClientCvarIfChanged("g_TeamName_Axis", "MPUI_GERMAN");

}



processPreviousMapToHistory()
{
	prevMap_map = getCvar("sv_map_name");

	// If prev map is defined, it means match started and this score needs to be saved
	if (prevMap_map != "")
	{
		// Move 2. saved map to 3. (removing the third)
		setCvar("sv_map3_name", 	getCvar("sv_map2_name"));
		setCvar("sv_map3_team1", 	getCvar("sv_map2_team1"));
		setCvar("sv_map3_team2", 	getCvar("sv_map2_team2"));
		setCvar("sv_map3_score1", 	getCvar("sv_map2_score1"));
		setCvar("sv_map3_score2", 	getCvar("sv_map2_score2"));

		// Move 1. saved map to 2. (removing the second)
		setCvar("sv_map2_name", 	getCvar("sv_map1_name"));
		setCvar("sv_map2_team1", 	getCvar("sv_map1_team1"));
		setCvar("sv_map2_team2", 	getCvar("sv_map1_team2"));
		setCvar("sv_map2_score1", 	getCvar("sv_map1_score1"));
		setCvar("sv_map2_score2", 	getCvar("sv_map1_score2"));

		// Save previous map to history at first location
		setCvar("sv_map1_name", prevMap_map);
		setCvar("sv_map1_team1", getCvar("sv_map_team1"));
		setCvar("sv_map1_team2", getCvar("sv_map_team2"));
		setCvar("sv_map1_score1", getCvar("sv_map_score1"));
		setCvar("sv_map1_score2", getCvar("sv_map_score2"));

		// remove prev map info
		setCvar("sv_map_name", "");
		setCvar("sv_map_team1", "");
		setCvar("sv_map_team2", "");
		setCvar("sv_map_score1", "");
		setCvar("sv_map_score2", "");
	}
}


refreshTeamNames()
{
	// Generate allies and axis team names
	// Generate team names according to player names
	wait level.fps_multiplier * 0.1;
	maps\mp\gametypes\_teamname::refreshTeamName("allies"); // will update level.teamname_allies
	wait level.fps_multiplier * 0.1;
	maps\mp\gametypes\_teamname::refreshTeamName("axis"); // will update level.teamname_axis
	wait level.frame;
}


determineTeamByMatchData()
{
	if (!matchIsActivated()) {
		assertMsg("determineTeamByMatchData called but match is not activated");
	}

	// Fill team names
	match_team1_name = matchGetData("team1_name");
	match_team2_name = matchGetData("team2_name");
	team1_players = [];
	team2_players = [];
	team1_allies = 0;
	team1_axis = 0;
	team2_allies = 0;
	team2_axis = 0;
	totalPlayingPlayers = 0;
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (isDefined(player.pers["team"]) && (player.pers["team"] == "allies" || player.pers["team"] == "axis"))
		{
			totalPlayingPlayers++;

			teamName = player matchPlayerGetData("team_name");

			if (teamName == match_team1_name)
			{
				if (player.pers["team"] == "allies")
					team1_allies++;
				else if (player.pers["team"] == "axis")
					team1_axis++;
				team1_players[team1_players.size] = player;
			}
			else if (teamName == match_team2_name)
			{
				if (player.pers["team"] == "allies")
					team2_allies++;
				else if (player.pers["team"] == "axis")
					team2_axis++;
				team2_players[team2_players.size] = player;
			}
		}
	}

	// Find which side that team is now
	// Atleast one team needs to join team to be able to determine sides
	game["match_team1_name"] = "";
	game["match_team2_name"] = "";
	game["match_team1_side"] = "";
	game["match_team2_side"] = "";

	if (level.gametype != "dm") 
	{
		// Fill team names
		game["match_team1_name"] = match_team1_name;
		game["match_team2_name"] = match_team2_name;

		if (team1_allies > team1_axis || team2_axis > team2_allies)
		{
			game["match_team1_side"] = "allies";
			game["match_team2_side"] = "axis";
		}
		else if (team1_axis > team1_allies || team2_allies > team2_axis)
		{
			game["match_team1_side"] = "axis";
			game["match_team2_side"] = "allies";
		}
	} else {
		// If there are exactly 2 playing players, set as assigned
		if (totalPlayingPlayers > 0 && totalPlayingPlayers <= 2 && (team1_players.size == 1 || team2_players.size == 1)) {

			game["match_team1_name"] = match_team1_name;
			game["match_team2_name"] = match_team2_name;

			if (team1_players.size == 1) game["match_team1_side"] = "player_" + (team1_players[0] getEntityNumber());
			if (team2_players.size == 1) game["match_team2_side"] = "player_" + (team2_players[0] getEntityNumber());
		}
	}

}


determineTeamByHistoryCvars()
{
	refreshTeamNames();

	// Fill team names
	game["match_team1_name"] = getCvar("sv_match_team1");
	game["match_team2_name"] = getCvar("sv_match_team2");

	// Find that side that team is now
	// Atleast one team must stay unrenamed or this will not work
	game["match_team1_side"] = "";
	game["match_team2_side"] = "";

	if (level.gametype != "dm") 
	{
		if (game["match_team1_name"] == level.teamname_allies || game["match_team2_name"] == level.teamname_axis)
		{
			game["match_team1_side"] = "allies";
			game["match_team2_side"] = "axis";
		}
		else if (game["match_team2_name"] == level.teamname_allies || game["match_team1_name"] == level.teamname_axis)
		{
			game["match_team1_side"] = "axis";
			game["match_team2_side"] = "allies";
		}
	} else {
		// Not supported
	}
}

determineTeamByFirstConnected()
{
	// Find first team by looking wich player connect
	players = getentarray("player", "classname");

	refreshTeamNames();

	game["match_team1_name"] = "";
	game["match_team2_name"] = "";
	game["match_team1_side"] = "";
	game["match_team2_side"] = "";

	if (level.gametype != "dm") 
	{

		firstPlayer = undefined;
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if (isDefined(player.pers["team"]) && (player.pers["team"] == "allies" || player.pers["team"] == "axis") &&
				(!isDefined(firstPlayer) || player.pers["timeConnected"] < firstPlayer.pers["timeConnected"]))
				firstPlayer = player;
		}

		// Fill team 1
		teamname1 = "";
		team1 = "allies";
		if (isDefined(firstPlayer))
		{
			teamname1 = level.teamname[firstPlayer.pers["team"]];
			team1 = firstPlayer.pers["team"];
		}
		// Fill team 2
		team2 = "axis";
		if (team1 == "axis")
			team2 = "allies";
		teamname2 = level.teamname[team2];

		game["match_team1_name"] = teamname1;
		game["match_team1_side"] = team1;
		game["match_team2_name"] = teamname2;
		game["match_team2_side"] = team2;
	
	} else {
		// Not supported
	}

}

resetAll()
{
	setCvar("sv_map_name", "");
	setCvar("sv_map_team1", "");
	setCvar("sv_map_team2", "");
	setCvar("sv_map_score1", "");
	setCvar("sv_map_score2", "");

	setCvar("sv_match_totaltime", "");
	setCvar("sv_match_players", "");
	setCvar("sv_match_team1", "");
	setCvar("sv_match_team2", "");


	game["match_exists"] = false;
	game["match_starttime"] = undefined;
	game["match_totaltime_prev"] = 0;

	// Reset cvars
	for (i = 1; i <= 3; i++)
	{
		setCvar("sv_map" + i + "_name", 	"");
		setCvar("sv_map" + i + "_team1", 	"");
		setCvar("sv_map" + i + "_team2", 	"");
		setCvar("sv_map" + i + "_score1", 	"");
		setCvar("sv_map" + i + "_score2", 	"");
	}

	game["match_team1_name"] = "";
	game["match_team1_score"] = "";
	game["match_team2_name"] = "";
	game["match_team2_score"] = "";

	// Generate team names again
	determineTeamByFirstConnected();
}

waitForPlayerOrClear(playersLast)
{
	wait level.fps_multiplier * 15;

	resetCount = 0;

	for(;;)
	{
		// Exit loop if teams are set
		if (game["match_teams_set"])
			return;

		// reset matchinfo if 30% of players disconnect or there are no players or there was no players last map
		players = getentarray("player", "classname");
		if (((players.size * 1.0) < (playersLast * 0.7)) || ((players.size * 1.0) > (playersLast * 1.2)) || players.size <= 1 || playersLast <= 1)
			resetCount++;
		else
			resetCount = 0;

		// We are sure to reset the match info
		if (resetCount >= 4)
		{
			clear();
			iprintln("Info about teams was cleared.");
			return;
		}

		wait level.fps_multiplier * 5;
	}
}

clear()
{
	resetAll();

	if (level.in_readyup)
	{
		// Stop demo recording if enabled
		maps\mp\gametypes\_record::stopRecordingForAll();

		//Reset Remaing Time in readyup to Clock
		maps\mp\gametypes\_readyup::HUD_ReadyUp_ResumingIn_Delete();
	}
}


// Well, COD2 dont have this function, so create it manually
ToUpper(char)
{
	switch (char)
	{
		case "a": char = "A"; break;
		case "b": char = "B"; break;
		case "c": char = "C"; break;
		case "d": char = "D"; break;
		case "e": char = "E"; break;
		case "f": char = "F"; break;
		case "g": char = "G"; break;
		case "h": char = "H"; break;
		case "i": char = "I"; break;
		case "j": char = "J"; break;
		case "k": char = "K"; break;
		case "l": char = "L"; break;
		case "m": char = "M"; break;
		case "n": char = "N"; break;
		case "o": char = "O"; break;
		case "p": char = "P"; break;
		case "q": char = "Q"; break;
		case "r": char = "R"; break;
		case "s": char = "S"; break;
		case "t": char = "T"; break;
		case "u": char = "U"; break;
		case "v": char = "V"; break;
		case "w": char = "W"; break;
		case "x": char = "X"; break;
		case "y": char = "Y"; break;
		case "z": char = "Z"; break;
	}
	return char;
}

GetMapName(mapname)
{
	if (mapname == "" || mapname.size < 3)
		return mapname;

	if (mapname == "mp_toujane" || mapname == "mp_toujane_fix")		return "Toujane";
	if (mapname == "mp_burgundy" || mapname == "mp_burgundy_fix")		return "Burgundy";
	if (mapname == "mp_dawnville" || mapname == "mp_dawnville_fix")		return "Dawnville";
	if (mapname == "mp_matmata" || mapname == "mp_matmata_fix")		return "Matmata";
	if (mapname == "mp_carentan" || mapname == "mp_carentan_fix")		return "Carentan";
	if (mapname == "mp_trainstation" || mapname == "mp_trainstation_fix")		return "Trainstation";
	if (mapname == "mp_breakout_tls")					return "Breakout TLS";
	if (mapname == "mp_chelm_fix")						return "Chelm";
	if (mapname == "mp_leningrad_tls")					return "Leningrad TLS";
	if (mapname == "mp_carentan_bal")					return "Carentan";
	if (mapname == "mp_dawnville_sun")					return "Dawnville Sun";
	if (mapname == "mp_railyard_mjr")					return "Railyard MJR";
	if (mapname == "mp_leningrad_mjr")					return "Leningrad MJR";

	if (ToLower(mapname[0]) == "m" && ToLower(mapname[1]) == "p" && ToLower(mapname[2]) == "_")
		mapname = ToUpper(mapname[3]) + getsubstr(mapname, 4, mapname.size);

	return mapname;
}


UpdatePlayerCvars()
{
	if (game["scr_matchinfo"] > 0)
	{
		teamNum_left  = "team1";
		teamNum_right = "team2";

		// Set player's team always on left
		if (isDefined(self.pers["team"]) && self.pers["team"] == game["match_team2_side"])
		{
			teamNum_left  = "team2";
			teamNum_right = "team1";
		}

		name_left = game["match_"+teamNum_left+"_name"];
		name_right = game["match_"+teamNum_right+"_name"];
		// Rename teams when matchinfo is without team names
		if (game["scr_matchinfo"] == 1 && isDefined(self.pers["team"]) && (self.pers["team"] == "allies" || self.pers["team"] == "axis"))
		{
			name_left  = "My Team";
			name_right = "Enemy";
		}
		// Handle empty teams
		if (name_left == "")  name_left = "?";
		if (name_right == "") name_right = "?";

		ui_score_left  = game["match_"+teamNum_left+"_score"];
		ui_score_right = game["match_"+teamNum_right+"_score"];

		ui_name_left = name_left;
		ui_name_right = name_right;




		side_left = game["match_"+teamNum_left+"_side"];  // allies / axis / player_<playername>
		side_right = game["match_"+teamNum_right+"_side"];

		side_left_team = "";
		side_right_team = "";
		if (startsWith(side_left, "player_") || startsWith(side_right, "player_"))
		{
			side_left_team = "none"; 
			side_right_team = "none";
		}
		else if (side_left == "axis" || side_right == "allies")
		{
			side_left_team = game["axis"]; 	  // german
			side_right_team = game["allies"]; // american british russian
		}
		else // also if sides not set
		{
			side_left_team = game["allies"]; // american british russian
			side_right_team = game["axis"];	 // german
		} 


		// Team names
		self setClientCvarIfChanged("ui_matchinfo_team1_name", ui_name_left);
		self setClientCvarIfChanged("ui_matchinfo_team2_name", ui_name_right);

		// Score
		self setClientCvarIfChanged("ui_matchinfo_team1_score", ui_score_left);
		self setClientCvarIfChanged("ui_matchinfo_team2_score", ui_score_right);

		// Team (american, british, german, russian)
		self setClientCvarIfChanged("ui_matchinfo_team1_team", 	side_left_team);
		self setClientCvarIfChanged("ui_matchinfo_team2_team", 	side_right_team);

		if (self.pers["matchinfo_ingame_visible"])
		{
			self setClientCvarIfChanged("ui_matchinfo_ingame_team1_team", 	side_left_team);
			self setClientCvarIfChanged("ui_matchinfo_ingame_team2_team", 	side_right_team);
		}







		matchtimetext = "";
		halfInfo = "";
		if (game["match_totaltime_text"] != "")
		{
			matchtimetext = "Match time:   " + game["match_totaltime_text"];

			if (!game["readyup_first_run"] && !level.in_bash)
			{
				if (level.gametype == "sd")
				{
					if (!game["is_halftime"])
						halfInfo = "Rounds to half:   " + (level.halfround - game["round"]);
					else
						halfInfo = "First half score:   " + game["half_1_"+side_right+"_score"] + " : " + game["half_1_"+side_left+"_score"];
				}
				else
					if (!game["is_halftime"])
						halfInfo = "First half";
					else
						halfInfo = "Second half";
			}
		}


		// For players in readyup in match show match info
		if (matchIsActivated() && level.in_readyup && (self.pers["team"] != "streamer")) {
			info_players = "";
			if (teamNum_left == "team1")
				info_players = level.match_description_players1 + "^7 | " + level.match_description_players2;
			else
				info_players = level.match_description_players2 + "^7 | " + level.match_description_players1;

			info_warning = "";
			if (level.match_description_playersUnknown != "")
				info_warning += "^3Unknown players: " + level.match_description_playersUnknown + "^7\n";
			if (!self matchPlayerIsAllowed()) {
				if (self matchPlayerGetData("uuid") == "")
					info_warning += "^1You are not logged into the match!^7";
				else
					info_warning += "^1You are not assigned to any team!^7";
			}

			self setClientCvarIfChanged("ui_matchinfo_info", info_warning);
			self setClientCvarIfChanged("ui_matchinfo_round", info_players);
			self setClientCvarIfChanged("ui_matchinfo_state", ""); // not used in ingame
			self setClientCvarIfChanged("ui_matchinfo_halfInfo", "");
			self setClientCvarIfChanged("ui_matchinfo_matchtime", "");

		} else {
			self setClientCvarIfChanged("ui_matchinfo_info", "");
			self setClientCvarIfChanged("ui_matchinfo_round", game["match_round"]);
			self setClientCvarIfChanged("ui_matchinfo_state", game["match_state"]);
			self setClientCvarIfChanged("ui_matchinfo_halfInfo", halfInfo);
			self setClientCvarIfChanged("ui_matchinfo_matchtime", matchtimetext);
		}


		// Map history
		for (j = 1; j <= 3; j++)
		{
			map = getCvar("sv_map" + j + "_name");
			score1 = getCvar("sv_map" + j + "_score1");
			score2 = getCvar("sv_map" + j + "_score2");

			cvarData = "";
			if (map == "" || score1 == "" || score2 == "") {
				break;
			} else 
			{
				if (teamNum_left == "team2")
				{
					temp = score1;
					score1 = score2;
					score2 = temp;
				}
				score = "";
				if (score1 != "" && score2 != "")
					score = score1 + ":" + score2;

				cvarData = GetMapName(map) + "  " + score;
			}

			self setClientCvarIfChanged("ui_matchinfo_map" + j, cvarData);
			//self setClientCvarIfChanged("ui_matchinfo_map" + j, "Toujane  13:7");
		}
	}
	else
	{
		// Team names
		self setClientCvarIfChanged("ui_matchinfo_team1_name", "");
		self setClientCvarIfChanged("ui_matchinfo_team2_name", "");

		// Score
		self setClientCvarIfChanged("ui_matchinfo_team1_score", "");
		self setClientCvarIfChanged("ui_matchinfo_team2_score", "");

		self setClientCvarIfChanged("ui_matchinfo_team1_team", "");
		self setClientCvarIfChanged("ui_matchinfo_team2_team", "");
		self setClientCvarIfChanged("ui_matchinfo_ingame_team1_team", "");
		self setClientCvarIfChanged("ui_matchinfo_ingame_team2_team", "");

		self setClientCvarIfChanged("ui_matchinfo_info", "");

		// Round
		self setClientCvarIfChanged("ui_matchinfo_round", "");
		self setClientCvarIfChanged("ui_matchinfo_state", "");
		// Half
		self setClientCvarIfChanged("ui_matchinfo_halfInfo", "");
		// Map history
		for (j = 1; j <= 2; j++)
		{
			self setClientCvarIfChanged("ui_matchinfo_map" + j, "");
		}
		// Play time
		self setClientCvarIfChanged("ui_matchinfo_matchtime", "");
	}
}


UpdateCvarsForPlayers()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		wait level.frame;	// spread commands send to player to multiple frames
		player = players[i];
		if (!isDefined(player)) // Because we wait a frame, next frame player may be disconnected
			continue;

		player UpdatePlayerCvars();
	}
}


getTimeString()
{
	if (level.gametype == "sd")
	{
		if (level.matchstarted) {
			if (level.in_strattime) {
				return "STRAT " + formatTime(int(level.strat_time - 1 - int((gettime() - level.starttime)/1000)));
			} else if (level.roundended) {
				if (level.roundwinner == "allies")
					return "Allies Win";
				else if (level.roundwinner == "axis")
					return "Axis Win";
				else if (level.roundwinner == "draw")
					return "Draw";
			} else if (level.roundstarted) {
				if (level.bombplanted)
					return "BOMB " + formatTime(int(level.bombtimer - 1 - int((gettime() - level.bombtimerstart)/1000)));
				else
					return formatTime(level.strat_time + int((level.roundlength * 60) - int((gettime() - level.starttime)/1000)));
			}
		}
	}
	return "";
}



refresh(firstMapRestart)
{
	// Save previous map score to map history
	if (!isDefined(game["match_previous_map_processed"]))
	{
		// Process cvars from previous map - load it into history cvars
		processPreviousMapToHistory();

		// Run timer - untill 1min the same number of player must connect
		// Othervise considere this as team left and we need to reset match info
		playersLast = getCvar("sv_match_players");
		if (playersLast != "")
		{
			level thread waitForPlayerOrClear(int(playersLast));
			//setcvar("sv_match_players", "");
		}

		// Save previous time left
		if (getCvar("sv_match_totaltime") != "")
		{
			game["match_totaltime_prev"] = getCvarInt("sv_match_totaltime");

			// Via this cvar we determinate if match is set from previous map
			game["match_exists"] = true;
		}
		else
			game["match_totaltime_prev"] = 0;

		game["match_previous_map_processed"] = true;
	}


	// On first run, offset thread from ther thread and this also make sure game["allies_score"] is defined
	wait level.frame * 8; // offset thread from other threads


	// New map
	if (matchIsActivated() && firstMapRestart) {
		prepareMap();
	}


	thread playerNames();
		

	for (;;)
	{
		team1_players = [];
		team2_players = [];

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if (isDefined(player.pers["team"]) && (player.pers["team"] == "allies" || player.pers["team"] == "axis"))
			{	
				if (level.gametype != "dm") 
				{
					if (game["match_team1_side"] == player.pers["team"])
						team1_players[team1_players.size] = player;
					else if (game["match_team2_side"] == player.pers["team"])
						team2_players[team2_players.size] = player;

				} else {
					playerSideName = "player_" + (player getEntityNumber());
					if (playerSideName == game["match_team1_side"])
						team1_players[team1_players.size] = player;
					else if (playerSideName == game["match_team2_side"])
						team2_players[team2_players.size] = player;
					else {
						// If player name not match, try to find by team
						if (team1_players.size < 1)
							team1_players[team1_players.size] = player;
						else if (team2_players.size < 1)
							team2_players[team2_players.size] = player;
						else {
							// Too many players, split to both teams
							if (team1_players.size <= team2_players.size)
								team1_players[team1_players.size] = player;
							else
								team2_players[team2_players.size] = player;
						}
					}
				}		
			}
		}


		/***********************************************************************************************************************************
		*** Determinate team names, side, score
		/***********************************************************************************************************************************/
		// Full team info
		if (game["scr_matchinfo"] == 2)
		{
			// Keep updating data about team names, played maps,.. untill match start
			// Called in every first readyup on every map
			if (!game["match_teams_set"])
			{
				// If match exists, load teams from cvars. Othervise load team by first connected player
				if (matchIsActivated())
					determineTeamByMatchData();

				else if (game["match_exists"])
					determineTeamByHistoryCvars();
				else
					determineTeamByFirstConnected();

				// for all players change team name in scoreboard
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					players[i] updateScoreboardTeamNames();
				}
			}

			// If game started and teams was not recognised, reset team info and do it it from scratch
			// This may happend if player in both teams gets renamed
			else
			{
				if (game["match_team1_side"] == "" || game["match_team2_side"] == "")
				{
					resetAll(); // reset map history and select team again
				}
			}

			// Main score update
			game["match_team1_score"] = "?";
			game["match_team2_score"] = "?";
			if (level.gametype != "dm") {
				if (game["match_team1_side"] != "") game["match_team1_score"] = game[game["match_team1_side"] + "_score"];
				if (game["match_team2_side"] != "") game["match_team2_score"] = game[game["match_team2_side"] + "_score"];
			} else {
				if (team1_players.size <= 1 && team2_players.size <= 1) {
					if (game["match_team1_side"] != "" && team1_players.size == 1) game["match_team1_score"] = team1_players[0].score;
					if (game["match_team2_side"] != "" && team2_players.size == 1) game["match_team2_score"] = team2_players[0].score;
				}
			}
		}

		else if (game["scr_matchinfo"] == 1) // basic info (no team names)
		{
			if (!game["match_teams_set"])
			{
				game["match_team1_name"] = "Team 1";
				game["match_team2_name"] = "Team 2";

				game["match_team1_side"] = "allies";
				game["match_team2_side"] = "axis";
			}

			game["match_team1_score"] = game[game["match_team1_side"] + "_score"];
			game["match_team2_score"] = game[game["match_team2_side"] + "_score"];
		}



		/***********************************************************************************************************************************
		*** Determinate match time, status, ...
		/***********************************************************************************************************************************/

		// Total time measuring
		if (game["match_totaltime_prev"] == 0 && !game["match_teams_set"])
			game["match_totaltime"] = 0;
		else
		{
			if (!isDefined(game["match_starttime"]))
				game["match_starttime"] = getTime();

			game["match_totaltime"] = game["match_totaltime_prev"] + (getTime() - game["match_starttime"]);
		}

		if (game["match_exists"])
			setCvarIfChanged("sv_match_totaltime", game["match_totaltime"]);


		elapsedTime = 0; // in seconds
		if (isDefined(game["match_starttime"]))
			elapsedTime = int((getTime() - game["match_starttime"]) / 1000);


		// Readyup is over, teams are set
		if (game["match_teams_set"])
		{
			// Save team name that will be used to load on next map
			setCvarIfChanged("sv_match_team1", game["match_team1_name"]);
			setCvarIfChanged("sv_match_team2", game["match_team2_name"]);

			// Update number of players in second minute (due to missing player)
			// If number of players change, matchinfo is reseted next map due to different number of players
			savedPlayers = GetCvarInt("sv_match_players"); // GetCvarInt return 0 if cvar is empty string
			players = getentarray("player", "classname");

			if (savedPlayers == 0 || ((elapsedTime >= 120 && elapsedTime <= 130) && players.size > savedPlayers))
				setCvarIfChanged("sv_match_players", players.size);
		}



		/***********************************************************************************************************************************
		*** Update history cvars to be able load info in next map
		/***********************************************************************************************************************************/
		totalScoreElapsed = false;
		if (level.gametype != "dm") {
			totalScoreElapsed = (game["allies_score"] + game["axis_score"]) > 1;
		} else {
			totalScoreElapsed = true;
		}

		// Save data from this map for next map
		if ((game["match_teams_set"] || game["scr_matchinfo"] == 1) && elapsedTime > (3*60) && totalScoreElapsed) // save map into hostory after 3 mins
		{
			setCvarIfChanged("sv_map_name", level.mapname);
			setCvarIfChanged("sv_map_score1", game["match_team1_score"]);
			setCvarIfChanged("sv_map_score2", game["match_team2_score"]);
		}




		// Total time
		if (game["match_totaltime"] > 0)
		{
			game["match_totaltime_text"] = formatTime(int(game["match_totaltime"] / 1000));
		}
		else
		{
			game["match_totaltime_text"] = "";
		}




		// Round info
		if (level.gametype == "sd")
		{
			game["match_round"] = "Round " + game["round"];

			if (level.matchround > 0)
				game["match_round"] += " | MR" + (level.matchround / 2);

			if (game["overtime_active"])
				game["match_round"] += " OT"; // overtime
		}
		else
			game["match_round"] = "";


		// State of match
		if (level.in_timeout)
			game["match_state"] = "Timeout";
		else if (level.in_readyup)
			game["match_state"] = "Ready-up";
		else if (level.in_bash)
			game["match_state"] = "Bash";
		else {
			game["match_state"] = getTimeString();
		}


		// Public info
		match_info = ""; 
		// Toujane 0:0  Ready-up
		// Toujane 3:3  Round 7 / 24
		// Toujane 13:7  >  Burgundy 0:0  Round 0 / 24  Ready-up
		// Toujane 13:7  >  Burgundy 6:0  Round 7 / 24

		if (level.gametype == "sd")
		{
			match_info = game["match_round"] + " ";
		}
		if (level.in_timeout)
			match_info += "Timeout";
		else if (level.in_readyup)
			match_info += "Ready-up";
		else if (level.in_bash)
			match_info += "Bash";
		else {
			// TODO
		}


		// Global server cvars visible via HLSW
		if (game["match_team1_name"] != "") 	setCvarIfChanged("_match_team1", game["match_team1_name"]);
		else					setCvarIfChanged("_match_team1", "-");
		if (game["match_team2_name"] != "") 	setCvarIfChanged("_match_team2", game["match_team2_name"]);
		else					setCvarIfChanged("_match_team2", "-");

		if (getcvar("sv_map_score1") != "") 	setCvarIfChanged("_match_score", getcvar("sv_map_score1") + ":" + getcvar("sv_map_score2"));
		else					setCvarIfChanged("_match_score", "-");

		if (match_info != "") 		setCvarIfChanged("_match_info", match_info);
		else					setCvarIfChanged("_match_info", "-");


		thread UpdateCvarsForPlayers();


		wait level.fps_multiplier * 0.5; // update every 0.5 seconds due to timer
	}


}


playerNames()
{
	if (!matchIsActivated())
		return;

	for (;;)
	{
		wait level.fps_multiplier * 1;

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			// Player may disconnect due to wait
			if (!isDefined(player)) continue;

			// Handle rename
			if (isDefined(player.matchinfo_lastName) && player.matchinfo_lastName != player.name)
			{
				level thread generateMatchDescriptionDebounced();
			}
			player.matchinfo_lastName = player.name;

			// Check time of last warning
			if (getTime() - player.pers["matchinfo_nickWarningLastTime"] < 8000)
				continue; // 8 seconds between warnings

			if ((player.pers["team"] == "allies" || player.pers["team"] == "axis") && level.in_readyup)
			{
				// If match is activated, check if the name contains player name
				if (player matchPlayerIsAllowed()) {
					match_name = player matchPlayerGetData("name");
					player_name = removeColorsFromString(player.name);

					if (contains(player_name, match_name) == false)
					{
						player iprintlnbold(" ");
						player iprintlnbold("^3Please rename yourself");
						player iprintlnbold("^3Your nickname must contain your player name: ^7'" + match_name + "'");
						player iprintlnbold(" ");
						player iprintlnbold(" ");

						player.pers["matchinfo_nickWarningLastTime"] = getTime();
					}

				}
			}
			
		}	
	}
}



generateMatchDescription()
{
	level.match_description = "";
	level.match_description_players1 = "";
	level.match_description_players2 = "";
	level.match_description_playersUnknown = "";
	level.match_missingPlayers = 0;
	level.match_mixedPlayers = 0;
	level.match_unjoinedPlayers = 0;

	level.match_players_names = "";
	level.match_players_nicknames = "";
	level.match_players_side = "";
	level.match_players_status = "";

	if (!matchIsActivated()) {
		return;
	}

	match_team1_name = matchGetData("team1_name");
	match_team2_name = matchGetData("team2_name");
	match_players1_uuid_arr = matchGetData("team1_player_uuids");
	match_players2_uuid_arr = matchGetData("team2_player_uuids");
	match_players1_name_arr = matchGetData("team1_player_names");
	match_players2_name_arr = matchGetData("team2_player_names");
	match_players1_arr_found = [];
	match_players2_arr_found = [];
	match_maps_arr = matchGetData("maps"); // might be empty
	match_minPlayerCount = int(matchGetData("players_count"));
	match_format = matchGetData("format"); // BO1, BO3, BO5

	factual_team1_allies = 0;
	factual_team1_axis = 0;
	factual_team1_otherSide = 0;
	factual_team2_allies = 0;
	factual_team2_axis = 0;
	factual_team2_otherSide = 0;

	strPlayers1 = "";
	strPlayers2 = "";
	strPlayersUnknown = "";

	players_team1 = [];
	players_team2 = [];
	players_unknown = [];

	// Find player from connected players
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++) {
		player = players[i];

		// Count factual players in teams
		teamNum = player matchPlayerGetData("team"); // team1 / team2

		if (teamNum == "team1" || (game["match_team1_side"] == player.pers["team"] && teamNum != "team2")) // include also unassigned players by checking the side assigned by match system
		{
			if (player.pers["team"] == "allies")
				factual_team1_allies++;
			else if (player.pers["team"] == "axis")
				factual_team1_axis++;
			else
				factual_team1_otherSide++;
		}
		else if (teamNum == "team2" || (game["match_team2_side"] == player.pers["team"] && teamNum != "team1")) // include also unassigned players by checking the side assigned by match system
		{
			if (player.pers["team"] == "allies")
				factual_team2_allies++;
			else if (player.pers["team"] == "axis")
				factual_team2_axis++;
			else
				factual_team2_otherSide++;
		}

		player.pers["matchinfo_error"] = "";
		player.pers["matchinfo_color"] = "";

		// Create colored strings of players in teams and their status
		player_uuid = player matchPlayerGetData("uuid");
		found = false;
		if (player_uuid != "") {
			for (j = 0; j < match_players1_uuid_arr.size; j++) {
				if (match_players1_uuid_arr[j] == player_uuid && !isDefined(match_players1_arr_found[j])) {
					if (strPlayers1 != "")
						strPlayers1 += ", ";

					player.pers["matchinfo_error"] = "Player has not joined a side yet";
					player.pers["matchinfo_color"] = "^5"; // cyan, team not selected yet
					if ((game["match_team1_side"] == "allies" || game["match_team1_side"] == "axis") && (player.pers["team"] == "allies" || player.pers["team"] == "axis"))
					{
						if (game["match_team1_side"] != player.pers["team"]) {
							player.pers["matchinfo_error"] = "Player is on the wrong side (" + player.pers["team"] + " instead of " + game["match_team1_side"] + ")";
							player.pers["matchinfo_color"] = "^1"; // red, wrong side
						} else {
							player.pers["matchinfo_error"] = "";
							player.pers["matchinfo_color"] = "^2"; // green, correct
						}
					} else if (startsWith(game["match_team1_side"], "player_") && (player.pers["team"] == "allies" || player.pers["team"] == "axis")) {
						if (game["match_team1_side"] != "player_" + (player getEntityNumber())) {
							player.pers["matchinfo_error"] = "Player is not in the correct team";
							player.pers["matchinfo_color"] = "^1"; // red, wrong side
						} else {
							player.pers["matchinfo_error"] = "";
							player.pers["matchinfo_color"] = "^2"; // green, correct
						}
					}
					
					strPlayers1 += player.pers["matchinfo_color"] + removeColorsFromString(match_players1_name_arr[j]) + "^7";
					match_players1_arr_found[j] = true;
					players_team1[players_team1.size] = player;
					found = true;
					break;
				}
			}
			for (j = 0; !found && j < match_players2_uuid_arr.size; j++) {
				if (match_players2_uuid_arr[j] == player_uuid && !isDefined(match_players2_arr_found[j])) {
					if (strPlayers2 != "")
						strPlayers2 += ", ";

					player.pers["matchinfo_error"] = "Player has not joined a side yet";
					player.pers["matchinfo_color"] = "^5"; // cyan, team not selected yet
					if ((game["match_team2_side"] == "allies" || game["match_team2_side"] == "axis") && (player.pers["team"] == "allies" || player.pers["team"] == "axis"))
					{
						if (game["match_team2_side"] != player.pers["team"]) {
							player.pers["matchinfo_error"] = "Player is on the wrong side (" + player.pers["team"] + " instead of " + game["match_team2_side"] + ")";
							player.pers["matchinfo_color"] = "^1"; // red, wrong side
						} else {
							player.pers["matchinfo_error"] = "";
							player.pers["matchinfo_color"] = "^2"; // green, correct
						}
					} else if (startsWith(game["match_team2_side"], "player_") && (player.pers["team"] == "allies" || player.pers["team"] == "axis")) { // DM
						if (game["match_team2_side"] != "player_" + (player getEntityNumber())) {
							player.pers["matchinfo_error"] = "Player is not in the correct team";
							player.pers["matchinfo_color"] = "^1"; // red, wrong side
						} else {
							player.pers["matchinfo_error"] = "";
							player.pers["matchinfo_color"] = "^2"; // green, correct
						}
					}

					strPlayers2 += player.pers["matchinfo_color"] + removeColorsFromString(match_players2_name_arr[j]) + "^7";
					match_players2_arr_found[j] = true;
					players_team2[players_team2.size] = player;
					found = true;
					break;
				}
			}
		}

		if (!found && player.pers["team"] != "streamer") {
			if (strPlayersUnknown != "")
				strPlayersUnknown += ", ";
			strPlayersUnknown += removeColorsFromString(player.name);
		}

		if (!found) {
			players_unknown[players_unknown.size] = player;
			player.pers["matchinfo_error"] = "Player does not belong to any team / match";
			player.pers["matchinfo_color"] = "^3"; // yellow, unknown player
		}
	}


	// Add line to player list
	level.match_players_names += 		"Match player name:" + "\n\n";
	level.match_players_nicknames += 	"Nick:" + "\n\n";
	level.match_players_side += 		"Side:" + "\n\n";
	level.match_players_status += 		"Status:" + "\n\n";

	for (j = 0; j < players_team1.size; j++) {
		player = players_team1[j];

		// Add line to player list
		level.match_players_names += 		"^7" + player.pers["matchinfo_color"] + player matchPlayerGetData("name") + "\n";
		level.match_players_nicknames += 	"^7" + player.pers["matchinfo_color"] + removeColorsFromString(player.name) + "\n";
		level.match_players_side += 		"^7" + player.pers["matchinfo_color"] + player.pers["team"] + "\n";
		level.match_players_status += 		"^7" + player.pers["matchinfo_color"] + iff(player.pers["matchinfo_error"] == "", "Ok", player.pers["matchinfo_error"]) + "\n";
	}
	// Loop match players and find not connected players
	for (j = 0; j < match_players1_name_arr.size; j++) {
		if (!isDefined(match_players1_arr_found[j])) {
			if (strPlayers1 != "")
				strPlayers1 += ", ";
			strPlayers1 += "^7" + match_players1_name_arr[j] + "^7";

			// Add line to player list
			level.match_players_names += 		"^7" + match_players1_name_arr[j] + "\n";
			level.match_players_nicknames += 	"^7" + "-" + "\n";
			level.match_players_side += 		"^7" + "-" + "\n";
			level.match_players_status += 		"^7" + "Not connected" + "\n";
		}
	}

	level.match_players_names += 		"\n";
	level.match_players_nicknames += 	"\n";
	level.match_players_side += 		"\n";
	level.match_players_status += 		"\n";

	for (j = 0; j < players_team2.size; j++) {
		player = players_team2[j];

		// Add line to player list
		level.match_players_names += 		"^7" + player.pers["matchinfo_color"] + player matchPlayerGetData("name") + "\n";
		level.match_players_nicknames += 	"^7" + player.pers["matchinfo_color"] + removeColorsFromString(player.name) + "\n";
		level.match_players_side += 		"^7" + player.pers["matchinfo_color"] + player.pers["team"] + "\n";
		level.match_players_status += 		"^7" + player.pers["matchinfo_color"] + iff(player.pers["matchinfo_error"] == "", "Ok", player.pers["matchinfo_error"]) + "\n";
	}
	// Loop match players and find not connected players
	for (j = 0; j < match_players2_name_arr.size; j++) {
		if (!isDefined(match_players2_arr_found[j])) {
			if (strPlayers2 != "")
				strPlayers2 += ", ";
			strPlayers2 += "^7" + match_players2_name_arr[j] + "^7";

			// Add line to player list
			level.match_players_names += 		"^7" + match_players2_name_arr[j] + "\n";
			level.match_players_nicknames += 	"^7" + "-" + "\n";
			level.match_players_side += 		"^7" + "-" + "\n";
			level.match_players_status += 		"^7" + "Not connected" + "\n";
		}
	}

	level.match_players_names += 		"\n";
	level.match_players_nicknames += 	"\n";
	level.match_players_side += 		"\n";
	level.match_players_status += 		"\n";

	for (j = 0; j < players_unknown.size; j++) {
		player = players_unknown[j];

		// Add line to player list
		level.match_players_names += 		"^7" + player.pers["matchinfo_color"] + "-" + "\n";
		level.match_players_nicknames += 	"^7" + player.pers["matchinfo_color"] + removeColorsFromString(player.name) + "\n";
		level.match_players_side += 		"^7" + player.pers["matchinfo_color"] + player.pers["team"] + "\n";
		level.match_players_status += 		"^7" + player.pers["matchinfo_color"] + player.pers["matchinfo_error"] + "\n";
	}


	// Check right number of players in teams, allow unknown players and allow 1 missing player
	team1_count_final = factual_team1_allies + factual_team1_axis; // match players + unknown players in team allies + axis
	team2_count_final = factual_team2_allies + factual_team2_axis;
	team1_count_total = factual_team1_allies + factual_team1_axis + factual_team1_otherSide; // match players + unknown players + logged players in other side (spectator)
	team2_count_total = factual_team2_allies + factual_team2_axis + factual_team2_otherSide;

	//iprintln("## team1 | allies=" + factual_team1_allies + " axis=" + factual_team1_axis + " otherSide=" + factual_team1_otherSide);
	//iprintln("## team2 | allies=" + factual_team2_allies + " axis=" + factual_team2_axis + " otherSide=" + factual_team2_otherSide);

	minPlayerCount = match_minPlayerCount;

	if (minPlayerCount > 0) { // 0 means no limit
		if (team1_count_total < minPlayerCount || team2_count_total < minPlayerCount)
		{
			// Count missing players
			level.match_missingPlayers = 0;
			if (team1_count_total < minPlayerCount)
				level.match_missingPlayers += (minPlayerCount - team1_count_total);
			if (team2_count_total < minPlayerCount)
				level.match_missingPlayers += (minPlayerCount - team2_count_total);

			//iprintln("## level.match_missingPlayers = " + level.match_missingPlayers);
		}

		if (team1_count_final < minPlayerCount || team2_count_final < minPlayerCount)
		{
			// Count missing players
			level.match_unjoinedPlayers = 0;
			if (team1_count_final < minPlayerCount)
				level.match_unjoinedPlayers += factual_team1_otherSide;
			if (team2_count_final < minPlayerCount)
				level.match_unjoinedPlayers += factual_team2_otherSide;

			//iprintln("## level.match_unjoinedPlayers = " + level.match_unjoinedPlayers);
		}
	}




	// If we have both teams with mixed players, disable readyup
	/*if ((factual_team1_allies > 0 && factual_team1_axis > 0) || (factual_team2_allies > 0 && factual_team2_axis > 0))
	{
		// Count mixed players
		level.match_mixedPlayers = 0;
		// Only count the minority side in each mixed team without using min/max
		if (factual_team1_allies > 0 && factual_team1_axis > 0)
		{
			if (factual_team1_allies < factual_team1_axis)
				level.match_mixedPlayers += factual_team1_allies;
			else
				level.match_mixedPlayers += factual_team1_axis;
		}
		if (factual_team2_allies > 0 && factual_team2_axis > 0)
		{
			if (factual_team2_allies < factual_team2_axis)
				level.match_mixedPlayers += factual_team2_allies;
			else
				level.match_mixedPlayers += factual_team2_axis;
		}

		//iprintln("## level.match_mixedPlayers = " + level.match_mixedPlayers);
	}*/

	// Check if side has players from both sides and count how many
	if ((game["match_team1_side"] == "allies" || game["match_team1_side"] == "axis") && (game["match_team2_side"] == "allies" || game["match_team2_side"] == "axis"))
	{
		if (factual_team1_allies > 0 && factual_team2_allies > 0) { // allies has players from both teams	
			// Determine which team is on wrong side
			if (game["match_team1_side"] == "allies") {
				level.match_mixedPlayers += factual_team2_allies; // team1 is allies, team2 is axis, count players in team2 on wrong side
			} else {
				level.match_mixedPlayers += factual_team1_allies; // team1 is axis, team2 is allies, count players in team1 on wrong side
			}		
		}
		if (factual_team1_axis > 0 && factual_team2_axis > 0) { // axis has players from both teams
			// Determine which team is on wrong side
			if (game["match_team1_side"] == "axis") {
				level.match_mixedPlayers += factual_team2_axis; // team1 is axis, team2 is allies, count players in team2 on wrong side
			} else {
				level.match_mixedPlayers += factual_team1_axis; // team1 is allies, team2 is axis, count players in team1 on wrong side
			}
		}
	}


	level.match_description_players1 = strPlayers1;
	level.match_description_players2 = strPlayers2;
	level.match_description_playersUnknown = strPlayersUnknown;





	level.match_description = 
		"Match: [^8" + removeColorsFromString(matchGetData("team1_name")) + "^7]  vs  [^9" + removeColorsFromString(matchGetData("team2_name")) + "^7]\n";// +
		//"Team 1: " + strPlayers1 + "^7\n" +
		//"Team 2: " + strPlayers2 + "^7\n";

	if (strPlayersUnknown != "")
		level.match_description += "^3Unknown players: " + strPlayersUnknown + "^7\n";

    // Format:  BO1 | 5v5
	level.match_description += "Format:  " + match_format + " | ";
	if (match_minPlayerCount > 0)
		level.match_description += match_minPlayerCount + "v" + match_minPlayerCount;
	else
		level.match_description += "no player limit";
	level.match_description += "\n";

	if (match_maps_arr.size > 0) {
		level.match_description += "Maps:  ";
		for (j = 0; j < match_maps_arr.size; j++) {
			if (j != 0)
				level.match_description += ", ";
			level.match_description += GetMapName(match_maps_arr[j]);
		}
		level.match_description += "\n";
	}

	if (level.match_missingPlayers > 0)
		level.match_description += "^1There are " + level.match_missingPlayers + " missing players!^7\n";
	else if (level.match_unjoinedPlayers > 0)
		level.match_description += "^1There are " + level.match_unjoinedPlayers + " unjoined players!^7\n";
	else if (level.match_mixedPlayers > 0)
		level.match_description += "^1There are " + level.match_mixedPlayers + " mixed players!^7\n";

}