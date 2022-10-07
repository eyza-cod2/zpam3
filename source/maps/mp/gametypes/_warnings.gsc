#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onConnected",  	::onConnected);
	addEventListener("onCvarChanged", 	::onCvarChanged);



	if (!isDefined(level.warnings_visible))	// may be already defined if update() is called from another file
		level.warnings_visible = false;

	thread sv_cheats_update();

	// Make sure warnigs get hided every restart
	wait level.frame; // wait to check if update was called
	if (!level.warnings_visible)
		hide();
}

onConnected()
{
	self setClientCvarIfChanged("ui_serverinfo_hud", level.warnings_text);
}

sv_cheats_update()
{
	// If this is after fresh map restart, update the warning if showed becuase sv_cheats is set too late
	if (game["firstInit"])
	{
		wait level.fps_multiplier * 0.2;

		if (level.warnings_visible)
			update();
	}
}


// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	// Server info update
	if (!isRegisterTime && !game["firstInit"] && !isDefined(game["cvars"][cvar]["inQuiet"]) && level.warnings_visible)
	{
		//iprintln("update_changedCvar " + cvar + " " + value);
		thread update();
	}
}




// Called from PAM_Header
update()
{
	//iprintln("update");

	if (game["is_public_mode"] || level.gametype == "strat" || (!level.in_readyup && level.gametype != "sd"))
	{
		hide();
		return;
	}

	level.warnings_visible = true;

	str = "";
	errors = "";
/*
	// ZPAM_RENAME
	errors += "^3This is preview version of PAM!^7\n";
	errors += "^3Report feedback to eyza#7930^7\n";
*/
	if (getcvarint("sv_cheats"))
	{
		errors += "^1Cheats are enabled!^7\n";
	}
	if (getcvar("g_password") == "")
	{
		errors += "^3Server password is not set!^7\n";
	}

	map = level.mapname;
	if (map == "mp_toujane" || map == "mp_burgundy" || map == "mp_dawnville" || map == "mp_matmata" || map == "mp_carentan")
	{
		errors += "^3This is old version of map, use fixed version^7\n";
	}

	if (errors != "")
	{
		str += errors + "\n";
	}

	// Changed cvars
	changedCvars = maps\mp\gametypes\global\cvar_system::getChangedCvarsString();
	if (changedCvars.size > 0)
	{
		str += "^3Changed cvars:"+"\n^7";

		for(i = 0; i < changedCvars.size; i++)
		{
			cvar = game["cvars"][changedCvars[i]]; // array

			str += cvar["name"] + " = " + cvar["value"] + "   (" + cvar["defaultValue"]  + ")" + "\n";
		}
	}

	level.warnings_text = str;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i] setClientCvarIfChanged("ui_serverinfo_hud", str);
	}
}

hide()
{
	//iprintln("hide");

	level.warnings_visible = false;
	level.warnings_text = "";

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i] setClientCvarIfChanged("ui_serverinfo_hud", "");
	}
}
