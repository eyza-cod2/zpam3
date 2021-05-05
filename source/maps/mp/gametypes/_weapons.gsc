#include maps\mp\gametypes\global\_global;

init()
{
	addEventListener("onCvarChanged", ::onCvarChanged);

	registerCvars();

	addEventListener("onStartGameType", ::onStartGameType);
}

// Called from start_gametype when registring cvars
registerCvars()
{
	var = ::registerCvar;

	// Nade spawn counts for each class
	[[var]]("scr_boltaction_nades", "INT", 3, 0, 99);
	[[var]]("scr_semiautomatic_nades", "INT", 2, 0, 99);
	[[var]]("scr_smg_nades", "INT", 1, 0, 99);
	[[var]]("scr_sniper_nades", "INT", 3, 0, 99);
	[[var]]("scr_mg_nades", "INT", 2, 0, 99);
	[[var]]("scr_shotgun_nades", "INT", 1, 0, 99);

	// Smoke spawn counts for each class
	[[var]]("scr_boltaction_smokes", "INT", 0, 0, 99);
	[[var]]("scr_semiautomatic_smokes", "INT", 0, 0, 99);
	[[var]]("scr_smg_smokes", "INT", 1, 0, 99);
	[[var]]("scr_sniper_smokes", "INT", 0, 0, 99);
	[[var]]("scr_mg_smokes", "INT", 0, 0, 99);
	[[var]]("scr_shotgun_smokes", "INT", 1, 0, 99);

	// Weapon Limits by class per team
	[[var]]("scr_boltaction_limit", "INT", 99, 0, 99);
	[[var]]("scr_sniper_limit", "INT", 99, 0, 99);
	[[var]]("scr_semiautomatic_limit", "INT", 99, 0, 99);
	[[var]]("scr_smg_limit", "INT", 99, 0, 99);
	[[var]]("scr_mg_limit", "INT", 99, 0, 99);
	[[var]]("scr_shotgun_limit", "INT", 99, 0, 99);

	// Allow weapon drop when player die
	[[var]]("scr_boltaction_allow_drop", "BOOL", 1);
	[[var]]("scr_sniper_allow_drop", "BOOL", 1);
	[[var]]("scr_semiautomatic_allow_drop", "BOOL", 1);
	[[var]]("scr_smg_allow_drop", "BOOL", 1);
	[[var]]("scr_mg_allow_drop", "BOOL", 1);
	[[var]]("scr_shotgun_allow_drop", "BOOL", 1);



	// Allow/Disallow Weapons
	[[var]]("scr_allow_greasegun", "BOOL", 1);
	[[var]]("scr_allow_m1carbine", "BOOL", 1);
	[[var]]("scr_allow_m1garand", "BOOL", 1);
	[[var]]("scr_allow_springfield", "BOOL", 1);
	[[var]]("scr_allow_thompson", "BOOL", 1);
	[[var]]("scr_allow_bar", "BOOL", 1);
	[[var]]("scr_allow_sten", "BOOL", 1);
	[[var]]("scr_allow_enfield", "BOOL", 1);
	[[var]]("scr_allow_enfieldsniper", "BOOL", 1);
	[[var]]("scr_allow_bren", "BOOL", 1);
	[[var]]("scr_allow_pps42", "BOOL", 1);
	[[var]]("scr_allow_nagant", "BOOL", 1);
	[[var]]("scr_allow_svt40", "BOOL", 1);
	[[var]]("scr_allow_nagantsniper", "BOOL", 1);
	[[var]]("scr_allow_ppsh", "BOOL", 1);
	[[var]]("scr_allow_mp40", "BOOL", 1);
	[[var]]("scr_allow_kar98k", "BOOL", 1);
	[[var]]("scr_allow_g43", "BOOL", 1);
	[[var]]("scr_allow_kar98ksniper", "BOOL", 1);
	[[var]]("scr_allow_mp44", "BOOL", 1);
	[[var]]("scr_allow_shotgun", "BOOL", 1);



	// Allow grenade / smoke drop when player die
	[[var]]("scr_allow_grenade_drop", "BOOL", 1); 	// level.allow_nadedrops
	[[var]]("scr_allow_smoke_drop", "BOOL", 1); 	// level.allow_smokedrops



	[[var]]("scr_allow_pistols", "BOOL", 1); 	// level.allow_pistols // NOTE: in sd next round
	[[var]]("scr_allow_turrets", "BOOL", 1); 	// level.allow_turrets // NOTE: after map/round reset


	[[var]]("scr_no_oneshot_pistol_kills", "BOOL", 0); 	//level.prevent_single_shot_pistol // Single Shot Kills
	[[var]]("scr_no_oneshot_ppsh_kills", "BOOL", 0); 	//level.prevent_single_shot_ppsh // Single Shot Kills
	[[var]]("scr_balance_ppsh_distance", "BOOL", 0); 	//level.balance_ppsh //ppsh -> tommy balance


	registerCvarEx("C", "scr_shotgun_rebalance", "BOOL", 0);	// level.scr_shotgun_rebalance
	registerCvarEx("C", "scr_hand_hitbox_fix", "BOOL", 0);		// level.scr_hand_hitbox_fix
}


