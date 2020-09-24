Rules()
{
	// Match Style
	setcvar("scr_sd_timelimit", 0);		// Time limit for map. 0=disabled (minutes)
	setcvar("scr_sd_half_round", 10);	// Number of rounds when half-time starts. 0=ignored
	setcvar("scr_sd_half_score", 0);	// Number of score when half-time starts. 0=ignored
	setcvar("scr_sd_end_round", 20);	// Number of rounds when map ends. 0=ignored
	setcvar("scr_sd_end_score", 11);	// Number of score when map ends. 0=ignored

	// Round options
	setcvar("scr_sd_strat_time", 4);	// Time before round starts where players cannot move
	setcvar("scr_sd_roundlength", 2);	// Time length of each round (min)
	setcvar("scr_sd_end_time", 6);		// Time et the end of the round (after last player is killed) when you can finding weapons for the next round
	setcvar("scr_sd_count_draws", 0);	// If players are killed at same time - count this round (1) or play new round (0)?

	// Bomb settings
	setcvar("scr_sd_bombtimer_show", 1);	// Show bombtimr stopwatch
	setcvar("scr_sd_bombtimer", 60);		// Time untill bomb explodes. (seconds)
	setcvar("scr_sd_PlantTime", 5);
	setcvar("scr_sd_DefuseTime", 10);
	setcvar("scr_sd_plant_points", 0);
	setcvar("scr_sd_defuse_points", 0);

	// Are there OT Rules?
	setcvar("scr_overtime", 1);

	// OT Rules
  	if (isDefined(game["overtime_active"]) && game["overtime_active"])
  	{
		setcvar("scr_sd_half_round", 3);
		setcvar("scr_sd_half_score", 0);
		setcvar("scr_sd_end_round", 6);
		setcvar("scr_sd_end_score", 4);
    }

	/*******************************
	  Shared gametype script cvars
	*******************************/

	// Readyup
	setcvar("scr_readyup", 1); 				// Enable readyup [0, 1] 0 = disbled  1 = enabled
	setcvar("scr_readyup_autoresume", 5); 	// Minutes to auto-resume halftime [0 - 10] 0 = disabled
	setcvar("scr_half_start_timer", 10); 	// Count-down timer when First-half starting / Second-half starting / Timeout ending

	// Time-out
	setcvar("scr_timeouts", 2);						// Total timeouts for one team
	setcvar("scr_timeouts_half", 1); 				// How many per side
	setcvar("scr_timeout_length", 5); 				// Length in minutes

	// Hud Options
	setcvar("scr_show_players_left", 1);
	setcvar("scr_show_objective_icons", 0);
	setcvar("scr_show_hitblip", 1);

	setcvar("scr_show_scoreboard", 2); 		//Score in the upper left corner [0 - 2] 0=hided  1=visible  2=visible only before and after round
	setcvar("scr_show_scoreboard_limit", 1);

	// Health Regeneration
	setcvar("scr_allow_health_regen", 1); 	// 0=no regen, 1=refill health after "scr_regen_delay"
	setcvar("scr_allow_regen_sounds", 1);
	setcvar("scr_regen_delay", 5000); 		//Time before regen starts

	// Ambients
	setcvar("scr_allow_ambient_fog", 0);
	setcvar("scr_allow_ambient_sounds", 0);
	setcvar("scr_allow_ambient_fire", 0);
	setcvar("scr_allow_ambient_weather", 0);


	setcvar("scr_allow_shellshock", 0);					// Create shell shock effect when player is hitted
	setcvar("scr_replace_russian", 1); 					// Replace russians with Americans / Brisith
	setcvar("scr_shotgun_rebalance", 0);				// Enable shotgun rebalance to fix long shot kills and short range hits
	setcvar("scr_blackout", 1); 						// If match is in progress, show map background all over the screen and disable sounds for connected player
	setcvar("scr_recording", 1); 						// Starts automatically recording when match starts
	setcvar("scr_diagonal_fix", 0); 					// Enable diagonal bug fix (disables leaning for players when strafing)
	setcvar("scr_fast_reload_fix", 1);				// Prevent players from shoting faster via double-scroll bug
	setcvar("scr_matchinfo", 1); 						// Show match info in menu (team names, score, score from previous map,....)
	setcvar("scr_map_vote", 0);							// Open voting system so players can vote about next map
	setcvar("scr_map_vote_replay", 0);					// Show option to replay this map in voting system
	setcvar("scr_auto_deadchat", 1);					// Automaticly enable / disable deadchat
	setcvar("scr_remove_killtriggers", 1);				// Remove some of the kill-triggers created in 1.3 path
	setcvar("scr_force_client_best_connection", 1); 	// Client-side cvar forces
	setcvar("scr_force_client_exploits", 1);

	setcvar("scr_friendlyfire", 1);
	setcvar("scr_drawfriend", 1);
	setcvar("scr_teambalance", 0);
	setcvar("scr_killcam", 0);
	setcvar("scr_spectatefree", 0);
	setcvar("scr_spectateenemy", 0);

	// Not Likely to Change
	setcvar("g_allowVote", 0);
	setcvar("g_antilag", 0);
	setcvar("g_maxDroppedWeapons", 32);
	setcvar("sv_fps", 30);
	setcvar("sv_maxRate", 25000);
	setcvar("sv_timeout", 60);				// Time after 999 player is kicked



	/*********
	WEAPONS
	*********/

	// Nade spawn counts for each class
	setcvar("scr_boltaction_nades", 1);
	setcvar("scr_semiautomatic_nades", 1);
	setcvar("scr_smg_nades", 1);
	setcvar("scr_sniper_nades", 1);
	setcvar("scr_mg_nades", 1);
	setcvar("scr_shotgun_nades", 1);

	// Smoke spawn counts for each class
	setcvar("scr_boltaction_smokes", 0);
	setcvar("scr_semiautomatic_smokes", 0);
	setcvar("scr_smg_smokes", 0);
	setcvar("scr_sniper_smokes", 0);
	setcvar("scr_mg_smokes", 0);
	setcvar("scr_shotgun_smokes", 1);

	// Weapon Limits by class per team
	setcvar("scr_boltaction_limit", 99);
	setcvar("scr_sniper_limit", 1);
	setcvar("scr_semiautomatic_limit", 99);
	setcvar("scr_smg_limit", 99);
	setcvar("scr_mg_limit", 99);
	setcvar("scr_shotgun_limit", 1);

	// Allow weapon drop when player die
	setcvar("scr_boltaction_allow_drop", 1);
	setcvar("scr_sniper_allow_drop", 0);
	setcvar("scr_semiautomatic_allow_drop", 1);
	setcvar("scr_smg_allow_drop", 1);
	setcvar("scr_mg_allow_drop", 1);
	setcvar("scr_shotgun_allow_drop", 0);

	// Allow grenade / smoke drop when player die
	setcvar("scr_allow_grenade_drop", 1);
	setcvar("scr_allow_smoke_drop", 0);

	// Player's weapon drop
	setcvar("scr_allow_primary_drop", 1);
	setcvar("scr_allow_secondary_drop", 1);

	// Allow/Disallow Weapons
	setcvar("scr_allow_greasegun", 1);
	setcvar("scr_allow_m1carbine", 1);
	setcvar("scr_allow_m1garand", 1);
	setcvar("scr_allow_springfield", 1);
	setcvar("scr_allow_thompson", 1);
	setcvar("scr_allow_bar", 1);
	setcvar("scr_allow_sten", 1);
	setcvar("scr_allow_enfield", 1);
	setcvar("scr_allow_enfieldsniper", 1);
	setcvar("scr_allow_bren", 1);
	setcvar("scr_allow_pps42", 1);
	setcvar("scr_allow_nagant", 1);
	setcvar("scr_allow_svt40", 1);
	setcvar("scr_allow_nagantsniper", 1);
	setcvar("scr_allow_ppsh", 1);
	setcvar("scr_allow_mp40", 1);
	setcvar("scr_allow_kar98k", 1);
	setcvar("scr_allow_g43", 1);
	setcvar("scr_allow_kar98ksniper", 1);
	setcvar("scr_allow_mp44", 1);
	setcvar("scr_allow_shotgun", 1);

	setcvar("scr_allow_pistols", 1);
	setcvar("scr_allow_turrets", 1);

	// Single Shot Kills
	setcvar("scr_no_oneshot_pistol_kills", 0);
	setcvar("scr_no_oneshot_ppsh_kills", 0);

	// PPSH Balance - Limits range of PPSH to same as Tommy
	setcvar("scr_balance_ppsh_distance", 0);



	// DO NOT MODIFY BELOW THIS LINE!
	game["leagueLogo"] = "";
	game["leagueString"] = &"S&D MR10 Mode";
}
