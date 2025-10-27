#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	// Weapon Limits by class per team
	arr = ruleCvarDefault(arr, "scr_overtime", 0);

	return arr;
}
