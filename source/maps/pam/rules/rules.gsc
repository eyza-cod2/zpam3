load()
{
    // Rules load - overide cvars with values for defined league mode
	switch (level.gametype)
	{
		case "sd": Get_SD_Rules(); break;
		case "dm": Get_DM_Rules(); break;
		case "strat": Get_Strat_Rules(); break;
	}

    // Used to check if cvar "pam_mode" was changed but no pam-change was executed (cvar was changed right before map_restart)
    game["loaded_pam_mode"] = level.pam_mode;
}

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
		// Deatmatch have all modes valid (it doesnt matter)
	}
    else if (gametype == "strat")
	{
		// Start have all modes valid (it doesnt matter)
	}

    return valid_mode;
}

Get_SD_Rules()
{
	switch (level.pam_mode)
	{
		case "pcw":
			maps\pam\rules\sd\pcw::Rules();
			break;
		case "cg":
			maps\pam\rules\sd\cg::Rules();
			break;
		case "cg_mr12":
			maps\pam\rules\sd\cg_mr12::Rules();
			break;
		case "cg_2v2":
			maps\pam\rules\sd\cg_2v2::Rules();
			break;
		case "mr3":
			maps\pam\rules\sd\mr3::Rules();
			break;
		case "mr10":
			maps\pam\rules\sd\mr10::Rules();
			break;
		case "mr12":
			maps\pam\rules\sd\mr12::Rules();
			break;
		case "mr15":
			maps\pam\rules\sd\mr15::Rules();
			break;
		case "fun":
			maps\pam\rules\sd\fun::Rules();
			break;
		case "pub":
		default:
			maps\pam\rules\sd\pub::Rules();
	}
}

Get_DM_Rules()
{
    maps\pam\rules\dm\dm::Rules();
}

Get_Strat_Rules()
{
    maps\pam\rules\strat\strat::Rules();
}
