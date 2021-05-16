#include maps\mp\gametypes\global\_global;

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

	map["mp_toujane_fix_v2"] = true;
	map["mp_burgundy_fix_v1"] = true;
	map["mp_dawnville_fix"] = true;
	map["mp_matmata_fix"] = true;
	map["mp_carentan_fix"] = true;

	map["fast_restart"] = 15; // special id for performing fast_restart




	gametype = [];
	gametype["sd"] = 0;
	gametype["dm"] = 1;
	gametype["strat"] = 2;
	gametype["tdm"] = 3;

	// List of SD pam modes
	pam_sd = [];
	modes = maps\mp\gametypes\global\rules::getListOfRuleSets("sd");
	for (i = 0; i < modes.size; i++)
		pam_sd[modes[i]] = i;

	// List of DM pam modes
	pam_dm = [];
	modes = maps\mp\gametypes\global\rules::getListOfRuleSets("dm");
	for (i = 0; i < modes.size; i++)
		pam_dm[modes[i]] = i;

	// List of TDM pam modes
	pam_tdm = [];
	modes = maps\mp\gametypes\global\rules::getListOfRuleSets("tdm");
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
	level.serverOptions.customSettingsDefalts = [];


	addEventListener("onConnected",   ::onConnected);
	addEventListener("onMenuResponse",   ::onMenuResponse);

	level thread checkingRconCvarThread();
}

