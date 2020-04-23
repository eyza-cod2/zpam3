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

    gametype = [];
    gametype["sd"] = 0;
    gametype["strat"] = 1;

	pam_sd = [];
	modes = maps\pam\rules\rules::getListOfRuleSets("sd");
	for (i = 0; i < modes.size; i++)
		pam_sd[modes[i]] = i;

	pam_strat["strat"] = 1;


    pam["sd"] = pam_sd;
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

        // Set selections to default
        self.pers["serverOptions_map"] =        level.mapname;
        self.pers["serverOptions_gametype"] =   level.gametype;
        self.pers["serverOptions_pam"] =        pam_mode; // default pam mode
        self.pers["serverOptions_cheats"] =     getCvarInt("sv_cheats");

        updatePAMArray(); // update level.serverOptions.pamArray correctly if was changed before

        self setClientCvar("ui_rcon_map_map", self.pers["serverOptions_map"]);
        self setClientCvar("ui_rcon_map_gametype", self.pers["serverOptions_gametype"]);

        // Show pam modes according to selected gametype
        loadPAMModeAndCheatsSettings();

        mapOptions_updateRconCommand();
    }

    else if (response == "fast_restart")
    {
        if (self.pers["rcon_logged_in"])
        {
            self closeMenu();
            self closeIngameMenu();

            // Will disable all comming map-restrat (so pam_mode can be changed correctly)
            level.pam_mode_change = true;

            self iprintlnbold("^3Applying fast_restart...");

            wait level.fps_multiplier * 1.5;

            map_restart(false); // fast_restart
        }
    }

    else if (startsWith(response, "map_"))
    {
        mapInput = getsubstr(response, 4);

		map = level.mapname; // set to default
        if (isDefined(level.serverOptions.mapArray[mapInput]))
            map = mapInput;

        // Save selected map
        self.pers["serverOptions_map"] = map;

        self setClientCvar("ui_rcon_map_map", map);

        mapOptions_updateRconCommand();
    }

    else if (startsWith(response, "gametype_"))
    {
        gametypeInput = getsubstr(response, 9);

		gametype = level.gametype; // set to default
        if (isDefined(level.serverOptions.gametypeArray[gametypeInput]))
            gametype = gametypeInput;

        // Save selected gametype
        self.pers["serverOptions_gametype"] = gametype;

        self setClientCvar("ui_rcon_map_gametype", gametype);

        // Load PAM modes according to new selected gametype
        updatePAMArray();

        loadPAMModeAndCheatsSettings();

        mapOptions_updateRconCommand();
    }

    else if (startsWith(response, "pam_"))
    {
        pam = level.pam_mode;
        if (level.gametype == "strat")
            pam = "strat"; // strat does not have pam modes

        pamInput = getsubstr(response, 4);

        if (isDefined(level.serverOptions.pamArray[pamInput]))
			pam = pamInput;

        // Save selected gametype
        self.pers["serverOptions_pam"] = pam;

        loadPAMModeAndCheatsSettings();

        mapOptions_updateRconCommand();
    }


    else if (startsWith(response, "cheats_"))
    {
        numberInput = getsubstr(response, 7);
        numberSafe = 0;

        if (numberInput == "1")
            numberSafe = 1;

        // Save selected gametype
        self.pers["serverOptions_cheats"] = numberSafe;

        loadPAMModeAndCheatsSettings();

        mapOptions_updateRconCommand();
    }
}

updatePAMArray()
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
loadPAMModeAndCheatsSettings()
{
    sd = -1;
    strat = -1;

    // Selected gametype
    gametype = self.pers["serverOptions_gametype"];
    pam = self.pers["serverOptions_pam"];

    if (gametype == "sd")
        sd = pam;
    else if (gametype == "strat")
        strat = pam;

    self setClientCvar("ui_rcon_map_pam_sd", sd);
    self setClientCvar("ui_rcon_map_pam_strat", strat);

    self setClientCvar("ui_rcon_map_cheats", self.pers["serverOptions_cheats"]);
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
    cheatsChanged = self.pers["serverOptions_cheats"] != getCvarInt("sv_cheats");

	// Because RCON commands can come only each 1 second, we need to separe them by wait command
	// Player typically run at 250 FPS, so wait 250 = 1sec
	// To be sure it will execute, we will wait 260

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
    if (mapChanged || gametypeChanged || pamChanged || cheatsChanged)
    {
        if (self.pers["serverOptions_cheats"] == 1)
        {
            rconString += "/rcon devmap " + self.pers["serverOptions_map"] + "; ";
            execString += "rcon devmap " + self.pers["serverOptions_map"] + ";";
        }
        else if (mapChanged || cheatsChanged || gametypeChanged)
        {
            rconString += "/rcon map " + self.pers["serverOptions_map"] + "; ";
            execString += "rcon map " + self.pers["serverOptions_map"] + ";";
        }
		else
		{
			rconString += "/rcon fast_restart;";
            execString += "rcon fast_restart;";
		}
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
