#include maps\mp\gametypes\global\_global;

init()
{
    addEventListener("onConnected",     ::onConnected);
    addEventListener("onConnectedAll",     ::onConnectedAll);
    addEventListener("onDisconnect",    ::onDisconnect);
    addEventListener("onJoinedTeam",    ::onJoinedTeam);
}

onConnected()
{
    self thread onWeaponChanged();
}

// Is called only once when map_restart
onConnectedAll()
{
    level thread Update_All_Weapon_Limits();
}

onDisconnect()
{
	level thread Update_All_Weapon_Limits();
}

onJoinedTeam(teamName)
{
	if (teamName == "spectator" || teamName == "streamer")
	{
		// Update weapons for leaved team
		if (self.leaving_team == "allies" || self.leaving_team == "axis")
			level thread Update_All_Weapon_Limits(); //(self.leaving_team);
	}
	else
	{
		// Update weapons just for me and my team
		if (self.leaving_team == "spectator" || self.leaving_team == "streamer" || self.leaving_team == "none")
			level thread Update_All_Weapon_Limits(); //(teamName); // update my new team

		// Update weapons for all
		else if (self.leaving_team == "allies" || self.leaving_team == "axis")
			level thread Update_All_Weapon_Limits(); //("all"); // update all teams
	}
}

onWeaponChanged()
{
    for(;;)
    {
        self waittill("weapon_changed", new_weapon, leavedWeapon, leavedWeaponFromTeam);

        // Unmark weapon before
        if (isDefined(leavedWeapon))
            Update_Client_Weapon(self, leavedWeapon, leavedWeaponFromTeam);

        // Mark this selected weapon as selected in menu
        self setClientCvarIfChanged(level.weapons[new_weapon].client_allowcvar, 3);


        level thread Update_All_Weapon_Limits();
    }
}


// Needs to be called when weapon statuses may have changed:
// Player Disconnect, Player Changes Teams (allies,axis,spec), Player Changes weapon, Class-Cvar changed, weapon is dropped/taken
Update_All_Weapon_Limits()
{
	 //iprintln("=====================Update_All_Weapon_Limits()=========================");

	// wait until player is fully connected/disconnected
	waittillframeend;

	// Number of used weapons in their classes
	allies_count = [];
	axis_count = [];   //axis_count["smg"] = 2   -   means there is used for example 1 thomson + 1 greasegun

	// Names of players that uses class
	allies_names = [];
	axis_names = [];

	// Check if class was limited in each side
	allies_was_limited = [];
	axis_was_limited = [];   //axis_count["sniper"] = true   -   means there are maximum number of snipers for team axis

	// Loads actual limits in cvar to level.weaponclass[<class>].limit
	// Load limit dvar from each class
	for(i = 0; i < level.weaponclasses.size; i++)
	{
		// boltaction sniper semiautomatic smg mg shotgun
		classname = level.weaponclasses[i];

		allies_count[classname] = 0;
		axis_count[classname] = 0;

		allies_names[classname] = [];
		axis_names[classname] = [];

		allies_was_limited[classname] = level.weaponclass[classname].allies_limited;
		axis_was_limited[classname] = level.weaponclass[classname].axis_limited;
	}


	// Count number of used weapons in each class
	players = getentarray("player", "classname");
	for(p = 0; p < players.size; p++)
	{
		player = players[p];

		// Player is not spawned yet || player is not in allies or axis team
		if (!isDefined(player.pers["weapon"]) || !(player.pers["team"] == "allies" || player.pers["team"] == "axis"))
			continue;

        // Find how many player from each team is using specific classes
		for(i = 0; i < level.weaponclasses.size; i++)
		{
			// boltaction sniper semiautomatic smg mg shotgun
			classname = level.weaponclasses[i];

			// Player have a weapon of class we are looking for
			if (level.weapons[player.pers["weapon"]].classname == classname)
			{
				if (player.pers["team"] == "allies")
				{
					allies_count[classname]++;
					allies_names[classname][allies_names[classname].size] = player.name;
				}
				else if (player.pers["team"] == "axis")
				{
					axis_count[classname]++;
					axis_names[classname][axis_names[classname].size] = player.name;
				}
			}
		}
	}


	// Format player names from array to string
	for(i = 0; i < level.weaponclasses.size; i++)
	{
		// boltaction sniper semiautomatic smg mg shotgun
		classname = level.weaponclasses[i];

		level.weaponclass[classname].allies_usedby = "";
		level.weaponclass[classname].axis_usedby = "";

		for (p = 0; p < allies_names[classname].size; p++)
		{
			playername = allies_names[classname][p];

			if (p!=0)
				level.weaponclass[classname].allies_usedby += "\n";

			level.weaponclass[classname].allies_usedby += playername;
		}


		for (p = 0; p < axis_names[classname].size; p++)
		{
			playername = axis_names[classname][p];

			if (p!=0)
				level.weaponclass[classname].axis_usedby += "\n";

			level.weaponclass[classname].axis_usedby += playername;
		}
	}





	// iprintln("\n\n----------------------------------------------------");


	// iprintln("#ALLIES_LIMITED_1:  sniper:" + level.weaponclass["sniper"].allies_limited + "  boltac:" + level.weaponclass["boltaction"].allies_limited + "  semiauto:" + level.weaponclass["semiautomatic"].allies_limited + "  smg:" + level.weaponclass["smg"].allies_limited + "  mg:" + level.weaponclass["mg"].allies_limited + "  shotgun:" + level.weaponclass["shotgun"].allies_limited);

	// iprintln("#ALLIES_COUNT:      sniper:" + allies_count["sniper"] + "  boltac:" + allies_count["boltaction"] + "  semiauto:" + allies_count["semiautomatic"] + "  smg:" + allies_count["smg"] + "  mg:" + allies_count["mg"] + "  shotgun:" + allies_count["shotgun"]);



	// Check if is used more weapons in class then allowed limit for each team
	for(i = 0; i < level.weaponclasses.size; i++)
	{
		// boltaction sniper semiautomatic smg mg shotgun
		classname = level.weaponclasses[i];

		// If maximum of allowed weapons in each class is reached for team allies
		if (allies_count[classname] >= level.weaponclass[classname].limit)
			level.weaponclass[classname].allies_limited = 1;
		else
			level.weaponclass[classname].allies_limited = 0;

		// If maximum of allowed weapons in each class is reached for team axis
		if (axis_count[classname] >= level.weaponclass[classname].limit)
			level.weaponclass[classname].axis_limited = 1;
		else
			level.weaponclass[classname].axis_limited = 0;





		// Update client cvars if there is any change from last check or its forced
		//if (allies_was_limited[classname] != level.weaponclass[classname].allies_limited) {
			Update_WeaponClass_HUDs("allies", classname);
		//}
		//if (axis_was_limited[classname] != level.weaponclass[classname].axis_limited) {
			Update_WeaponClass_HUDs("axis", classname);
		//}
	}


	// iprintln("#ALLIES_LIMITED_2:  sniper:" + level.weaponclass["sniper"].allies_limited + "  boltac:" + level.weaponclass["boltaction"].allies_limited + "  semiauto:" + level.weaponclass["semiautomatic"].allies_limited + "  smg:" + level.weaponclass["smg"].allies_limited + "  mg:" + level.weaponclass["mg"].allies_limited + "  shotgun:" + level.weaponclass["shotgun"].allies_limited);


	// iprintln("----------------------------------------------------\n\n");


}

