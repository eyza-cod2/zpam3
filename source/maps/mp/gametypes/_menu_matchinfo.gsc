#include maps\mp\gametypes\_callbacksetup;

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
	// Team names
	level.teamname_allies = "";
	level.teamname_axis = "";
	level.teamname_all = "";

	addEventListener("onConnected",     ::onConnected);

	if (!level.scr_matchinfo)
		return;


	addEventListener("onConnectedAll",  ::onConnectedAll);
	addEventListener("onMenuResponse",  ::onMenuResponse);


	if (!isDefined(game["match_teams_set"]))
		game["match_teams_set"] = false;

	// Once match start, save teams
	if (!level.in_readyup)
		game["match_teams_set"] = true;

	level thread refresh();
}


onConnected()
{
	if (level.scr_matchinfo)
	{
		self setClientCvar("ui_show_matchinfo", "1");

		if (!isDefined(self.pers["timeConnected"]))
		{
			self.pers["timeConnected"] = getTime();

			// Update all team name only once
			waittillframeend;
			level.teamname_all = getTeamName("");
		}
	}
	else
	{
		wait level.fps_multiplier * 1;
		self setClientCvar("ui_show_matchinfo", "0");
	}
}

onConnectedAll()
{
	waittillframeend;

	generateTeamNames();
	level.teamname_all = getTeamName("");
}

generateTeamNames()
{
	// Generate team names according to player names
    level.teamname_allies = getTeamName("allies");
	level.teamname_axis = getTeamName("axis");

	level.teamname["allies"] = level.teamname_allies;
	level.teamname["axis"] = level.teamname_axis;
}


processPreviousMapToHistory()
{
	prevMap_map = getCvar("sv_map_name");

	// If prev map is defined, it means match started and this score needs to be saved
	if (prevMap_map != "")
	{
		// Move 1. saved map to 2. (removing the second)
		setCvar("sv_map2_name", 	getCvar("sv_map1_name"));
		setCvar("sv_map2_team1", 	getCvar("sv_map1_team1"));
		setCvar("sv_map2_team2", 	getCvar("sv_map1_team2"));
		setCvar("sv_map2_score", 	getCvar("sv_map1_score"));

		// Save previous map to history at first location
		setCvar("sv_map1_name", prevMap_map);
		setCvar("sv_map1_team1", getCvar("sv_map_team1"));
		setCvar("sv_map1_team2", getCvar("sv_map_team2"));
		setCvar("sv_map1_score", getCvar("sv_map_score"));

		// remove prev map info
		setCvar("sv_map_name", "");
		setCvar("sv_map_team1", "");
		setCvar("sv_map_team2", "");
		setCvar("sv_map_score", "");
	}
}


determineTeamByHistoryCvars()
{
	// Fill team names
	game["match_team1_name"] = getCvar("sv_map1_team1");
	game["match_team2_name"] = getCvar("sv_map1_team2");

	// Find that side that team is now
	// Atleast one team must stay unrenamed or this will not work
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
	else
	{
		game["match_team1_side"] = "";
		game["match_team2_side"] = "";
	}
}

determineTeamByFirstConnected()
{
	// Find first team by looking wich player connect
	players = getentarray("player", "classname");
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


	// Handle empty teams
	if (teamname1 == "" && teamname2 == "")
	{
		teamname1 = level.teamname_all;
		teamname2 = "?";
	}
	else if (teamname1 == "")
		teamname1 = "?";
	else if (teamname2 == "")
		teamname2 = "?";


	game["match_team1_name"] = teamname1;
	game["match_team1_side"] = team1;
	game["match_team2_name"] = teamname2;
	game["match_team2_side"] = team2;
}

resetAll()
{
	setCvar("sv_map_name", "");
	setCvar("sv_map_team1", "");
	setCvar("sv_map_team2", "");
	setCvar("sv_map_score", "");

	setCvar("sv_map_timeleft", "");
	setCvar("sv_map_players", "");

	game["match_starttime"] = undefined;
	game["match_timeprev"] = 0;

	resetTeamInfo();
}

