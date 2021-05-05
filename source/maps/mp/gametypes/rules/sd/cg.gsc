#include maps\mp\gametypes\global\_global;

Load()
{
	game["leagueLogo"] = "cybergamer_logo";
	game["leagueString"] = &"S&D Ladder Mode";
	game["leagueStringOvertime"] = &"S&D Ladder Mode  ^3Overtime";
	game["ruleCvars"] = GetCvars();
}

GetCvars()
{
	arr = [];

	// Match Style
	arr = ruleCvarDefault(arr, "scr_sd_timelimit", 0);		// Time limit for map. 0=disabled (minutes)
	arr = ruleCvarDefault(arr, "scr_sd_half_round", 10);	// Number of rounds when half-time starts. 0=ignored
	arr = ruleCvarDefault(arr, "scr_sd_half_score", 0);	// Number of score when half-time starts. 0=ignored
	arr = ruleCvarDefault(arr, "scr_sd_end_round", 20);	// Number of rounds when map ends. 0=ignored
	arr = ruleCvarDefault(arr, "scr_sd_end_score", 0);		// Number of score when map ends. 0=ignored

	// Round options
	arr = ruleCvarDefault(arr, "scr_sd_strat_time", 6);	// Time before round starts where players cannot move
	arr = ruleCvarDefault(arr, "scr_sd_roundlength", 2);	// Time length of each round (min)
	arr = ruleCvarDefault(arr, "scr_sd_end_time", 6);		// Time et the end of the round (after last player is killed) when you can finding weapons for the next round
	arr = ruleCvarDefault(arr, "scr_sd_count_draws", 0);	// If players are killed at same time - count this round (1) or play new round (0)?
	arr = ruleCvarDefault(arr, "scr_sd_round_report", 1);		// Print kill and damage stats at the end of the round

	// Bomb settings
	arr = ruleCvarDefault(arr, "scr_sd_bombtimer_show", 1);	// Show bombtimr stopwatch
	arr = ruleCvarDefault(arr, "scr_sd_bombtimer", 60);		// Time untill bomb explodes. (seconds)
	arr = ruleCvarDefault(arr, "scr_sd_PlantTime", 5);
	arr = ruleCvarDefault(arr, "scr_sd_DefuseTime", 10);
	arr = ruleCvarDefault(arr, "scr_sd_plant_points", 0);
	arr = ruleCvarDefault(arr, "scr_sd_defuse_points", 0);



	// Are there OT Rules?
	arr = ruleCvarDefault(arr, "scr_overtime", 0);

	/*******************************
	  Shared gametype script cvars
	*******************************/

	// Readyup
	arr = ruleCvarDefault(arr, "scr_readyup", 1); 				// Enable readyup [0, 1] 0 = disbled  1 = enabled
	arr = ruleCvarDefault(arr, "scr_readyup_autoresume", 5); 	// Minutes to auto-resume halftime [0 - 10] 0 = disabled
	arr = ruleCvarDefault(arr, "scr_readyup_nadetraining", 1); 	// Enable strat grenade fly mode in readyup
	arr = ruleCvarDefault(arr, "scr_half_start_timer", 10); 	// Count-down timer when First-half starting / Second-half starting / Timeout ending

	// Time-out
	arr = ruleCvarDefault(arr, "scr_timeouts", 2);						// Total timeouts for one team
	arr = ruleCvarDefault(arr, "scr_timeouts_half", 1); 				// How many per side
	arr = ruleCvarDefault(arr, "scr_timeout_length", 5); 				// Length in minutes

	// Hud Options
	arr = ruleCvarDefault(arr, "scr_show_players_left", 1);
	arr = ruleCvarDefault(arr, "scr_show_objective_icons", 0);
	arr = ruleCvarDefault(arr, "scr_show_hitblip", 1);

	arr = ruleCvarDefault(arr, "scr_show_scoreboard", 1); 		//Score in the upper left corner [0 - 1] 0=hided  1=visible  (if 1, score can be still hided by player settings)
	arr = ruleCvarDefault(arr, "scr_show_scoreboard_limit", 0);

	// Health Regeneration
	arr = ruleCvarDefault(arr, "scr_allow_health_regen", 1); 	// 0=no regen, 1=refill health after "scr_regen_delay"
	arr = ruleCvarDefault(arr, "scr_allow_regen_sounds", 1);
	arr = ruleCvarDefault(arr, "scr_regen_delay", 5000); 		//Time before regen starts

	// Ambients
	arr = ruleCvarDefault(arr, "scr_allow_ambient_fog", 0);
	arr = ruleCvarDefault(arr, "scr_allow_ambient_sounds", 0);
	arr = ruleCvarDefault(arr, "scr_allow_ambient_fire", 0);
	arr = ruleCvarDefault(arr, "scr_allow_ambient_weather", 0);


	arr = ruleCvarDefault(arr, "scr_allow_shellshock", 0);					// Create shell shock effect when player is hitted
	arr = ruleCvarDefault(arr, "scr_replace_russian", 1); 					// Replace russians with Americans / Brisith
	arr = ruleCvarDefault(arr, "scr_blackout", 1); 						// If match is in progress, show map background all over the screen and disable sounds for connected player
	arr = ruleCvarDefault(arr, "scr_recording", 1); 						// Starts automatically recording when match starts
	arr = ruleCvarDefault(arr, "scr_matchinfo", 2); 						// Show match info in menu (1 = without team names, 2 = with team names)
	arr = ruleCvarDefault(arr, "scr_map_vote", 0);						// Open voting system so players can vote about next map
	arr = ruleCvarDefault(arr, "scr_map_vote_replay", 0);					// Show option to replay this map in voting system
	arr = ruleCvarDefault(arr, "scr_auto_deadchat", 1);					// Automaticly enable / disable deadchat
	arr = ruleCvarDefault(arr, "scr_remove_killtriggers", 1);					// Remove some of the kill-triggers created in 1.3 path
	arr = ruleCvarDefault(arr, "scr_bash", 1);							// Bash mode can be called via menu in readyup

	arr = ruleCvarDefault(arr, "scr_friendlyfire", 1);
	arr = ruleCvarDefault(arr, "scr_drawfriend", 1);
	arr = ruleCvarDefault(arr, "scr_teambalance", 0);
	arr = ruleCvarDefault(arr, "scr_spectatefree", 0);
	arr = ruleCvarDefault(arr, "scr_spectateenemy", 0);

	arr = ruleCvarDefault(arr, "g_allowVote", 0);
	arr = ruleCvarDefault(arr, "g_maxDroppedWeapons", 32);
	arr = ruleCvarDefault(arr, "sv_fps", 30);
	arr = ruleCvarDefault(arr, "sv_maxRate", 25000);
	arr = ruleCvarDefault(arr, "sv_timeout", 60);				// Time after 999 player is kicked
	arr = ruleCvarDefault(arr, "g_antilag", 0);

	arr = ruleCvarDefault(arr, "scr_fast_reload_fix", 1);				// Prevent players from shoting faster via double-scroll bug
	arr = ruleCvarDefault(arr, "scr_shotgun_rebalance", 1);				// Enable shotgun rebalance to fix long shot kills and short range hits
	arr = ruleCvarDefault(arr, "scr_prone_peek_fix", 1);				// Prevent players from doing fast peeks from prone (time, after player can prone again will be increased)
	arr = ruleCvarDefault(arr, "scr_mg_peek_fix", 1);				// When mg is dropped, player is spawned right behid mg
	arr = ruleCvarDefault(arr, "scr_hand_hitbox_fix", 1);				// Damage to left hand is adjusted for rifles and scopes.
	arr = ruleCvarDefault(arr, "scr_killcam", 0);					// Killcam




	/*********
	WEAPONS
	*********/

	// Nade spawn counts for each class
	arr = ruleCvarDefault(arr, "scr_boltaction_nades", 1);
	arr = ruleCvarDefault(arr, "scr_semiautomatic_nades", 1);
	arr = ruleCvarDefault(arr, "scr_smg_nades", 1);
	arr = ruleCvarDefault(arr, "scr_sniper_nades", 1);
	arr = ruleCvarDefault(arr, "scr_mg_nades", 1);
	arr = ruleCvarDefault(arr, "scr_shotgun_nades", 1);

	// Smoke spawn counts for each class
	arr = ruleCvarDefault(arr, "scr_boltaction_smokes", 0);
	arr = ruleCvarDefault(arr, "scr_semiautomatic_smokes", 0);
	arr = ruleCvarDefault(arr, "scr_smg_smokes", 0);
	arr = ruleCvarDefault(arr, "scr_sniper_smokes", 0);
	arr = ruleCvarDefault(arr, "scr_mg_smokes", 0);
	arr = ruleCvarDefault(arr, "scr_shotgun_smokes", 1);

	// Weapon Limits by class per team
	arr = ruleCvarDefault(arr, "scr_boltaction_limit", 99);
	arr = ruleCvarDefault(arr, "scr_sniper_limit", 1);
	arr = ruleCvarDefault(arr, "scr_semiautomatic_limit", 99);
	arr = ruleCvarDefault(arr, "scr_smg_limit", 99);
	arr = ruleCvarDefault(arr, "scr_mg_limit", 99);
	arr = ruleCvarDefault(arr, "scr_shotgun_limit", 1);

	// Allow weapon drop when player die
	arr = ruleCvarDefault(arr, "scr_boltaction_allow_drop", 1);
	arr = ruleCvarDefault(arr, "scr_sniper_allow_drop", 0);
	arr = ruleCvarDefault(arr, "scr_semiautomatic_allow_drop", 1);
	arr = ruleCvarDefault(arr, "scr_smg_allow_drop", 1);
	arr = ruleCvarDefault(arr, "scr_mg_allow_drop", 1);
	arr = ruleCvarDefault(arr, "scr_shotgun_allow_drop", 0);

	// Allow grenade / smoke drop when player die
	arr = ruleCvarDefault(arr, "scr_allow_grenade_drop", 1);
	arr = ruleCvarDefault(arr, "scr_allow_smoke_drop", 0);

	// Player's weapon drop
	arr = ruleCvarDefault(arr, "scr_allow_primary_drop", 1);
	arr = ruleCvarDefault(arr, "scr_allow_secondary_drop", 1);

	// Allow/Disallow Weapons
	arr = ruleCvarDefault(arr, "scr_allow_greasegun", 1);
	arr = ruleCvarDefault(arr, "scr_allow_m1carbine", 1);
	arr = ruleCvarDefault(arr, "scr_allow_m1garand", 1);
	arr = ruleCvarDefault(arr, "scr_allow_springfield", 1);
	arr = ruleCvarDefault(arr, "scr_allow_thompson", 1);
	arr = ruleCvarDefault(arr, "scr_allow_bar", 1);
	arr = ruleCvarDefault(arr, "scr_allow_sten", 1);
	arr = ruleCvarDefault(arr, "scr_allow_enfield", 1);
	arr = ruleCvarDefault(arr, "scr_allow_enfieldsniper", 1);
	arr = ruleCvarDefault(arr, "scr_allow_bren", 1);
	arr = ruleCvarDefault(arr, "scr_allow_pps42", 1);
	arr = ruleCvarDefault(arr, "scr_allow_nagant", 1);
	arr = ruleCvarDefault(arr, "scr_allow_svt40", 1);
	arr = ruleCvarDefault(arr, "scr_allow_nagantsniper", 1);
	arr = ruleCvarDefault(arr, "scr_allow_ppsh", 1);
	arr = ruleCvarDefault(arr, "scr_allow_mp40", 1);
	arr = ruleCvarDefault(arr, "scr_allow_kar98k", 1);
	arr = ruleCvarDefault(arr, "scr_allow_g43", 1);
	arr = ruleCvarDefault(arr, "scr_allow_kar98ksniper", 1);
	arr = ruleCvarDefault(arr, "scr_allow_mp44", 1);
	arr = ruleCvarDefault(arr, "scr_allow_shotgun", 1);

	arr = ruleCvarDefault(arr, "scr_allow_pistols", 1);
	arr = ruleCvarDefault(arr, "scr_allow_turrets", 1);

	// Single Shot Kills
	arr = ruleCvarDefault(arr, "scr_no_oneshot_pistol_kills", 0);
	arr = ruleCvarDefault(arr, "scr_no_oneshot_ppsh_kills", 0);

	// PPSH Balance - Limits range of PPSH to same as Tommy
	arr = ruleCvarDefault(arr, "scr_balance_ppsh_distance", 0);

	return arr;
}
