#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	// Player's weapon drop
	registerCvar("scr_allow_primary_drop", "BOOL", 0);
	registerCvar("scr_allow_secondary_drop", "BOOL", 0);


	// Add thread to all dropped weapon
	level thread Weapon_PickUp_Monitor();

	addEventListener("onConnected",     ::onConnected);

	// If is allwed to drop player's secondary weapon
	if (level.allow_primary_drop || level.allow_secondary_drop)
		addEventListener("onSpawnedPlayer",    ::onSpawnedPlayer);
}

// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		case "scr_allow_primary_drop": 		level.allow_primary_drop = value; return true;
        	case "scr_allow_secondary_drop": 	level.allow_secondary_drop = value; return true;
	}
	return false;
}

onConnected()
{
	self.dropped_weapons = 0;
	self.taked_weapons = 0;
}

onSpawnedPlayer()
{
    // Monitor Weapon Drop
    if (!level.in_readyup && level.gametype != "strat")
        self thread playersWeaponDrop();
}


// "Hold F to drop a weapon" functionality
playersWeaponDrop()
{
	self endon("disconnect");
	self endon("killed_player");

	for(;;)
	{
        wait level.fps_multiplier * .25;

        // Timer of how long F is pressed
		timer = 0;
		while (self UseButtonPressed() && !(level.gametype == "sd" && self.bombinteraction))
		{
			timer += level.fps_multiplier * .1;

			// How long you have to hold f
            if (timer > 1.0)
            {
                slot[0] = self getWeaponSlotWeapon("primary");
                slot[1] = self getWeaponSlotWeapon("primaryb");
                current = self getcurrentweapon();

                // If primary weapon can not be dropped
                if (!level.allow_primary_drop && current == slot[0])
                    break;
                // If secondary weapon can not be dropped
                if (!level.allow_secondary_drop && current == slot[1])
                    break;

                // We can drop weapon only if we have 2 weapons
                if (slot[0] == "none" || slot[1] == "none")
                {
                    self iprintln("^3You can not drop your last weapon.");
                    break;
                }

                // No weapon in hands (player is on ladder for example)
                if (current == "none")
                    break;

                // Check if current weapon can be dropped (snipers are disabled for example in cg)
                if (!maps\mp\gametypes\_weapon_limiter::isWeaponDropable(current))
                {
                    self iprintln("^3This weapon can not be dropped.");
                    break;
                }

				// Drop primary weapon only if weapon in secondary slot is big weapon
                if (current == slot[0] && !isDefined(level.weapons[slot[1]]))
                {
                    self iprintln("^3Primary weapon can be dropped only if there are 2 main weapons.");
                    break;
                }




                // Drop weapon
                self dropItem(current);
                level notify("weapon_dropped", current, self);

                // Switch to wepoan that left
                if (current == slot[0])
                    self switchToWeapon(slot[1]);
                else
                    self switchToWeapon(slot[0]);

                // Used in strattime to check if some weapon was dropped
                self.dropped_weapons++;

				wait level.fps_multiplier * 1;

                break;
            }

			wait level.fps_multiplier * .1;
		}
	}
}





// Add thread to dropped weapon
Weapon_PickUp_Monitor()
{
	while(1)
	{
		level waittill("weapon_dropped", weaponname, player);

		// Run thread on all dropped weapons, grenades, smokes
		entities = getentarray("weapon_"+weaponname, "classname");
		for(i = 0; i < entities.size; i++)
		{
			if (!isDefined(entities[i].hasBrain))
			{
				entities[i] thread pickup_think(weaponname);
			}
		}
	}
}


// self is reference to dropped weapon
pickup_think(weaponname) {

	self.hasBrain = true;

//	iprintln("## Running thread on spawend weapon " + weaponname);

	//iprintln(self.count);
	//iprintln(self.spawnflags);


    for (;;)
    {
    	// Called if weapon is picked up or ammo is used
    	self waittill("trigger", player, dropedWeaponEntitiy);


        //iprintln("trigger weapon: " + weaponname);


        // Called even if ammo is picked up
        player.taked_weapons++;
        level notify("weapon_taked", weaponname, player); // used in weapon_limiter



    	if (isDefined(dropedWeaponEntitiy))
    	{
    		//iprintln(weaponname + " picked up and changed with " + dropedWeaponEntitiy.classname);

    		// Run thread on new dropped weapon // From "weapon_m1garand_mp" to "m1garand_mp"
            dropedWeaponName = getsubstr(dropedWeaponEntitiy.classname, "weapon_".size);
    		//dropedWeaponEntitiy thread pickup_think(dropedWeaponName);

            level notify("weapon_dropped", dropedWeaponName, player);
    	}
    	else
    	{
    		// Weapon was picked up to empty slot or just ammo was picked up
    		//iprintln(weaponname + " - empty slot or ammo picked up.");
    	}


        waittillframeend;


    	// If non-sniper player pickup sniper weapon on the ground, drop it
    	// Check, if this picked up weapon is allowed to drop
    	if (!player maps\mp\gametypes\_weapon_limiter::isWeaponPickable(weaponname))
    	{
			player iprintln("^3You cannot pickup this limited weapon!");

			// Drop back to ground
			player dropItem(weaponname);
			level notify("weapon_dropped", weaponname, player);

			primary = player getWeaponSlotWeapon("primary");
			primaryb = player getWeaponSlotWeapon("primaryb");

			if (primary != "none")
				player switchToWeapon(primary);
			else if (primaryb != "none")
				player switchToWeapon(primaryb);
    	}

    }
	//iprintln("\n");
}