resetTeamInfo()
{
	// Reset cvars
	for (i = 1; i <= 2; i++)
	{
		setCvar("sv_map" + i + "_name", 	"");
		setCvar("sv_map" + i + "_team1", 	"");
		setCvar("sv_map" + i + "_team2", 	"");
		setCvar("sv_map" + i + "_score", 	"");
	}

	game["match_team1_name"] = "";
	game["match_team1_score"] = "";
	game["match_team2_name"] = "";
	game["match_team2_score"] = "";

	game["match_team1_half1"] = undefined;
	game["match_team2_half1"] = undefined;
	game["match_team1_half2"] = undefined;
	game["match_team2_half2"] = undefined;

	// Generate team names again
	determineTeamByFirstConnected();
}

waitForPlayerOrReset(playersLast)
{
	wait level.fps_multiplier * 60;

	players = getentarray("player", "classname");

	// reset score if 30% of players disconnect or there are no players or there was no players last map
	if (((players.size * 1.0) < (playersLast * 0.7)) || players.size == 0 || playersLast == 0)
	{
		iprintln("Info about teams was cleared.");
		resetAll();

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

	if (ToLower(mapname[0]) == "m" && ToLower(mapname[1]) == "p" && ToLower(mapname[2]) == "_")
		mapname = ToUpper(mapname[3]) + getsubstr(mapname, 4, mapname.size);

	return mapname;
}

setClientCvarIfChanged(cvar, value)
{
	if (!isDefined(self.pers["match_cvarValues_" + cvar]))
		self.pers["match_cvarValues_" + cvar] = "";

	// Convert value to string (to avoid wierd unmatching variable types errors)
	valueStr = value + "";

	// If value changed from last
	if (valueStr != self.pers["match_cvarValues_" + cvar])
	{
		self setClientCvar(cvar, valueStr);
	}

	self.pers["match_cvarValues_" + cvar] = valueStr;
}

UpdatePlayerCvars()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		// Save data we want send to client into local variable
		// So we can check if value changes from last time to decrease the ammound of sended commands to client

		// Team names
		player setClientCvarIfChanged("ui_match_team1_name", game["match_team1_name"]);
		player setClientCvarIfChanged("ui_match_team2_name", game["match_team2_name"]);

		// scores
		player setClientCvarIfChanged("ui_match_team1_score", game["match_team1_score"]);
		player setClientCvarIfChanged("ui_match_team2_score", game["match_team2_score"]);

		// Round
		player setClientCvarIfChanged("ui_match_round", game["match_round"]);

		// Map name
		//player setClientCvarIfChanged("ui_match_map", GetMapName(level.mapname));

		// Map history
		for (j = 1; j <= 2; j++)
		{
			player setClientCvarIfChanged("ui_match_map" + j + "_name", GetMapName(getCvar("sv_map" + j + "_name")));
			player setClientCvarIfChanged("ui_match_map" + j + "_score", getCvar("sv_map" + j + "_score"));
		}

		// Halfs info
		player setClientCvarIfChanged("ui_match_1half", game["match_team1_half1"] + " : " + game["match_team2_half1"]);
		player setClientCvarIfChanged("ui_match_2half", game["match_team1_half2"] + " : " + game["match_team2_half2"]);

		// Half rounds left
		player setClientCvarIfChanged("ui_match_halfText", game["match_halfText"]);
		player setClientCvarIfChanged("ui_match_halfRounds", game["match_halfRounds"]);

		// Total time
		player setClientCvarIfChanged("ui_match_totaltime", game["match_totaltime_text"]);
	}
}




