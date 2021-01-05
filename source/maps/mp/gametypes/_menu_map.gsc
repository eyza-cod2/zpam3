#include maps\mp\gametypes\_callbacksetup;

init()
{
    map = [];
    map["mp_breakout"] = 0;
    map["mp_brecourt"] = 1;
    map["mp_burgundy"] = 2;
    map["mp_carentan"] = 3;
    map["mp_dawnville"] = 4;
    map["mp_decoy"] = 5;
    map["mp_downtown"] = 6;
    map["mp_farmhouse"] = 7;
    map["mp_harbor"] = 8;
    map["mp_leningrad"] = 9;
    map["mp_matmata"] = 10;
    map["mp_railyard"] = 11;
    map["mp_rhine"] = 12;
    map["mp_toujane"] = 13;
    map["mp_trainstation"] = 14;
    map["fast_restart"] = 15; // special id for performing fast_restart

    gametype = [];
    gametype["sd"] = 0;
    gametype["dm"] = 1;
    gametype["strat"] = 2;
    gametype["tdm"] = 3;

    // List of SD pam modes
  	pam_sd = [];
  	modes = maps\pam\rules\rules::getListOfRuleSets("sd");
  	for (i = 0; i < modes.size; i++)
  		pam_sd[modes[i]] = i;

    // List of DM pam modes
	pam_dm = [];
  	modes = maps\pam\rules\rules::getListOfRuleSets("dm");
  	for (i = 0; i < modes.size; i++)
  		pam_dm[modes[i]] = i;

	// List of TDM pam modes
  	pam_tdm = [];
  	modes = maps\pam\rules\rules::getListOfRuleSets("tdm");
  	for (i = 0; i < modes.size; i++)
  		pam_tdm[modes[i]] = i;

    // List of Start pam modes
  	pam_strat["strat"] = 0;


    pam["sd"] = pam_sd;
    pam["dm"] = pam_dm;
	pam["tdm"] = pam_tdm;
    pam["strat"] = pam_strat;



    level.serverOptions = spawnStruct();

    level.serverOptions.gametypeArray = gametype;
    level.serverOptions.mapArray = map;
    level.serverOptions.pamArray = pam[level.gametype];
    level.serverOptions.pamGametypesArray = pam;



	addEventListener("onMenuResponse",   ::onMenuResponse);
}


/*
Called when command scriptmenuresponse is executed on client side
self is player that called scriptmenuresponse
Return true to indicate that menu response was handled in this function
*/
onMenuResponse(menu, response)
{
	if (menu != "ingame")
		return;

	if (startsWith(response, "rcon_map_"))
	{
		substr = getSubstr(response, 9);

		self mapOptions(substr);

		return true;
	}
}

mapOptions(response)
{

    if (response == "open")
    {
        pam_mode = level.pam_mode;
        if (level.gametype == "strat")
            pam_mode = "strat"; // strat does not have pam modes
        onOpen(pam_mode);
    }

    else if (startsWith(response, "map_"))
    {
        mapInput = getsubstr(response, 4);
        onMapChange(mapInput);
    }
    else if (startsWith(response, "gametype_"))
    {
        gametypeInput = getsubstr(response, 9);
		    onGametypeChange(gametypeInput);
    }
    else if (startsWith(response, "pam_"))
    {
        pamInput = getsubstr(response, 4);
        onPamChange(pamInput);
    }

    else if (startsWith(response, "fast_reload_fix_"))
    {
        numberInput = getsubstr(response, 16);
        numberSafe = 0;
        if (numberInput == "1")
            numberSafe = 1;
        // Save selected
        self.pers["serverOptions_fastReloadFix"] = numberSafe;
        // Update string
        mapOptions_updateRconCommand();
    }

    else if (startsWith(response, "diagonal_fix_"))
    {
        numberInput = getsubstr(response, 13);
        numberSafe = 0;
        if (numberInput == "1")
            numberSafe = 1;
        // Save selected
        self.pers["serverOptions_diagonalFix"] = numberSafe;
        // Update string
        mapOptions_updateRconCommand();
    }

    else if (startsWith(response, "shotgun_rebalance_"))
    {
        numberInput = getsubstr(response, 18);
        numberSafe = 0;
        if (numberInput == "1")
            numberSafe = 1;
        // Save selected
        self.pers["serverOptions_shotgunRebalance"] = numberSafe;
        // Update string
        mapOptions_updateRconCommand();
    }

    else if (startsWith(response, "prone_peak_fix_"))
    {
        numberInput = getsubstr(response, 15);
        numberSafe = 0;
        if (numberInput == "1")
            numberSafe = 1;
        // Save selected
        self.pers["serverOptions_pronePeakFix"] = numberSafe;
        // Update string
        mapOptions_updateRconCommand();
    }
}

