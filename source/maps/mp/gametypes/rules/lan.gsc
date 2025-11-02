#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	//arr = ruleCvarDefault(arr, "scr_readyup_autoresume_half", 0); 	// Minutes to auto-resume halftime [0 - 10] 0 = disabled
	//arr = ruleCvarDefault(arr, "scr_readyup_autoresume_map", 0); 	// Minutes to auto-resume between maps [0 - 10] 0 = disabled

	return arr;
}
