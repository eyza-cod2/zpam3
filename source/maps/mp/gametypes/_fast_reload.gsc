#include maps\mp\gametypes\_callbacksetup;

init()
{
    level.fastReload_startTime = getTime();

    addEventListener("onConnected",     ::onConnected);
}

onConnected()
{
    if (!level.scr_fast_reload_fix)
      return;

    self thread manageWeaponCycleDelay();
}

// Called if cvar scr_fast_reload_fix changes
cvarChanged()
{
  	if (level.scr_fast_reload_fix) // changed to 1
  	{
    		players = getentarray("player", "classname");
    		for(i = 0; i < players.size; i++)
    		{
      			player = players[i];
      			player onConnected();
    		}
  	}
}

getCurrentWeaponSlot()
{
    weapon1 = self getweaponslotweapon("primary");
	weapon2 = self getweaponslotweapon("primaryb");

    current = self getcurrentweapon(); // can be none ()

	if(current == weapon1)
		return "primary";
	else if(current == weapon2)
		return "primaryb";
    else
        return "none";
}

getClipAmmo()
{
    currentSlot = getCurrentWeaponSlot();

    return self getweaponslotclipammo(currentSlot);
}

manageWeaponCycleDelay()
{
    self endon("disconnect");

    lastClipAmmo = 0;
    lastWeapon = "";

    // Start as activated to fix problem when the cvar is set at the end of the round
    cycleDelayActivated = true;
    cycleDelayTime = 0;

    wait level.fps_multiplier * 0.2;

    for (;;)
    {
        wait level.frame;

        // Fast reload fix was turned off by cvar
        if (!level.scr_fast_reload_fix)
        {
          if (!cycleDelayActivated) // wait until cycle dalay is restored to original state
            return;
        }

        // If we have weapon that can be bugged
        if (cycleDelayActivated)
        {
            cycleDelayTime -= level.frame;

            if (cycleDelayTime <= 0)
            {
                //self iprintln("^2Fast reload bug ok");
                self setClientCvar("cg_weaponCycleDelay", "0");

                cycleDelayActivated = false;
                cycleDelayTime = 0;
            }
        }


        currentWeapon = self getcurrentweapon();

        // Player is planting, or is using ladder
        if (currentWeapon == "none")
        {
            cycleDelayTime = 0; // reset cycle delay
            continue;
        }


        if (currentWeapon != lastWeapon)
        {
            //self iprintln("weapon switched");
            lastWeapon = currentWeapon;

            lastClipAmmo = self getClipAmmo();

            cycleDelayTime = 0; // reset cycle delay

            continue; // ignore weapon clip ammo change because weapon is changed
        }


        currentClipAmmo = self getClipAmmo();

        // If weapon fired
        if (currentClipAmmo < lastClipAmmo)
        {
            // Get time how long rechamber will take
            timer = GetRechamberTime(currentWeapon);

      			if (timer > 0)
      			{
  	            cycleDelayActivated = true;
  	            cycleDelayTime = timer;

  	            //self iprintln("^1Preventing fast reload bug");
  	            self setClientCvar("cg_weaponCycleDelay", "200");	// time in ms when player can change weapon again
      			}
        }

        lastClipAmmo = currentClipAmmo;
    }
}



/*
Hit fire                                      Ready to fire again
   ^                                                  ^
   |                                                  |
   |  Fire time   |           Rechamber time          |
   | ------------ | ----------------------------------|
   |    0.33s     |                 1s                |
   |              |                     |             |
   |              | Rechamber bolt time |             |
   |              | ------------------- |             |
   |              |        0.65s        |             |

      All able      Fire, bash, zoom        All able
                         disabled

Rechamber time - fire disabled
Rechember bolt time - bash disabled

*/
GetRechamberTime(weaponName)
{
    timer = 0;
    switch(weaponName)
    {
        case "kar98k_mp":               timer = 1.33; break;
        case "kar98k_sniper_mp":        timer = 1.33; break;

        case "enfield_mp":              timer = 1.397; break;
        case "enfield_scope_mp":        timer = 1.38; break;

        case "mosin_nagant_mp":         timer = 1.28; break;
        case "mosin_nagant_sniper_mp":  timer = 1.33; break;

        case "springfield_mp":          timer = 1.33; break;

        case "shotgun_mp":              timer = 1.0163; break;
	      case "shotgun_rebalanced_mp":              timer = 1.0163; break;
    }

    return timer;
}
