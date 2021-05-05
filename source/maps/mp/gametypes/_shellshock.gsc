#include maps\mp\gametypes\global\_global;

// Source from maps/mp/pam/shellshock.gsc
// content moved here

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_allow_shellshock", "BOOL", 1);

	if(game["firstInit"])
	{
		precacheShellShock("default");
	}
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_allow_shellshock": 		level.scr_allow_shellshock = value; return true;
	}
	return false;
}

shellshockOnDamage(cause, damage)
{
	if (level.scr_allow_shellshock)
	{
		if( cause == "MOD_EXPLOSIVE" ||
			cause == "MOD_GRENADE" ||
			cause == "MOD_GRENADE_SPLASH" ||
			cause == "MOD_PROJECTILE" ||
			cause == "MOD_PROJECTILE_SPLASH" )
		{
			time = 0;

			if(damage >= 90)
				time = 4;
			else if(damage >= 50)
				time = 3;
			else if(damage >= 25)
				time = 2;
			else if(damage > 10)
				time = 1;

			if(time)
				self shellshock("default", time);
		}
	}
}
