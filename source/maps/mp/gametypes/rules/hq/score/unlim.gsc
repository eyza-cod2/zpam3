#include maps\mp\gametypes\global\_global;

Load()
{
	game["rules_formatString"] = &"Unlimited time";

	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	// Match Style
	arr = ruleCvarDefault(arr, "scr_hq_timelimit", 0);		// Time limit. When halftime is enabled, its time limit per half. 0=disabled (minutes)
	arr = ruleCvarDefault(arr, "scr_hq_half_score", 0);		// Number of score when half-time starts. Has no effect when halftime is disabled.
	arr = ruleCvarDefault(arr, "scr_hq_end_score", 0);		// Number of score when map ends. 0=ignored

	// Halftime
	arr = ruleCvarDefault(arr, "scr_hq_halftime", 0);		// Do halftime. When 1, scr_hq_timelimit means time per half

	// Are there OT Rules?
	arr = ruleCvarDefault(arr, "scr_overtime", 0);

	return arr;
}
