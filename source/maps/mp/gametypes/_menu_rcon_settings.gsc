#include maps\mp\gametypes\global\_global;

init()
{
	// Array of cvars
	cvar_names = [];
	cvar_names_gt = [];

	cvar_names[cvar_names.size] = "scr_sd_timelimit";		cvar_names_gt[cvar_names_gt.size] = "sd";
	cvar_names[cvar_names.size] = "scr_sd_half_round";		cvar_names_gt[cvar_names_gt.size] = "sd";
	cvar_names[cvar_names.size] = "scr_sd_half_score";		cvar_names_gt[cvar_names_gt.size] = "sd";
	cvar_names[cvar_names.size] = "scr_sd_end_round";		cvar_names_gt[cvar_names_gt.size] = "sd";
	cvar_names[cvar_names.size] = "scr_sd_end_score";		cvar_names_gt[cvar_names_gt.size] = "sd";
	cvar_names[cvar_names.size] = "scr_sd_strat_time";		cvar_names_gt[cvar_names_gt.size] = "sd";
	cvar_names[cvar_names.size] = "scr_sd_roundlength";		cvar_names_gt[cvar_names_gt.size] = "sd";

	cvar_names[cvar_names.size] = "scr_dm_timelimit";		cvar_names_gt[cvar_names_gt.size] = "dm";
	cvar_names[cvar_names.size] = "scr_dm_half_score";		cvar_names_gt[cvar_names_gt.size] = "dm";
	cvar_names[cvar_names.size] = "scr_dm_end_score";		cvar_names_gt[cvar_names_gt.size] = "dm";
	cvar_names[cvar_names.size] = "scr_dm_halftime";		cvar_names_gt[cvar_names_gt.size] = "dm";

	cvar_names[cvar_names.size] = "scr_tdm_timelimit";		cvar_names_gt[cvar_names_gt.size] = "tdm";
	cvar_names[cvar_names.size] = "scr_tdm_half_score";		cvar_names_gt[cvar_names_gt.size] = "tdm";
	cvar_names[cvar_names.size] = "scr_tdm_end_score";		cvar_names_gt[cvar_names_gt.size] = "tdm";
	cvar_names[cvar_names.size] = "scr_tdm_halftime";		cvar_names_gt[cvar_names_gt.size] = "tdm";

	cvar_names[cvar_names.size] = "scr_hq_timelimit";		cvar_names_gt[cvar_names_gt.size] = "hq";
	cvar_names[cvar_names.size] = "scr_hq_half_score";		cvar_names_gt[cvar_names_gt.size] = "hq";
	cvar_names[cvar_names.size] = "scr_hq_end_score";		cvar_names_gt[cvar_names_gt.size] = "hq";
	cvar_names[cvar_names.size] = "scr_hq_halftime";		cvar_names_gt[cvar_names_gt.size] = "hq";

	cvar_names[cvar_names.size] = "scr_ctf_timelimit";		cvar_names_gt[cvar_names_gt.size] = "ctf";
	cvar_names[cvar_names.size] = "scr_ctf_half_score";		cvar_names_gt[cvar_names_gt.size] = "ctf";
	cvar_names[cvar_names.size] = "scr_ctf_end_score";		cvar_names_gt[cvar_names_gt.size] = "ctf";
	cvar_names[cvar_names.size] = "scr_ctf_halftime";		cvar_names_gt[cvar_names_gt.size] = "ctf";

	cvar_names[cvar_names.size] = "scr_htf_timelimit";		cvar_names_gt[cvar_names_gt.size] = "htf";
	cvar_names[cvar_names.size] = "scr_htf_half_score";		cvar_names_gt[cvar_names_gt.size] = "htf";
	cvar_names[cvar_names.size] = "scr_htf_end_score";		cvar_names_gt[cvar_names_gt.size] = "htf";
	cvar_names[cvar_names.size] = "scr_htf_halftime";		cvar_names_gt[cvar_names_gt.size] = "htf";

	cvar_names[cvar_names.size] = "scr_re_timelimit";		cvar_names_gt[cvar_names_gt.size] = "re";
	cvar_names[cvar_names.size] = "scr_re_half_round";		cvar_names_gt[cvar_names_gt.size] = "re";
	cvar_names[cvar_names.size] = "scr_re_half_score";		cvar_names_gt[cvar_names_gt.size] = "re";
	cvar_names[cvar_names.size] = "scr_re_end_round";		cvar_names_gt[cvar_names_gt.size] = "re";
	cvar_names[cvar_names.size] = "scr_re_end_score";		cvar_names_gt[cvar_names_gt.size] = "re";
	cvar_names[cvar_names.size] = "scr_re_strat_time";		cvar_names_gt[cvar_names_gt.size] = "re";
	cvar_names[cvar_names.size] = "scr_re_roundlength";		cvar_names_gt[cvar_names_gt.size] = "re";


	cvar_names[cvar_names.size] = "debug_fastreload";		cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "debug_shotgun";			cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "debug_handhitbox";		cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "debug_torsohitbox";		cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "debug_pronepeek";		cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "debug_spectator";		cvar_names_gt[cvar_names_gt.size] = "";

	cvar_names[cvar_names.size] = "scr_fast_reload_fix";		cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "scr_shotgun_consistent";		cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "scr_smoke_fix";				cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "scr_hitbox_hand_fix";		cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "scr_hitbox_torso_fix";		cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "scr_prone_peek_fix";			cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "scr_mg_peek_fix";			cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "g_antilag";					cvar_names_gt[cvar_names_gt.size] = "";
	cvar_names[cvar_names.size] = "scr_killcam";				cvar_names_gt[cvar_names_gt.size] = "";







	// Array with cvar name used as index
	cvars = [];
	for (i = 0; i < cvar_names.size; i++)
	{
		cvars[cvar_names[i]] = true;
	}



	level.rcon_settings = spawnStruct();


	level.rcon_settings.cvar_names = cvar_names;
	level.rcon_settings.cvars_gt = cvar_names_gt;
	level.rcon_settings.cvars = cvars;


	addEventListener("onConnected",   ::onConnected);
	addEventListener("onMenuResponse",   ::onMenuResponse);

	level thread checkingRconCvarThread();
}

