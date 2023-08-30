#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_recording", "BOOL", 0);

	if(game["firstInit"])
	{
		// Precache
		precacheString2("STRING_RECORDING_INFO", &"Recording will start automatically...");
	}


	addEventListener("onConnected",         ::onConnected);

	if (!level.scr_recording)
		return;

	// Match ID is just random string to avoid demo overwrite
	if (!isDefined(game["recordingMatchID"]))
		game["recordingMatchID"] = generateHash(2);

	addEventListener("onSpawnedPlayer",     ::onSpawnedPlayer);
	addEventListener("onSpawnedSpectator",     ::onSpawnedSpectator);
	addEventListener("onMenuResponse",  ::onMenuResponse);

	level thread onReadyupOver();
}


// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_recording": level.scr_recording = value; return true;
	}
	return false;
}


onConnected()
{
	if (!isDefined(self.pers["autorecording_enabled"]))
		self.pers["autorecording_enabled"] = true;

	if (!level.scr_recording)
		return;

	if (!isDefined(self.pers["recording_executed"]))
		self.pers["recording_executed"] = false;

	if (!isDefined(self.pers["recording_stop_executed"]))
		self.pers["recording_stop_executed"] = false;

	// Shot text "Recording will start automatically"
	if (isEnabled())
		self show();
}


onSpawnedPlayer()
{
	if (isEnabled())
		self show();

	self onSpawned();
}

onSpawnedSpectator()
{
  	self hide();

	self onSpawned();
}



/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu != "exec_cmd")
		return;

	if (response == "start_recording")
	{
		self.pers["recording_executed"] = true;
		return true;
	}
	if (response == "stop_recording")
	{
		self.pers["recording_stop_executed"] = true;
		return true;
	}
}




onSpawned()
{
	if (!self.pers["recording_executed"])
	{
		// If player connect in the middle of the match, start recording (recording was not runned yet)
		if (!level.in_readyup && !level.in_timeout && (self.pers["team"] == "allies" || self.pers["team"] == "axis"))
		{
			waittillframeend; // wait until team names are generated
			self execRecording();
		}
	}
}

onReadyupOver()
{
	for (;;)
	{
		level waittill("rupover");

		startRecordingForAll();
	}
}




isEnabled()
{
  return isDefined(self.pers["autorecording_enabled"]) && self.pers["autorecording_enabled"];
}

enable()
{
  self.pers["autorecording_enabled"] = true;
  if (level.scr_recording)
    self show();
}

disable()
{
  self.pers["autorecording_enabled"] = false;
  if (level.scr_recording)
    self hide();
}

toggle()
{
  if (isEnabled())
    self disable();
  else
    self enable();
}

// Show hud element
show()
{
  if (!self.pers["recording_executed"] && !game["match_exists"]) // show only if we are not recording
  {
    if (!isDefined(self.recording_info))
    {
      self.recording_info = addHUDClient(self, 2, -1, 1, (1,1,1), "left", "bottom", "left", "bottom");
      self.recording_info setText(game["STRING_RECORDING_INFO"]);
      self.recording_info.font = "smallfixed";
    }
    self.recording_info.alpha = 0.75;
  }
}
// Hide hud element
hide()
{
  if (isDefined(self.recording_info))
  {
    self.recording_info.alpha = 0;
  }
}




generateDemoName()
{
	// Wait untill team names are generated in case recording is executed right at start of new round
	waittillframeend;

	teamPrefix = "";

	// If team names are turned off (deathmatch)
	if (game["scr_matchinfo"] > 0)
	{
		// Assing my team name as first
		myTeamName = game["match_team1_name"];
		enemyTeamName = game["match_team2_name"];
		if (self.pers["team"] == game["match_team2_side"])
		{
			myTeamName = game["match_team2_name"];
			enemyTeamName = game["match_team1_name"];
		}


		// Protection if team names from match info are empty
		if (myTeamName == "" || enemyTeamName == "")
		{
			maps\mp\gametypes\_teamname::refreshTeamName("allies"); // will update level.teamname_allies
			maps\mp\gametypes\_teamname::refreshTeamName("axis"); // will update level.teamname_axis

			if (self.pers["team"] == "allies")
			{
				myTeamName = level.teamname_allies;
				enemyTeamName = level.teamname_axis;
			}
			else
			{
				myTeamName = level.teamname_axis;
				enemyTeamName = level.teamname_allies;
			}
		}


		// Generated name is empty
		if (myTeamName == "")
			myTeamName = "!";
		if (enemyTeamName == "")
			enemyTeamName = "!";


		// Get only a-z A-Z 0-9
		myTeamName = getSecureString(myTeamName);
		enemyTeamName = getSecureString(enemyTeamName);

		// Limit length
		enemyExtraLen = 11 - enemyTeamName.size;
		if (enemyExtraLen < 0) enemyExtraLen = 0;
		myExtraLen = 7 - myTeamName.size;
		if (myExtraLen < 0) myExtraLen = 0;

		myTeamName = getsubstr(myTeamName, 0, 7 + enemyExtraLen);
		enemyTeamName = getsubstr(enemyTeamName, 0, 11 + myExtraLen);

		// Get number of players
		myTeamPlayers = 0;
		enemyTeamPlayers = 0;
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			player = players[i];

			if (player.pers["team"] == "allies")
			{
				if (self.pers["team"] == "allies")
					myTeamPlayers++;
				else
					enemyTeamPlayers++;
			}
			else if (player.pers["team"] == "axis")
			{
				if (self.pers["team"] == "axis")
					myTeamPlayers++;
				else
					enemyTeamPlayers++;
			}
		}

		teamPrefix = myTeamName + "_" + enemyTeamName;

		// Show xVx text only if it is not 5v5
		if (myTeamPlayers != 5 && enemyTeamPlayers != 5)
			teamPrefix += "_" + myTeamPlayers + "v" + enemyTeamPlayers;
	}
	else
	{
		teamPrefix = getsubstr(getSecureString(self.name), 0, 18);
	}



	// Map name
	mapname = level.mapname;
	if (mapname == "mp_toujane" || mapname == "mp_toujane_fix")				mapname = "tj";
	else if (mapname == "mp_burgundy" || mapname == "mp_burgundy_fix")			mapname = "bg";
	else if (mapname == "mp_dawnville" || mapname == "mp_dawnville_fix")			mapname = "dw";
	else if (mapname == "mp_matmata" || mapname == "mp_matmata_fix")			mapname = "mat";
	else if (mapname == "mp_carentan" || mapname == "mp_carentan_fix")			mapname = "car";
	else if (mapname == "mp_breakout_tls")							mapname = "bre";
	else if (mapname == "mp_chelm_fix")							mapname = "che";
	else if (mapname == "mp_crossroads")							mapname = "crs";
	else
	{
		if (ToLower(mapname[0]) == "m" && ToLower(mapname[1]) == "p" && ToLower(mapname[2]) == "_")
			mapname = getsubstr(mapname, 3, mapname.size);

		// Trim to 3 chars
		mapname = getsubstr(mapname, 0, 3);
	}

	demoName = teamPrefix + "_" + mapname;

	if (level.gametype != "sd")
		demoName += "#" + level.gametype;

	demoName += "#" + game["recordingMatchID"];

	// Avoiding file overwritting
	if ((level.gametype == "sd" || level.gametype == "re") && game["roundsplayed"] > 0 && !game["overtime_active"])
		demoName += "_r" + game["roundsplayed"]; // use round-number
	else if (level.gametype != "sd" && level.gametype != "re" && isDefined(level.matchstarted) && level.matchstarted)
	{
		demoName += "_" + self generateHash(2); // add random hash at the end of demo name to avoid file overwritting
	}


	return demoName;
}


