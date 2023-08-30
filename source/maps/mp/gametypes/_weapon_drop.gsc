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

	self.weapon_slot0 = "none";
	self.weapon_slot1 = "none";
	self.weapon_current = "none";
}

onSpawnedPlayer()
{
	if (!level.in_readyup && level.gametype != "strat")
	{
		self thread playerWeaponWatcher();
		self thread playersWeaponDrop();
	}
}

playerWeaponWatcher()
{
	self endon("disconnect");

	primary = "none";
	primaryb = "none";
	current = "none";

	for(;;)
	{
		wait level.frame;
		waittillframeend;

		if (!isAlive(self))
		{
			wait level.frame;
			self.weapon_slot0 = "none";
			self.weapon_slot1 = "none";
			self.weapon_current = "none";
			return;
		}

		self.weapon_slot0 = primary;
		self.weapon_slot1 = primaryb;
		self.weapon_current = current;

		primary = self getWeaponSlotWeapon("primary");
		primaryb = self getWeaponSlotWeapon("primaryb");
		current = self getcurrentweapon();
	}

}


// "Hold F to drop a weapon" functionality
playersWeaponDrop()
{
	self endon("disconnect");

	for(;;)
	{
		wait level.fps_multiplier * .25;

		if (!isAlive(self))
			return;

		// Timer of how long F is pressed
		timer = 0;
		while (self UseButtonPressed() && !(level.gametype == "sd" && self.bombinteraction) && !(level.gametype == "re" && self.obj_carrier))
		{
			timer += level.fps_multiplier * .1;

			if (!isAlive(self))
				return;

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
					self iprintln("^3Cannot drop your last weapon.");
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
					self iprintln("^3Primary weapon can be dropped only if you have 2 primary weapons.");
					break;
				}


				// Drop weapon
				self dropItem(current);
				waittillframeend; // wait before next "weapon_dropped" can be called
				level notify("weapon_dropped", current, self);

				// Switch to wepoan that left
				if (current == slot[0])
					self switchToWeapon(slot[1]);
				else
					self switchToWeapon(slot[0]);

				// Used in strattime to check if some weapon was dropped
				self.dropped_weapons++;


				wait level.fps_multiplier * .25;

				// Play sound in strattime indicating where the weapon is dropped
				if (isDefined(level.in_strattime) && level.in_strattime)
				{
					self playSound("zpam_weap_drop");
				}

				wait level.fps_multiplier * .75;

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

		//iprintln("Weapon dropped -> " + weaponname + " by " + player.name);

		// Run thread on all dropped weapons, grenades, smokes
		entities = getentarray("weapon_"+weaponname, "classname");
		for(i = 0; i < entities.size; i++)
		{
			if (!isDefined(entities[i].hasBrain))
			{
				entities[i] thread dropped_weapon_think(weaponname);
			}
		}
	}
}


