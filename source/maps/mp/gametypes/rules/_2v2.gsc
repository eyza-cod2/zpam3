#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	// Weapon Limits by class per team
	arr = ruleCvarDefault(arr, "scr_boltaction_limit", 99);
	arr = ruleCvarDefault(arr, "scr_sniper_limit", 0);
	arr = ruleCvarDefault(arr, "scr_semiautomatic_limit", 99);
	arr = ruleCvarDefault(arr, "scr_smg_limit", 99);
	arr = ruleCvarDefault(arr, "scr_mg_limit", 99);
	arr = ruleCvarDefault(arr, "scr_shotgun_limit", 0);

	return arr;
}
