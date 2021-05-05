Init()
{
	// Rules load - overide cvars with values for defined league mode
	switch (level.gametype)
	{
		case "sd": Load_SD_Rules(); break;
		case "dm": Load_DM_Rules(); break;
		case "tdm": Load_TDM_Rules(); break;
		case "strat": Load_Strat_Rules(); break;
	}

	// League name header (is defined in each mode file)
	if (!isdefined(game["leagueLogo"]))
		game["leagueLogo"] = "";
	if (!isdefined(game["leagueString"]))
		game["leagueString"] = &"^1Unknown pam mode name";
	if (!isDefined(game["leagueStringOvertime"]))
		game["leagueStringOvertime"] = undefined; // just to know
	/#
	if (!isDefined(game["ruleCvars"]))
		assertMsg("Rule cvars was not loaded!");
	#/

	// Precache
	if (game["firstInit"])
	{
		precacheString(game["leagueString"]);
		if (isDefined(game["leagueStringOvertime"]))
			precacheString(game["leagueStringOvertime"]);
		// Precache logo
		if (game["leagueLogo"] != "")
			precacheShader(game["leagueLogo"]);
	}

	println("Loaded rules for pam mode: " + level.pam_mode);
}

ruleCvarDefault(array, cvarName, value)
{
	array[toLower(cvarName)] = value;
	return array;
}

// Called when pam_mode cvar is initialized
getListOfRuleSets(gametype)
{
	valid_mode = [];

	if (gametype == "sd")
	{
		valid_mode[0] = "pub";
		valid_mode[1] = "pcw";
		valid_mode[2] = "cg_2v2";
		valid_mode[3] = "cg_mr12";
		valid_mode[4] = "cg";
		valid_mode[5] = "mr3";
		valid_mode[6] = "mr10";
		valid_mode[7] = "mr12";
		valid_mode[8] = "mr15";
		valid_mode[9] = "fun";
	}
	else if (gametype == "dm")
	{
		valid_mode[0] = "pub";
		valid_mode[1] = "warmup";
		valid_mode[2] = "pcw";
	}
	else if (gametype == "tdm")
	{
		valid_mode[0] = "pub";
		valid_mode[1] = "pcw";
	}
	else if (gametype == "strat")
	{
		// Start have all modes valid (it doesnt matter)
	}

	return valid_mode;
}

Load_SD_Rules()
{
	switch (level.pam_mode)
	{
		case "pcw": 	maps\mp\gametypes\rules\sd\pcw::Load(); break;
		case "cg": 	maps\mp\gametypes\rules\sd\cg::Load(); break;
		case "cg_mr12": maps\mp\gametypes\rules\sd\cg_mr12::Load(); break;
		case "cg_2v2": 	maps\mp\gametypes\rules\sd\cg_2v2::Load(); break;
		case "mr3": 	maps\mp\gametypes\rules\sd\mr3::Load(); break;
		case "mr10": 	maps\mp\gametypes\rules\sd\mr10::Load(); break;
		case "mr12": 	maps\mp\gametypes\rules\sd\mr12::Load(); break;
		case "mr15": 	maps\mp\gametypes\rules\sd\mr15::Load(); break;
		case "fun": 	maps\mp\gametypes\rules\sd\fun::Load(); break;
		case "pub": 	maps\mp\gametypes\rules\sd\pub::Load(); break;
	}
}

Load_DM_Rules()
{
	switch (level.pam_mode)
	{
		case "pcw": 	maps\mp\gametypes\rules\dm\pcw::Load(); break;
		case "warmup": 	maps\mp\gametypes\rules\dm\warmup::Load(); break;
		case "pub": 	maps\mp\gametypes\rules\dm\pub::Load(); break;
	}
}

Load_TDM_Rules()
{
	switch (level.pam_mode)
	{
		case "pcw": maps\mp\gametypes\rules\tdm\pcw::Load(); break;
		case "pub": maps\mp\gametypes\rules\tdm\pub::Load(); break;
	}
}

Load_Strat_Rules()
{
    maps\mp\gametypes\rules\strat\strat::Load();
}




/*
===========================================
= Get default values for rcon menu
===========================================
*/

Get_CvarDefaultValues(gametype, pam_mode)
{
	switch (gametype)
	{
		case "sd": 	return Get_SD_CvarDefaultValues(pam_mode);
		case "dm": 	return Get_DM_CvarDefaultValues(pam_mode);
		case "tdm": 	return Get_TDM_CvarDefaultValues(pam_mode);
		case "strat": 	return Get_Strat_CvarDefaultValues(pam_mode);
	}
}


Get_SD_CvarDefaultValues(pam_mode)
{
	switch (pam_mode)
	{
		case "pcw": 	return maps\mp\gametypes\rules\sd\pcw::GetCvars();
		case "cg": 	return maps\mp\gametypes\rules\sd\cg::GetCvars();
		case "cg_mr12": return maps\mp\gametypes\rules\sd\cg_mr12::GetCvars();
		case "cg_2v2": 	return maps\mp\gametypes\rules\sd\cg_2v2::GetCvars();
		case "mr3": 	return maps\mp\gametypes\rules\sd\mr3::GetCvars();
		case "mr10": 	return maps\mp\gametypes\rules\sd\mr10::GetCvars();
		case "mr12": 	return maps\mp\gametypes\rules\sd\mr12::GetCvars();
		case "mr15": 	return maps\mp\gametypes\rules\sd\mr15::GetCvars();
		case "fun": 	return maps\mp\gametypes\rules\sd\fun::GetCvars();
	}
}

Get_DM_CvarDefaultValues(pam_mode)
{
	switch (pam_mode)
	{
		case "pcw": 	return maps\mp\gametypes\rules\dm\pcw::GetCvars();
		case "warmup": 	return maps\mp\gametypes\rules\dm\warmup::GetCvars();
	}
}

Get_TDM_CvarDefaultValues(pam_mode)
{
	switch (pam_mode)
	{
		case "pcw": return maps\mp\gametypes\rules\tdm\pcw::GetCvars();
	}
}

Get_Strat_CvarDefaultValues(pam_mode)
{
    return maps\mp\gametypes\rules\strat\strat::GetCvars();
}
