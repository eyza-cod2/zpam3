#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	// Rifles-only mode
	arr = ruleCvarDefault(arr, "scr_rifle_mode", 1);


	// Nade spawn counts for each class
	arr = ruleCvarDefault(arr, "scr_boltaction_nades", 0);
	arr = ruleCvarDefault(arr, "scr_sniper_nades", 0);

	// Smoke spawn counts for each class
	arr = ruleCvarDefault(arr, "scr_boltaction_smokes", 0);
	arr = ruleCvarDefault(arr, "scr_sniper_smokes", 0);

	// Weapon Limits by class per team
	arr = ruleCvarDefault(arr, "scr_boltaction_limit", 99);
	arr = ruleCvarDefault(arr, "scr_sniper_limit", 99);

	// Allow weapon drop when player die
	arr = ruleCvarDefault(arr, "scr_boltaction_allow_drop", 0);
	arr = ruleCvarDefault(arr, "scr_sniper_allow_drop", 0);
	arr = ruleCvarDefault(arr, "scr_pistol_allow_drop", 0);

	// Allow grenade / smoke drop when player die
	arr = ruleCvarDefault(arr, "scr_allow_grenade_drop", 0);
	arr = ruleCvarDefault(arr, "scr_allow_smoke_drop", 0);

	// Player's weapon drop
	arr = ruleCvarDefault(arr, "scr_allow_primary_drop", 0);
	arr = ruleCvarDefault(arr, "scr_allow_secondary_drop", 0);

	// Allow/Disallow Weapons
	arr = ruleCvarDefault(arr, "scr_allow_springfield", 1);
	arr = ruleCvarDefault(arr, "scr_allow_enfield", 1);
	arr = ruleCvarDefault(arr, "scr_allow_enfieldsniper", 1);
	arr = ruleCvarDefault(arr, "scr_allow_nagant", 1);
	arr = ruleCvarDefault(arr, "scr_allow_nagantsniper", 1);
	arr = ruleCvarDefault(arr, "scr_allow_kar98k", 1);
	arr = ruleCvarDefault(arr, "scr_allow_kar98ksniper", 1);

	return arr;
}
