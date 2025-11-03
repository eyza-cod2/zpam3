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

	addEventListener("onSpawnedPlayer",     ::onSpawnedPlayer);
	addEventListener("onSpawnedSpectator",     ::onSpawnedSpectator);

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
  return true; //isDefined(self.pers["autorecording_enabled"]) && self.pers["autorecording_enabled"];
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
      self.recording_info = addHUDClient(self, 2, -1, 0.75, (1,1,1), "left", "bottom", "left", "bottom");
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
	else if (mapname == "mp_dawnville" || mapname == "mp_dawnville_fix" || mapname == "mp_dawnville_sun")			mapname = "dw";
	else if (mapname == "mp_matmata" || mapname == "mp_matmata_fix")			mapname = "mat";
	else if (mapname == "mp_carentan" || mapname == "mp_carentan_fix" || mapname == "mp_carentan_bal")			mapname = "car";
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

	demoName = "";

	if (matchIsActivated()) {
		demoName += getsubstr(getSecureString(self matchPlayerGetData("name")), 0, 12) + "_";
	}

	demoName += teamPrefix + "_" + mapname;

	if (level.gametype != "sd")
		demoName += "#" + level.gametype;

	// Avoiding file overwritting
	if ((level.gametype == "sd" || level.gametype == "re") && game["roundsplayed"] > 0) {
		if (game["overtime_active"])
			demoName += "_ot";
		demoName += "_r" + game["roundsplayed"]; // use round-number
	}

	return demoName;
}


getSecureString(string)
{
    // Remove chars that cannot be used in filename on Windows (for recording purposes)
    string_secure = "";
    allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789=-+_#!()[]{}";


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

	if (self.pers["recording_executed"])
	{
		self iprintln("Already recording");
		return;
	}

	demoName = generateDemoName();

	if (matchIsActivated()) {
		self setClientCvar2("cl_demoAutoRecordUploadUrl", "https://master.cod2x.me/api/match/test/demo-upload/"); // CoD2x 1.4.5.1-test.12 and later
	}
	
	self setClientCvar2("cl_demoAutoRecordName", demoName); // CoD2x 1.4.5.1-test.12 and later

	self.pers["recording_executed"] = true;

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

	self setClientCvar2("cl_demoAutoRecordName", ""); // CoD2x 1.4.5.1-test.12 and later

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
