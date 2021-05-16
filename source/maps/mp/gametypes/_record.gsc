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

	if (game["scr_matchinfo"] == 0) // used to get team names
		return;

	// Match ID is just random string to avoid demo overwrite
	if (!isDefined(game["recordingMatchID"]))
		game["recordingMatchID"] = generateHash(2);

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
		if (!level.in_readyup && !level.in_timeout && (self.sessionteam == "allies" || self.sessionteam == "axis"))
		{
			waittillframeend; // wait until team names are generated
			self execRecording();
		}
	}
}

onReadyupOver()
{
	level waittill("rupover");

	startRecordingForAll();
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

    // Assing my team name as first
    myTeamName = game["match_team1_name"];
    enemyTeamName = game["match_team2_name"];
    if (self.pers["team"] == "axis" && game["match_team2_side"] == "axis")
    {
        myTeamName = game["match_team2_name"];
        enemyTeamName = game["match_team1_name"];
    }

    // Get only a-z A-Z 0-9
    myTeamName = getSecureString(myTeamName);
    enemyTeamName = getSecureString(enemyTeamName);

    // Limit length
    myTeamName = getsubstr(myTeamName, 0, 7);
    enemyTeamName = getsubstr(enemyTeamName, 0, 11);

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

	// Shot xVx text only if it is not 5v5
	xVx = "";
	if (myTeamPlayers != 5 && enemyTeamPlayers != 5)
		xVx = "_"+myTeamPlayers+"v"+enemyTeamPlayers;

    // Map name
    mapname = level.mapname;


	if (mapname == "mp_toujane" || mapname == "mp_toujane_fix_v2")		mapname = "tj";
	else if (mapname == "mp_burgundy" || mapname == "mp_burgundy_fix_v1")	mapname = "bg";
	else if (mapname == "mp_dawnville" || mapname == "mp_dawnville_fix")		mapname = "dw";
	else if (mapname == "mp_matmata" || mapname == "mp_matmata_fix")		mapname = "mat";
	else if (mapname == "mp_carentan" || mapname == "mp_carentan_fix")		mapname = "car";
	else
	{
		if (ToLower(mapname[0]) == "m" && ToLower(mapname[1]) == "p" && ToLower(mapname[2]) == "_")
	        	mapname = getsubstr(mapname, 3, mapname.size);
		if (mapname > 3)
			mapname = getsubstr(mapname, 0, 3);
	}

    demoName = myTeamName+"_"+enemyTeamName+xVx + "_" + mapname+"#" + game["recordingMatchID"];

    // Avoiding file overwritting
    if (level.gametype == "sd" && game["roundsplayed"] > 0 && !game["overtime_active"])
        demoName += "_round" + game["roundsplayed"]; // use round-number
    else if (level.gametype != "sd")
        demoName += "_" + self generateHash(3); // add random hash at the end of demo name to avoid file overwritting

    return demoName;
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

    return string_secure;
}




startRecordingForAll()
{
    players = getentarray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        player = players[i];

		if (!player.pers["recording_executed"] && (player.sessionteam == "allies" || player.sessionteam == "axis"))
			player execRecording();
    }
}

// Called from matchinfo if players disconnect
stopRecordingForAll()
{
	if (!level.scr_recording) // recordign is not enabled
		return;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player.pers["autorecording_enabled"])
		{
			// Do record
			// Exec command on client side
			// If some menu is already opened:
			//	- by player (by ESC command) -> it will work well over already opened menu
			//  - by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
			//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
			player closeMenu();
			player closeInGameMenu();
			player setClientCvar2("exec_cmd", "stoprecord");
			player openMenu(game["menu_exec_cmd"]);		// open menu via script
			player closeMenu();				// will only close menu opened by script


			player iprintln("Recording stopped.");

			if (player isEnabled())
				player show(); // show recording will start automaticallly again
		}
	}
}


execRecording()
{
	// Auto recording is turned off by player, print atleast warning message
	if (!self.pers["autorecording_enabled"])
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

    	self iprintln("Recording to 'main/demos/"+demoName+".dm_1'");

    	// Do record
	// Exec command on client side
	// If some menu is already opened:
	//	- by player (by ESC command) -> it will work well over already opened menu
	//  - by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
	//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
	self closeMenu();
	self closeInGameMenu();
	self setClientCvar2("exec_cmd", "stoprecord; record " + demoName);

	wait level.frame;

	self openMenu(game["menu_exec_cmd"]);		// open menu via script
	self closeMenu();							// will only close menu opened by script

	self.pers["recording_executed"] = true;

  	self hide();
}




generateHash(len)
{
    // Generate random hash (disbled chars: -----   <>:\"/\\|?*   )
    avaibleChars = "0123456789";//abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    hash = "";
    for (i = 0; i < len; i++)
    {
        randIndex = randomintrange(0, avaibleChars.size);// Returns a random integer r, where min <= r < max
        hash = hash + "" + avaibleChars[randIndex];
    }

    return hash;
}