onConnected()
{
	self.pers["rcon_settings_keyboard_for"] = "";

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

	if (startsWith(response, "rcon_settings_"))
	{
		substr = getSubstr(response, 14);

		self settingsOptions(substr);

		return true;
	}
}




generateUUID()
{
	if (!isDefined(self.pers["rcon_settings_uuid"]))
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

		self.pers["rcon_settings_uuid"] = hash;
		self setClientCvar2("ui_rcon_settings_exec", "rcon set rcon_settings_uuid "+ hash);
	}
	else
	{
		// Update vstr cvar because level.rconCvar may be changed
		self setClientCvar2("ui_rcon_settings_exec", "rcon set rcon_settings_uuid "+ self.pers["rcon_settings_uuid"]);
	}
}


checkingRconCvarThread()
{
    // Define or reset cvar to default
    setCvar("rcon_settings_uuid", "");

    for(;;)
    {
        wait level.fps_multiplier * 0.5;

        // Check if cvar is changed
        cvarValue = getCvar("rcon_settings_uuid");
        if (cvarValue != "")
        {
            // Check if cvar value equals to UUID of some player
            players = getentarray("player", "classname");
            for(i = 0; i < players.size; i++)
            {
            	player = players[i];

		// This player is player who set the correct uuid
                if (isDefined(player.pers["rcon_settings_uuid"]) && cvarValue == player.pers["rcon_settings_uuid"])
                {
			// Apply cvar changes
			for(j = 0; j < level.rcon_settings.cvar_names.size; j++)
			{
				cvar_name = level.rcon_settings.cvar_names[j];
				setCvar(cvar_name, player.pers["rcon_settings_" + cvar_name]);
			}

			break;
                }
            }

            setCvar("rcon_settings_uuid", "");
        }
    }
}











