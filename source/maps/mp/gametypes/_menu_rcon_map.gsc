#include maps\mp\gametypes\global\_global;

init()
{
	map = [];
	map["mp_breakout"] = true;
	map["mp_brecourt"] = true;
	map["mp_burgundy"] = true;
	map["mp_carentan"] = true;
	map["mp_dawnville"] = true;
	map["mp_decoy"] = true;
	map["mp_downtown"] = true;
	map["mp_farmhouse"] = true;
	map["mp_harbor"] = true;
	map["mp_leningrad"] = true;
	map["mp_matmata"] = true;
	map["mp_railyard"] = true;
	map["mp_rhine"] = true;
	map["mp_toujane"] = true;
	map["mp_trainstation"] = true;
	map["mp_toujane_fix"] = true;
	map["mp_burgundy_fix"] = true;
	map["mp_dawnville_fix"] = true;
	map["mp_matmata_fix"] = true;
	map["mp_carentan_fix"] = true;
	map["mp_breakout_tls"] = true;
	map["mp_chelm_fix"] = true;
	map["wawa_3daim"] = true;
	map["mp_crossroads"] = true;
	map["mp_dawnville_sun"] = true;
	map["mp_leningrad_tls"] = true;
	map["mp_trainstation_fix"] = true;
	map["mp_vallente_fix"] = true;
	map["mp_carentan_bal"] = true;
	map["mp_railyard_mjr"] = true;
	map["mp_leningrad_mjr"] = true;

	map["fast_restart"] = true;




	gametype = [];
	gametype["sd"] = 0;
	gametype["dm"] = 1;
	gametype["strat"] = 2;
	gametype["tdm"] = 3;
	gametype["hq"] = 4;
	gametype["ctf"] = 5;
	gametype["htf"] = 6;
	gametype["re"] = 7;



	level.rcon_map = spawnStruct();

	level.rcon_map.gametypeArray = gametype;
	level.rcon_map.mapArray = map;


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
		availableChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789";
		hash = "";
		for (len = 0; len < 32; len++)
		{
			randIndex = randomintrange(0, availableChars.size);// Returns a random integer r, where min <= r < max
			hash = hash + "" + availableChars[randIndex];
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
				if (maps\mp\gametypes\_matchinfo::canMapBeChanged())
				{
					if (player.pers["rcon_map_apply_action"] == "fast_restart")
						map_restart(false);
					else
						map(player.pers["rcon_map_apply_action"], false);
				}
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

    else if (startsWith(response, "cvars_"))
    {
        pamInput = getsubstr(response, 6);
	onKeepChangedCvarChange(pamInput);
    }


    else if (startsWith(response, "score_allies_+"))
    {
	    self.pers["rcon_map_scoreAllies"]++;
	    mapOptions_updateRconCommand();
    }
    else if (startsWith(response, "score_allies_-"))
    {
	    if (self.pers["rcon_map_scoreAllies"] > -1)
	    {
		    self.pers["rcon_map_scoreAllies"]--;
		    mapOptions_updateRconCommand();
	    }
    }

    else if (startsWith(response, "score_axis_+"))
    {
	    self.pers["rcon_map_scoreAxis"]++;
	    mapOptions_updateRconCommand();
    }
    else if (startsWith(response, "score_axis_-"))
    {
	    if (self.pers["rcon_map_scoreAxis"] > -1)
	    {
		    self.pers["rcon_map_scoreAxis"]--;
		    mapOptions_updateRconCommand();
	    }
    }
}


onOpen(pam_mode)
{
	// Set selections to default
	self.pers["rcon_map_map"] =        level.mapname;
	self.pers["rcon_map_gametype"] =   level.gametype;
	self.pers["rcon_map_pam"] =        pam_mode; // default pam mode
	self.pers["rcon_map_keepChangedCvars"] = true;

	self.pers["rcon_map_scoreAllies"] = -1;
	self.pers["rcon_map_scoreAxis"] = -1;

	// Load PAM modes according to new selected gametype
	load_and_select_pam_mode();

	self setClientCvar2("ui_rcon_map_map", self.pers["rcon_map_map"]);

	mapOptions_updateRconCommand();
}



onMapChange(mapInput)
{
	map = level.mapname; // set to default
	if (isDefined(level.rcon_map.mapArray[mapInput]))
		map = mapInput;

	// Save selected map
	self.pers["rcon_map_map"] = map;

	self setClientCvar2("ui_rcon_map_map", map);

	mapOptions_updateRconCommand();
}



onGametypeChange(gametypeInput)
{
	gametype = level.gametype; // set to default
	if (isDefined(level.rcon_map.gametypeArray[gametypeInput]))
		gametype = gametypeInput;

	// If gametype is changed and fast_restart is selected, resotre actual map
	if (self.pers["rcon_map_map"] == "fast_restart")
		self.pers["rcon_map_map"] = level.mapname;

	// Save selected gametype
	self.pers["rcon_map_gametype"] = gametype;

	// Load PAM modes according to new selected gametype
	load_and_select_pam_mode();

	mapOptions_updateRconCommand();
}


onPamChange(pamInput)
{
	if (self.pers["rcon_map_gametype"] == "strat")
		return;

	// Parse and save individual sub modes
	saveSubPamMode(pamInput);

	// Save selected pam
	self.pers["rcon_map_pam"] = joinSubPamModes();

	loadSubPamModes();

	mapOptions_updateRconCommand();
}


saveSubPamMode(str)
{
	gametype = self.pers["rcon_map_gametype"];

	if ((gametype == "sd"  && (str == "comp")) ||
	    (gametype == "dm"  && (str == "comp" || str == "warmup")) ||
	    (gametype == "tdm" && (str == "comp")) ||
	    (gametype == "hq" && (str == "comp")) ||
	    (gametype == "ctf" && (str == "comp")) ||
	    (gametype == "htf" && (str == "comp")) ||
	    (gametype == "re" && (str == "comp")))
		self.pers["rcon_map_pam_league"] = str;

	else if ((gametype == "sd"  && (str == "mr3" || str == "mr10" || str == "mr12" || str == "mr15" || str == "20rounds")) ||
	         (gametype == "dm"  && (str == "10min" || str == "15min" || str == "30min" || str == "60min" || str == "unlim")) ||
		 (gametype == "tdm" && (str == "10min" || str == "15min" || str == "30min" || str == "60min" || str == "unlim")) ||
		 (gametype == "hq"  && (str == "10min" || str == "15min" || str == "30min" || str == "60min" || str == "unlim")) ||
		 (gametype == "ctf" && (str == "10min" || str == "15min" || str == "30min" || str == "60min" || str == "unlim")) ||
		 (gametype == "htf" && (str == "10min" || str == "15min" || str == "30min" || str == "60min" || str == "unlim")) ||
		 (gametype == "re"  && (str == "mr3" || str == "mr10" || str == "mr12" || str == "mr15" || str == "20rounds")))
	{
		if (self.pers["rcon_map_pam_gamesettings"] == str)
			self.pers["rcon_map_pam_gamesettings"] = "";
		else
			self.pers["rcon_map_pam_gamesettings"] = str;
	}
	else if (str == "na")
		self.pers["rcon_map_pam_na"] = !self.pers["rcon_map_pam_na"];
	else if (str == "1v1" || str == "2v2")
		self.pers["rcon_map_pam_2v2"] = !self.pers["rcon_map_pam_2v2"];
	else if (str == "draw")
		self.pers["rcon_map_pam_draw"] = !self.pers["rcon_map_pam_draw"];
	else if (str == "lan")
		self.pers["rcon_map_pam_lan"] = !self.pers["rcon_map_pam_lan"];
	else if (str == "custom")
		self.pers["rcon_map_pam_custom"] = !self.pers["rcon_map_pam_custom"];
	else if (str == "rifle")
		self.pers["rcon_map_pam_rifle"] = !self.pers["rcon_map_pam_rifle"];
}


loadSubPamModes()
{
	self.pers["rcon_map_pam_league"] = "";
	self.pers["rcon_map_pam_gamesettings"] = "";
	self.pers["rcon_map_pam_na"] = false;
	self.pers["rcon_map_pam_2v2"] = false;
	self.pers["rcon_map_pam_draw"] = false;
	self.pers["rcon_map_pam_lan"] = false;
	self.pers["rcon_map_pam_custom"] = false;
	self.pers["rcon_map_pam_rifle"] = false;

	array = splitString(self.pers["rcon_map_pam"], "_");

	for (i = 0; i < array.size; i++)
	{
		saveSubPamMode(array[i]);
	}
}


joinSubPamModes()
{
	str = self.pers["rcon_map_pam_league"];
	if (self.pers["rcon_map_pam_gamesettings"] != "") 	str += "_" + self.pers["rcon_map_pam_gamesettings"];
	if (self.pers["rcon_map_pam_rifle"]) 		str += "_rifle";
	if (self.pers["rcon_map_pam_na"])		str += "_na";
	if (self.pers["rcon_map_pam_2v2"]) 		str += "_2v2";
	if (self.pers["rcon_map_pam_draw"]) 		str += "_draw";
	if (self.pers["rcon_map_pam_lan"]) 		str += "_lan";
	if (self.pers["rcon_map_pam_custom"]) 		str += "_custom";
	return str;
}


load_and_select_pam_mode()
{
	// Load selected gametype
	gametype = self.pers["rcon_map_gametype"];
	pam_mode_selected = self.pers["rcon_map_pam"];
	pam_mode = level.pam_mode;

	if (maps\mp\gametypes\global\rules::IsValidPAMModeForGametype(gametype, pam_mode_selected))	// pam on previous gametype exists in new gametype - keep same
		self.pers["rcon_map_pam"] = pam_mode_selected;
	else if (maps\mp\gametypes\global\rules::IsValidPAMModeForGametype(gametype, pam_mode))
		self.pers["rcon_map_pam"] = pam_mode;
	else
		self.pers["rcon_map_pam"] = "comp";	// default selected

	loadSubPamModes();
}

onKeepChangedCvarChange(pamInput)
{
	if (pamInput == "keep")
	{
		self.pers["rcon_map_keepChangedCvars"] = true;
	}
	else if (pamInput == "restore")
	{
		self.pers["rcon_map_keepChangedCvars"] = false;
	}

	mapOptions_updateRconCommand();
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
	fastRestart = self.pers["rcon_map_map"] == "fast_restart";
	stratSelected = self.pers["rcon_map_gametype"] == "strat";
	gametypeChanged = self.pers["rcon_map_gametype"] != level.gametype;
	mapChanged = self.pers["rcon_map_map"] != level.mapname;
	pamChanged = self.pers["rcon_map_pam"] != pam_mode && !stratSelected;

	scoreAlliesChanged = self.pers["rcon_map_scoreAllies"] != -1;
	scoreAxisChanged = self.pers["rcon_map_scoreAxis"] != -1;
	scoreAllowed = level.scr_score_change_mode > 0 && (game["readyup_first_run"] || level.scr_score_change_mode == 2) && (self.pers["rcon_map_gametype"] == "sd" || self.pers["rcon_map_gametype"] == "re") && !fastRestart && !pamChanged && !gametypeChanged;

	changedCvarsAllowed = !fastRestart && !gametypeChanged && !pamChanged && level.pam_mode_custom; // enable that option only if cvars are changed

	pamIsValid = self.pers["rcon_map_pam"] != "" || stratSelected;




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
				rconString += "/rcon g_gametype " + self.pers["rcon_map_gametype"] + "; ";
				addCvarToChange("g_gametype", self.pers["rcon_map_gametype"]);
			}

			if (pamChanged && !stratSelected) // dont change pam if gametype is strat
			{
				rconString += "/rcon pam_mode " + self.pers["rcon_map_pam"] + "; ";
				addCvarToChange("pam_mode", self.pers["rcon_map_pam"]);
			}

			if (gametypeChanged || pamChanged)
			{
				addCvarToChange("pam_mode_custom", "0"); // if pam_mode is changed, we need to reset custom changes to load cvars correctly on map restart
			}

			if (changedCvarsAllowed && self.pers["rcon_map_keepChangedCvars"] == false)
			{
				rconString += "/rcon pam_mode_custom 0; ";
				addCvarToChange("pam_mode_custom", "0");
			}

			if (scoreAllowed && scoreAlliesChanged)
			{
				rconString += "/rcon scr_score_allies " + self.pers["rcon_map_scoreAllies"] + "; ";
				addCvarToChange("scr_score_allies", self.pers["rcon_map_scoreAllies"]);
			}
			if (scoreAllowed && scoreAxisChanged)
			{
				rconString += "/rcon scr_score_axis " + self.pers["rcon_map_scoreAxis"] + "; ";
				addCvarToChange("scr_score_axis", self.pers["rcon_map_scoreAxis"]);
			}

			// If map of gametype is changed, map needs to be reseted
			if (mapChanged || gametypeChanged)
			{
				rconString += "/rcon map " + self.pers["rcon_map_map"] + "; ";
				self.pers["rcon_map_apply_action"] = self.pers["rcon_map_map"];
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
	gametype = self.pers["rcon_map_gametype"];
	sd = "-1";
	dm = "-1";
	tdm = "-1";
	hq = "-1";
	ctf = "-1";
	htf = "-1";
	re = "-1";
	strat = "-1";

	sd_gamesettings = "-1";
	dm_gamesettings = "-1";
	tdm_gamesettings = "-1";
	hq_gamesettings = "-1";
	ctf_gamesettings = "-1";
	htf_gamesettings = "-1";
	re_gamesettings = "-1";

	pam_na = "0";
	pam_2v2 = "0";
	pam_draw = "0";
	pam_lan = "0";
	pam_custom = "0";
	pam_rifle = "0";

	keepChangedCvars = "-2";
	numOfChangedCvars = "";

	if (self.pers["rcon_map_pam_na"])
		pam_na = "1";
	if (self.pers["rcon_map_pam_2v2"])
		pam_2v2 = "1";
	if (self.pers["rcon_map_pam_draw"])
		pam_draw = "1";
	if (self.pers["rcon_map_pam_lan"])
		pam_lan = "1";
	if (self.pers["rcon_map_pam_custom"])
		pam_custom = "1";
	if (self.pers["rcon_map_pam_rifle"])
		pam_rifle = "1";


	// Show disabled pam options if fast_Restart is selected
	if (fastRestart)
	{
		if (gametype == "sd")
		{
			sd = "-2";
			sd_gamesettings = "-2";
		}
		else if (gametype == "dm")
		{
			dm = "-2";
			dm_gamesettings = "-2";
		}
		else if (gametype == "tdm")
		{
			tdm = "-2";
			tdm_gamesettings = "-2";
		}
		else if (gametype == "hq")
		{
			hq = "-2";
			hq_gamesettings = "-2";
		}
		else if (gametype == "ctf")
		{
			ctf = "-2";
			ctf_gamesettings = "-2";
		}
		else if (gametype == "htf")
		{
			htf = "-2";
			htf_gamesettings = "-2";
		}
		if (gametype == "re")
		{
			re = "-2";
			re_gamesettings = "-2";
		}
		else if (gametype == "strat")
		{
			strat = "-2";
		}

		gametype = "-2";

		pam_na = "-2";
		pam_2v2 = "-2";
		pam_draw = "-2";
		pam_lan = "-2";
		pam_custom = "-2";
		pam_rifle = "-2";
	}
	// Highlight correct pam mode
	else if (gametype == "sd")
	{
		sd = self.pers["rcon_map_pam_league"];
		sd_gamesettings = self.pers["rcon_map_pam_gamesettings"];
	}
	else if (gametype == "dm")
	{
		dm = self.pers["rcon_map_pam_league"];
		dm_gamesettings = self.pers["rcon_map_pam_gamesettings"];
	}
	else if (gametype == "tdm")
	{
		tdm = self.pers["rcon_map_pam_league"];
		tdm_gamesettings = self.pers["rcon_map_pam_gamesettings"];
	}
	else if (gametype == "hq")
	{
		hq = self.pers["rcon_map_pam_league"];
		hq_gamesettings = self.pers["rcon_map_pam_gamesettings"];
	}
	else if (gametype == "ctf")
	{
		ctf = self.pers["rcon_map_pam_league"];
		ctf_gamesettings = self.pers["rcon_map_pam_gamesettings"];
	}
	else if (gametype == "htf")
	{
		htf = self.pers["rcon_map_pam_league"];
		htf_gamesettings = self.pers["rcon_map_pam_gamesettings"];
	}
	else if (gametype == "re")
	{
		re = self.pers["rcon_map_pam_league"];
		re_gamesettings = self.pers["rcon_map_pam_gamesettings"];
	}
	else if (gametype == "strat")
		strat = "";


	if (gametype == "strat")
	{
		pam_na = "-1";
		pam_2v2 = "-1";
		pam_draw = "-1";
		pam_lan = "-1";
		pam_custom = "-1";
		pam_rifle = "-1";
	}

	if (changedCvarsAllowed)
	{
		if (self.pers["rcon_map_keepChangedCvars"])
			keepChangedCvars = "keep";
		else
			keepChangedCvars = "restore";

		num = maps\mp\gametypes\global\cvar_system::getNumberOfChangedCvars();

		numOfChangedCvars = "(changed cvars: ^1"+ num +"^7)";
	}



	self setClientCvar2("ui_rcon_map_gametype", gametype);

	self setClientCvar2("ui_rcon_map_pam_sd", sd);
	self setClientCvar2("ui_rcon_map_pam_dm", dm);
	self setClientCvar2("ui_rcon_map_pam_tdm", tdm);
	self setClientCvar2("ui_rcon_map_pam_hq", hq);
	self setClientCvar2("ui_rcon_map_pam_ctf", ctf);
	self setClientCvar2("ui_rcon_map_pam_htf", htf);
	self setClientCvar2("ui_rcon_map_pam_re", re);
	self setClientCvar2("ui_rcon_map_pam_strat", strat);

	self setClientCvar2("ui_rcon_map_pam_sd_gamesettings", sd_gamesettings);
	self setClientCvar2("ui_rcon_map_pam_dm_gamesettings", dm_gamesettings);
	self setClientCvar2("ui_rcon_map_pam_tdm_gamesettings", tdm_gamesettings);
	self setClientCvar2("ui_rcon_map_pam_hq_gamesettings", hq_gamesettings);
	self setClientCvar2("ui_rcon_map_pam_ctf_gamesettings", ctf_gamesettings);
	self setClientCvar2("ui_rcon_map_pam_htf_gamesettings", htf_gamesettings);
	self setClientCvar2("ui_rcon_map_pam_re_gamesettings", re_gamesettings);

	self setClientCvar2("ui_rcon_map_pam_na", pam_na);
	self setClientCvar2("ui_rcon_map_pam_2v2", pam_2v2);
	self setClientCvar2("ui_rcon_map_pam_draw", pam_draw);
	self setClientCvar2("ui_rcon_map_pam_lan", pam_lan);
	self setClientCvar2("ui_rcon_map_pam_custom", pam_custom);
	self setClientCvar2("ui_rcon_map_pam_rifle", pam_rifle);






	if (self.pers["rcon_map_scoreAllies"] == -1 || !scoreAllowed)
    		self setClientCvar2("ui_rcon_map_score_allies", "-");
	else
		self setClientCvar2("ui_rcon_map_score_allies", self.pers["rcon_map_scoreAllies"]);

	if (self.pers["rcon_map_scoreAxis"] == -1 || !scoreAllowed)
    		self setClientCvar2("ui_rcon_map_score_axis", "-");
	else
		self setClientCvar2("ui_rcon_map_score_axis", self.pers["rcon_map_scoreAxis"]);


	if (scoreAllowed)
		self setClientCvar2("ui_rcon_map_score_enabled", 1);
	else
		self setClientCvar2("ui_rcon_map_score_enabled", 0);



	self setClientCvar2("ui_rcon_map_cvars", keepChangedCvars);
	self setClientCvar2("ui_rcon_map_numberOfChangedCvars", numOfChangedCvars);





    self setClientCvar2("ui_rcon_map_execString", rconString);

    if (rconString.size > 60)
        self setClientCvar2("ui_rcon_map_exec_size", "1"); // smaller font size
    else
        self setClientCvar2("ui_rcon_map_exec_size", "0");

}
