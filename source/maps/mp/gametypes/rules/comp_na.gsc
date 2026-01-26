#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
    arr = ruleCvarDefault(arr, "scr_smoke_type", 2);
    arr = ruleCvarDefault(arr, "g_antilag", 1);
    arr = ruleCvarDefault(arr, "scr_hitbox_neck_kill", 1);
    arr = ruleCvarDefault(arr, "sv_fps", 30);
    arr = ruleCvarDefault(arr, "scr_bar_buffed", 1);
    arr = ruleCvarDefault(arr, "scr_bren_buffed", 1);
    arr = ruleCvarDefault(arr, "scr_breakout_british", 1);
    arr = ruleCvarDefault(arr, "scr_allow_turrets", 0);

    return arr;
}