settingsOptions(response)
{
	if (response == "open")
        {
		// Set selections to default
		for(i = 0; i < level.rcon_settings.cvar_names.size; i++)
		{
			cvar_name = level.rcon_settings.cvar_names[i];

			self.pers["rcon_settings_" + cvar_name] = "" + getCvar(cvar_name);
		}

		self.pers["rcon_settings_keyboard_for"] = "";

		updateUI();
		return;
        }

	if (startsWith(response, "key_"))
	{
		key = getsubstr(response, 4);

		if (self.pers["rcon_settings_keyboard_for"] == "")
			return;

		pers_cvar_value = "rcon_settings_" + self.pers["rcon_settings_keyboard_for"];

		if (key == "0" || key == "1" || key == "2" || key == "3" || key == "4" || key == "5" || key == "6" || key == "7" || key == "8" || key == "9" || key == ".")
		{
			self.pers[pers_cvar_value] += key;
		}
		else if (key == "enter")
		{
			// If field is empty, restore previous value
			if (self.pers[pers_cvar_value] == "")
				self.pers[pers_cvar_value] = getCvar(self.pers["rcon_settings_keyboard_for"]);

			self.pers["rcon_settings_keyboard_for"] = "";
		}
		else if (key == "backspace")
		{
			self.pers[pers_cvar_value] = getsubstr(self.pers[pers_cvar_value], 0, self.pers[pers_cvar_value].size - 1);
		}

		updateUI();


		return;
	}

	for(i = 0; i < level.rcon_settings.cvar_names.size; i++)
	{
		cvar_name = level.rcon_settings.cvar_names[i];

		//Ex: debug_fastreload_1 starts with debug_fastreload_
		if (startsWith(response, cvar_name + "_"))
		{
			gt = level.rcon_settings.cvars_gt[i];
			// Cvar from different gametype
			if (gt != "" && gt != level.gametype)
				break;

			value = getsubstr(response, cvar_name.size + 1);

			if (value == "edit")
			{
				// Toggle editing a field
				if (self.pers["rcon_settings_keyboard_for"] == "")
				{
					self.pers["rcon_settings_keyboard_for"] = cvar_name;

					thread cursor(cvar_name);
				}
				else
					self.pers["rcon_settings_keyboard_for"] = "";

				updateUI();
			}

			else
			{
				self.pers["rcon_settings_keyboard_for"] = "";

				self.pers["rcon_settings_" + cvar_name] = value;
				updateUI();
			}

			break;
		}
	}
}


updateUI()
{
	rconString = "";

	// Get changed cvars to create rcon string
	for(i = 0; i < level.rcon_settings.cvar_names.size; i++)
	{
		cvar_name = level.rcon_settings.cvar_names[i];
		gt = level.rcon_settings.cvars_gt[i];

		if ((gt == "" || gt == level.gametype) && self.pers["rcon_settings_" + cvar_name] != getCvar(cvar_name))
		{
			rconString += "/rcon "+cvar_name+" " + self.pers["rcon_settings_" + cvar_name] + "; ";
		}
	}

	// Update UI cvars with actual selections
	for(i = 0; i < level.rcon_settings.cvar_names.size; i++)
	{
		cvar_name = level.rcon_settings.cvar_names[i];
		gt = level.rcon_settings.cvars_gt[i];
		value = self.pers["rcon_settings_" + cvar_name];

		if (gt == "" || gt == level.gametype)
		{
			if (self.pers["rcon_settings_keyboard_for"] == cvar_name)
				value += "|";
		}
		else
			value = "";

		self setClientCvarIfChanged("ui_rcon_settings_"+cvar_name, value);

	}


	self setClientCvarIfChanged("ui_rcon_settings_execString", rconString);
}


cursor(cvar_name)
{
	self endon("disconnect");

	self setClientCvarIfChanged("ui_rcon_settings_enter_help", 1);

	char = "";
	while(self.pers["rcon_settings_keyboard_for"] == cvar_name || char == "|")
	{
		if (char == "|")
			char = "";
		else
			char = "|";

		self setClientCvarIfChanged("ui_rcon_settings_"+cvar_name, self.pers["rcon_settings_" + cvar_name] + char + " ");

		wait level.fps_multiplier * .4;
	}

	self setClientCvarIfChanged("ui_rcon_settings_enter_help", 0);
}
