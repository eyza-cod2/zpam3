load()
{
    // Rules load - overide cvars with values for defined league mode
	switch (level.gametype)
	{
		case "sd":  Get_SD_Rules(); break;
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
		valid_mode[2] = "cg_1v1";
		valid_mode[3] = "cg_2v2";
		valid_mode[4] = "cg_mr12";
		valid_mode[5] = "cg";
		valid_mode[6] = "mr3";
		valid_mode[7] = "mr10";
        valid_mode[8] = "mr12";
		valid_mode[9] = "mr15";
		valid_mode[10] = "bash";
		valid_mode[11] = "fun";
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
		case "bash":
			maps\pam\rules\sd\bash::Rules();
			break;
		case "pcw":
			maps\pam\rules\sd\pcw::Rules();
			break;
		case "cg":
			maps\pam\rules\sd\cg::Rules();
			break;
		case "cg_mr12":
			maps\pam\rules\sd\cg_mr12::Rules();
			break;
		case "cg_1v1":
			maps\pam\rules\sd\cg_1v1::Rules();
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

Get_Strat_Rules()
{
    maps\pam\rules\strat\strat::Rules();
}
