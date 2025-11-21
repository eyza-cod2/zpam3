#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	// Weapon Limits by class per team
    arr = ruleCvarDefault(arr, "g_antilag", 1);					// Antilag 1 means that players ping is considered when calculating hit location - what you see on your monitor is also what the server will see
    arr = ruleCvarDefault(arr, "scr_hitbox_neck_kill", 0);			// neck hitbox will count as a headshot, buffs non-bolts
    
    arr = ruleCvarDefault(arr, "scr_bar_buffed", 1);    // BAR buff
    arr = ruleCvarDefault(arr, "scr_bren_buffed", 1);   // Bren LMG buff

	return arr;
}