// This function is called when cvar changes value.
// Is also called when cvar is registered
// Return true if cvar was handled here, otherwise false
onCvarChanged(cvar, value, isRegisterTime)
{
	switch(cvar)
	{
		// Nothing get updated because we are getting value directly from getCvar()
		case "scr_boltaction_nades":
		case "scr_boltaction_smokes":
		case "scr_semiautomatic_nades":
		case "scr_semiautomatic_smokes":
		case "scr_smg_nades":
		case "scr_smg_smokes":
		case "scr_sniper_nades":
		case "scr_sniper_smokes":
		case "scr_mg_nades":
		case "scr_mg_smokes":
		case "scr_shotgun_nades":
		case "scr_shotgun_smokes":
		return true;

		// If class limit changed, update all weapons
		case "scr_boltaction_limit":
		case "scr_sniper_limit":
		case "scr_semiautomatic_limit":
		case "scr_smg_limit":
		case "scr_mg_limit":
		case "scr_shotgun_limit":
			if (!isRegisterTime)
			{
				thread updateLimit(cvar, value);
				thread maps\mp\gametypes\_weapon_limiter::Update_All_Weapon_Limits();
			}
		return true;


		// Allow weapon drop if player dead
		case "scr_boltaction_allow_drop":
		case "scr_sniper_allow_drop":
		case "scr_semiautomatic_allow_drop":
		case "scr_smg_allow_drop":
		case "scr_mg_allow_drop":
		case "scr_shotgun_allow_drop":
            		if (!isRegisterTime) thread updateDrop(cvar, value);
			return true;



		// If some wepaons was enabled/disabled
		case "scr_allow_greasegun":
		case "scr_allow_m1carbine":
		case "scr_allow_m1garand":
		case "scr_allow_springfield":
		case "scr_allow_thompson":
		case "scr_allow_bar":
		case "scr_allow_sten":
		case "scr_allow_enfield":
		case "scr_allow_enfieldsniper":
		case "scr_allow_bren":
		case "scr_allow_pps42":
		case "scr_allow_nagant":
		case "scr_allow_svt40":
		case "scr_allow_nagantsniper":
		case "scr_allow_ppsh":
		case "scr_allow_mp40":
		case "scr_allow_kar98k":
		case "scr_allow_g43":
		case "scr_allow_kar98ksniper":
		case "scr_allow_mp44":
		case "scr_allow_shotgun":
			if (!isRegisterTime) thread updateAllowed(cvar, value);
		return true;



		case "scr_allow_grenade_drop": 		level.allow_nadedrops = value; return true;
        	case "scr_allow_smoke_drop": 		level.allow_smokedrops = value; return true;





		case "scr_allow_pistols": 		level.allow_pistols = value; return true;
		case "scr_allow_turrets": 		level.allow_turrets = value; return true;


		case "scr_no_oneshot_pistol_kills": 		level.prevent_single_shot_pistol = value; return true;
		case "scr_no_oneshot_ppsh_kills": 		level.prevent_single_shot_ppsh = value; return true;
		case "scr_balance_ppsh_distance": 		level.balance_ppsh = value; return true;


		case "scr_shotgun_rebalance":
			level.scr_shotgun_rebalance = value;
			return true;

		case "scr_hand_hitbox_fix":
			level.scr_hand_hitbox_fix = value;
			return true;

	}


	return false;
}


