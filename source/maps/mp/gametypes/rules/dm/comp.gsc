#include maps\mp\gametypes\global\_global;

Load()
{
	game["rules_leagueString"] = &"Deathmatch";
	game["rules_formatString"] = &"15 min"; // default

	game["ruleCvars"] = GetCvars(game["ruleCvars"]);
}

GetCvars(arr)
{
	// Match Style
	arr = ruleCvarDefault(arr, "scr_dm_timelimit", 15);		// Time limit. When halftime is enabled, its time limit per half. 0=disabled (minutes)
	arr = ruleCvarDefault(arr, "scr_dm_half_score", 0);		// Number of score when half-time starts. Has no effect when halftime is disabled.
	arr = ruleCvarDefault(arr, "scr_dm_end_score", 0);		// Number of score when map ends. 0=ignored
	arr = ruleCvarDefault(arr, "scr_dm_strat_time", 3);			// Strat time
	arr = ruleCvarDefault(arr, "scr_dm_halftime", 0);			// Do halftime. When 1, scr_tdm_timelimit means time per half

	// Are there OT Rules?
	arr = ruleCvarDefault(arr, "scr_overtime", 0);

	/*******************************
	  Shared gametype script cvars
	*******************************/

	// Readyup
	arr = ruleCvarDefault(arr, "scr_readyup", 1); 				// Enable readyup [0, 1] 0 = disbled  1 = enabled
	arr = ruleCvarDefault(arr, "scr_readyup_autoresume_half", 2); 	// Minutes to auto-resume halftime [0 - 10] 0 = disabled
	arr = ruleCvarDefault(arr, "scr_readyup_autoresume_map", 5); 	// Minutes to auto-resume between maps [0 - 10] 0 = disabled
	arr = ruleCvarDefault(arr, "scr_readyup_nadetraining", 1); 	// Enable strat grenade fly mode in readyup
	arr = ruleCvarDefault(arr, "scr_readyup_start_timer", 10); 	// Count-down timer with black screen when all players are ready

	// Time-out
	arr = ruleCvarDefault(arr, "scr_timeouts", 0);						// Total timeouts for one team
	//arr = ruleCvarDefault(arr, "scr_timeouts_half", 1); 				// How many per side
	//arr = ruleCvarDefault(arr, "scr_timeout_length", 5); 				// Length in minutes

	// Hud Options
	arr = ruleCvarDefault(arr, "scr_show_players_left", 0);
	arr = ruleCvarDefault(arr, "scr_show_objective_icons", 0);
	arr = ruleCvarDefault(arr, "scr_show_hitblip", 1);

	arr = ruleCvarDefault(arr, "scr_show_scoreboard", 0); 		//Score in the upper left corner [0 - 1] 0=hided  1=visible  (if 1, score can be still hided by player settings)
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
	arr = ruleCvarDefault(arr, "scr_replace_russian", 0); 					// Replace russians with Americans / Brisith
	arr = ruleCvarDefault(arr, "scr_blackout", 1); 						// If match is in progress, show map background all over the screen and disable sounds for connected player
	arr = ruleCvarDefault(arr, "scr_recording", 1); 						// Starts automatically recording when match starts
	arr = ruleCvarDefault(arr, "scr_matchinfo", 2); 						// Show match info in menu (1 = without team names, 2 = with team names)
	arr = ruleCvarDefault(arr, "scr_map_vote", 0);						// Open voting system so players can vote about next map
	arr = ruleCvarDefault(arr, "scr_map_vote_replay", 0);					// Show option to replay this map in voting system
	arr = ruleCvarDefault(arr, "scr_remove_killtriggers", 1);					// Remove some of the kill-triggers created in 1.3 path
	arr = ruleCvarDefault(arr, "scr_bash", 0);															// Bash mode can be called via menu in readyup

	arr = ruleCvarDefault(arr, "scr_friendlyfire", 0);
	arr = ruleCvarDefault(arr, "scr_drawfriend", 0);
	arr = ruleCvarDefault(arr, "scr_teambalance", 0);
	arr = ruleCvarDefault(arr, "scr_spectatefree", 0);
	arr = ruleCvarDefault(arr, "scr_spectateenemy", 0);
	arr = ruleCvarDefault(arr, "scr_streamersystem", 1);				// Enable streamer system (menu overlay with auto-killcam, auto-spectator, xray, etc.. features)

	arr = ruleCvarDefault(arr, "g_allowVote", 0);
	arr = ruleCvarDefault(arr, "g_maxDroppedWeapons", 10);
	arr = ruleCvarDefault(arr, "sv_fps", 30/*40*/); // CoD2x since version 1.4.3.1 allows 40 snaps
	arr = ruleCvarDefault(arr, "sv_maxRate", 25000);
	arr = ruleCvarDefault(arr, "sv_timeout", 60);					// Time after 999 player is kicked
	arr = ruleCvarDefault(arr, "g_antilag", 0);					// Antilag 1 means that players ping is considered when calculating hit location - what you see on your monitor is also what the server will see
	arr = ruleCvarDefault(arr, "g_knockback", 0);					// Speed energy if player is hitted by grenade, other player, etc; turned off to avoid "sliding" effect

	arr = ruleCvarDefault(arr, "scr_fast_reload_fix", 1);				// Prevent players from shoting faster via double-scroll bug
	arr = ruleCvarDefault(arr, "scr_shotgun_consistent", 1);			// Enable consistent shotgun to fix long shot kills and short range hits
	arr = ruleCvarDefault(arr, "scr_prone_peek_fix", 1);				// Prevent players from doing fast peeks from prone (time, after player can prone again will be increased)
	arr = ruleCvarDefault(arr, "scr_mg_peek_fix", 1);				// When mg is dropped, player is spawned right behid mg
	arr = ruleCvarDefault(arr, "scr_hitbox_hand_fix", 1);				// Damage to left hand is adjusted for rifles and scopes.
	arr = ruleCvarDefault(arr, "scr_hitbox_torso_fix", 1);					// Damage of M1, rifles, scopes and shotgun is adjusted to have less hits in game
	arr = ruleCvarDefault(arr, "scr_hitbox_neck_kill", 0);			// neck hitbox will count as a headshot, buffs non-bolts
	arr = ruleCvarDefault(arr, "scr_killcam", 0);					// Killcam


  	/*********
	WEAPONS
	*********/
	// Rifles-only mode
	arr = ruleCvarDefault(arr, "scr_rifle_mode", 0);

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
	arr = ruleCvarDefault(arr, "scr_shotgun_smokes", 0);

	// Weapon Limits by class per team
	arr = ruleCvarDefault(arr, "scr_boltaction_limit", 99);
	arr = ruleCvarDefault(arr, "scr_sniper_limit", 99);
	arr = ruleCvarDefault(arr, "scr_semiautomatic_limit", 99);
	arr = ruleCvarDefault(arr, "scr_smg_limit", 99);
	arr = ruleCvarDefault(arr, "scr_mg_limit", 99);
	arr = ruleCvarDefault(arr, "scr_shotgun_limit", 99);

	// Allow weapon drop when player die
	arr = ruleCvarDefault(arr, "scr_boltaction_allow_drop", 1);
	arr = ruleCvarDefault(arr, "scr_sniper_allow_drop", 0);
	arr = ruleCvarDefault(arr, "scr_semiautomatic_allow_drop", 1);
	arr = ruleCvarDefault(arr, "scr_smg_allow_drop", 1);
	arr = ruleCvarDefault(arr, "scr_mg_allow_drop", 1);
	arr = ruleCvarDefault(arr, "scr_shotgun_allow_drop", 0);
	arr = ruleCvarDefault(arr, "scr_pistol_allow_drop", 1);

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
