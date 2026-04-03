#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
    arr = ruleCvarDefault(arr, "scr_smoke_type", 2);
    arr = ruleCvarDefault(arr, "g_antilag", 1);
    arr = ruleCvarDefault(arr, "sv_fps", 40);
    arr = ruleCvarDefault(arr, "g_shotgun_spread_fix", 0);

    return arr;
}