refresh()
{
	// Save previous map score to map history
	if (!isDefined(game["match_previous_map_processed"]))
	{
		// Process cvars from previous map - load it into history cvars
		processPreviousMapToHistory();

		// Run timer - untill 1min the same number of player must connect
		// Othervise considere this as team left and we need to reset match info
		//
		playersLast = getCvar("sv_map_players");
		if (playersLast != "")
		{
			level thread waitForPlayerOrReset(int(playersLast));
			setcvar("sv_map_players", "");
		}

		// Save previous time left
		if (getCvar("sv_map_timeleft") != "")
			game["match_timeprev"] = getCvarInt("sv_map_timeleft");
		else
			game["match_timeprev"] = 0;

		game["match_previous_map_processed"] = true;
	}



	for (;;)
	{
		wait level.fps_multiplier * 1;

		// Total time measuring
		if (game["match_timeprev"] == 0 && level.in_readyup)
			game["match_totaltime"] = 0;
		else
		{
			if (!isDefined(game["match_starttime"]))
				game["match_starttime"] = getTime();

			game["match_totaltime"] = game["match_timeprev"] + (getTime() - game["match_starttime"]);
		}
		setCvar("sv_map_timeleft", game["match_totaltime"]);


		// Keep updating data about team names, played maps,.. untill match start
		if (!game["match_teams_set"])
		{
			// Generate allies and axis team names
			generateTeamNames();

			/*
			If there is defined map, load teams from cvars. Othervise load team by first connected player

			These variables are set:
			game["match_team1_name"] = "UGNC";
			game["match_team2_name"] = "TEAMNAME";
			game["match_team1_side"] = "allies";
			game["match_team2_side"] = "axis";
			*/
			prevMap_map =   getCvar("sv_map1_name");
			if (prevMap_map != "")
				determineTeamByHistoryCvars();
			else
				determineTeamByFirstConnected();

		}

		// If game started and teams was not recognised, reset team info and do it it from scratch
		// This may happend if player in both teams gets renamed
		else
		{
			if (game["match_team1_side"] == "" || game["match_team2_side"] == "")
			{
				resetTeamInfo(); // reset map history

				determineTeamByFirstConnected();
			}
		}

		// Main score update
		if (game["match_team1_side"] == "") 	game["match_team1_score"] = "?";
		else 									game["match_team1_score"] = game[game["match_team1_side"] + "_score"];
		if (game["match_team2_side"] == "") 	game["match_team2_score"] = "?";
		else 									game["match_team2_score"] = game[game["match_team2_side"] + "_score"];


		// Round
		if (!isDefined(game["match_round"]))
			game["match_round"] = "";
		if (level.in_readyup)
			game["match_round"] = "Ready-up";
		else if (!level.roundended) // to avoid increasing rounds player
			game["match_round"] = "Round " + (game["roundsplayed"] + 1);



		if (!isDefined(game["match_team1_half1"]))
		{
			game["match_team1_half1"] = "-";
			game["match_team2_half1"] = "-";
			game["match_team1_half2"] = "-";
			game["match_team2_half2"] = "-";
		}
		// 1st Half info
		if (!level.in_readyup && !game["is_halftime"] && !game["overtime_active"] && game["match_team1_side"] != "")
		{
			game["match_team1_half1"] = game["half_1_" + game["match_team1_side"] + "_score"];
			game["match_team2_half1"] = game["half_1_" + game["match_team2_side"] + "_score"];
		}
		// 2nd half info
		if (!level.in_readyup && game["is_halftime"] && !game["overtime_active"] && game["match_team1_side"] != "")
		{
			game["match_team1_half2"] = game["half_2_" + game["match_team1_side"] + "_score"];
			game["match_team2_half2"] = game["half_2_" + game["match_team2_side"] + "_score"];
		}

		// Half rounds left
		if (level.halfround && !game["is_halftime"])
		{
			game["match_halfText"] = "Rounds to half:";
			game["match_halfRounds"] = level.halfround - game["roundsplayed"];
		}
		else
		{
			game["match_halfText"] =  "Rounds to end:";
			game["match_halfRounds"] = level.matchround - game["roundsplayed"];
		}


		// Total time
		secTotal = int(game["match_totaltime"] / 1000);
		min = int(secTotal / 60);
		sec = secTotal % 60;

		if (min < 10) min = "0" + min;
		if (sec < 10) sec = "0" + sec;

		game["match_totaltime_text"] = min + ":" + sec;



		UpdatePlayerCvars();


		// Save data from this map for next map
		if (game["match_teams_set"])
		{
			setCvar("sv_map_name", level.mapname);
			setCvar("sv_map_team1", game["match_team1_name"]);
			setCvar("sv_map_team2", game["match_team2_name"]);

			// Dont update score if we are in overtime
			if (!game["overtime_active"])
			{
				setCvar("sv_map_score", game["match_team1_score"] + " : " + game["match_team2_score"]);
			}
			else
			{
				// TODO: set +1 score to winner of overtime
			}

			// Update number of player in this match
			// Update this value only if it increases - avoid decreasing it for case when players disconnect in the middle of the match
			// so next time map restart the info about match is properly reseted due to low number of players
			players = getentarray("player", "classname");
			if (players.size > GetCvarInt("sv_map_players"))
				setcvar("sv_map_players", players.size);
		}

		if (game["match_team1_name"] != "") 	setCvar("_match_team1", game["match_team1_name"]);
		else									setCvar("_match_team1", "-");
		if (game["match_team1_name"] != "") 	setCvar("_match_team2", game["match_team2_name"]);
		else									setCvar("_match_team2", "-");

		if (getcvar("sv_map_score") != "") 		setCvar("_match_score", getcvar("sv_map_score"));
		else									setCvar("_match_score", "-");

		if (game["match_round"] != "") 			setCvar("_match_round", game["match_round"]);
		else									setCvar("_match_round", "-");

	}
}