// Called after the <gametype>.gsc::main() and <map>.gsc::main() scripts are called
// At this point game specific variables are defined (like game["allies"], game["axis"], game["american_soldiertype"], ...)
// Called again for every round in round-based gameplay
onStartGameType()
{
	if(game["firstInit"])
	{
		precacheWeapons();
	}

	// Weapons & Limits
	maps\mp\gametypes\_weapons::defineWeapons();

	// Disable MG
	if (!level.allow_turrets)
	{
		deletePlacedEntity("misc_turret");
		deletePlacedEntity("misc_mg42");
	}
}


precacheWeapons()
{
	switch(game["allies"])
	{
	case "american":

		precacheItem("greasegun_mp");
		precacheItem("m1carbine_mp");
		precacheItem("m1garand_mp");
		precacheItem("springfield_mp");
		//precacheItem("shotgun_mp");
		precacheItem("thompson_mp");
		precacheItem("bar_mp");

		precacheItem("frag_grenade_american_mp");
		precacheItem("smoke_grenade_american_mp");

		precacheItem("colt_mp");

		break;

	case "british":

		precacheItem("sten_mp");
		precacheItem("enfield_mp");
		precacheItem("m1garand_mp");
		precacheItem("enfield_scope_mp");
		//precacheItem("shotgun_mp");
		precacheItem("thompson_mp");
		precacheItem("bren_mp");

		precacheItem("frag_grenade_british_mp");
		precacheItem("smoke_grenade_british_mp");

		precacheItem("webley_mp");

		break;

	case "russian":

		precacheItem("PPS42_mp");
		precacheItem("mosin_nagant_mp");
		precacheItem("SVT40_mp");
		precacheItem("mosin_nagant_sniper_mp");
		//precacheItem("shotgun_mp");
		precacheItem("ppsh_mp");

		precacheItem("frag_grenade_russian_mp");
		precacheItem("smoke_grenade_russian_mp");

		precacheItem("TT30_mp");

		break;
	}

	// German weapons
	precacheItem("mp40_mp");
	precacheItem("kar98k_mp");
	precacheItem("g43_mp");
	precacheItem("kar98k_sniper_mp");
	//precacheItem("shotgun_mp");
	precacheItem("mp44_mp");

	precacheItem("frag_grenade_german_mp");
	precacheItem("smoke_grenade_german_mp");

	precacheItem("luger_mp");



	// Weapons for all
	precacheItem("shotgun_mp");
	precacheItem("binoculars_mp");
}



