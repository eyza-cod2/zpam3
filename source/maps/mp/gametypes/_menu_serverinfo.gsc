#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onStartGameType", ::onStartGameType);
	addEventListener("onCvarChanged",   ::onCvarChanged);
	addEventListener("onConnected",     ::onConnected);
	addEventListener("onDisconnect",    ::onDisconnect);

	registerCvarEx("I", "scr_motd", "STRING", "Welcome. This server is running zPAM4.00");	// ZPAM_RENAME

	level.motd = "";
	level.serverversion = "";
	level.serverinfo_left1 = "";
	level.serverinfo_left2 = "";
	level.serverinfo_right1 = "";
	level.serverinfo_right2 = "";
	level.match_description = "";
}

// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	waittillframeend; // wait till game variables are set
	generateGlobalServerInfo();
}

onConnected()
{
	self endon("disconnect");

	if (matchIsActivated()) {

		// Prevent calling multiple times in one frame
		level notify("menu_serverinfo_onConnected");
		level endon("menu_serverinfo_onConnected");
		waittillframeend;

		generateMatchDescription(); // regenerate match description

		updateCvarsForAllPlayers();
	}
}

onDisconnect() 
{
	if (matchIsActivated()) {

		// Prevent calling multiple times in one frame
		level notify("menu_serverinfo_onDisconnect");
		level endon("menu_serverinfo_onDisconnect");
		waittillframeend; // wait untill player is removed

		generateMatchDescription(); // regenerate match description

		updateCvarsForAllPlayers();
	}
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	// Server info update
	if (!isRegisterTime && !game["firstInit"] && !isDefined(game["cvars"][cvar]["inQuiet"]) && cvar != "pam_mode_custom")
	{
		generateGlobalServerInfo(); // regenerate server info

		updateCvarsForAllPlayers();
	}

	switch(cvar)
	{
		case "scr_motd": level.scr_motd = value; return true;
	}
	return false;
}


// Called from menu wen serverinfo menu is opened
updateServerInfo()
{
	self updateCvarsForPlayer();
}

updateCvarsForPlayer()
{
	motd = level.motd;

	if (level.match_description != "")
		motd = level.match_description + "\n\n" + motd;

	self setClientCvarIfChanged("ui_motd", motd);
	self setClientCvarIfChanged("ui_serverversion", level.serverversion);

	// These are set from gametype
	self setClientCvarIfChanged("ui_serverinfo_left1", level.serverinfo_left1);
	self setClientCvarIfChanged("ui_serverinfo_left2", level.serverinfo_left2);

	// These are global
	self setClientCvarIfChanged("ui_serverinfo_right1", level.serverinfo_right1);
	self setClientCvarIfChanged("ui_serverinfo_right2", level.serverinfo_right2);
}

updateCvarsForAllPlayers()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++) {
		players[i] updateCvarsForPlayer();
	}
}


generateGlobalServerInfo()
{
	// Generate motd
	motd = level.scr_motd;
	motd_final = "";
	skipNextChar = false;
	for (i=0; i < motd.size; i++)
	{
		if (skipNextChar)
		{
			skipNextChar = false;
			continue;
		}

		if (motd[i] == "\\" && i < motd.size-1 && motd[i+1] == "n")
		{
			skipNextChar = true;
			motd_final += "\n";
		}
		else
			motd_final += "" + motd[i];
	}
	motd = motd_final;

	// Replace zPAMx.xx pattern with zPAM4.00
	motd_final = "";
	i = 0;
	while (i < motd.size)
	{
		// Look for "zPAM" followed by a digit, dot, digit, digit
		if (
			i + 6 < motd.size &&
			motd[i] == "z" &&
			motd[i+1] == "P" &&
			motd[i+2] == "A" &&
			motd[i+3] == "M" &&
			isDigit(motd[i+4]) &&
			motd[i+5] == "." &&
			isDigit(motd[i+6]) &&
			isDigit(motd[i+7])
		)
		{
			motd_final += "zPAM4.00"; // ZPAM_RENAME
			i += 8;
			continue;
		}
		motd_final += motd[i];
		i++;
	}
	level.motd = motd_final;



	level.serverversion = getCvar("version") + "    "; // "CoD2 MP 1.3 build pc_1.3_1_1 Mon May 01 2006 05:05:43PM win-x86"

	sys_cpuGHz = getCvarFloat("sys_cpuGHz"); // "2.59199"
	if (sys_cpuGHz != 0)
		level.serverversion += " (CPU " + format_fractional(sys_cpuGHz, 1, 2) + " GHz)";

	sys_gpu = getcvar("sys_gpu"); // "Intel(R) UHD Graphics"
	if (sys_gpu != "")
		level.serverversion += " (GPU " + sys_gpu + ")";

	level.serverversion += " (" + getcvarint("sv_maxclients") + " slots)"; // (14 slots)

	if (contains(level.serverversion, "win"))
		level.serverversion += " (Windows server)";
	else if (contains(level.serverversion, "linux"))
		level.serverversion += " (Linux server)";




	title = "PAM mode:\n";
	value = level.pam_mode + "\n";

	title +="Fast reload fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_fast_reload_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_fast_reload_fix) 	value += changed+"Enabled ^9Disabled^7" + "\n";
	else				value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="Consistent shotgun:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_shotgun_consistent") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_shotgun_consistent) 	value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="Hand hitbox fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_hitbox_hand_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_hitbox_hand_fix) 		value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";


	title +="Torso hitbox fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_hitbox_torso_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_hitbox_torso_fix) 	value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="Prone peek fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_prone_peek_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_prone_peek_fix) 		value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="MG clip fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_mg_peek_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_mg_peek_fix) 		value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="Antilag:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("g_antilag") && !game["is_public_mode"]) changed = "^3";
	if (level.antilag) 			value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title += "\n";
	value += "\n";


	if (game["is_public_mode"] == false)
	{
		str = "";
		changedCvars = maps\mp\gametypes\global\cvar_system::getChangedCvarsString();
		if (changedCvars.size > 0)
		{
			for(i = 0; i < changedCvars.size; i++)
			{
				switch(changedCvars[i])
				{
					case "scr_fast_reload_fix":
					case "scr_shotgun_consistent":
					case "scr_hitbox_hand_fix":
					case "scr_hitbox_torso_fix":
					case "scr_prone_peek_fix":
					case "scr_mg_peek_fix":
					case "g_antilag":
						continue;
				}

				str += changedCvars[i]+"\n";
			}
		}
		if (str != "")
		{
			title += "^3Changed cvars:"+"\n";
			value += str;
		}
	}

	level.serverinfo_right1 = title;
	level.serverinfo_right2 = value;
}


