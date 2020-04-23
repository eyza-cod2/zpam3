#include maps\mp\gametypes\_callbacksetup;

// Source from maps/mp/pam/shellshock.gsc
// content moved here

init()
{
	precacheShellShock("default");
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