onOpen(pam_mode)
{
  // Set selections to default
  self.pers["serverOptions_map"] =        level.mapname;
  self.pers["serverOptions_gametype"] =   level.gametype;
  self.pers["serverOptions_pam"] =        pam_mode; // default pam mode

  self.pers["serverOptions_fastReloadFix"] = level.scr_fast_reload_fix;
  self.pers["serverOptions_diagonalFix"] = level.scr_diagonal_fix;
  self.pers["serverOptions_shotgunRebalance"] = level.scr_shotgun_rebalance;
  self.pers["serverOptions_pronePeakFix"] = level.scr_prone_peak_fix;


  loadPAMArray(); // update level.serverOptions.pamArray correctly if was changed before

  self setClientCvar("ui_rcon_map_map", self.pers["serverOptions_map"]);

  // Show pam modes according to selected gametype
  highlightSelectedItems();

  mapOptions_updateRconCommand();
}



onMapChange(mapInput)
{
  map = level.mapname; // set to default
  if (isDefined(level.serverOptions.mapArray[mapInput]))
      map = mapInput;

  // Save selected map
  self.pers["serverOptions_map"] = map;

  self setClientCvar("ui_rcon_map_map", map);

  highlightSelectedItems();

  mapOptions_updateRconCommand();
}



onGametypeChange(gametypeInput)
{
  gametype = level.gametype; // set to default
  if (isDefined(level.serverOptions.gametypeArray[gametypeInput]))
      gametype = gametypeInput;

  // If gametype is changed and fast_restart is selected, resotre actual map
  if (self.pers["serverOptions_map"] == "fast_restart")
    self.pers["serverOptions_map"] = level.mapname;

  // Save selected gametype
  self.pers["serverOptions_gametype"] = gametype;

  // Load PAM modes according to new selected gametype
  loadPAMArray();

  highlightSelectedItems();

  mapOptions_updateRconCommand();
}



onPamChange(pamInput)
{
  pam = level.pam_mode;
  if (level.gametype == "strat")
      pam = "strat"; // strat does not have pam modes

  if (isDefined(level.serverOptions.pamArray[pamInput]))
    pam = pamInput;

  // Save selected gametype
  self.pers["serverOptions_pam"] = pam;

  highlightSelectedItems();

  mapOptions_updateRconCommand();
}



loadPAMArray()
{
    // Load selected gametype
    gametype = self.pers["serverOptions_gametype"];
    PAMModeBefore = self.pers["serverOptions_pam"];

    // Load PAM modes according to selected gametype
    level.serverOptions.pamArray = level.serverOptions.pamGametypesArray[gametype];

    pam_mode = level.pam_mode;
    if (gametype == "strat")
        pam_mode = "strat"; // strat does not have pam modes

    if (isDefined(level.serverOptions.pamArray[PAMModeBefore]))	// pam on previous gametype exists in new gametype - keep same
        self.pers["serverOptions_pam"] = PAMModeBefore;
    else if (isDefined(level.serverOptions.pamArray[pam_mode]))
        self.pers["serverOptions_pam"] = pam_mode;
    else
        self.pers["serverOptions_pam"] = "";

    return level.serverOptions_pam;
}

// Show pam modes according to selected gametype
highlightSelectedItems()
{

}