/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu != "ingame")
		return false;

	if (response == "open")
	{

	}
}



removeSameItems(array)
{
    array_to_return = [];
    index = 0;

    for (i = 0; i < array.size; i++)
    {
        // Loop array to check if word already exists
        item_already_exists = false;
        for (j = 0; j < array_to_return.size; j++)
        {
            if (array_to_return[j] == array[i])
            {
                item_already_exists = true;
                break;
            }
        }

        if (item_already_exists)
            continue;

        array_to_return[index] = array[i];
        index++;
    }

    return array_to_return;
}


getSecureString(string)
{
    // Remove chars that cannot be used in filename on Windows (for recording purposes)
    string_secure = "";
    allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";


    for (j = 0; j < string.size; j++)
    {
        saveChar = false;
        for (i = 0; i < allowedChars.size; i++)
        {
            if (allowedChars[i] == string[j])
                saveChar = true;
        }

        if (saveChar)
            string_secure += string[j];
    }

    // Remove spaces from beginid and ending
	if (string_secure.size > 0)
	{
	    while(string_secure[0] == " ")
	        string_secure = getsubstr(string_secure, 1);
		while(string_secure[string_secure.size-1] == " ")
	        string_secure = getsubstr(string_secure, 0, string_secure.size - 1);
	}

    // Limit to 15 chars
    string_secure = getsubstr(string_secure, 0, 15);

    return string_secure;
}

