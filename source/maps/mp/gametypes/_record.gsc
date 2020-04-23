#include maps\mp\gametypes\_callbacksetup;

init()
{
    if (!level.scr_recording)
        return;

	// Match ID is just random string to avoid demo overwrite
	if (!isDefined(game["recordingMatchID"]))
    	game["recordingMatchID"] = generateHash(3);

    addEventListener("onConnected",         ::onConnected);
    addEventListener("onSpawnedPlayer",     ::onSpawnedPlayer);
	addEventListener("onMenuResponse",  ::onMenuResponse);

	level thread onReadyupOver();
}

onConnected()
{
    if (!isDefined(self.pers["isRecording"]))
        self.pers["isRecording"] = false;

	if (!isDefined(self.pers["recordingStopped"]))
        self.pers["recordingStopped"] = false;
}

onSpawnedPlayer()
{
	if (!self.pers["isRecording"])
	{
		// Stop recording when imidietly player spawns
		// This make sure demos will be separed by each map
		if (!self.pers["recordingStopped"])
		{
			self setClientCvar("exec_cmd", "stoprecord");
		    self openMenu(game["menu_exec_cmd"]);
		    self closeMenu();
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

    // Map name
    mapname = level.mapname;
    if (ToLower(mapname[0]) == "m" && ToLower(mapname[1]) == "p" && ToLower(mapname[2]) == "_")
        mapname = getsubstr(mapname, 3, mapname.size);

    demoName = myTeamPlayers+"v"+enemyTeamPlayers+"_"+mapname+"_"+myTeamName+"_"+enemyTeamName+"__"+game["recordingMatchID"];

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
	self closeMenu(); // in case some menu is opened, it needs to be closed or it will not start recording
	self closeInGameMenu();
    self setClientCvar("exec_cmd", ("record " + demoName));
    self openMenu(game["menu_exec_cmd"]);
    self closeMenu();

	self.pers["isRecording"] = true;
}

generateHash(len)
{
    // Generate random hash (disbled chars: -----   <>:\"/\\|?*   )
    avaibleChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    hash = "";
    for (i = 0; i < len; i++)
    {
        randIndex = randomintrange(0, avaibleChars.size);// Returns a random integer r, where min <= r < max
        hash = hash + "" + avaibleChars[randIndex];
    }

    return hash;
}
