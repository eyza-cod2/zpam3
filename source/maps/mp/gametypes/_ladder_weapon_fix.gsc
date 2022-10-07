#include maps\mp\gametypes\global\_global;

// Weapon ladder bug is when you 2x fast switch weapon and then hold fire button - weapon is invisible with no switch sound
// Using a ladder with weapon bugged makes no sound for opponent and is disabled by league rules

Init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvar("scr_ladder_weapon_fix", "BOOL", 1);	// level.scr_ladder_weapon_fix

	addEventListener("onConnected",     ::onConnected);
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_ladder_weapon_fix":
			level.scr_ladder_weapon_fix = value;
			if (!isRegisterTime)
			{
				if (level.scr_ladder_weapon_fix) // changed to 1
				{
						players = getentarray("player", "classname");
						for(i = 0; i < players.size; i++)
						{
								player = players[i];
								player onConnected();
						}
				}
			}
			return true;
	}
	return false;
}

onConnected()
{
	if (!level.scr_ladder_weapon_fix)
		return;

	self thread bug_fix();
}



bug_fix()
{
	self endon("disconnect");

	fireTime = 0.0;
	fixApplied = false;

	for(;;)
	{
		if (level.in_readyup)
		{
				wait level.fps_multiplier * 1;
				continue;
		}

		if (self attackbuttonpressed() && !self isOnGround() && !self.usingMG)
			fireTime += level.frame;
		else
		{
			fireTime = 0;
			fixApplied = false;
		}

		if (fireTime > 1.0)
		{
			primary = self getWeaponSlotWeapon("primary");
			primaryb = self getWeaponSlotWeapon("primaryb");
			current = self getcurrentweapon();

			if (current != "none" && fixApplied == false)
			{
				//self iprintln("^1Ladder weapon bug");

				if (current == primary && primaryb != "none")
					self switchToWeapon(primaryb);
				else if (current == primaryb && primary != "none")
					self switchToWeapon(primary);

				fixApplied = true;
			}
		}

		wait level.frame;
	}
}
