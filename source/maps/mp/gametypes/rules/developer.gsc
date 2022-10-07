#include maps\mp\gametypes\global\_global;

Load()
{
	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	//arr = ruleCvarDefault(arr, "scr_sd_timelimit", 0);		// Time limit for map. 0=disabled (minutes)
	//arr = ruleCvarDefault(arr, "scr_sd_half_round", 12);	// Number of rounds when half-time starts. 0=ignored
	//arr = ruleCvarDefault(arr, "scr_sd_half_score", 0);	// Number of score when half-time starts. 0=ignored
	//arr = ruleCvarDefault(arr, "scr_sd_end_round", 24);	// Number of rounds when map ends. 0=ignored
	//arr = ruleCvarDefault(arr, "scr_sd_end_score", 13);	// Number of score when map ends. 0=ignored

	// Round options
	arr = ruleCvarDefault(arr, "scr_sd_strat_time", 3);	// Time before round starts where players cannot move
	//arr = ruleCvarDefault(arr, "scr_sd_roundlength", 2);	// Time length of each round (min)
	//arr = ruleCvarDefault(arr, "scr_sd_end_time", 6);		// Time et the end of the round (after last player is killed) when you can finding weapons for the next round
	//arr = ruleCvarDefault(arr, "scr_sd_count_draws", 0);	// If players are killed at same time - count this round (1) or play new round (0)?
	//arr = ruleCvarDefault(arr, "scr_sd_round_report", 1);		// Print kill and damage stats at the end of the round


	// Match Style
	arr = ruleCvarDefault(arr, "scr_ctf_timelimit", 0.6);		// Time limit. When halftime is enabled, its time limit per half. 0=disabled (minutes)
	arr = ruleCvarDefault(arr, "scr_ctf_half_score", 0);		// Number of score when half-time starts. Has no effect when halftime is disabled.
	arr = ruleCvarDefault(arr, "scr_ctf_end_score", 0);		// Number of score when map ends. 0=ignored
	arr = ruleCvarDefault(arr, "scr_ctf_flag_autoreturn_time", 10);// Flag auto return
	arr = ruleCvarDefault(arr, "scr_ctf_halftime", 1);		// Do halftime. When 1, scr_ctf_timelimit means time per half


	arr = ruleCvarDefault(arr, "scr_hq_timelimit", 2);		// Time limit. When halftime is enabled, its time limit per half. 0=disabled (minutes)
	arr = ruleCvarDefault(arr, "scr_hq_half_score", 0);		// Number of score when half-time starts. Has no effect when halftime is disabled.
	arr = ruleCvarDefault(arr, "scr_hq_end_score", 0);		// Number of score when map ends. 0=ignored
	arr = ruleCvarDefault(arr, "scr_hq_halftime", 1);		// Do halftime. When 1, scr_hq_timelimit means time per half

	// HQ settings
	arr = ruleCvarDefault(arr, "scr_hq_neutralizing_points", 10);
	arr = ruleCvarDefault(arr, "scr_hq_radio_respawn_time", 3);
	arr = ruleCvarDefault(arr, "scr_hq_radio_hold_time", 120);
	arr = ruleCvarDefault(arr, "scr_hq_multiple_capture", 1);



	return arr;
}