// self is reference to dropped weapon
dropped_weapon_think(weaponname)
{
	self.hasBrain = true;

	//iprintln("## Running thread on spawend weapon " + weaponname);


	// Undropable weapon (scope, shotgun) may be dropped when weapon is changed with another weapon
	// Disable pickup by default and handle pickup by player who drop it
	if (maps\mp\gametypes\_weapon_limiter::isWeaponDropable(weaponname) == false)
		self thread undroppable_weapon_think(weaponname);



	origin = self.origin;
	angles = self.angles;
	model = self.model;


	for (;;)
	{
		// Called if weapon is picked up or ammo is used
		self waittill("trigger", player, dropedWeaponEntitiy);

		//iprintln("trigger weapon: " + weaponname);

		// Called even if ammo is picked up
		player.taked_weapons++;




		if (isDefined(dropedWeaponEntitiy))
		{
			//iprintln(weaponname + " picked up and changed with " + dropedWeaponEntitiy.classname);

			// From "weapon_m1garand_mp" to "m1garand_mp"
			droppedWeaponName = getsubstr(dropedWeaponEntitiy.classname, "weapon_".size);

			// Run thread on new dropped weapon
			waittillframeend; // wait before next "weapon_dropped" can be called
			level notify("weapon_dropped", droppedWeaponName, player);
		}
		else
		{
			// Weapon was picked up to empty slot or just ammo was picked up
			//iprintln(weaponname + " - empty slot or ammo picked up.");

			// Is main weapon or pistol (ignore grenade and smoke)
			if (maps\mp\gametypes\_weapons::isMainWeapon(weaponname) || maps\mp\gametypes\_weapons::isPistol(weaponname))
			{
				slot0 = player getWeaponSlotWeapon("primary");
				slot1 = player getWeaponSlotWeapon("primaryb");
				current = player getcurrentweapon();

				/*
				iprintln("-------------------");
				iprintln(player.weapon_slot0);
				iprintln(player.weapon_slot1);
				iprintln(player.weapon_current);
				iprintln("-------------------");
				iprintln(slot0);
				iprintln(slot1);
				iprintln(current);
				iprintln("-------------------");
				*/

				// If there was empty slot in previous frame and that slot now contain this weapon, it means this weapon was picked into empty slot (no ammo pickup)
				if ((player.weapon_slot0 == "none" && slot0 == weaponname && player.weapon_slot1 == slot1 && player.weapon_slot1 == current) ||
				    (player.weapon_slot1 == "none" && slot1 == weaponname && player.weapon_slot0 == slot0 && player.weapon_slot0 == current))
				{
					//iprintln(weaponname + " - picked up into empty slot");
				}
				else
				{
					//iprintln(weaponname + " - ammo picked up");

					if (isDefined(level.in_strattime) && level.in_strattime)
					{
						// Spawn new weapon - this weapon will act as dropped weaon and have gravity animation
						wep = spawn("weapon_"+weaponname, origin);
						wep.angles = angles;

						// Run thread on new dropped weapon
						waittillframeend; // wait before next "weapon_dropped" can be called
						level notify("weapon_dropped", weaponName, player);

						return;
					}
				}
			}


		}


		// In strattime, give player max ammo for picked weapon (needed especialy for scriptly dropped weapons - they dont have max ammo for some reason)
		if (isDefined(level.in_strattime) && level.in_strattime)
		{
			if (maps\mp\gametypes\_weapons::isMainWeapon(weaponname) || maps\mp\gametypes\_weapons::isPistol(weaponname))
			{
				//iprintln("giving max ammo for " + weaponname + " (strat_time)");
				player givemaxammo(weaponname);
			}
		}


		waittillframeend;


		// If non-sniper player pickup sniper weapon on the ground, drop it
		// Check, if this picked up weapon is allowed to drop
		// This is JUST IN CASE as the pickup enable/disable logic may not work, because pickup is predicted on client side
		if (!player maps\mp\gametypes\_weapon_limiter::isWeaponPickable(weaponname))
		{
			player iprintln("^3You cannot pickup this limited weapon!");

			// Drop back to ground
			player dropItem(weaponname);
			waittillframeend; // wait before next "weapon_dropped" can be called
			level notify("weapon_dropped", weaponname, player);

			primary = player getWeaponSlotWeapon("primary");
			primaryb = player getWeaponSlotWeapon("primaryb");

			if (primary != "none")
			player switchToWeapon(primary);
			else if (primaryb != "none")
			player switchToWeapon(primaryb);
		}

	}
}


// self is reference to dropped weapon
undroppable_weapon_think(weaponname)
{
	//iprintln("undroppable_weapon_think("+weaponname+")");


	isEnabled = false;
	self disable_pickup();

	for(;;)
	{
		wait level.fps_multiplier * 0.05;

		if (!isDefined(self))
		{
			//iprintln("deleted weapon");
			return;
		}

		enable = false;
		players = getentarray("player", "classname");
		for (i = 0; i < players.size; i++)
		{
			player = players[i];

			if (isAlive(player) == false)
				continue;

			eye = player maps\mp\gametypes\global\player::getEyeOrigin();

			dist = distance(eye, self.origin);

			//player iprintln(dist);

			if (dist > (150 + player.movingDifference * 5))	// 100 + moving offset since pickup is predicted (moving difference is around 18 when running)
				continue;

			if (player maps\mp\gametypes\_weapon_limiter::isWeaponPickable(weaponname))
				enable = true;
			else
			{
				enable = false;
				break;
			}
		}

		if (isEnabled != enable)
		{
			isEnabled = enable;

			if (enable)	self enable_pickup();
			else		self disable_pickup();
		}
	}

}

/*
	When weapon is dropped, special content bit is set when there is no ammo to disable pickup
	This makes the weapon not pickable: (reversed code)
		if ( !clientAmmoCount && !clipIndex )
			ent->r.contents &= ~0x200000u;
*/
enable_pickup()
{
	//iprintln("enabled");
	old = self setcontents(0); // get old content
	new = old | 2097152; // 0x200000
	new = self setcontents(new); // get content
}

disable_pickup()
{
	//iprintln("disabled");
	old = self setcontents(0); // get old content
	new = old & -2097153; // 0xFFDFFFFF (negated 0x200000)
	new = self setcontents(new); // get content
}