generateMatchDescription()
{
	level.match_description = "";

	if (!matchIsActivated())
		return;

	match_team1_name = matchGetData("team1_name");
	match_team2_name = matchGetData("team2_name");
	match_players1_uuid_arr = matchGetData("team1_player_uuids");
	match_players2_uuid_arr = matchGetData("team2_player_uuids");
	match_players1_name_arr = matchGetData("team1_player_names");
	match_players2_name_arr = matchGetData("team2_player_names");
	match_players1_arr_found = [];
	match_players2_arr_found = [];
	match_maps_arr = matchGetData("maps");

	players1 = "";
	players2 = "";
	playersUnknown = "";

	// Find player from connected players
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++) {
		player = players[i];

		player_uuid = player matchPlayerGetData("uuid");

		//printLn("Player: " + player.name + " UUID: " + player_uuid);
		
		found = false;
		if (player_uuid != "") {
			for (j = 0; j < match_players1_uuid_arr.size; j++) {
				if (match_players1_uuid_arr[j] == player_uuid && !isDefined(match_players1_arr_found[j])) {
					if (players1 != "")
						players1 += ", ";
					players1 += "^2" + removeColorsFromString(match_players1_name_arr[j]) + "^7";
					match_players1_arr_found[j] = true;
					found = true;
					break;
				}
			}
			for (j = 0; !found && j < match_players2_uuid_arr.size; j++) {
				if (match_players2_uuid_arr[j] == player_uuid && !isDefined(match_players2_arr_found[j])) {
					if (players2 != "")
						players2 += ", ";
					players2 += "^2" + removeColorsFromString(match_players2_name_arr[j]) + "^7";
					match_players2_arr_found[j] = true;
					found = true;
					break;
				}
			}
		}

		if (!found) {
			if (playersUnknown != "")
				playersUnknown += ", ";
			playersUnknown += player.name;
		}
	}

	// Loop match players and find not connected players
	for (j = 0; j < match_players1_name_arr.size; j++) {
		if (!isDefined(match_players1_arr_found[j])) {
			if (players1 != "")
				players1 += ", ";
			players1 += "^7" + match_players1_name_arr[j] + "^7";
		}
	}
	for (j = 0; j < match_players2_name_arr.size; j++) {
		if (!isDefined(match_players2_arr_found[j])) {
			if (players2 != "")
				players2 += ", ";
			players2 += "^7" + match_players2_name_arr[j] + "^7";
		}
	}


	level.match_description = 
		"Match | " + getCvar("sv_hostname") + "^7\n" +
		"Team 1:  [^8" + removeColorsFromString(matchGetData("team1_name")) + "^7]:  " + players1 + "^7\n" +
		"Team 2:  [^9" + removeColorsFromString(matchGetData("team2_name")) + "^7]:  " + players2 + "^7\n";

	if (playersUnknown != "")
		level.match_description += "^3Unknown players: " + playersUnknown + "^7\n";

	level.match_description += "Maps:  ";
	for (j = 0; j < match_maps_arr.size; j++) {
		if (j != 0)
			level.match_description += ", ";
		level.match_description += match_maps_arr[j];
	}

}