// Called only when weapon changed via menu
isWeaponAvaible(response)
{
	// This weapon is not defined || is not allowed || is not avaible for my team
	if (!isDefined(level.weapons[response]) || !level.weapons[response].allow || !(level.weapons[response].team == "both" || self.pers["team"] == level.weapons[response].team))
		return false;

	//Weapon Limiter - check if weapon is in use
	if (!self isWeaponSelectable(response))
		return false;

	return true;
}

isWeaponDropable(weaponname)
{
	if (maps\mp\gametypes\_weapons::isPistol(weaponname) && getCvarInt("scr_pistol_allow_drop") == 1)
		return true;

	if (isDefined(level.weapons[weaponname]) && level.weaponclass[level.weapons[weaponname].classname].allow_drop)
		return true;

	return false;
}

isWeaponPickable(weaponname)
{
	// This weapon is weapon that player starts the round with, he can pick it back
	if (isDefined(self.selectedWeaponOnRoundStart) && self.selectedWeaponOnRoundStart == weaponname)
		return true;

	// If weapon is allowed for drop, it can be also picked up
	if (maps\mp\gametypes\_weapons::isMainWeapon(weaponname))
	{
		classname = level.weapons[weaponname].classname;
		if (!level.weaponclass[classname].allow_drop)
            		return false;
	}
	else if (maps\mp\gametypes\_weapons::isPistol(weaponname))
	{
		if (getCvarInt("scr_pistol_allow_drop") == 0)
			return false;
	}

	return true;
}

isWeaponSaveable(weaponname)
{
    if (maps\mp\gametypes\_weapons::isMainWeapon(weaponname))
    {
      // Player has this weapon selected, it means it can be saved
      if (isDefined(self.pers["weapon"]) && self.pers["weapon"] == weaponname)
        return true;

      weaponclass = level.weapons[weaponname].classname;

      // Atleast 2 weapons are enabled
      if (level.weaponclass[weaponclass].limit > 1)
      {
        // Save only if there is atleast one free slot for weapon
        weapon_class_count = self getUsageOfWeaponClass(weaponclass, true);

      	if (weapon_class_count < level.weaponclass[weaponclass].limit)
      		return true;
      }
    }
    return false;
}

