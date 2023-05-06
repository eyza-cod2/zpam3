#include maps\mp\gametypes\global\_global;

Load()
{
	game["rules_formatString"] = &"MR3";
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	// Match Style
	arr = ruleCvarDefault(arr, "scr_re_timelimit", 0);		// Time limit for map. 0=disabled (minutes)
	arr = ruleCvarDefault(arr, "scr_re_half_round", 3);	// Number of rounds when half-time starts. 0=ignored
	arr = ruleCvarDefault(arr, "scr_re_half_score", 0);	// Number of score when half-time starts. 0=ignored
	arr = ruleCvarDefault(arr, "scr_re_end_round", 6);		// Number of rounds when map ends. 0=ignored
	arr = ruleCvarDefault(arr, "scr_re_end_score", 4);		// Number of score when map ends. 0=ignored

	// Are there OT Rules?
	arr = ruleCvarDefault(arr, "scr_overtime", 1);

	// OT Rules - MR3 format
  	if (isDefined(game["overtime_active"]) && game["overtime_active"])
  	{
		arr = ruleCvarDefault(arr, "scr_re_half_round", 3);
		arr = ruleCvarDefault(arr, "scr_re_half_score", 0);
		arr = ruleCvarDefault(arr, "scr_re_end_round", 6);
		arr = ruleCvarDefault(arr, "scr_re_end_score", game["overtime_score"] + 4); // 12 / 12  ->  16 / 16  ->  20 / 20  -> ...
	}

	arr = ruleCvarDefault(arr, "scr_show_scoreboard_limit", 1);	// show limit in score with slash

	return arr;
}