mapOptions_updateRconCommand()
{
    rconString = "";
    execString = "";

    pam_mode = level.pam_mode;
    if (level.gametype == "strat")
        pam_mode = "strat"; // strat does not have pam modes

    gametypeChanged = self.pers["serverOptions_gametype"] != level.gametype;
    mapChanged = self.pers["serverOptions_map"] != level.mapname;
    pamChanged = self.pers["serverOptions_pam"] != pam_mode;

    fastReloadChanged = self.pers["serverOptions_fastReloadFix"] != level.scr_fast_reload_fix;
    diagonalChanged = self.pers["serverOptions_diagonalFix"] != level.scr_diagonal_fix;
    shotgunChanged = self.pers["serverOptions_shotgunRebalance"] != level.scr_shotgun_rebalance;
    pronePeakChanged = self.pers["serverOptions_pronePeakFix"] != level.scr_prone_peak_fix;

    fastRestart = self.pers["serverOptions_map"] == "fast_restart";

	// Because RCON commands can come only each 1 second, we need to separe them by wait command
	// Player typically run at 250 FPS, so wait 250 = 1sec
	// To be sure it will execute, we will wait 260

    if (fastRestart)
    {
        rconString += "/rcon fast_restart;";
        execString += "rcon fast_restart;";
    }
    else
    {
        if (gametypeChanged)
        {
            rconString += "/rcon g_gametype " + self.pers["serverOptions_gametype"] + "; ";
            execString += "rcon g_gametype " + self.pers["serverOptions_gametype"] + "; wait 260;";
        }

        if (pamChanged && self.pers["serverOptions_gametype"] != "strat") // dont change pam if gametype is strat
        {
            rconString += "/rcon pam_mode " + self.pers["serverOptions_pam"] + "; ";
            execString += "rcon pam_mode " + self.pers["serverOptions_pam"] + "; wait 260;";
        }

        // If map of gametype is changed, map needs to be reseted
        if (mapChanged || gametypeChanged)
        {
            rconString += "/rcon map " + self.pers["serverOptions_map"] + "; ";
            execString += "rcon map " + self.pers["serverOptions_map"] + ";";
        }
        else if (fastRestart)
        {
          rconString += "/rcon fast_restart;";
          execString += "rcon fast_restart;";
        }

        // If nothing changed, we can change additional cvars
        if (!mapChanged && !gametypeChanged && !pamChanged)
        {
          if (fastReloadChanged)
          {
            rconString += "/rcon scr_fast_reload_fix " + self.pers["serverOptions_fastReloadFix"] + "; ";
            execString += "rcon scr_fast_reload_fix " + self.pers["serverOptions_fastReloadFix"] + "; wait 260;";
          }

          if (diagonalChanged)
          {
            rconString += "/rcon scr_diagonal_fix " + self.pers["serverOptions_diagonalFix"] + "; ";
            execString += "rcon scr_diagonal_fix " + self.pers["serverOptions_diagonalFix"] + "; wait 260;";
          }

          if (shotgunChanged)
          {
            rconString += "/rcon scr_shotgun_rebalance " + self.pers["serverOptions_shotgunRebalance"] + "; ";
            execString += "rcon scr_shotgun_rebalance " + self.pers["serverOptions_shotgunRebalance"] + "; wait 260;";
          }

          if (pronePeakChanged)
          {
            rconString += "/rcon scr_prone_peak_fix " + self.pers["serverOptions_pronePeakFix"] + "; ";
            execString += "rcon scr_prone_peak_fix " + self.pers["serverOptions_pronePeakFix"] + "; wait 260;";
          }
        }
    }


    // -1 = not visible
    // -2 = disabled
    gametype = self.pers["serverOptions_gametype"];
    sd = -1;
    dm = -1;
	tdm = -1;
    strat = -1;
    //TODO cheats = self.pers["serverOptions_cheats"];

    pam = self.pers["serverOptions_pam"];
    map = self.pers["serverOptions_map"];

    // Show disabled pam options if fast_Restart is selected
    if (map == "fast_restart")
    {
      if (gametype == "sd")
          sd = -2;
      else if (gametype == "dm")
          dm = -2;
	  else if (gametype == "tdm")
          tdm = -2;
      else if (gametype == "strat")
          strat = -2;

      gametype = -2;
    }
    // Highlight correct pam mode
    else if (gametype == "sd")
        sd = pam;
    else if (gametype == "dm")
        dm = pam;
    else if (gametype == "tdm")
        tdm = pam;
    else if (gametype == "strat")
        strat = pam;

    self setClientCvar("ui_rcon_map_gametype", gametype);

    self setClientCvar("ui_rcon_map_pam_sd", sd);
    self setClientCvar("ui_rcon_map_pam_dm", dm);
    self setClientCvar("ui_rcon_map_pam_tdm", tdm);
    self setClientCvar("ui_rcon_map_pam_strat", strat);

    // If nothing changed, we can change additional cvars
    if (!mapChanged && !gametypeChanged && !pamChanged)
    {
      self setClientCvar("ui_rcon_map_fast_reload_fix", self.pers["serverOptions_fastReloadFix"]);
      self setClientCvar("ui_rcon_map_diagonal_fix", self.pers["serverOptions_diagonalFix"]);
      self setClientCvar("ui_rcon_map_shotgun_rebalance", self.pers["serverOptions_shotgunRebalance"]);
      self setClientCvar("ui_rcon_map_prone_peak_fix", self.pers["serverOptions_pronePeakFix"]);
    }
    else
    {
        self setClientCvar("ui_rcon_map_fast_reload_fix", "-2"); // disabled
        self setClientCvar("ui_rcon_map_diagonal_fix", "-2"); // disabled
        self setClientCvar("ui_rcon_map_shotgun_rebalance", "-2"); // disabled
        self setClientCvar("ui_rcon_map_prone_peak_fix", "-2"); // disabled
    }


    self setClientCvar("ui_rcon_map_execString", rconString);
    self setClientCvar("ui_rcon_map_exec", execString);

    if (rconString.size > 60)
        self setClientCvar("ui_rcon_map_exec_size", "1"); // smaller font size
    else
        self setClientCvar("ui_rcon_map_exec_size", "0");

}

startsWith(string, substring)
{
	match = true;
	for (i = 0; i < string.size && i < substring.size; i++)
	{
		if (string[i] != substring[i])
		{
			match = false;
			break;
		}
	}

	return match;
}


isDigitalNumber(string)
{
	isDigitalNumber = true;
	for (i = 0; i < string.size; i++)
	{
		numberString = string[i];

		if (numberString != "0" &&
			numberString != "1" &&
			numberString != "2" &&
			numberString != "3" &&
			numberString != "4" &&
			numberString != "5" &&
			numberString != "6" &&
			numberString != "7" &&
			numberString != "8" &&
			numberString != "9")
		{
			isDigitalNumber = false;
			break;
		}
	}

	return isDigitalNumber;
}