getTeamName(team)
{
	perc = 0.82;

	names = [];

    players = getentarray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
    	player = players[i];

		// If team is not set, generate team name from all players
        if (player.pers["team"] == team || team == "")
        {
            name = player.name; // name may be like:    "ahoj^1kokos^^33pica^^^777neco__^nic^^kokos"
            name_clean = "";    // name clean:      	"ahojkokospica^7neco__^nic^^kokos"

            ignoreNumber = 0;
            for (j = 0; j < name.size; j++)
            {
                char = name[j];

                if (ignoreNumber > 0 && (char == "0" || char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9"))
                {
                    ignoreNumber--;

                } else if (char == "^" && ignoreNumber < 2)
                {
                    ignoreNumber++;
                }
                else
                {
                    name_clean += char;
                }
            }

            names[names.size] = name_clean;
        }
    }



    if (names.size == 0)
    {
        return ""; // EMPTYTEAM
    }
    else if (names.size == 1)
    {
        return getSecureString(names[0]);
    }


	// Save length of the longest name
	maxLength = 0;
	for (i = 0; i < names.size; i++)
	{
		if (names[i].size > maxLength)
			maxLength = names[i].size;
	}


	// Create arrays of substrings from name
	separes = [];
	for(i = 0; i < names.size; i++)
	{
		name = names[i];
		separes[i] = [];

		for (j = 0; j < name.size; j++)
		{
			index = name.size - 1 - j;
			separes[i][index] = [];

			for (k = 0; k < j+1; k++)
			{
				substring = getsubstr(name, k, name.size - j + k);
				separes[i][index][k] = substring;
			}
		}
	}

/*
	// Debug name separes
	println("-------------------");
	for(i = 0; i < separes.size; i++)
	{
		println("-------------------");
		for (j = 0; j < separes[i].size; j++)
		{
			print("separes["+i+"]["+j+"] = [\"");
			for (k = 0; k < separes[i][j].size; k++)
			{
				if (k!=0)
					print(", \"");
				print(separes[i][j][k] + "\"");
			}
			println("]");
		}
	}
*/

	// Marge name separes
	separes_marged = [];
	separes_marged_count = [];
	for(i = 0; i < maxLength; i++)
	{
		separes_marged[i] = [];
		separes_marged_count[i] = [];

		for (j = 0; j < separes.size; j++)
		{
			// If there is no more substrings for this player-name, break
			if (!isDefined(separes[j]) || !isDefined(separes[j][i]))
				continue;

			// Remove already defined items
			separes_clean = removeSameItems(separes[j][i]);

			for (k = 0; k < separes_clean.size; k++)
			{
				exists_in_array = false;
				for (l = 0; l < separes_marged[i].size; l++)
				{
					if (ToLower(separes_marged[i][l]) == ToLower(separes_clean[k]))
					{
						// We found word already in "separes_marged[i]" array - so count up
						separes_marged_count[i][l]++;
						exists_in_array = true;
						break;
					}
				}
				if (!exists_in_array)
				{
					// If this word does not exist in array, add it
					separes_marged[i][separes_marged[i].size] = separes_clean[k];
					separes_marged_count[i][separes_marged_count[i].size] = 1;
				}
			}
		}
	}

/*
	// Debuging
	for (i = 0; i < separes_marged.size; i++)
	{
		println("Most used words of length " + (i+1) + " are: ");
		for (l = 0; l < separes_marged[i].size; l++)
		{
			if (l != 0)
				print(", ");
			print(separes_marged_count[i][l] + ":\"" + separes_marged[i][l] + "\"");
		}
		println("\n");
	}
*/


	// Find the most used word in marged separes and save it
	most_used_word = [];
	most_used_count = [];
	for (i = 0; i < separes_marged.size; i++)
	{
		last_word = "";
		last_count = 0;
		for(j = 0; j < separes_marged[i].size; j++)
		{
			if (separes_marged_count[i][j] > last_count)
			{
				last_count = separes_marged_count[i][j];
				last_word = separes_marged[i][j];
			}
		}
		most_used_word[i] = last_word;
		most_used_count[i] = last_count;
	}

/*
	// Debuging
	println("");
	for (i = 0; i < most_used_word.size; i++)
	{
		println("Most used word of length " + (i+1) + " is \"" + most_used_word[i] + "\" ("+most_used_count[i]+")");
	}
*/


	// Create array of most used words where each word will be presents many times it was used
	most_used_extended = [];
	count = 0;
	for (i = 0; i < most_used_word.size; i++)
	{
		if (most_used_count[i] <= 1)
			continue;

		for(j = 0; j < most_used_count[i]; j++)
		{
			most_used_extended[count] = most_used_word[i];
			count++;
		}
	}

    // If there is no char that is used more whan once (for example just two players connected with different chars in their name)
    if (most_used_extended.size == 0)
    {
        most_used_extended[0] = ""; // UNKNOWN
    }


/*
	println("");
	for (i = 0; i < most_used_extended.size; i++)
	{
		println(i + ": len_" + most_used_extended[i].size + " ---- \"" + most_used_extended[i] + "\"");
	}
*/

	// Find the final most used word by percentage
	index = int(count * perc);
	final_word = most_used_extended[index];


    final_word_secure = getSecureString(final_word);


    // Debug
	//println("\n\nSelected name of team: \"" + final_word +"\" : " + index + "    --- secured: \"" + final_word_secure + "\"");

    return final_word_secure;
}
