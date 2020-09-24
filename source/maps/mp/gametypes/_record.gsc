#include maps\mp\gametypes\_callbacksetup;

init()
{
    if (!level.scr_recording)
        return;

	// Match ID is just random string to avoid demo overwrite
	if (!isDefined(game["recordingMatchID"]))
    	game["recordingMatchID"] = generateHash(2);

    addEventListener("onConnected",         ::onConnected);
    addEventListener("onSpawnedPlayer",     ::onSpawnedPlayer);
    addEventListener("onSpawnedSpectator",     ::onSpawnedSpectator);
	addEventListener("onMenuResponse",  ::onMenuResponse);

	level thread onReadyupOver();
}

onConnected()
{
    if (!isDefined(self.pers["isRecording"]))
        self.pers["isRecording"] = false;

	if (!isDefined(self.pers["recordingStopped"]))
        self.pers["recordingStopped"] = false;

  // Shot text "Recording will start automatically"
  if (!self.pers["isRecording"])
  {
    self.recording_info = maps\mp\gametypes\_hud_system::addHUDClient(self, 2, -1, 1, (1,1,1), "left", "bottom", "left", "bottom");
  	self.recording_info setText(game["STRING_RECORDING_INFO"]);
    self.recording_info.font = "smallfixed";
    self.recording_info.alpha = 0.75;
  }
}


onSpawnedPlayer()
{
  if (isDefined(self.recording_info))
    self.recording_info.alpha = 0.75;

	self onSpawned();
}

onSpawnedSpectator()
{
  if (isDefined(self.recording_info))
    self.recording_info.alpha = 0;

	self onSpawned();
}


onSpawned()
{
	if (!self.pers["isRecording"])
	{
		// Stop recording when imidietly player spawns
		// This make sure demos will be separed by each map
		if (!self.pers["recordingStopped"])
		{
			// Exec command on client side
			// If some menu is already opened:
			//	- by player (by ESC command) -> it will work well over already opened menu
			//  - by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
			//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
			self setClientCvar("exec_cmd", "stoprecord");
			self openMenu(game["menu_exec_cmd"]);		// open menu via script
			self closeMenu();							// will only close menu opened by script

			self.pers["recordingStopped"] = true;
		}

	    // If player connect in the middle of the match, start recording
	    // If recording was not runned yet
	    if (!level.in_readyup && !level.in_timeout)
	    {
	    	self execRecording();
	    }
	}
}

/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu == game["menu_ingame"] && response == "record")
	{
		self execRecording();
		return true;
	}
}

onReadyupOver()
{
    level waittill("rupover");

	startRecordingForAll();
}


generateDemoName()
{
    // Wait untill team names are generated in case recording is executed right at start of new round
    waittillframeend;

    // Assing my team name as first
    myTeamName = level.teamname_allies;
    enemyTeamName = level.teamname_axis;
    if (self.pers["team"] == "axis")
    {
        myTeamName = level.teamname_axis;
        enemyTeamName = level.teamname_allies;
    }

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
    if (ToLower(mapname[0]) == "m" && ToLower(mapname[1]) == "p" && ToLower(mapname[2]) == "_")
        mapname = getsubstr(mapname, 3, mapname.size);

	if (mapname == "toujane")	mapname = "tj";
	if (mapname == "burgundy")	mapname = "bg";
	if (mapname == "dawnville")	mapname = "dw";
	if (mapname == "matmata")	mapname = "mat";
	if (mapname == "carentan")	mapname = "car";

    demoName = myTeamName+"_"+enemyTeamName+xVx + "_" + mapname+"_#" + game["recordingMatchID"];

    // Avoiding file overwritting
    if (level.gametype == "sd" && game["roundsplayed"] > 0 && !game["overtime_active"])
        demoName += "_round" + game["roundsplayed"]; // use round-number
    else if (level.gametype != "sd")
        demoName += "_" + self generateHash(3); // add random hash at the end of demo name to avoid file overwritting

    return demoName;
}


startRecordingForAll()
{
    players = getentarray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        player = players[i];

		if (!player.pers["isRecording"] && (player.sessionteam == "allies" || player.sessionteam == "axis"))
			player execRecording();
    }
}


execRecording()
{
	if (self.pers["isRecording"])
	{
		self iprintln("Already recording");
		return;
	}

	demoName = generateDemoName();

    self iprintln("Recording to '"+level.pam_folder+"/demos/"+demoName+".dm_1'");

    // Do record
	// Exec command on client side
	// If some menu is already opened:
	//	- by player (by ESC command) -> it will work well over already opened menu
	//  - by script (via openMenu()) -> that menu will be closed and exec_cmd will not be closed correctly
	//			(mouse will be visible with clear backgorund.... so closeMenu() is called to close that menu)
	self setClientCvar("exec_cmd", ("record " + demoName));
	self openMenu(game["menu_exec_cmd"]);		// open menu via script
	self closeMenu();							// will only close menu opened by script

	self.pers["isRecording"] = true;

  if (isDefined(self.recording_info))
    self.recording_info.alpha = 0;
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