getSecureString(string)
{
    // Remove chars that cannot be used in filename on Windows (for recording purposes)
    string_secure = "";
    allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789=-+_#!.()[]{}";


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

    return string_secure;
}




startRecordingForAll()
{
    players = getentarray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        player = players[i];

		if (!player.pers["recording_executed"] && (player.pers["team"] == "allies" || player.pers["team"] == "axis"))
			player thread execRecording();
    }
}


execRecording()
{
	self endon("disconnect");

	//self iprintln("exec record");

	// Ignore bots
	if (self.pers["isBot"])
		return;

	// Auto recording is turned off by player, print atleast warning message
	if (!self isEnabled())
	{
		self iprintln("Don't forget to record!");
		self.pers["recording_executed"] = true;
		return;
	}


	if (self.pers["recording_executed"])
	{
		self iprintln("Already recording");
		return;
	}

	demoName = generateDemoName();

	// Try to execute the command every second untill its confirmed by openscriptmenu
	while(!self.pers["recording_executed"])
	{
		// Exec command on client side
		// If some menu is already opened:
		//	- by player (main menu / quick messages) -> NOT WORKING - command will not be executed
		//	- by player (by ESC key) -> that menu will be closed
		//  	- by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
		//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
		self closeMenu();
		self closeInGameMenu();
		self setClientCvar2("exec_cmd", "clear; stoprecord; record " + demoName + "; openScriptMenu exec_cmd start_recording");
		self openMenu(game["menu_exec_cmd"]);		// open menu via script
		self closeMenu();				// will only close menu opened by script

		// Wait a second before next menu opening
		for (i = 0; i < 9 && !self.pers["recording_executed"]; i++)
			wait level.fps_multiplier * .1;
	}

	self iprintln("Recording to 'main/demos/"+demoName+".dm_1'");

  	self hide();
}






// Called from matchinfo if players disconnect
stopRecordingForAll()
{
	if (!level.scr_recording) // recordign is not enabled
		return;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i] thread stopRecording();
	}
}

stopRecording()
{
	self endon("disconnect");

	// Auto recording is disabled
	if (!self isEnabled())
		return;

	self.pers["recording_stop_executed"] = false;

	// Try to execute the command every second untill its confirmed by openscriptmenu
	while(!self.pers["recording_stop_executed"])
	{
		// Open menu only if player is alive (to make sure no other menu is opened)
		// Because stop recording may be called when matchinfo is cleared - it will close sevrerinfo menu for connected players
		if (IsAlive(self))
		{
			// Exec command on client side
			// If some menu is already opened:
			//	- by player (main menu / quick messages) -> NOT WORKING - command will not be executed
			//	- by player (by ESC key) -> that menu will be closed
			//  	- by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
			//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
			self closeMenu();
			self closeInGameMenu();
			self setClientCvar2("exec_cmd", "stoprecord; openScriptMenu exec_cmd stop_recording");
			self openMenu(game["menu_exec_cmd"]);		// open menu via script
			self closeMenu();				// will only close menu opened by script
		}

		// Wait a second before next menu opening
		for (i = 0; i < 9 && !self.pers["recording_stop_executed"]; i++)
			wait level.fps_multiplier * .1;
	}

	self iprintln("Recording stopped.");

	self show(); // show recording will start automaticallly again
}






generateHash(len)
{
    // Generate random hash (disbled chars: -----   <>:\"/\\|?*   )
    availableChars = "0123456789";//abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    hash = "";
    for (i = 0; i < len; i++)
    {
        randIndex = randomintrange(0, availableChars.size);// Returns a random integer r, where min <= r < max
        hash = hash + "" + availableChars[randIndex];
    }

    return hash;
}
