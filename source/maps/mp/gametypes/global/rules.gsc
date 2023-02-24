Init()
{
	// League name header (is defined in each mode file)
	if (!isdefined(game["rules_leagueString"]))
		game["rules_leagueString"] = &"^1Unknown pam mode name";
	if (!isdefined(game["rules_formatString"]))
		game["rules_formatString"] = &"";
	if (!isdefined(game["rules_stringColor"]))
		game["rules_stringColor"] = (0.9, 1, 1);
	if (!isDefined(game["ruleCvars"]))
		game["ruleCvars"] = [];

	// Overtime change detection
	overtime_changed = isDefined(game["overtime_active"]) && isDefined(game["rules_overtime_previous"]) && game["overtime_active"] != game["rules_overtime_previous"];
	game["rules_overtime_previous"] = game["overtime_active"];



	// Rules load
	loaded = false;
	switch (level.gametype)
	{
		case "sd": 	loaded = Load_SD_Rules(); break;
		case "dm": 	loaded = Load_DM_Rules(); break;
		case "tdm": 	loaded = Load_TDM_Rules(); break;
		case "ctf": 	loaded = Load_CTF_Rules(); break;
		case "hq": 	loaded = Load_HQ_Rules(); break;
		case "htf": 	loaded = Load_HTF_Rules(); break;
		case "re": 	loaded = Load_RE_Rules(); break;
		case "strat": 	loaded = Load_Strat_Rules(); break;
	}
	assert(loaded);

	/#
	if (game["ruleCvars"].size == 0 && !game["is_public_mode"])
		assertMsg("Rule cvars was not loaded!");
	#/


	// Precache
	if (game["firstInit"])
	{
		precacheString(game["rules_leagueString"]);
		precacheString(game["rules_formatString"]);
	}


	if (game["firstInit"] || overtime_changed)
	{
		assert(level.pam_mode != "");

		_2v2 = PAMModeContains("2v2");
		russian = PAMModeContains("russian");
		lan = PAMModeContains("lan");
		pcw = PAMModeContains("pcw");
		ot = isDefined(game["overtime_active"]) && game["overtime_active"];
		rifle = PAMModeContains("rifle");

		// This is because of fucking cod2 precache system
		game["leagueOptionsString"] = &"";
		if (!rifle && !ot && !pcw && _2v2 && russian && lan)	game["leagueOptionsString"] = &"2v2 | Russian | LAN";
		if (!rifle && !ot && !pcw && _2v2 && !russian && lan)	game["leagueOptionsString"] = &"2v2 | LAN";
		if (!rifle && !ot && !pcw && _2v2 && russian && !lan)	game["leagueOptionsString"] = &"2v2 | Russian";
		if (!rifle && !ot && !pcw && !_2v2 && russian && lan)	game["leagueOptionsString"] = &"Russian | LAN";
		if (!rifle && !ot && !pcw && _2v2 && !russian && !lan)	game["leagueOptionsString"] = &"2v2";
		if (!rifle && !ot && !pcw && !_2v2 && russian && !lan)	game["leagueOptionsString"] = &"Russian";
		if (!rifle && !ot && !pcw && !_2v2 && !russian && lan)	game["leagueOptionsString"] = &"LAN";
		// -
		if (!rifle && !ot && pcw && _2v2 && russian && lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Russian | LAN";
		if (!rifle && !ot && pcw && _2v2 && !russian && lan)	game["leagueOptionsString"] = &"PCW | 2v2 | LAN";
		if (!rifle && !ot && pcw && _2v2 && russian && !lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Russian";
		if (!rifle && !ot && pcw && !_2v2 && russian && lan)	game["leagueOptionsString"] = &"PCW | Russian | LAN";
		if (!rifle && !ot && pcw && _2v2 && !russian && !lan)	game["leagueOptionsString"] = &"PCW | 2v2";
		if (!rifle && !ot && pcw && !_2v2 && russian && !lan)	game["leagueOptionsString"] = &"PCW | Russian";
		if (!rifle && !ot && pcw && !_2v2 && !russian && lan)	game["leagueOptionsString"] = &"PCW | LAN";
		if (!rifle && !ot && pcw && !_2v2 && !russian && !lan)	game["leagueOptionsString"] = &"PCW";
		//
		//
		if (!rifle && ot && !pcw && _2v2 && russian && lan)	game["leagueOptionsString"] = &"2v2 | Russian | LAN | ^3Overtime";
		if (!rifle && ot && !pcw && _2v2 && !russian && lan)	game["leagueOptionsString"] = &"2v2 | LAN | ^3Overtime";
		if (!rifle && ot && !pcw && _2v2 && russian && !lan)	game["leagueOptionsString"] = &"2v2 | Russian | ^3Overtime";
		if (!rifle && ot && !pcw && !_2v2 && russian && lan)	game["leagueOptionsString"] = &"Russian | LAN | ^3Overtime";
		if (!rifle && ot && !pcw && _2v2 && !russian && !lan)	game["leagueOptionsString"] = &"2v2 | ^3Overtime";
		if (!rifle && ot && !pcw && !_2v2 && russian && !lan)	game["leagueOptionsString"] = &"Russian | ^3Overtime";
		if (!rifle && ot && !pcw && !_2v2 && !russian && lan)	game["leagueOptionsString"] = &"LAN | ^3Overtime";
		// -
		if (!rifle && ot && pcw && _2v2 && russian && lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Russian | LAN | ^3Overtime";
		if (!rifle && ot && pcw && _2v2 && !russian && lan)	game["leagueOptionsString"] = &"PCW | 2v2 | LAN | ^3Overtime";
		if (!rifle && ot && pcw && _2v2 && russian && !lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Russian | ^3Overtime";
		if (!rifle && ot && pcw && !_2v2 && russian && lan)	game["leagueOptionsString"] = &"PCW | Russian | LAN | ^3Overtime";
		if (!rifle && ot && pcw && _2v2 && !russian && !lan)	game["leagueOptionsString"] = &"PCW | 2v2 | ^3Overtime";
		if (!rifle && ot && pcw && !_2v2 && russian && !lan)	game["leagueOptionsString"] = &"PCW | Russian | ^3Overtime";
		if (!rifle && ot && pcw && !_2v2 && !russian && lan)	game["leagueOptionsString"] = &"PCW | LAN | ^3Overtime";
		if (!rifle && ot && pcw && !_2v2 && !russian && !lan)	game["leagueOptionsString"] = &"PCW | ^3Overtime";
		if (!rifle && ot && !pcw && !_2v2 && !russian && !lan)	game["leagueOptionsString"] = &"^3Overtime";
		//
		//
		//
		if (rifle && !ot && !pcw && _2v2 && russian && lan)	game["leagueOptionsString"] = &"2v2 | Rifle | Russian | LAN";
		if (rifle && !ot && !pcw && _2v2 && !russian && lan)	game["leagueOptionsString"] = &"2v2 | Rifle | LAN";
		if (rifle && !ot && !pcw && _2v2 && russian && !lan)	game["leagueOptionsString"] = &"2v2 | Rifle | Russian";
		if (rifle && !ot && !pcw && !_2v2 && russian && lan)	game["leagueOptionsString"] = &"Russian | Rifle | LAN";
		if (rifle && !ot && !pcw && _2v2 && !russian && !lan)	game["leagueOptionsString"] = &"2v2 | Rifle";
		if (rifle && !ot && !pcw && !_2v2 && russian && !lan)	game["leagueOptionsString"] = &"Russian | Rifle";
		if (rifle && !ot && !pcw && !_2v2 && !russian && lan)	game["leagueOptionsString"] = &"LAN | Rifle";
		// -
		if (rifle && !ot && pcw && _2v2 && russian && lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Rifle | Russian | LAN";
		if (rifle && !ot && pcw && _2v2 && !russian && lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Rifle | LAN";
		if (rifle && !ot && pcw && _2v2 && russian && !lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Rifle | Russian";
		if (rifle && !ot && pcw && !_2v2 && russian && lan)	game["leagueOptionsString"] = &"PCW | Russian | Rifle | LAN";
		if (rifle && !ot && pcw && _2v2 && !russian && !lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Rifle";
		if (rifle && !ot && pcw && !_2v2 && russian && !lan)	game["leagueOptionsString"] = &"PCW | Russian | Rifle";
		if (rifle && !ot && pcw && !_2v2 && !russian && lan)	game["leagueOptionsString"] = &"PCW | LAN | Rifle";
		if (rifle && !ot && pcw && !_2v2 && !russian && !lan)	game["leagueOptionsString"] = &"PCW | Rifle";
		//
		//
		if (rifle && ot && !pcw && _2v2 && russian && lan)	game["leagueOptionsString"] = &"2v2 | Rifle | Russian | LAN | ^3Overtime";
		if (rifle && ot && !pcw && _2v2 && !russian && lan)	game["leagueOptionsString"] = &"2v2 | Rifle | LAN | ^3Overtime";
		if (rifle && ot && !pcw && _2v2 && russian && !lan)	game["leagueOptionsString"] = &"2v2 | Rifle | Russian | ^3Overtime";
		if (rifle && ot && !pcw && !_2v2 && russian && lan)	game["leagueOptionsString"] = &"Russian | Rifle | LAN | ^3Overtime";
		if (rifle && ot && !pcw && _2v2 && !russian && !lan)	game["leagueOptionsString"] = &"2v2 | Rifle | ^3Overtime";
		if (rifle && ot && !pcw && !_2v2 && russian && !lan)	game["leagueOptionsString"] = &"Russian | Rifle | ^3Overtime";
		if (rifle && ot && !pcw && !_2v2 && !russian && lan)	game["leagueOptionsString"] = &"Rifle | LAN | ^3Overtime";
		// -
		if (rifle && ot && pcw && _2v2 && russian && lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Rifle | Russian | LAN | ^3Overtime";
		if (rifle && ot && pcw && _2v2 && !russian && lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Rifle | LAN | ^3Overtime";
		if (rifle && ot && pcw && _2v2 && russian && !lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Rifle | Russian | ^3Overtime";
		if (rifle && ot && pcw && !_2v2 && russian && lan)	game["leagueOptionsString"] = &"PCW | Russian | Rifle | LAN | ^3Overtime";
		if (rifle && ot && pcw && _2v2 && !russian && !lan)	game["leagueOptionsString"] = &"PCW | 2v2 | Rifle | ^3Overtime";
		if (rifle && ot && pcw && !_2v2 && russian && !lan)	game["leagueOptionsString"] = &"PCW | Russian | Rifle | ^3Overtime";
		if (rifle && ot && pcw && !_2v2 && !russian && lan)	game["leagueOptionsString"] = &"PCW | Rifle | LAN | ^3Overtime";
		if (rifle && ot && pcw && !_2v2 && !russian && !lan)	game["leagueOptionsString"] = &"PCW | Rifle | ^3Overtime";
		if (rifle && ot && !pcw && !_2v2 && !russian && !lan)	game["leagueOptionsString"] = &"Rifle | ^3Overtime";
		if (rifle && !ot && !pcw && !_2v2 && !russian && !lan)	game["leagueOptionsString"] = &"Rifle";



		precacheString(game["leagueOptionsString"]);
	}

	println("Loaded rules for pam mode: " + level.pam_mode);
}

ruleCvarDefault(array, cvarName, value)
{
	cvarName = toLower(cvarName);
	array[cvarName] = value;
	return array;
}


IsValidPAMMode(cvar, value_now, registerTime)
{
	isValid = IsValidPAMModeForGametype(level.gametype, value_now);

	if (level.gametype == "strat" && !registerTime)
		isValid = false;

	if (!isValid)
	{
		// Print not valid warning
		if (!registerTime)
		{
			iprintln("^3DVAR change detected: ^2" + value_now + "^3 is not a valid value for dvar ^2" + cvar["name"]);

			if (level.gametype == "sd")
			{
				iprintln("^3Following values are valid:");
				iprintln("^7pub, comp");
				iprintln("^3Sub-modes:");
				iprintln("^7_mr3, _mr10, _mr12, _mr15, _20rounds");
				iprintln("^7_2v2, _rifle, _russian, _lan, _pcw");
			}
			else if (level.gametype == "dm")
			{
				iprintln("^3Following values are valid:");
				iprintln("^7pub, comp, warmup");
				iprintln("^3Sub-modes:");
				iprintln("^710min, 15min, 30min, 60min, unlim");
				iprintln("^7_2v2, _rifle, _russian, _lan, _pcw");
			}
			else if (level.gametype == "tdm")
			{
				iprintln("^3Following values are valid:");
				iprintln("^7pub, comp");
				iprintln("^3Sub-modes:");
				iprintln("^710min, 15min, 30min, 60min, unlim");
				iprintln("^7_2v2, _rifle, _russian, _lan, _pcw");
			}
			else if (level.gametype == "ctf")
			{
				iprintln("^3Following values are valid:");
				iprintln("^7pub, comp");
				iprintln("^3Sub-modes:");
				iprintln("^710min, 15min, 30min, 60min, unlim");
				iprintln("^7_2v2, _rifle, _russian, _lan, _pcw");
			}
			else if (level.gametype == "hq")
			{
				iprintln("^3Following values are valid:");
				iprintln("^7pub, comp");
				iprintln("^3Sub-modes:");
				iprintln("^710min, 15min, 30min, 60min, unlim");
				iprintln("^7_2v2, _rifle, _russian, _lan, _pcw");
			}
			else if (level.gametype == "htf")
			{
				iprintln("^3Following values are valid:");
				iprintln("^7pub, comp");
				iprintln("^3Sub-modes:");
				iprintln("^710min, 15min, 30min, 60min, unlim");
				iprintln("^7_2v2, _rifle, _russian, _lan, _pcw");
			}
			else if (level.gametype == "re")
			{
				iprintln("^3Following values are valid:");
				iprintln("^7pub, comp");
				iprintln("^3Sub-modes:");
				iprintln("^7_mr3, _mr10, _mr12, _mr15, _20rounds");
				iprintln("^7_2v2, _rifle, _russian, _lan, _pcw");
			}
			else
				iprintln("^3Change to other gametype!");

		}
	}

	if (!isValid && registerTime)
	{
		println("Cvar " + cvar["name"] + " has invalid value '"+value_now+"'. Using default value '" + cvar["defaultValue"] + "'.");
	}

	return isValid;
}


IsValidPAMModeForGametype(gametype, pammode)
{
	isValid = true;

	array = maps\mp\gametypes\global\string::splitString(pammode, "_");

	if (array.size <= 0)
		isValid = false;

	// Submodes
	for (i = 0; i < array.size; i++)
	{
		if (i == 0)
		{
			// First must be league
			if ((gametype == "sd"  && array[0] != "pub" && array[0] != "comp") ||
			    (gametype == "dm"  && array[0] != "pub" && array[0] != "comp" && array[0] != "warmup") ||
			    (gametype == "tdm" && array[0] != "pub" && array[0] != "comp") ||
			    (gametype == "ctf" && array[0] != "pub" && array[0] != "comp") ||
			    (gametype == "hq" && array[0] != "pub" && array[0] != "comp") ||
			    (gametype == "htf" && array[0] != "pub" && array[0] != "comp") ||
			    (gametype == "re" && array[0] != "pub" && array[0] != "comp"))
			{
				isValid = false;
				break;
			}
		}
		else
		{
			if (!IsToggleSubPamMode(array[i]) && (
			    (gametype == "sd"  && array[i] != "mr3" && array[i] != "mr10" && array[i] != "mr12" && array[i] != "mr15" && array[i] != "20rounds") ||
			    (gametype == "dm"  && array[i] != "10min" && array[i] != "15min" && array[i] != "30min" && array[i] != "60min" && array[i] != "unlim") ||
			    (gametype == "tdm" && array[i] != "10min" && array[i] != "15min" && array[i] != "30min" && array[i] != "60min" && array[i] != "unlim") ||
			    (gametype == "ctf" && array[i] != "10min" && array[i] != "15min" && array[i] != "30min" && array[i] != "60min" && array[i] != "unlim") ||
			    (gametype == "hq"  && array[i] != "10min" && array[i] != "15min" && array[i] != "30min" && array[i] != "60min" && array[i] != "unlim") ||
			    (gametype == "htf" && array[i] != "10min" && array[i] != "15min" && array[i] != "30min" && array[i] != "60min" && array[i] != "unlim") ||
			    (gametype == "re" && array[i] != "mr3" && array[i] != "mr10" && array[i] != "mr12" && array[i] != "mr15" && array[i] != "20rounds")))
			{
				isValid = false;
				break;
			}
		}
	}


	return isValid;
}


PAMModeContains(string)
{
	array = maps\mp\gametypes\global\string::splitString(level.pam_mode, "_");

	for (i = 0; i < array.size; i++)
	{
		if (array[i] == string)
		{
			return true;
		}
	}
	return false;
}



IsToggleSubPamMode(name)
{
	switch(name)
	{
		case "2v2":
		case "russian":
		case "lan":
		case "pcw":
		case "rifle":
			return true;
	}
	/#
	if (name == "developer")
		return true;
	#/
	return false;
}

LoadToggleSubPamMode(name)
{
	switch(name)
	{
		case "2v2": 	maps\mp\gametypes\rules\_2v2::Load(); return true;
		case "russian": maps\mp\gametypes\rules\russian::Load(); return true;
		case "lan": 	maps\mp\gametypes\rules\lan::Load(); return true;
		case "pcw": 	maps\mp\gametypes\rules\pcw::Load(); return true;
		case "rifle": 	maps\mp\gametypes\rules\rifle::Load(); return true;
	}
	/#
	if (name == "developer") {
		maps\mp\gametypes\rules\developer::Load();
		return true;
	}
	#/
	return false;
}

Load_SD_Rules()
{
	if (level.pam_mode == "pub")
	{
		maps\mp\gametypes\rules\sd\pub::Load();
		return true;
	}

	array = maps\mp\gametypes\global\string::splitString(level.pam_mode, "_");

	if (array.size <= 0)
		return false;

	// First must be league
	if (array[0] == "comp")
		maps\mp\gametypes\rules\sd\comp::Load();
	else
		return false;

	// Score settings
	for (i = 1; i < array.size; i++)
	{
		switch(array[i])
		{
			case "mr3": 	maps\mp\gametypes\rules\sd\score\mr3::Load(); break;
			case "mr10": 	maps\mp\gametypes\rules\sd\score\mr10::Load(); break;
			case "mr12": 	maps\mp\gametypes\rules\sd\score\mr12::Load(); break;
			case "mr15": 	maps\mp\gametypes\rules\sd\score\mr15::Load(); break;
			case "20rounds": maps\mp\gametypes\rules\sd\score\_20rounds::Load(); break;
			default:
				valid = LoadToggleSubPamMode(array[i]);
				if (!valid) return false;
				break;
		}
	}

	return true;
}

Load_DM_Rules()
{
	if (level.pam_mode == "pub")
	{
		maps\mp\gametypes\rules\dm\pub::Load();
		return true;
	}

	array = maps\mp\gametypes\global\string::splitString(level.pam_mode, "_");

	if (array.size <= 0)
		return false;

	// First must be league
	if (array[0] == "comp")
		maps\mp\gametypes\rules\dm\comp::Load();
	else if (array[0] == "warmup")
		maps\mp\gametypes\rules\dm\warmup::Load();
	else
		return false;

	// Score settings
	for (i = 1; i < array.size; i++)
	{
		switch(array[i])
		{
			case "10min": 	maps\mp\gametypes\rules\dm\score\_10min::Load(); break;
			case "15min": 	maps\mp\gametypes\rules\dm\score\_15min::Load(); break;
			case "30min": 	maps\mp\gametypes\rules\dm\score\_30min::Load(); break;
			case "60min": 	maps\mp\gametypes\rules\dm\score\_60min::Load(); break;
			case "unlim": 	maps\mp\gametypes\rules\dm\score\unlim::Load(); break;
			default:
				valid = LoadToggleSubPamMode(array[i]);
				if (!valid) return false;
				break;
		}
	}

	return true;
}

Load_TDM_Rules()
{
	if (level.pam_mode == "pub")
	{
		maps\mp\gametypes\rules\tdm\pub::Load();
		return true;
	}

	array = maps\mp\gametypes\global\string::splitString(level.pam_mode, "_");

	if (array.size <= 0)
		return false;

	// First must be league
	if (array[0] == "comp")
		maps\mp\gametypes\rules\tdm\comp::Load();
	else
		return false;

	// Score settings
	for (i = 1; i < array.size; i++)
	{
		switch(array[i])
		{
			case "10min": 	maps\mp\gametypes\rules\tdm\score\_10min::Load(); break;
			case "15min": 	maps\mp\gametypes\rules\tdm\score\_15min::Load(); break;
			case "30min": 	maps\mp\gametypes\rules\tdm\score\_30min::Load(); break;
			case "60min": 	maps\mp\gametypes\rules\tdm\score\_60min::Load(); break;
			case "unlim": 	maps\mp\gametypes\rules\tdm\score\unlim::Load(); break;
			default:
				valid = LoadToggleSubPamMode(array[i]);
				if (!valid) return false;
				break;
		}
	}

	return true;
}

Load_CTF_Rules()
{
	if (level.pam_mode == "pub")
	{
		maps\mp\gametypes\rules\ctf\pub::Load();
		return true;
	}

	array = maps\mp\gametypes\global\string::splitString(level.pam_mode, "_");

	if (array.size <= 0)
		return false;

	// First must be league
	if (array[0] == "comp")
		maps\mp\gametypes\rules\ctf\comp::Load();
	else
		return false;

	// Score settings
	for (i = 1; i < array.size; i++)
	{
		switch(array[i])
		{
			case "10min": 	maps\mp\gametypes\rules\ctf\score\_10min::Load(); break;
			case "15min": 	maps\mp\gametypes\rules\ctf\score\_15min::Load(); break;
			case "30min": 	maps\mp\gametypes\rules\ctf\score\_30min::Load(); break;
			case "60min": 	maps\mp\gametypes\rules\ctf\score\_60min::Load(); break;
			case "unlim": 	maps\mp\gametypes\rules\ctf\score\unlim::Load(); break;
			default:
				valid = LoadToggleSubPamMode(array[i]);
				if (!valid) return false;
				break;
		}
	}

	return true;
}

Load_HQ_Rules()
{
	if (level.pam_mode == "pub")
	{
		maps\mp\gametypes\rules\hq\pub::Load();
		return true;
	}

	array = maps\mp\gametypes\global\string::splitString(level.pam_mode, "_");

	if (array.size <= 0)
		return false;

	// First must be league
	if (array[0] == "comp")
		maps\mp\gametypes\rules\hq\comp::Load();
	else
		return false;

	// Score settings
	for (i = 1; i < array.size; i++)
	{
		switch(array[i])
		{
			case "10min": 	maps\mp\gametypes\rules\hq\score\_10min::Load(); break;
			case "15min": 	maps\mp\gametypes\rules\hq\score\_15min::Load(); break;
			case "30min": 	maps\mp\gametypes\rules\hq\score\_30min::Load(); break;
			case "60min": 	maps\mp\gametypes\rules\hq\score\_60min::Load(); break;
			case "unlim": 	maps\mp\gametypes\rules\hq\score\unlim::Load(); break;
			default:
				valid = LoadToggleSubPamMode(array[i]);
				if (!valid) return false;
				break;
		}
	}

	return true;
}

Load_HTF_Rules()
{
	if (level.pam_mode == "pub")
	{
		maps\mp\gametypes\rules\htf\pub::Load();
		return true;
	}

	array = maps\mp\gametypes\global\string::splitString(level.pam_mode, "_");

	if (array.size <= 0)
		return false;

	// First must be league
	if (array[0] == "comp")
		maps\mp\gametypes\rules\htf\comp::Load();
	else
		return false;

	// Score settings
	for (i = 1; i < array.size; i++)
	{
		switch(array[i])
		{
			case "10min": 	maps\mp\gametypes\rules\htf\score\_10min::Load(); break;
			case "15min": 	maps\mp\gametypes\rules\htf\score\_15min::Load(); break;
			case "30min": 	maps\mp\gametypes\rules\htf\score\_30min::Load(); break;
			case "60min": 	maps\mp\gametypes\rules\htf\score\_60min::Load(); break;
			case "unlim": 	maps\mp\gametypes\rules\htf\score\unlim::Load(); break;
			default:
				valid = LoadToggleSubPamMode(array[i]);
				if (!valid) return false;
				break;
		}
	}

	return true;
}

Load_RE_Rules()
{
	if (level.pam_mode == "pub")
	{
		maps\mp\gametypes\rules\re\pub::Load();
		return true;
	}

	array = maps\mp\gametypes\global\string::splitString(level.pam_mode, "_");

	if (array.size <= 0)
		return false;

	// First must be league
	if (array[0] == "comp")
		maps\mp\gametypes\rules\re\comp::Load();
	else
		return false;

	// Score settings
	for (i = 1; i < array.size; i++)
	{
		switch(array[i])
		{
			case "mr3": 	maps\mp\gametypes\rules\re\score\mr3::Load(); break;
			case "mr10": 	maps\mp\gametypes\rules\re\score\mr10::Load(); break;
			case "mr12": 	maps\mp\gametypes\rules\re\score\mr12::Load(); break;
			case "mr15": 	maps\mp\gametypes\rules\re\score\mr15::Load(); break;
			case "20rounds": maps\mp\gametypes\rules\re\score\_20rounds::Load(); break;
			default:
				valid = LoadToggleSubPamMode(array[i]);
				if (!valid) return false;
				break;
		}
	}

	return true;
}

Load_Strat_Rules()
{
    maps\mp\gametypes\rules\strat\strat::Load();

    return true;
}