// Called when weapon changed via menu
isWeaponSelectable(weaponname)
{
  weaponclass = level.weapons[weaponname].classname;
	weapon_class_count = self getUsageOfWeaponClass(weaponclass, false);

	// We are on maximum limit, so disable selection
	if (weapon_class_count >= level.weaponclass[weaponclass].limit)
		return false;

	return true;
}


getUsageOfWeaponClass(weaponclass, countSelf)
{
  weapon_class_count = 0;
  // Find how many players from my team have weapons from the class
  players = getentarray("player", "classname");
  for(i = 0; i < players.size; i++)
  {
      player = players[i];

      // Player is not spawned yet || Player is in different team || its me
      if (!isDefined(player.pers["weapon"]) || player.pers["team"] != self.pers["team"] || (!countSelf && player == self))
        continue;

      // Players selected weapon is in class we are looking for
      if (level.weapons[player.pers["weapon"]].classname == weaponclass)
        weapon_class_count++;
  }
  return weapon_class_count;
}


Update_WeaponClass_HUDs(team, weaponclass)
{


	if (team == "allies")
		allowed = !level.weaponclass[weaponclass].allies_limited;
	else
		allowed = !level.weaponclass[weaponclass].axis_limited;


	/*
	if (allowed)
	{
		 iprintln("## ^2ALLOW^7:   team: " + team + "   weaponclass: " + weaponclass);
	}
	else
		iprintln("## ^1DISABLE^7: team: " + team + "   weaponclass: " + weaponclass);*/


	// Najde všechny zbraně konkrétní classy a zakáže/povolí je
	for(weap_index = 0; weap_index < level.weaponnames.size; weap_index++)
	{
		weaponname = level.weaponnames[weap_index];

		if (level.weapons[weaponname].classname != weaponclass)
			continue;

		if (level.weapons[weaponname].team != team && level.weapons[weaponname].team != "both")
			continue;

		//debugtext = "###                                     |---> " + weaponname + "       (";

    thread Update_WeaponClass_HUDs_Cvars(weaponname, team);

		//iprintln(debugtext+")");

		//wait level.fps_multiplier * 0.05;
	}
}

Update_WeaponClass_HUDs_Cvars(weaponname, team)
{
  players = getentarray("player", "classname");
  for(i = 0; i < players.size; i++)
  {
    player = players[i];
    if (!isDefined(player)) // Because we wait a frame, next frame player may be disconnected
      continue;

    if (!isDefined(player.pers["team"]))
      continue;

    if (player.pers["team"] != team)
      continue;

    Update_Client_Weapon(player, weaponname, team);

    wait level.frame;
  }
}

// Use "team" variable only if weapon is useable for both teams
Update_Client_Weapon(player, weaponname, team)
{
	weaponclass = level.weapons[weaponname].classname;

	if (team == "allies")
		allowed = !level.weaponclass[weaponclass].allies_limited;
	else
		allowed = !level.weaponclass[weaponclass].axis_limited;



	i_have_this_weapon = isDefined(player.pers["weapon"]) && player.pers["weapon"] == weaponname;
    i_have_weapon_of_this_class = isDefined(player.pers["weapon"]) && level.weapons[player.pers["weapon"]].classname == weaponclass;

    slot[0] = player getWeaponSlotWeapon("primary");
    slot[1] = player getWeaponSlotWeapon("primaryb");


	cvarValue = -1;

	if (!level.weapons[weaponname].allow || level.weaponclass[weaponclass].limit == 0) {
		cvarValue = 0;
	}
	else if (level.weapons[weaponname].team == "both")
	{
		if (i_have_this_weapon)
			cvarValue = 3; // 3 = selected

		else if (team == "allies")
		{
			if(level.weaponclass[weaponclass].allies_limited && !i_have_weapon_of_this_class)
				cvarValue = 2; // 2 = disabled
			else
				cvarValue = 1; // 1 = visible
		}
		else if (team == "axis")
		{
			if(level.weaponclass[weaponclass].axis_limited && !i_have_weapon_of_this_class)
				cvarValue = 2; // 2 = disabled
			else
				cvarValue = 1; // 1 = visible
		}
	}
	else
	{
		if (i_have_this_weapon)
			cvarValue = 3; // 3 = selected

		else if (allowed || i_have_weapon_of_this_class)
			cvarValue = 1; // 1 = visible

		else
			cvarValue = 2; // 2 = disabled

    /*
    0 - not visivle
    1 - visible
    2 - disabled
    3 - selected
    */
	}




  if (cvarValue != -1)
	{
		  player setClientCvarIfChanged(level.weapons[weaponname].client_allowcvar, cvarValue);

			if (player.pers["team"] == "allies")
			{
					player setClientCvarIfChanged("ui_weapons_"+weaponclass+"_usedby", level.weaponclass[weaponclass].allies_usedby);
			}
			else if (player.pers["team"] == "axis")
			{
					player setClientCvarIfChanged("ui_weapons_"+weaponclass+"_usedby", level.weaponclass[weaponclass].axis_usedby);
			}
	}

}