onConnected()
{
	self.pers["rcon_map_apply_cvars"] = [];
	self.pers["rcon_map_apply_action"] = "";

	generateUUID();
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




generateUUID()
{
	if (!isDefined(self.pers["rcon_map_uuid"]))
	{
		// Generate random hash
		avaibleChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789";
		hash = "";
		for (len = 0; len < 32; len++)
		{
			randIndex = randomintrange(0, avaibleChars.size);// Returns a random integer r, where min <= r < max
			hash = hash + "" + avaibleChars[randIndex];
		}
		//println("uuid " + hash + " generated for player" +self.name);

		self.pers["rcon_map_uuid"] = hash;
		self setClientCvar2("ui_rcon_map_exec", "rcon set rcon_map_uuid "+ hash);
	}
	else
	{
		// Update vstr cvar because level.rconCvar may be changed
		self setClientCvar2("ui_rcon_map_exec", "rcon set rcon_map_uuid "+ self.pers["rcon_map_uuid"]);
	}
}


checkingRconCvarThread()
{
    // Define or reset cvar to default
    setCvar("rcon_map_uuid", "");

    for(;;)
    {
        wait level.fps_multiplier * 0.5;

        // Check if cvar is changed
        cvarValue = getCvar("rcon_map_uuid");
        if (cvarValue != "")
        {
            // Check if cvar value equals to UUID of some player
            players = getentarray("player", "classname");
            for(i = 0; i < players.size; i++)
            {
            	player = players[i];

		// This player is player who set the correct uuid
                if (isDefined(player.pers["rcon_map_uuid"]) && cvarValue == player.pers["rcon_map_uuid"])
                {
			// Apply cvar changes
			for(j = 0; j < player.pers["rcon_map_apply_cvars"].size; j++)
			{
				cvar = player.pers["rcon_map_apply_cvars"][j];
				setCvar(cvar["name"], cvar["value"]);

				if (player.pers["rcon_map_apply_action"] == "")
					wait level.fps_multiplier * 0.5;
			}

			// Apply action
			if (player.pers["rcon_map_apply_action"] != "")
			{
				if (player.pers["rcon_map_apply_action"] == "fast_restart")
					map_restart(false);
				else
					map(player.pers["rcon_map_apply_action"], false);
			}

			break;
                }
            }

            setCvar("rcon_map_uuid", "");
        }
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

    else if (startsWith(response, "mode_settings_"))
    {
        numberInput = getsubstr(response, 14);
	onModeSettingsChange(numberInput);
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

    else if (startsWith(response, "prone_peek_fix_"))
    {
        numberInput = getsubstr(response, 15);
        numberSafe = 0;
        if (numberInput == "1")
            numberSafe = 1;
        // Save selected
        self.pers["serverOptions_pronePeekFix"] = numberSafe;
        // Update string
        mapOptions_updateRconCommand();
    }

    else if (startsWith(response, "mg_clip_fix_"))
    {
        numberInput = getsubstr(response, 12);
        numberSafe = 0;
        if (numberInput == "1")
            numberSafe = 1;
        // Save selected
        self.pers["serverOptions_mgClipFix"] = numberSafe;
        // Update string
        mapOptions_updateRconCommand();
    }

    else if (startsWith(response, "hitbox_rebalance_"))
    {
        numberInput = getsubstr(response, 17);
        numberSafe = 0;
        if (numberInput == "1")
            numberSafe = 1;
        // Save selected
        self.pers["serverOptions_hitboxRebalance"] = numberSafe;
        // Update string
        mapOptions_updateRconCommand();
    }

    else if (startsWith(response, "killcam_"))
    {
        numberInput = getsubstr(response, 8);
        numberSafe = 0;
        if (numberInput == "1")
            numberSafe = 1;
        // Save selected
        self.pers["serverOptions_killcam"] = numberSafe;
        // Update string
        mapOptions_updateRconCommand();
    }



    else if (startsWith(response, "score_allies_+"))
    {
	    self.pers["serverOptions_scoreAllies"]++;
	    mapOptions_updateRconCommand();
    }
    else if (startsWith(response, "score_allies_-"))
    {
	    if (self.pers["serverOptions_scoreAllies"] > -1)
	    {
		    self.pers["serverOptions_scoreAllies"]--;
		    mapOptions_updateRconCommand();
	    }
    }

    else if (startsWith(response, "score_axis_+"))
    {
	    self.pers["serverOptions_scoreAxis"]++;
	    mapOptions_updateRconCommand();
    }
    else if (startsWith(response, "score_axis_-"))
    {
	    if (self.pers["serverOptions_scoreAxis"] > -1)
	    {
		    self.pers["serverOptions_scoreAxis"]--;
		    mapOptions_updateRconCommand();
	    }
    }
}

onOpen(pam_mode)
{
  // Set selections to default
  self.pers["serverOptions_map"] =        level.mapname;
  self.pers["serverOptions_gametype"] =   level.gametype;
  self.pers["serverOptions_pam"] =        pam_mode; // default pam mode
  self.pers["serverOptions_modeSettingsCustom"] = level.pam_mode_custom;

  self.pers["serverOptions_fastReloadFix"] = level.scr_fast_reload_fix;
  self.pers["serverOptions_shotgunRebalance"] = level.scr_shotgun_rebalance;
  self.pers["serverOptions_pronePeekFix"] = level.scr_prone_peek_fix;
  self.pers["serverOptions_mgClipFix"] = level.scr_mg_peek_fix;
  self.pers["serverOptions_hitboxRebalance"] = level.scr_hand_hitbox_fix;
  self.pers["serverOptions_killcam"] = level.scr_killcam;

  self.pers["serverOptions_scoreAllies"] = -1;
  self.pers["serverOptions_scoreAxis"] = -1;

  loadPAMArray(); // update level.serverOptions.pamArray correctly if was changed before

  self setClientCvar2("ui_rcon_map_map", self.pers["serverOptions_map"]);

  mapOptions_updateRconCommand();
}



onMapChange(mapInput)
{
  map = level.mapname; // set to default
  if (isDefined(level.serverOptions.mapArray[mapInput]))
      map = mapInput;

  // Save selected map
  self.pers["serverOptions_map"] = map;

  self setClientCvar2("ui_rcon_map_map", map);

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

  // Reset custom settings
  self.pers["serverOptions_modeSettingsCustom"] = false;
  // Load custom settings of new selected pam mode
  loadCustomSettings();



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

  // Reset custom settings
  self.pers["serverOptions_modeSettingsCustom"] = false;
  // Load custom settings of new selected pam mode
  loadCustomSettings();

  mapOptions_updateRconCommand();
}

onModeSettingsChange(numberInput)
{
	numberSafe = 0;
        if (numberInput == "1")
            numberSafe = 1;
        // Save selected
        self.pers["serverOptions_modeSettingsCustom"] = numberSafe;

        // Load custom settings of new selected pam mode
	if (self.pers["serverOptions_modeSettingsCustom"] == 0)
		loadCustomSettings();

        // Update string
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






loadCustomSettings()
{
	//println("# Getting rule cvars for gametype:"+self.pers["serverOptions_gametype"] + ", pam:"+self.pers["serverOptions_pam"]);

	// Load default settings for currently selected pam mode
	cvarDefaults = maps\mp\gametypes\global\rules::Get_CvarDefaultValues(self.pers["serverOptions_gametype"], self.pers["serverOptions_pam"]);

	if (isDefined(cvarDefaults))
	{
		if (isDefined(cvarDefaults["scr_fast_reload_fix"])) 	self.pers["serverOptions_fastReloadFix"] = cvarDefaults["scr_fast_reload_fix"];
		if (isDefined(cvarDefaults["scr_shotgun_rebalance"])) 	self.pers["serverOptions_shotgunRebalance"] = cvarDefaults["scr_shotgun_rebalance"];
		if (isDefined(cvarDefaults["scr_prone_peek_fix"])) 	self.pers["serverOptions_pronePeekFix"] = cvarDefaults["scr_prone_peek_fix"];
		if (isDefined(cvarDefaults["scr_mg_peek_fix"])) 	self.pers["serverOptions_mgClipFix"] = cvarDefaults["scr_mg_peek_fix"];
		if (isDefined(cvarDefaults["scr_hand_hitbox_fix"])) 	self.pers["serverOptions_hitboxRebalance"] = cvarDefaults["scr_hand_hitbox_fix"];
		if (isDefined(cvarDefaults["scr_killcam"])) 	self.pers["serverOptions_killcam"] = cvarDefaults["scr_killcam"];
	}
}

addCvarToChange(name, value)
{
	cvar["name"] = name;
	cvar["value"] = value;
	self.pers["rcon_map_apply_cvars"][self.pers["rcon_map_apply_cvars"].size] = cvar;
}

mapOptions_updateRconCommand()
{
	rconString = "";

	pam_mode = level.pam_mode;
	if (level.gametype == "strat")
		pam_mode = "strat"; // strat does not have pam modes

	gametypeChanged = self.pers["serverOptions_gametype"] != level.gametype;
	mapChanged = self.pers["serverOptions_map"] != level.mapname;
	pamChanged = self.pers["serverOptions_pam"] != pam_mode;
	customSettingsChanged = self.pers["serverOptions_modeSettingsCustom"] != level.pam_mode_custom;

	fastReloadChanged = self.pers["serverOptions_fastReloadFix"] != level.scr_fast_reload_fix;
	shotgunChanged = self.pers["serverOptions_shotgunRebalance"] != level.scr_shotgun_rebalance;
	pronePeekChanged = self.pers["serverOptions_pronePeekFix"] != level.scr_prone_peek_fix;
	mgClipChanged = self.pers["serverOptions_mgClipFix"] != level.scr_mg_peek_fix;
	hitboxRebalanceChanged = self.pers["serverOptions_hitboxRebalance"] != level.scr_hand_hitbox_fix;
	killcamChanged = self.pers["serverOptions_killcam"] != level.scr_killcam;

	scoreAlliesChanged = self.pers["serverOptions_scoreAllies"] != -1;
	scoreAxisChanged = self.pers["serverOptions_scoreAxis"] != -1;
	scoreAllowed = game["readyup_first_run"] && self.pers["serverOptions_gametype"] == "sd";

	fastRestart = self.pers["serverOptions_map"] == "fast_restart";
	stratSelected = self.pers["serverOptions_gametype"] == "strat";
	customSettings = self.pers["serverOptions_modeSettingsCustom"];

	pamIsValid = isDefined(level.serverOptions.pamArray[self.pers["serverOptions_pam"]]) || stratSelected;

	// Because RCON commands can come only each 1 second, we need to separe them by wait command
	// Player typically run at 250 FPS, so wait 250 = 1sec
	// To be sure it will execute, we will wait 260

	self.pers["rcon_map_apply_cvars"] = [];
	self.pers["rcon_map_apply_action"] = "";

	if (fastRestart)
	{
		rconString += "/rcon fast_restart;";
		self.pers["rcon_map_apply_action"] = "fast_restart";
	}
	else
	{
		if (pamIsValid)
		{

			if (gametypeChanged)
			{
				rconString += "/rcon g_gametype " + self.pers["serverOptions_gametype"] + "; ";
				addCvarToChange("g_gametype", self.pers["serverOptions_gametype"]);
			}

			if (customSettingsChanged)
			{
				rconString += "/rcon pam_mode_custom " + customSettings + "; ";
				addCvarToChange("pam_mode_custom", customSettings);
			}

			if (pamChanged && !stratSelected) // dont change pam if gametype is strat
			{
				rconString += "/rcon pam_mode " + self.pers["serverOptions_pam"] + "; ";
				addCvarToChange("pam_mode", self.pers["serverOptions_pam"]);
			}

			if (scoreAllowed && scoreAlliesChanged)
			{
				rconString += "/rcon scr_score_allies " + self.pers["serverOptions_scoreAllies"] + "; ";
				addCvarToChange("scr_score_allies", self.pers["serverOptions_scoreAllies"]);
			}
			if (scoreAllowed && scoreAxisChanged)
			{
				rconString += "/rcon scr_score_axis " + self.pers["serverOptions_scoreAxis"] + "; ";
				addCvarToChange("scr_score_axis", self.pers["serverOptions_scoreAxis"]);
			}

			if (customSettings == 1)
			{
				if (fastReloadChanged)
				{
					rconString += "/rcon scr_fast_reload_fix " + self.pers["serverOptions_fastReloadFix"] + "; ";
					addCvarToChange("scr_fast_reload_fix", self.pers["serverOptions_fastReloadFix"]);
				}
				if (shotgunChanged)
				{
					rconString += "/rcon scr_shotgun_rebalance " + self.pers["serverOptions_shotgunRebalance"] + "; ";
					addCvarToChange("scr_shotgun_rebalance", self.pers["serverOptions_shotgunRebalance"]);
				}
				if (pronePeekChanged)
				{
					rconString += "/rcon scr_prone_peek_fix " + self.pers["serverOptions_pronePeekFix"] + "; ";
					addCvarToChange("scr_prone_peek_fix", self.pers["serverOptions_pronePeekFix"]);
				}
				if (mgClipChanged)
				{
					rconString += "/rcon scr_mg_peek_fix " + self.pers["serverOptions_mgClipFix"] + "; ";
					addCvarToChange("scr_mg_peek_fix", self.pers["serverOptions_mgClipFix"]);
				}
				if (hitboxRebalanceChanged)
				{
					rconString += "/rcon scr_hand_hitbox_fix " + self.pers["serverOptions_hitboxRebalance"] + "; ";
					addCvarToChange("scr_hand_hitbox_fix", self.pers["serverOptions_hitboxRebalance"]);
				}
				if (killcamChanged)
				{
					rconString += "/rcon scr_killcam " + self.pers["serverOptions_killcam"] + "; ";
					addCvarToChange("scr_killcam", self.pers["serverOptions_killcam"]);
				}
			}

			// If map of gametype is changed, map needs to be reseted
			if (mapChanged || gametypeChanged)
			{
				rconString += "/rcon map " + self.pers["serverOptions_map"] + "; ";
				self.pers["rcon_map_apply_action"] = self.pers["serverOptions_map"];
			}
			else if (pamChanged)
			{
				rconString += "/rcon fast_restart;";
				self.pers["rcon_map_apply_action"] = "fast_restart";
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

    pam = self.pers["serverOptions_pam"];
    map = self.pers["serverOptions_map"];

    // Show disabled pam options if fast_Restart is selected
    if (fastRestart)
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

    self setClientCvar2("ui_rcon_map_gametype", gametype);

    self setClientCvar2("ui_rcon_map_pam_sd", sd);
    self setClientCvar2("ui_rcon_map_pam_dm", dm);
    self setClientCvar2("ui_rcon_map_pam_tdm", tdm);
    self setClientCvar2("ui_rcon_map_pam_strat", strat);


	if (self.pers["serverOptions_scoreAllies"] == -1 || !scoreAllowed)
    		self setClientCvar2("ui_rcon_map_score_allies", "-");
	else
		self setClientCvar2("ui_rcon_map_score_allies", self.pers["serverOptions_scoreAllies"]);

	if (self.pers["serverOptions_scoreAxis"] == -1 || !scoreAllowed)
    		self setClientCvar2("ui_rcon_map_score_axis", "-");
	else
		self setClientCvar2("ui_rcon_map_score_axis", self.pers["serverOptions_scoreAxis"]);


	if (scoreAllowed)
		self setClientCvar2("ui_rcon_map_score_enabled", 1);
	else
		self setClientCvar2("ui_rcon_map_score_enabled", 0);



	if (pamIsValid && !fastRestart)
	{

		self setClientCvar2("ui_rcon_map_mode_settings", customSettings);


		// If custom settings are not selected, disable not sleected option
		val0 = self.pers["serverOptions_fastReloadFix"];
		val1 = self.pers["serverOptions_fastReloadFix"];
		if (!customSettings && !val1)
			val1 = "-2";
		if (!customSettings && val0)
			val0 = "-2";
		self setClientCvar2("ui_rcon_map_fast_reload_fix_0", val0);
		self setClientCvar2("ui_rcon_map_fast_reload_fix_1", val1);


		// If custom settings are not selected, disable not sleected option
		val0 = self.pers["serverOptions_shotgunRebalance"];
		val1 = self.pers["serverOptions_shotgunRebalance"];
		if (!customSettings && !val1)
			val1 = "-2";
		if (!customSettings && val0)
			val0 = "-2";
		self setClientCvar2("ui_rcon_map_shotgun_rebalance_0", val0);
		self setClientCvar2("ui_rcon_map_shotgun_rebalance_1", val1);


		// If custom settings are not selected, disable not sleected option
		val0 = self.pers["serverOptions_pronePeekFix"];
		val1 = self.pers["serverOptions_pronePeekFix"];
		if (!customSettings && !val1)
			val1 = "-2";
		if (!customSettings && val0)
			val0 = "-2";
		self setClientCvar2("ui_rcon_map_prone_peek_fix_0", val0);
		self setClientCvar2("ui_rcon_map_prone_peek_fix_1", val1);


		// If custom settings are not selected, disable not sleected option
		val0 = self.pers["serverOptions_mgClipFix"];
		val1 = self.pers["serverOptions_mgClipFix"];
		if (!customSettings && !val1)
			val1 = "-2";
		if (!customSettings && val0)
			val0 = "-2";
		self setClientCvar2("ui_rcon_map_mg_clip_fix_0", val0);
		self setClientCvar2("ui_rcon_map_mg_clip_fix_1", val1);


		// If custom settings are not selected, disable not sleected option
		val0 = self.pers["serverOptions_hitboxRebalance"];
		val1 = self.pers["serverOptions_hitboxRebalance"];
		if (!customSettings && !val1)
			val1 = "-2";
		if (!customSettings && val0)
			val0 = "-2";
		self setClientCvar2("ui_rcon_map_hitbox_rebalance_0", val0);
		self setClientCvar2("ui_rcon_map_hitbox_rebalance_1", val1);


		// If custom settings are not selected, disable not sleected option
		val0 = self.pers["serverOptions_killcam"];
		val1 = self.pers["serverOptions_killcam"];
		if (!customSettings && !val1)
			val1 = "-2";
		if (!customSettings && val0)
			val0 = "-2";
		self setClientCvar2("ui_rcon_map_killcam_0", val0);
		self setClientCvar2("ui_rcon_map_killcam_1", val1);
	}
	else
	{
		// Disabled
		self setClientCvar2("ui_rcon_map_mode_settings", -2);
		self setClientCvar2("ui_rcon_map_fast_reload_fix_0", -2);
		self setClientCvar2("ui_rcon_map_fast_reload_fix_1", -2);
		self setClientCvar2("ui_rcon_map_shotgun_rebalance_0", -2);
		self setClientCvar2("ui_rcon_map_shotgun_rebalance_1", -2);
		self setClientCvar2("ui_rcon_map_prone_peek_fix_0", -2);
		self setClientCvar2("ui_rcon_map_prone_peek_fix_1", -2);
		self setClientCvar2("ui_rcon_map_mg_clip_fix_0", -2);
		self setClientCvar2("ui_rcon_map_mg_clip_fix_1", -2);
		self setClientCvar2("ui_rcon_map_hitbox_rebalance_0", -2);
		self setClientCvar2("ui_rcon_map_hitbox_rebalance_1", -2);
		self setClientCvar2("ui_rcon_map_killcam_1", -2);
		self setClientCvar2("ui_rcon_map_killcam_0", -2);
	}



    self setClientCvar2("ui_rcon_map_execString", rconString);

    if (rconString.size > 60)
        self setClientCvar2("ui_rcon_map_exec_size", "1"); // smaller font size
    else
        self setClientCvar2("ui_rcon_map_exec_size", "0");

}
