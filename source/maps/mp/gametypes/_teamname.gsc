#include maps\mp\gametypes\_callbacksetup;


Init()
{
	// Team names
	level.teamname_allies = "";
	level.teamname_axis = "";
	level.teamname_all = "";

  level.teamname["allies"] = "";
  level.teamname["axis"] = "";

  // Wait untill all players are spawned
  waittillframeend;

  // Generate team names
  refreshTeamName("allies");
  refreshTeamName("axis");
}

// Generate team names for specified team
refreshTeamName(team)
{
  if (team == "allies")
  {
    level.teamname_allies = getTeamName(team);
    level.teamname["allies"] = level.teamname_allies;
    return level.teamname_allies;
  }
  else if (team == "axis")
  {
    level.teamname_axis = getTeamName(team);
    level.teamname["axis"] = level.teamname_axis;
    return level.teamname_axis;
  }
  else if (team == "")
  {
    level.teamname_all = getTeamName(team);
    return level.teamname_all;
  }
  return "";
}

// Generate team name base on all players
refreshTeamNameForAll()
{
  refreshTeamName("");
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
        if (isDefined(player.pers["team"]) && (player.pers["team"] == team || team == ""))
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