defineWeapons()
{
	// List of all weapons that can be enabled or disabled by server cvars
	// If you want to add new weapons, you have to create new cvars in cvars.gsc


	switch(game["allies"])
	{
	case "american":
		addWeapon("greasegun_mp", 		"smg", 				"allies", 	"scr_allow_greasegun", 		"ui_allow_greasegun");
		addWeapon("m1carbine_mp", 		"semiautomatic",	"allies", 	"scr_allow_m1carbine",		"ui_allow_m1carbine");
		addWeapon("m1garand_mp", 		"semiautomatic", 	"allies", 	"scr_allow_m1garand", 		"ui_allow_m1garand");
		addWeapon("springfield_mp", 	"sniper", 			"allies", 	"scr_allow_springfield", 	"ui_allow_springfield");
		addWeapon("thompson_mp", 		"smg", 				"allies", 	"scr_allow_thompson", 		"ui_allow_thompson");
		addWeapon("bar_mp", 			"mg", 				"allies", 	"scr_allow_bar", 			"ui_allow_bar");
		break;

	case "british":
		addWeapon("sten_mp", 			"smg", 				"allies", 	"scr_allow_sten", 			"ui_allow_sten");
		addWeapon("enfield_mp", 		"boltaction", 		"allies", 	"scr_allow_enfield", 		"ui_allow_enfield");
		addWeapon("m1garand_mp", 		"semiautomatic", 	"allies", 	"scr_allow_m1garand", 		"ui_allow_m1garand");
		addWeapon("enfield_scope_mp", 	"sniper",			"allies", 	"scr_allow_enfieldsniper", 	"ui_allow_enfieldsniper");
		addWeapon("thompson_mp", 		"smg", 				"allies", 	"scr_allow_thompson", 		"ui_allow_thompson");
		addWeapon("bren_mp", 			"mg", 				"allies", 	"scr_allow_bren", 			"ui_allow_bren");
		break;

	case "russian":
		addWeapon("PPS42_mp", 			"smg", 				"allies", 	"scr_allow_pps42", 			"ui_allow_pps42");
		addWeapon("mosin_nagant_mp", 	"boltaction", 		"allies", 	"scr_allow_nagant", 		"ui_allow_nagant");
		addWeapon("SVT40_mp", 			"semiautomatic", 	"allies", 	"scr_allow_svt40", 			"ui_allow_svt40");
		addWeapon("mosin_nagant_sniper_mp", "sniper", 		"allies", 	"scr_allow_nagantsniper", 	"ui_allow_nagantsniper");
		addWeapon("ppsh_mp", 			"smg", 				"allies", 	"scr_allow_ppsh", 			"ui_allow_ppsh");
		break;
	}

	// Germans
	addWeapon("mp40_mp", 			"smg", 				"axis", 	"scr_allow_mp40", 			"ui_allow_mp40");
	addWeapon("kar98k_mp", 			"boltaction", 		"axis", 	"scr_allow_kar98k", 		"ui_allow_kar98k");
	addWeapon("g43_mp", 			"semiautomatic", 	"axis", 	"scr_allow_g43", 			"ui_allow_g43");
	addWeapon("kar98k_sniper_mp", 	"sniper", 			"axis", 	"scr_allow_kar98ksniper", 	"ui_allow_kar98ksniper");
	addWeapon("mp44_mp", 			"mg", 				"axis", 	"scr_allow_mp44", 			"ui_allow_mp44");

	// All teams
	addWeapon("shotgun_mp", 		"shotgun", 			"both", 	"scr_allow_shotgun", 		"ui_allow_shotgun");

	// Array of Available Weapon Classes
	// If you want to add new classes, you have to create new cvars in start_gametype.gsc
	//		(className, 		cvarLimit, 					cvarNades, 						cvarSmokes,				cvarAllowDrop)
	addClass("boltaction", 		"scr_boltaction_limit",		"scr_boltaction_nades", 	"scr_boltaction_smokes",	"scr_boltaction_allow_drop");
	addClass("sniper", 			"scr_sniper_limit",			"scr_semiautomatic_nades", 	"scr_semiautomatic_smokes", "scr_sniper_allow_drop");
	addClass("semiautomatic", 	"scr_semiautomatic_limit",	"scr_smg_nades", 			"scr_smg_smokes",			"scr_semiautomatic_allow_drop");
	addClass("smg", 			"scr_smg_limit",			"scr_sniper_nades", 		"scr_sniper_smokes",		"scr_smg_allow_drop");
	addClass("mg", 				"scr_mg_limit",				"scr_mg_nades", 			"scr_mg_smokes",			"scr_mg_allow_drop");
	addClass("shotgun", 		"scr_shotgun_limit",		"scr_shotgun_nades", 		"scr_shotgun_smokes",		"scr_shotgun_allow_drop");

}



addWeapon(weaponName, className, teamName, serverCvar, clientCvar)
{
	if (!isDefined(level.weaponnames))
		level.weaponnames = [];
	if (!isDefined(level.weapons))
		level.weapons = [];

	level.weaponnames[level.weaponnames.size] = weaponName;

	level.weapons[weaponName] = spawnstruct();
	level.weapons[weaponName].server_allowcvar = serverCvar;
	level.weapons[weaponName].client_allowcvar = clientCvar;
	level.weapons[weaponName].classname = className;
	level.weapons[weaponName].team = teamName;

	level.weapons[weaponName].allow = getCvarInt(serverCvar);
}

addClass(className, cvarLimit, cvarNades, cvarSmokes, cvarAllowDrop)
{
	if (!isDefined(level.weaponclasses))
		level.weaponclasses = [];
	if (!isDefined(level.weaponclass))
		level.weaponclass = [];

	//iprintln("------adding weapon class: "+className);

	level.weaponclasses[level.weaponclasses.size] = className;

	level.weaponclass[className] = spawnstruct();

	level.weaponclass[className].cvar = cvarLimit;
	level.weaponclass[className].cvarNades = cvarNades;
	level.weaponclass[className].cvarSmokes = cvarSmokes;
	level.weaponclass[className].cvarAllowDrop = cvarAllowDrop;

	level.weaponclass[className].limit = getCvarInt(cvarLimit);
	level.weaponclass[className].allow_drop = getCvarInt(cvarAllowDrop);

	level.weaponclass[className].axis_limited = 0;
	level.weaponclass[className].allies_limited = 0;

	level.weaponclass[className].allies_usedby = "";
	level.weaponclass[className].axis_usedby = "";



	// All weapons in this class are disabled
	if (level.weaponclass[className].limit == 0)
	{
		level.weaponclass[className].allies_limited = 1;
		level.weaponclass[className].axis_limited = 1;
	}
}



