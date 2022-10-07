#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	arr = ruleCvarDefault(arr, "scr_replace_russian", 0); 	// Replace russians with Americans / Brisith

	return arr;
}
