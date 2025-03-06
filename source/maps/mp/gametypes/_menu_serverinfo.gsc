#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onStartGameType", ::onStartGameType);
	addEventListener("onCvarChanged",   ::onCvarChanged);

	registerCvarEx("I", "scr_motd", "STRING", "Welcome. This server is running zPAM3.34 NA");	// ZPAM_RENAME

	level.motd = "";
	level.serverversion = "";
	level.serverinfo_left1 = "";
	level.serverinfo_left2 = "";
	level.serverinfo_right1 = "";
	level.serverinfo_right2 = "";
}

// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	generateGlobalServerInfo();
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	// Server info update
	if (!isRegisterTime && !game["firstInit"] && !isDefined(game["cvars"][cvar]["inQuiet"]) && cvar != "pam_mode_custom")
	{
		thread generateGlobalServerInfo();
	}

	switch(cvar)
	{
		case "scr_motd": level.scr_motd = value; return true;
	}
	return false;
}


// Called from menu wen serverinfo menu is opened
updateServerInfo()
{
	self setClientCvarIfChanged("ui_motd", level.motd);
	self setClientCvarIfChanged("ui_serverversion", level.serverversion);

	// These are set from gametype
	self setClientCvarIfChanged("ui_serverinfo_left1", level.serverinfo_left1);
	self setClientCvarIfChanged("ui_serverinfo_left2", level.serverinfo_left2);

	// These are global
	self setClientCvarIfChanged("ui_serverinfo_right1", level.serverinfo_right1);
	self setClientCvarIfChanged("ui_serverinfo_right2", level.serverinfo_right2);
}

generateGlobalServerInfo()
{
	waittillframeend; // wait untill all other server change functions are processed

	// Generate motd
	motd = level.scr_motd;
	motd_final = "";
	skipNextChar = false;
	for (i=0; i < motd.size; i++)
	{
		if (skipNextChar)
		{
			skipNextChar = false;
			continue;
		}

		if (motd[i] == "\\" && i < motd.size-1 && motd[i+1] == "n")
		{
			skipNextChar = true;
			motd_final += "\n";
		}
		else
			motd_final += "" + motd[i];
	}
	level.motd = motd_final;




	level.serverversion = getCvar("version") + "    "; // "CoD2 MP 1.3 build pc_1.3_1_1 Mon May 01 2006 05:05:43PM win-x86"

	sys_cpuGHz = getCvarFloat("sys_cpuGHz"); // "2.59199"
	if (sys_cpuGHz != 0)
		level.serverversion += " (CPU " + format_fractional(sys_cpuGHz, 1, 2) + " GHz)";

	sys_gpu = getcvar("sys_gpu"); // "Intel(R) UHD Graphics"
	if (sys_gpu != "")
		level.serverversion += " (GPU " + sys_gpu + ")";

	level.serverversion += " (" + getcvarint("sv_maxclients") + " slots)"; // (14 slots)

	if (contains(level.serverversion, "win"))
		level.serverversion += " (Windows server)";
	else if (contains(level.serverversion, "linux"))
		level.serverversion += " (Linux server)";




	title = "PAM mode:\n";
	value = level.pam_mode + "\n";

	title +="Fast reload fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_fast_reload_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_fast_reload_fix) 	value += changed+"Enabled ^9Disabled^7" + "\n";
	else				value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="Consistent shotgun:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_shotgun_consistent") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_shotgun_consistent) 	value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="Hand hitbox fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_hitbox_hand_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_hitbox_hand_fix) 		value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";


	title +="Torso hitbox fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_hitbox_torso_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_hitbox_torso_fix) 	value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="Prone peek fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_prone_peek_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_prone_peek_fix) 		value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="MG clip fix:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("scr_mg_peek_fix") && !game["is_public_mode"]) changed = "^3";
	if (level.scr_mg_peek_fix) 		value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title +="Antilag:\n";
	changed = "^7"; if (maps\mp\gametypes\global\cvar_system::isCvarChangedFromRuleValue("g_antilag") && !game["is_public_mode"]) changed = "^3";
	if (level.antilag) 			value += changed+"Enabled ^9Disabled^7" + "\n";
	else					value += "^9Enabled "+changed+"Disabled^7" + "\n";

	title += "\n";
	value += "\n";


	if (game["is_public_mode"] == false)
	{
		str = "";
		changedCvars = maps\mp\gametypes\global\cvar_system::getChangedCvarsString();
		if (changedCvars.size > 0)
		{
			for(i = 0; i < changedCvars.size; i++)
			{
				switch(changedCvars[i])
				{
					case "scr_fast_reload_fix":
					case "scr_shotgun_consistent":
					case "scr_hitbox_hand_fix":
					case "scr_hitbox_torso_fix":
					case "scr_prone_peek_fix":
					case "scr_mg_peek_fix":
					case "g_antilag":
						continue;
				}

				str += changedCvars[i]+"\n";
			}
		}
		if (str != "")
		{
			title += "^3Changed cvars:"+"\n";
			value += str;
		}
	}

	level.serverinfo_right1 = title;
	level.serverinfo_right2 = value;
}