deletePlacedEntity(entity)
{
	entities = getentarray(entity, "classname");
	for(i = 0; i < entities.size; i++)
	{
		//println("DELETED: ", entities[i].classname);
		entities[i] delete();
	}
}



// Adds pistol to primaryb slot only if empty
givePistol()
{
	weapon2 = self getweaponslotweapon("primaryb");
	if(weapon2 == "none")
	{
		if(self.pers["team"] == "allies")
		{
			switch(game["allies"])
			{
			case "american":
				pistoltype = "colt_mp";
				break;

			case "british":
				pistoltype = "webley_mp";
				break;

			default:
				assert(game["allies"] == "russian");
				pistoltype = "TT30_mp";
				break;
			}
		}
		else
		{
			assert(self.pers["team"] == "axis");
			switch(game["axis"])
			{
			default:
				assert(game["axis"] == "german");
				pistoltype = "luger_mp";
				break;
			}
		}

		self takeWeapon("colt_mp");
		self takeWeapon("webley_mp");
		self takeWeapon("TT30_mp");
		self takeWeapon("luger_mp");

		if (!level.allow_pistols)
			return;

		//self giveWeapon(pistoltype);
		self setWeaponSlotWeapon("primaryb", pistoltype);
		self giveMaxAmmo(pistoltype);
	}
}

GetGrenadeTypeName()
{
	grenadetype = "none";
	if(self.pers["team"] == "allies")
		grenadetype = "frag_grenade_" + game["allies"] + "_mp";
	else if (self.pers["team"] == "axis")
		grenadetype = "frag_grenade_" + game["axis"] + "_mp";

	return grenadetype;
}

GetSmokeTypeName()
{
	grenadetype = "none";
	if(self.pers["team"] == "allies")
		grenadetype = "smoke_grenade_" + game["allies"] + "_mp";
	else if (self.pers["team"] == "axis")
		grenadetype = "smoke_grenade_" + game["axis"] + "_mp";

	return grenadetype;
}


giveGrenadesFor(weapon, count)
{
	// remove all grenades
	self takeWeapon("frag_grenade_american_mp");
	self takeWeapon("frag_grenade_british_mp");
	self takeWeapon("frag_grenade_russian_mp");
	self takeWeapon("frag_grenade_german_mp");

	grenadetype = self GetGrenadeTypeName();
	fraggrenadecount = getWeaponBasedGrenadeCount(weapon);

	if(fraggrenadecount)
	{
		if (isDefined(count)) // replace count with own number
			fraggrenadecount = count;

		self giveWeapon(grenadetype);
		self setWeaponClipAmmo(grenadetype, fraggrenadecount);
	}

	self switchtooffhand(grenadetype);
}

giveSmokesFor(weapon, count)
{
	// remove all smokes
	self takeWeapon("smoke_grenade_american_mp");
	self takeWeapon("smoke_grenade_british_mp");
	self takeWeapon("smoke_grenade_russian_mp");
	self takeWeapon("smoke_grenade_german_mp");

	smokegrenadetype = self GetSmokeTypeName();
	smokegrenadecount = getWeaponBasedSmokeGrenadeCount(weapon);

	if(smokegrenadecount)
	{
		if (isDefined(count)) // replace count with own number
			smokegrenadecount = count;

		self giveWeapon(smokegrenadetype);
		self setWeaponClipAmmo(smokegrenadetype, smokegrenadecount);
	}
}


giveBinoculars()
{
	self giveWeapon("binoculars_mp");
}

dropWeapons()
{
	self thread dropWeapon();
	self thread dropNade();
	self thread dropSmoke();
}

dropWeapon()
{
	current = self getcurrentweapon();

	//iprintln(current);

	if (current == "sprint_weap_mp")
		return;

	if(current == "none")
		return;

	weapon1 = self getweaponslotweapon("primary");
	weapon2 = self getweaponslotweapon("primaryb");

	if(current == weapon1)
		currentslot = "primary";
	else
	{
		assert(current == weapon2);
		currentslot = "primaryb";
	}

	clipsize = self getweaponslotclipammo(currentslot);
	reservesize = self getweaponslotammo(currentslot);

	// Pistols are not defined in level.weapons - so check if this weapon exists
	if (isDefined(level.weapons[current]))
	{
		weapon_class = level.weapons[current].classname;

		if (getCvarInt(level.weaponclass[weapon_class].cvarAllowDrop) == 0)
			return;
	}

	if(clipsize || reservesize) {
		self dropItem(current);

		level notify("weapon_dropped", current, self);
	}

}

dropNade()
{
	if (!level.allow_nadedrops)
		return;

	grenadetype = self GetGrenadeTypeName();

	if(grenadetype != "none")
	{
		ammosize = self getammocount(grenadetype);

		if(ammosize)
		{
			/*
			- Droped grenade bug -
			If player has cooked grenade and is killed, that grenade will be throwed to ground.
			And because that grenade is not removed from players slot, extra grenade is dropped to ground for pickup

			To fix this bug, we will look for grenade entities in map close to player
			To detect it correctly, these rules must apply:
				- throwed grenade is always spawned with 40 offset from player origin in Z axis
				- that greande will blow in exacly 3.8 seconds

			Avoid greande drop if these rules applies!
			*/

			// Loop grenades in map
			grenades = getentarray("grenade","classname");
			grenadeToWatch = undefined;
			for(i=0;i<grenades.size;i++)
			{
				if(isDefined(grenades[i].origin))
				{
					distance = distance(grenades[i].origin, self.origin);
					distanceZ = grenades[i].origin[2] - self.origin[2]; // must be positive
					// This grenade is close to player
					if (distance < 50 && distanceZ > 38 && distanceZ < 42)
					{
						grenadeToWatch = grenades[i];
						break;
					}
				}
			}
			// There is grenade close to player
			if (isDefined(grenadeToWatch))
			{
				// Wait right before grenade explode
				wait level.fps_multiplier * 3.5;

				// Grenade still does not explode - we are sure that this grande is throwed from this player and will explode in a few miliseconds
				if (isDefined(grenadeToWatch))
					return; // Cancel extra grenade drop
			}

			self dropItem(grenadetype);
			level notify("weapon_dropped", grenadetype, self);
		}
	}
}

dropSmoke()
{
	if (!level.allow_smokedrops)
		return;

	grenadetype = self GetSmokeTypeName();

	if(grenadetype != "none")
	{
		ammosize = self getammocount(grenadetype);

		if(ammosize) {
			self dropItem(grenadetype);
			level notify("weapon_dropped", grenadetype, self);
		}
	}
}

// Get number of greandes based on selected weapon
getWeaponBasedGrenadeCount(weapon)
{
	className = level.weapons[weapon].classname;
	cvarNades = level.weaponclass[className].cvarNades;

	return getCvarInt(cvarNades);
}

getWeaponBasedSmokeGrenadeCount(weapon)
{
	className = level.weapons[weapon].classname;
	cvarSmokes = level.weaponclass[className].cvarSmokes;

	return getCvarInt(cvarSmokes);
}

getFragGrenadeCount()
{
	grenadetype = self GetGrenadeTypeName();

	if (grenadetype == "none")
		return 0;

	count = self getammocount(grenadetype);
	return count;
}

getSmokeGrenadeCount()
{
	grenadetype = self GetSmokeTypeName();

	if (grenadetype == "none")
		return 0;

	count = self getammocount(grenadetype);
	return count;
}

isPistol(weapon)
{
	switch(weapon)
	{
	case "colt_mp":
	case "webley_mp":
	case "luger_mp":
	case "TT30_mp":
		return true;
	default:
		return false;
	}
}

isMainWeapon(weapon)
{
	// Include any main weapons that can be saved at the end of the round

	return isDefined(level.weapons[weapon]);
}

getRandomWeapon()
{
	for (;;)
	{
		weaponname = level.weaponnames[randomInt(level.weaponnames.size)];
		weapon = level.weapons[weaponname];

		if (weapon.allow == false || weapon.team != self.pers["team"])
			continue;

		// Check if random selected weapon is free and allowed
		if(!self maps\mp\gametypes\_weapon_limiter::isWeaponAvaible(weaponname))
			continue;

		return weaponname;
	}
}



getWeaponName(weapon)
{
	switch(weapon)
	{
	// American
	case "m1carbine_mp":
		weaponname = &"WEAPON_M1A1CARBINE";
		break;

	case "m1garand_mp":
		weaponname = &"WEAPON_M1GARAND";
		break;

	case "thompson_mp":
		weaponname = &"WEAPON_THOMPSON";
		break;

	case "bar_mp":
		weaponname = &"WEAPON_BAR";
		break;

	case "springfield_mp":
		weaponname = &"WEAPON_SPRINGFIELD";
		break;

	case "greasegun_mp":
		weaponname = &"WEAPON_GREASEGUN";
		break;

	case "shotgun_mp":
		weaponname = &"WEAPON_SHOTGUN";
		break;

	// British
	case "enfield_mp":
		weaponname = &"WEAPON_LEEENFIELD";
		break;

	case "sten_mp":
		weaponname = &"WEAPON_STEN";
		break;

	case "bren_mp":
		weaponname = &"WEAPON_BREN";
		break;

	case "enfield_scope_mp":
		weaponname = &"WEAPON_SCOPEDLEEENFIELD";
		break;

	// Russian
	case "mosin_nagant_mp":
		weaponname = &"WEAPON_MOSINNAGANT";
		break;

	case "SVT40_mp":
		weaponname = &"WEAPON_SVT40";
		break;

	case "PPS42_mp":
		weaponname = &"WEAPON_PPS42";
		break;

	case "ppsh_mp":
		weaponname = &"WEAPON_PPSH";
		break;

	case "mosin_nagant_sniper_mp":
		weaponname = &"WEAPON_SCOPEDMOSINNAGANT";
		break;

	//German
	case "kar98k_mp":
		weaponname = &"WEAPON_KAR98K";
		break;

	case "g43_mp":
		weaponname = &"WEAPON_G43";
		break;

	case "mp40_mp":
		weaponname = &"WEAPON_MP40";
		break;

	case "mp44_mp":
		weaponname = &"WEAPON_MP44";
		break;

	case "kar98k_sniper_mp":
		weaponname = &"WEAPON_SCOPEDKAR98K";
		break;


	default:
		weaponname = &"WEAPON_UNKNOWNWEAPON";
		break;
	}

	return weaponname;
}

useAn(weapon)
{
	switch(weapon)
	{
	case "m1carbine_mp":
	case "m1garand_mp":
	case "mp40_mp":
	case "mp44_mp":
	case "shotgun_mp":
		result = true;
		break;

	default:
		result = false;
		break;
	}

	return result;
}

// Get called from cvars.gsc if some cvar of scr_allow_<weaponname> changed
updateAllowed(cvarName, cvarValue)
{
	for(i = 0; i < level.weaponnames.size; i++)
	{
		weaponname = level.weaponnames[i];

		// Find weapon struct by server cvar name
		if (cvarName == level.weapons[weaponname].server_allowcvar)
		{
			team = level.weapons[weaponname].team;
			classname = level.weapons[weaponname].classname;

			level.weapons[weaponname].allow = cvarValue;

			// Disable or enable weapon to all clients
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				players[i] setClientCvar2(level.weapons[weaponname].client_allowcvar, cvarvalue);
			}

			break;
		}
	}
}

updateLimit(cvarName, cvarValue)
{
	for(i = 0; i < level.weaponclasses.size; i++)
	{
		weaponclass = level.weaponclasses[i];

		// Find weapon struct by server cvar name
		if (cvarName == level.weaponclass[weaponclass].cvar)
		{
			level.weaponclass[weaponclass].limit = cvarValue;

			break;
		}
	}
}

updateDrop(cvarName, cvarValue)
{
	for(i = 0; i < level.weaponclasses.size; i++)
	{
		weaponclass = level.weaponclasses[i];

		// Find weapon struct by server cvar name
		if (cvarName == level.weaponclass[weaponclass].cvarAllowDrop)
		{
			level.weaponclass[weaponclass].allow_drop = cvarValue;

			break;
		}
	}
}
